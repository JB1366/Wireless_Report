#!/bin/sh
#============================================================================#
#               _    _  _               _                                    #
#              | |  | |(_)             | |                                   #
#              | |  | | _  _ __  ___   | |  ___  ___  ___                    #
#              | |/\| || || '__|/ _ \  | | / _ \/ __|/ __|                   #
#              \  /\  /| || |  |  __/  | ||  __/\__ \\__ \                   #
#               \/  \/ |_||_|   \___|  |_| \___||___/|___/                   #
#                                                                            #
#               _____                             _                          #
#              |  __ \                           | |                         #
#              | |__) | ___  _ __    ___   _ __  | |_                        #
#              |  _  / / _ \| '_ \  / _ \ | '__| | __|                       #
#              | | \ \|  __/| |_) || (_) || |    | |_                        #
#              |_|  \_\\___|| .__/  \___/ |_|     \__|                       #
#                           | |                                              #
#                           |_|                                              #
#                                                                            #
# Author: JB_1366                                                            #
#============================================================================#

# --- Auto-Discovery ---
SCRIPT_VERSION="1.0.6"
ROUTER_IP=$(nvram get lan_ipaddr)
DEVICE_LIST=$(nvram get cfg_device_list)
M_NAME=$(echo "$DEVICE_LIST" | sed 's/</\n/g' | grep ">$ROUTER_IP>" | awk -F'>' '{print $1}')
# NODE_DATA=$(echo "$DEVICE_LIST" | sed 's/</\n/g' | awk -F '>' '{ if ($2 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ && $4 == 0 && $2 != "'"$ROUTER_IP"'") print $1 "|" $2 }' | sort -t . -k 4,4n)
NODE_DATA=$(nvram get asus_device_list | sed 's/</\n/g' | grep '>2$' | awk -F '>' '{print $1 "|" $3}' | sort -t . -k 4,4n)
NODE_COUNT_TOTAL=$(echo "$NODE_DATA" | grep -c "|"); [ "$NODE_COUNT_TOTAL" -gt 1 ] && N_SUFFIX="(NODES)" || N_SUFFIX="(NODE)"
NODE_USER=$(nvram get http_username)
SSH_KEY="/tmp/home/root/.ssh/id_dropbear"
SSH_PORT=$(nvram get sshd_port)
SSH_PORT=${SSH_PORT:-22}
USB_PATH=$(find /mnt -maxdepth 2 -type d -name "gen_report" | head -n 1); [ -z "$USB_PATH" ] && USB_PATH="/tmp/gen_report" && mkdir -p "$USB_PATH"
CONF_FILE="/jffs/addons/wireless_report/webui.conf"
[ -f "$CONF_FILE" ] && . "$CONF_FILE"

# --- Environment ---
export PATH="/usr/sbin:/usr/bin:/sbin:/bin:/jffs/bin"
KNOWN_DB="$USB_PATH/known_macs.db"
HISTORY_DB="$USB_PATH/rssi_history.db"
OUT_FILE="/tmp/wireless.asp"
YAZ_CLIENTS="/jffs/addons/YazDHCP.d/DHCP_clients"
SEEN_MACS="/tmp/seen_macs.txt"
ARP_CACHE="/tmp/arp_cache.tmp"
YAZ_CACHE="/tmp/yaz_cache.tmp"
NEW_HISTORY="/tmp/rssi_new.db"
Q_RELAY="/tmp/q_relay.tmp" 
MAIN_ROWS="/tmp/main_rows.tmp"; NODE_ROWS="/tmp/node_rows.tmp"; ALL_ROWS="/tmp/all_rows.tmp"
> $SEEN_MACS; > $MAIN_ROWS; > $NODE_ROWS; > $ALL_ROWS; > $NEW_HISTORY; > $Q_RELAY

# --- Helper Functions ---
get_rssi_style() {
    local r=$1
    if [ "$r" -ge -50 ]; then echo "color: #30d158; font-weight: bold;"
    elif [ "$r" -ge -60 ]; then echo "color: #64d2ff; font-weight: bold;"
    elif [ "$r" -ge -70 ]; then echo "color: #ffd60a; font-weight: bold;"
    else echo "color: #ff453a; font-weight: bold;"; fi
}

get_bars() {
    local r=$1
    if [ "$r" -ge -50 ]; then echo "<span class='bar-box sig-exc'>||||</span>"
    elif [ "$r" -ge -60 ]; then echo "<span class='bar-box sig-good'>|||</span>"
    elif [ "$r" -ge -70 ]; then echo "<span class='bar-box sig-fair'>||</span>"
    else echo "<span class='bar-box sig-poor'>|</span>"; fi
}

get_trend() {
    local mac=$(echo "$1" | tr '[:lower:]' '[:upper:]'); local current=$2
    local old=$(grep "$mac" "$HISTORY_DB" | cut -d'|' -f2)
    echo "$mac|$current" >> "$NEW_HISTORY"
    if [ -z "$old" ] || [ "$old" -eq 0 ]; then echo "<span class='trend-box'>•</span>"; return; fi
    if [ "$current" -gt "$old" ]; then echo "<span class='trend-box trend-up sig-exc'>↑</span>"
    elif [ "$current" -lt "$old" ]; then echo "<span class='trend-box trend-down sig-poor'>↓</span>"
    else echo "<span class='trend-box'>•</span>"; fi
}

check_new() {
    local mac=$(echo "$1" | tr '[:lower:]' '[:upper:]')
    [ ! -f "$KNOWN_DB" ] && touch "$KNOWN_DB"
    if ! grep -qi "$mac" "$KNOWN_DB"; then echo "$mac" >> "$KNOWN_DB"; echo "new-device-row"; fi
}

ip_to_num() { echo "$1" | awk -F. '{if(NF==4) printf "%03d%03d%03d%03d", $1,$2,$3,$4; else printf "000000000000";}' ; }

get_band_html() {
    local iface=$1; local width=$2; local w_text=""
    [ -n "$width" ] && w_text=" ($width"M")"
    if echo "$iface" | grep -q "wl0"; then echo "<td data-sort='2.4' style='text-align:center;'><span class='text-24'>2.4G$w_text</span></td>"
    elif echo "$iface" | grep -q "wl1"; then echo "<td data-sort='5' style='text-align:center;'><span class='text-5g'>5G$w_text</span></td>"
    else echo "<td data-sort='6' style='text-align:center;'><span class='text-6g'>6G$w_text</span></td>"; fi
}

fmt_time() {
    T=$1; [ -z "$T" ] || ! echo "$T" | grep -qE '^[0-9]+$' && echo "<span data-sort='0'>---</span>" && return
    local pulse=""; [ "$T" -lt 1800 ] && pulse="pulse-blue"
    echo "$T" | awk -v p="$pulse" '{d=int($1/86400); h=int(($1%86400)/3600); m=int(($1%3600)/60); printf "<span class=\""p"\" data-sort=\"%s\">", $1; if(d>0) printf "%02dd %02dh", d, h; else if(h>0) printf "%02dh %02dm", h, m; else printf "00h %02dm", m; printf "</span>";}'
}

# Updated to handle F or C based on webui.conf
to_f() {
    local raw_c=$1
    [ -z "$raw_c" ] || ! echo "$raw_c" | grep -qE '^-?[0-9]+$' && echo "--" && return
    
    # Default to Fahrenheit if REPORT_UNIT is missing or not 'C'
    if [ "$REPORT_UNIT" = "C" ]; then
        echo "${raw_c}°C"
    else
        # The math: (C * 1.8) + 32
        echo "$raw_c" | awk '{printf "%.0f°F", ($1 * 1.8) + 32}'
    fi
}

# Adjusted thresholds: 167°F (75°C) and 155°F (68°C)
get_temp_class() {
    local temp_str=$1
    [ "$temp_str" = "--" ] && echo "val-blue" && return
    
    # Strip the symbol for comparison
    local val=$(echo "$temp_str" | sed 's/[^0-9.]//g')
    
    if [ "$REPORT_UNIT" = "C" ]; then
        awk -v t="$val" 'BEGIN { if(t>75) print "stat-hot"; else if(t>68) print "stat-warm"; else print "val-blue"; }'
    else
        awk -v t="$val" 'BEGIN { if(t>167) print "stat-hot"; else if(t>155) print "stat-warm"; else print "val-blue"; }'
    fi
}
 
get_load_class() { local l=$1; [ "$l" = "--" ] && echo "val-blue" && return; awk -v l="$l" 'BEGIN { if(l>2.0) print "stat-hot"; else if(l>1.0) print "stat-warm"; else print "val-blue"; }'; }

# --- Data Capture ---
grep "0x2" /proc/net/arp | awk '{print $4 "|" $1}' | tr '[:lower:]' '[:upper:]' > $ARP_CACHE
[ -f "$YAZ_CLIENTS" ] && awk -F',' '{print toupper($1) "|" $2 "|" $3}' "$YAZ_CLIENTS" > $YAZ_CACHE || > $YAZ_CACHE
T_EXC=0; T_GOOD=0; T_FAIR=0; T_POOR=0
# Updated Main Temp Grab
M_C_RAW=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
M_C=$((M_C_RAW / 1000))
M_TEMP=$(to_f "$M_C")
M_LOAD=$(cat /proc/loadavg | awk '{print $1}')
M_TOTAL=0; N_TOTAL=0
M_UPTIME_STR=$(uptime | awk -F'( |multivars_delim|,|:)+' '{if ($7=="day" || $7=="days") print $6"d "$8"h "$9"m"; else print $6"h "$7"m"}')
M_BOOT_TIME=$(date -d @$(( $(date +%s) - $(cut -d. -f1 /proc/uptime) )) "+%m/%d %I:%M %p")

# Main Router Scan
for iface in $(ifconfig -a | grep -oE "wl[0-9](\.[0-9])?"); do
    [ "$iface" = "wl0.0" ] || [ "$iface" = "wl1.0" ] && continue
    SNAME=$(nvram get "${iface}_ssid")
    [ -z "$SNAME" ] && SNAME=$(nvram get "${iface%.*}_ssid")
    for mac in $(wl -i "$iface" assoclist 2>/dev/null | awk '{print $2}'); do
        m_up=$(echo "$mac" | tr '[:lower:]' '[:upper:]')
        [ "$m_up" = "C8:7F:54:4F:C8:01" ] && continue
        rssi=$(wl -i "$iface" rssi "$mac" 2>/dev/null | awk '{print $1}')
        [ "$rssi" -le -100 ] || [ "$rssi" -eq 0 ] || grep -qi "$m_up" "$SEEN_MACS" && continue
        echo "$m_up" >> "$SEEN_MACS"
        raw_info=$(wl -i "$iface" sta_info "$mac" 2>/dev/null)
        rx_raw=$(echo "$raw_info" | grep "rate of last rx pkt" | awk '{print $6/1000}')
        tx_raw=$(echo "$raw_info" | grep "rate of last tx pkt" | awk -F': ' '{print $2}' | awk '{print $1/1000}')
        max_raw=$(echo "$raw_info" | grep "Max Rate =" | awk '{print $4}')
        mhz_width=$(echo "$raw_info" | grep "chanspec" | awk -F'/' '{print $2}' | awk '{print $1}')
        [ -z "$mhz_width" ] && mhz_width="20"
        [ -z "$rx_raw" ] || [ "$rx_raw" = "0" ] && rx_disp="?" || rx_disp="${rx_raw%.*}"
        [ -z "$tx_raw" ] || [ "$tx_raw" = "0" ] && tx_disp="${max_raw:-?}" || tx_disp="${tx_raw%.*}"
        l_rate_disp="${rx_disp} / ${tx_disp}M"
        [ "$rx_disp" = "?" ] && [ "$tx_disp" = "?" ] && l_rate_disp="---"
        l_rate_val=${tx_disp:-0}
        is_new=$(check_new "$m_up"); trend=$(get_trend "$m_up" "$rssi"); bars=$(get_bars "$rssi")
        rssi_style=$(get_rssi_style "$rssi")
        uptime=$(echo "$raw_info" | grep 'in network' | awk '{print $3}')
        yaz_data=$(grep -i "$m_up" "$YAZ_CACHE" 2>/dev/null | head -n 1)
        name=$(echo "$yaz_data" | awk -F'|' '{print $3}'); [ -z "$name" ] && name="Unknown"
        ip=$(grep -i "$m_up" "$ARP_CACHE" | cut -d'|' -f2 | head -n 1)
        [ -z "$ip" ] && ip=$(echo "$yaz_data" | awk -F'|' '{print $2}')
        [ -z "$ip" ] && ip="---"
        ip_s=$(ip_to_num "$ip"); band_td=$(get_band_html "$iface" "$mhz_width")
        if [ "$rssi" -ge -50 ]; then T_EXC=$((T_EXC+1)); elif [ "$rssi" -ge -60 ]; then T_GOOD=$((T_GOOD+1)); elif [ "$rssi" -ge -70 ]; then T_FAIR=$((T_FAIR+1)); else T_POOR=$((T_POOR+1)); fi
        ROW_STR="<tr class='$is_new'><td style='text-align:left;'>$name</td><td class='toggle-cell'><span class='m-val' data-sort='$m_up'>$m_up</span><span class='i-val' data-sort='$ip_s'>$ip</span></td><td data-sort='$rssi'>$bars <span style='$rssi_style'>$rssi</span> $trend</td><td data-sort='$l_rate_val' style='$rssi_style; text-align:center;'>$l_rate_disp</td><td class='toggle-ssid'><span class='s-val' data-sort='$SNAME'>$SNAME</span><span class='if-val' data-sort='$iface'>$iface</span></td>$band_td<td>$(fmt_time "$uptime")</td></tr>"
        echo "$ROW_STR" >> $MAIN_ROWS; echo "$ROW_STR" >> $ALL_ROWS
        M_TOTAL=$((M_TOTAL + 1))
    done
done

# --- Node Loop ---
N_NAMES=""; N_TEMPS=""; N_LOADS=""; N_BOOTS=""; N_UPTIMES=""; N_SPLIT_COUNTS=""
NODE_COLORS="#64d2ff #30d158 #ffd60a #bf40bf #ff9500 #ff453a"; PIPE=" <span style='color:white;'>|</span> "; COLOR_IDX=0; ACTIVE_NODES=0
MC_T=$(get_temp_class "$M_TEMP"); MC_L=$(get_load_class "$M_LOAD")
MAIN_LABEL="<span class='router-branding'>$M_NAME (MAIN)</span>"
CONSOLIDATED_T="<span class='val-blue'>${M_TEMP}</span>"
CONSOLIDATED_L="<span class='val-blue'>${M_LOAD}</span>"
CONSOLIDATED_U="<span class='val-blue'>${M_UPTIME_STR}</span>"
CONSOLIDATED_B="<span class='val-blue'>${M_BOOT_TIME}</span>"
N_SPLIT_COUNTS=""
for line in $NODE_DATA; do
    NODE_OUT=""
    IP=$(echo "$line" | cut -d'|' -f2); ALIAS=$(echo "$line" | cut -d'|' -f1)
    [ -z "$IP" ] && continue
    # UPDATED: Use the loaded $SSH_PORT
    NODE_OUT=$(/usr/bin/ssh -p "$SSH_PORT" -i "$SSH_KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=1 "${NODE_USER}@${IP}" "
        UP_SEC=\$(cut -d. -f1 /proc/uptime)
        UP_SEC=\$(cut -d. -f1 /proc/uptime)
        F_UP=\$(awk -v s=\"\$UP_SEC\" 'BEGIN {d=int(s/86400); h=int((s%86400)/3600); m=int((s%3600)/60); if(d>0) printf \"%dd %dh\", d, h; else if(h>0) printf \"%dh %dm\", h, m; else printf \"0h %dm\", m}')
        NODE_COUNT=0
        for iface in \$(ifconfig -a | grep -oE \"wl[0-9](\.[0-9])?\"); do
            SN=\$(nvram get \"\${iface}_ssid\"); [ -z \"\$SN\" ] && SN=\$(nvram get \"\${iface%.*}_ssid\")
            for mac in \$(wl -i \"\$iface\" assoclist 2>/dev/null | awk '{print \$2}'); do
                RAW=\$(wl -i \"\$iface\" sta_info \"\$mac\" 2>/dev/null)
                RSSI=\$(wl -i \"\$iface\" rssi \"\$mac\" 2>/dev/null | awk '{print \$1}')
                RX=\$(echo \"\$RAW\" | grep \"rate of last rx pkt\" | awk '{print \$6/1000}')
                TX=\$(echo \"\$RAW\" | grep \"rate of last tx pkt\" | awk -F': ' '{print \$2}' | awk '{print \$1/1000}')
                MX=\$(echo \"\$RAW\" | grep \"Max Rate =\" | awk '{print \$4}')
                W=\$(echo \"\$RAW\" | grep \"chanspec\" | awk -F'/' '{print \$2}' | awk '{print \$1}')
                [ -z \"\$W\" ] && W=\"20\"
                RXD=\$(echo \"\$RX\" | awk '{if (\$1==0) print \"?\"; else printf \"%.0f\", \$1}')
                TXD=\$(echo \"\$TX\" | awk -v m=\"\$MX\" '{if (\$1==0) print m; else printf \"%.0f\", \$1}')
                [ \"\$RXD\" = \"?\" ] && [ \"\$TXD\" = \"?\" ] && LRD=\"\${MX:-?}\" || LRD=\"\${RXD} / \${TXD}M\"
                echo \"DATA|\$mac|\$RSSI|\$iface|\$(echo \"\$RAW\" | grep \"in network\" | awk '{print \$3}')|\$SN|\$TX|\$LRD|\$W\"
                NODE_COUNT=\$((NODE_COUNT + 1))
            done
        done
        echo \"TEMP|\$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | cut -c1-2)\"
        echo \"LOAD|\$(cat /proc/loadavg | awk '{print \$1}')\"
        echo \"UPTIME_VAL|\$F_UP\"; echo \"UPTIME_RAW|\$UP_SEC\"; echo \"COUNT|\$NODE_COUNT\"
    " 2>/dev/null)
    if [ -n "$NODE_OUT" ]; then
        ACTIVE_NODES=$((ACTIVE_NODES + 1)); COLOR_IDX=$((COLOR_IDX + 1))
        CUR_COLOR=$(echo $NODE_COLORS | cut -d' ' -f$((COLOR_IDX)))
        [ -z "$CUR_COLOR" ] && CUR_COLOR="#ffffff"
        
        STAR_HTML="<span style='color:$CUR_COLOR;'><sup>$ACTIVE_NODES</sup></span>"
        NODE_BRAND="<span class='router-branding' style='color:$CUR_COLOR;'>${ALIAS}<sup>$ACTIVE_NODES</sup></span>"
        [ -z "$N_NAMES" ] && N_NAMES="$NODE_BRAND" || N_NAMES="$N_NAMES$PIPE$NODE_BRAND"
        
		# 1. Capture and Process Node Temp
        cur_t_raw=$(echo "$NODE_OUT" | grep "TEMP|" | cut -d'|' -f2)
        [ ${#cur_t_raw} -gt 3 ] && cur_t_raw=$((cur_t_raw / 1000))
        cur_t=$(to_f "$cur_t_raw")
        cur_l=$(echo "$NODE_OUT" | grep "LOAD|" | cut -d'|' -f2)
        cur_up_r=$(echo "$NODE_OUT" | grep "UPTIME_RAW|" | cut -d'|' -f2)
		cur_up_v=$(echo "$NODE_OUT" | grep "UPTIME_VAL|" | cut -d'|' -f2)
        cur_up_r=$(echo "$NODE_OUT" | grep "UPTIME_RAW|" | cut -d'|' -f2); N_TOTAL=$((N_TOTAL + cur_c))
		boot_d=$(date -d @$(( $(date +%s) - ${cur_up_r:-0} )) "+%m/%d %I:%M %p")
        
        # Color-Synced Footers for ALL DEVICES
        CONSOLIDATED_T="$CONSOLIDATED_T | <span style='color:$CUR_COLOR;'>${cur_t}</span>"
        CONSOLIDATED_L="$CONSOLIDATED_L | <span style='color:$CUR_COLOR;'>${cur_l}</span>"
        CONSOLIDATED_U="$CONSOLIDATED_U | <span style='color:$CUR_COLOR;'>${cur_up_v}</span>"
        CONSOLIDATED_B="$CONSOLIDATED_B | <span style='color:$CUR_COLOR;'>${boot_d}</span>"
        if [ -z "$N_TEMPS" ]; then N_TEMPS="$cur_t"; N_LOADS="$cur_l"; else N_TEMPS="$N_TEMPS$PIPE$cur_t"; N_LOADS="$N_LOADS$PIPE$cur_l"; fi
		               
        # Color-Synced Footers for NODES view
        [ -z "$N_UPTIMES" ] && N_UPTIMES="<span style='color:$CUR_COLOR;'>$cur_up_v</span>" || N_UPTIMES="$N_UPTIMES$PIPE<span style='color:$CUR_COLOR;'>$cur_up_v</span>"
        [ -z "$N_BOOTS" ] && N_BOOTS="<span style='color:$CUR_COLOR;'>$boot_d</span>" || N_BOOTS="$N_BOOTS$PIPE<span style='color:$CUR_COLOR;'>$boot_d</span>"
        node_display_count=0
		while read -r dline; do
            m_up=$(echo "$dline" | cut -d'|' -f2 | tr '[:lower:]' '[:upper:]')
            [ "$m_up" = "C8:7F:54:4F:C8:01" ] || grep -qi "$m_up" "$SEEN_MACS" && continue
			N_TOTAL=$((N_TOTAL + 1))
            node_display_count=$((node_display_count + 1))
			echo "$m_up" >> "$SEEN_MACS"; r_raw=$(echo "$dline" | cut -d'|' -f3)
            if [ "$r_raw" -ge -50 ]; then echo "EXC" >> "$Q_RELAY"
            elif [ "$r_raw" -ge -60 ]; then echo "GOOD" >> "$Q_RELAY"
            elif [ "$r_raw" -ge -70 ]; then echo "FAIR" >> "$Q_RELAY"
            else echo "POOR" >> "$Q_RELAY"; fi
            yaz_data_n=$(grep -i "$m_up" "$YAZ_CACHE" 2>/dev/null | head -n 1)
            n_name=$(echo "$yaz_data_n" | awk -F'|' '{print $3}'); [ -z "$n_name" ] && n_name="Unknown"
            n_ip=$(grep -i "$m_up" "$ARP_CACHE" | cut -d'|' -f2 | head -n 1)
            [ -z "$n_ip" ] && n_ip=$(echo "$yaz_data_n" | awk -F'|' '{print $2}')
            [ -z "$n_ip" ] && n_ip="---"; i_raw=$(echo "$dline" | cut -d'|' -f4); u_raw=$(echo "$dline" | cut -d'|' -f5); s_name=$(echo "$dline" | cut -d'|' -f6)
            l_rate_val=$(echo "$dline" | cut -d'|' -f7); l_rate_disp_n=$(echo "$dline" | cut -d'|' -f8); w_raw=$(echo "$dline" | cut -d'|' -f9)
            is_new=$(check_new "$m_up"); trend=$(get_trend "$m_up" "$r_raw"); bars_n=$(get_bars "$r_raw"); rssi_style_n=$(get_rssi_style "$r_raw")
            ip_ns=$(ip_to_num "$n_ip"); band_td_n=$(get_band_html "$i_raw" "$w_raw")
            N_ROW="<tr><td style='text-align:left;'>$n_name$STAR_HTML</td><td class='toggle-cell'><span class='m-val' data-sort='$m_up'>$m_up</span><span class='i-val' data-sort='$ip_ns'>$n_ip</span></td><td data-sort='$r_raw'>$bars_n <span style='$rssi_style_n'>$r_raw</span> $trend</td><td data-sort='$l_rate_val' style='$rssi_style_n; text-align:center;'>$l_rate_disp_n</td><td class='toggle-ssid'><span class='s-val' data-sort='$s_name'>$s_name</span><span class='if-val' data-sort='$i_raw'>$i_raw</span></td>$band_td_n<td>$(fmt_time "$u_raw")</td></tr>"
            echo "$N_ROW" >> $NODE_ROWS; echo "$N_ROW" >> $ALL_ROWS
        done <<EOF
$(echo "$NODE_OUT" | grep "DATA|")
EOF
        if [ -n "$node_display_count" ]; then
            if [ -z "$N_SPLIT_COUNTS" ]; then
                N_SPLIT_COUNTS="<span style='color:$CUR_COLOR;'>$node_display_count</span>"
            else
                N_SPLIT_COUNTS="$N_SPLIT_COUNTS | <span style='color:$CUR_COLOR;'>$node_display_count</span>"
            fi
        fi
    fi
done

T_EXC=$((T_EXC + $(grep -c "EXC" "$Q_RELAY"))); T_GOOD=$((T_GOOD + $(grep -c "GOOD" "$Q_RELAY")))
T_FAIR=$((T_FAIR + $(grep -c "FAIR" "$Q_RELAY"))); T_POOR=$((T_POOR + $(grep -c "POOR" "$Q_RELAY")))
echo "DEBUG: Main=$M_TOTAL Node=$N_TOTAL" > /tmp/math_check.txt
mv "$NEW_HISTORY" "$HISTORY_DB"; GRAND_TOTAL=$((M_TOTAL + N_TOTAL))
BRAND_LINE_ALL="<span class='router-branding'>$M_NAME</span> | $N_NAMES"

if [ "$ACTIVE_NODES" -ge 1 ]; then 
    FULL_DEVICE_BREAKDOWN="Devices: <span class='val-blue'>$GRAND_TOTAL</span> <span class='dash-sep'>—›</span> <span class='val-blue'>$M_TOTAL</span> | $N_SPLIT_COUNTS"
else 
    FULL_DEVICE_BREAKDOWN="Devices: <span class='val-blue'>$M_TOTAL</span>"
fi

# --- HTML Output ---
CUR_TIME=$(date '+%m/%d %I:%M:%S %p')
/usr/bin/printf '\xEF\xBB\xBF' > $OUT_FILE
cat <<HTML >> $OUT_FILE
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" />
<title>ASUS Wireless Router $M_NAME - Wireless Report</title>
<link rel="stylesheet" href="index_style.css" />
<link rel="stylesheet" href="form_style.css" />
<link rel="stylesheet" href="usp_style.css" />
<link rel="stylesheet" href="other.css" />
<script src="/js/jquery.js"></script>
<script src="/state.js"></script>
<script src="/general.js"></script>
<script src="/popup.js"></script>
<style>
  #wifiReportContainer { color: #f2f2f7; font-size: 12px; font-family: Arial, sans-serif; }
  .report-header-main { position: relative; left: -0.1875in; text-align: center; color: #0096ff; margin: 30px 0 10px 0; font-size: 1.6em; text-transform: uppercase; font-weight: bold; }
  .total-count { position: relative; left: -0.1875in; text-align: center; color: #f2f2f7; margin-bottom: 12px; font-size: 11px; font-weight: bold; text-transform: uppercase; letter-spacing: 0.5px; }
  .count-highlight { background: #0096ff; color: #000; padding: 1px 6px; border-radius: 3px; margin-left: 4px; font-weight: 900; }
  .quality-bar { text-align: left; margin-bottom: 12px; display: flex; justify-content: center; gap: 8px; flex-wrap: wrap; align-items: center; width: 96%; }
  .q-box { display: inline-block; height: 28px; line-height: 26px; text-align: center; padding: 0 12px; border-radius: 4px; background: rgba(0,0,0,0.4); border: 1px solid #475a68; font-weight: bold; box-sizing: border-box; }
  .btn-black-blue { background: rgba(0,0,0,0.6); border: 1px solid #475a68; color: #0096ff; cursor: pointer; padding: 0 12px; font-size: 11px; border-radius: 4px; font-weight: bold; height: 28px; line-height: 26px; transition: all 0.2s ease; box-sizing: border-box; }
  .btn-black-blue:hover, .btn-black-blue.active { border-color: #0096ff; box-shadow: 0 0 10px rgba(0,150,255,0.4); color: #0096ff; }
  .btn-black-blue.active { background: rgba(0,150,255,0.15); }
  #countdown { margin-left: 6px; color: #0096ff; font-weight: bold; }
  .grid-container { display: flex; flex-direction: column; gap: 15px; align-items: flex-start; width: 100%; }
  .report-column { width: 96%; background: #1c232b; border-radius: 8px; border: 1px solid #475a68; overflow: hidden; display: flex; flex-direction: column; }
  table.report_table { width: 100%; border-collapse: collapse; }
  table.report_table.show-ip .m-val { display: none !important; } 
  table.report_table.show-ip .i-val { display: inline !important; color: #64d2ff; }
  table.report_table.show-iface .s-val { display: none !important; } 
  table.report_table.show-iface .if-val { display: inline !important; color: #ffa500; }
  table.report_table thead th { position: sticky; top: 0; z-index: 10; background: linear-gradient(to bottom, #0096ff, #0056b3); color: #fff; padding: 8px; cursor: pointer; text-align: center; border-right: 1px solid rgba(255,255,255,0.1); }
  table.report_table th:hover { background: #00e5ff; color: #000; text-shadow: 0 0 10px rgba(0,229,255,0.8); }
  table.report_table td { padding: 6px; border-bottom: 1px solid #3d454b; background: #1c232b; vertical-align: middle; text-align: center; }
  table.report_table tr td:first-child { text-align: left; padding-left: 10px; }
  table.report_table tfoot td { border-top: 1px solid #475a68; padding: 12px 10px !important; font-weight: bold; background: #171b1f; color: #fff; }
  .f-res { color: #0096ff; }
  .pulse-blue { color: #00e5ff !important; font-weight: bold; animation: pulse-blue-glow 2s infinite; }
  @keyframes pulse-blue-glow { 0% { opacity: 1; } 50% { opacity: 0.5; } 100% { opacity: 1; } }
  .sig-exc { color: #30d158; } .sig-good { color: #64d2ff; } .sig-fair { color: #ffd60a; } .sig-poor { color: #ff453a; }
  .stat-warm { color: #ffa500 !important; font-weight: bold; } .stat-hot { color: #ff453a !important; font-weight: bold; }
  .bar-box { font-family: monospace; font-weight: 900; width: 40px; display: inline-block; text-align: right; margin-right: 5px; }
  .section-header { background: linear-gradient(to bottom, #171b1f, #354961); color: #ffffff; font-weight: bold; padding: 12px; text-align: center; border-bottom: 1px solid #475a68; }
  .router-branding { color: #0096ff; font-size: 1.4em; font-weight: bold; text-transform: uppercase; display: inline-block; margin-bottom: 4px; }
  .header-stats-row { display: block; font-size: 14px; color: #f2f2f7; margin-top: 5px; font-weight: bold; white-space: nowrap; width: 100%; overflow: visible !important; }
  .sep-line { border: 0; border-top: 1px solid #475a68; margin: 8px -12px; width: calc(100% + 24px); display: block; }
  .val-blue { color: #0096ff; font-weight: bold; }
  .m-val, .s-val { display: inline; } .i-val, .if-val { display: none; }
  .text-24 { color: #ffa500 !important; font-weight: bold; }
  .text-5g { color: #0096ff !important; font-weight: bold; }
  .text-6g { color: #bf40bf !important; font-weight: bold; }
  .modal-overlay { display: none; position: fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.4); z-index:9999; align-items: center; justify-content: center; backdrop-filter: blur(8px); }
  .modal-content { background: rgba(0, 0, 0, 0.2); width: 95%; max-width: 1450px; margin: auto; padding:15px; border-radius:15px; border:1px solid rgba(0, 150, 255, 0.4); position: relative; max-height: 95vh; overflow-y: auto; box-shadow: 0 0 40px rgba(0,0,0,0.6); backdrop-filter: blur(20px); }
  .close-x { position: absolute; top: 10px; right: 20px; color: #fff; font-size: 30px; cursor: pointer; font-weight: bold; }
  .modal-grid { display: flex; width: 100%; gap: 5px; margin-top: 5px; align-items: flex-start; justify-content: center; }
  .modal-grid .report-column { flex: 1; max-width: 49.5%; }
  .dash-sep { color: rgba(255,255,255,0.4); font-size: 0.9em; margin: 0 4px; animation: sep-glow 3s infinite ease-in-out; }
  @keyframes sep-glow { 0% { color: rgba(255,255,255,0.2); } 50% { color: #0096ff; text-shadow: 0 0 5px #0096ff; } 100% { color: rgba(255,255,255,0.2); } }
  #allCol { display: none; }
  .row-break { flex-basis: 100%; height: 0; margin: 0; }
  sup { font-size: 0.6em; margin-left: 2px; }
</style>
<script>
function initial(){ 
    show_menu(); 
    var savedRate = localStorage.getItem('wifiReportAutoRefresh') || "0";
    document.getElementById('refreshRate').value = savedRate;
    initAutoRefresh(parseInt(savedRate));
    sortTable(2, 'mainTable', false, true);
    if(document.getElementById('nodeTable')) sortTable(2, 'nodeTable', false, true);
    sortTable(2, 'allTable', false, true);
}
var timeLeft = 0; var refreshTimer = null; var isRefreshing = false;
function triggerRefresh() {
    if (isRefreshing) return; isRefreshing = true;
    var btn = document.querySelector('.btn-manual');
    btn.innerText = "Refreshing...";
    fetch('/apply.cgi', { method: 'POST', body: 'action_mode=apply&rc_service=restart_wireless_report&current_page=$INSTALLED_PAGE&next_page=$INSTALLED_PAGE' }).then(function() { setTimeout(function() { window.location.reload(); }, 5000); });
}
function initAutoRefresh(seconds) {
    clearInterval(refreshTimer);
    if (seconds > 0) {
        timeLeft = seconds;
        refreshTimer = setInterval(function() { timeLeft--; if (timeLeft <= 0) { triggerRefresh(); clearInterval(refreshTimer); } document.getElementById('countdown').innerHTML = "&nbsp;" + timeLeft + "s"; }, 1000);
    } else { document.getElementById('countdown').innerHTML = ""; }
}
function switchTab(view) {
    var split = document.getElementById('splitView');
    var all = document.getElementById('allCol');
    var btnMain = document.getElementById('btnMain');
    var btnAll = document.getElementById('btnAll');
    if(view === 'all') {
        split.style.display = 'none'; all.style.display = 'flex';
        btnAll.classList.add('active'); btnMain.classList.remove('active');
    } else {
        split.style.display = 'flex'; all.style.display = 'none';
        btnMain.classList.add('active'); btnAll.classList.remove('active');
    }
}
function toggleCols(tId, cls, header, labelA, labelB) { 
    var table = document.getElementById(tId); if(!table) return;
    var isActive = table.classList.toggle(cls); header.innerHTML = (isActive ? labelB : labelA) + " ⇅";
    var colIdx = (cls === 'show-ip') ? 1 : 4; sortTable(colIdx, tId, true);
}
function sortTable(n, tId, keepDir, forceDesc) {
    var table = document.getElementById(tId); if(!table) return;
    var tbody = table.tBodies[0]; var rows = Array.prototype.slice.call(tbody.rows); if(!rows.length) return;
    var dir = table.getAttribute("data-dir-" + n) || "asc";
    if (forceDesc) { dir = "desc"; } else if (!keepDir) { dir = (dir === "asc") ? "desc" : "asc"; }
    table.setAttribute("data-dir-" + n, dir);
    var headers = table.querySelectorAll('th');
    headers.forEach(function(h, idx) {
        var baseText = h.innerText.replace(/[▼▲⇅]/g, "").trim();
        var toggleIcon = (idx === 1 || idx === 4) ? " ⇅" : "";
        if (idx === n) h.innerHTML = baseText + (dir === "asc" ? " ▲" : " ▼");
        else {
            if(idx === 1) h.innerHTML = (table.classList.contains('show-ip') ? "IP ADDRESS" : "MAC ADDRESS") + toggleIcon;
            else if(idx === 4) h.innerHTML = (table.classList.contains('show-iface') ? "IFACE" : "SSID") + toggleIcon;
            else h.innerHTML = baseText + toggleIcon;
        }
    });
    rows.sort(function(a, b) {
        var valA, valB; var cellA = a.cells[n]; var cellB = b.cells[n];
        if (n === 1) { 
            var sel = table.classList.contains('show-ip') ? '.i-val' : '.m-val';
            valA = cellA.querySelector(sel).getAttribute('data-sort'); valB = cellB.querySelector(sel).getAttribute('data-sort');
        } else if (n === 4) { 
            var sel = table.classList.contains('show-iface') ? '.if-val' : '.s-val';
            valA = cellA.querySelector(sel).innerText.trim().toLowerCase(); valB = cellB.querySelector(sel).innerText.trim().toLowerCase();
        } else if (cellA.hasAttribute('data-sort')) { valA = cellA.getAttribute('data-sort'); valB = cellB.getAttribute('data-sort');
        } else { valA = cellA.innerText.trim(); valB = cellB.innerText.trim(); }
        var numA = parseFloat(valA); var numB = parseFloat(valB);
        if(!isNaN(numA) && !isNaN(numB)) { return dir === "asc" ? numA - numB : numB - numA; }
        return dir === "asc" ? valA.localeCompare(valB) : valB.localeCompare(valA);
    });
    rows.forEach(function(r) { tbody.appendChild(r); });
}
function openPopout() {
    var body = document.getElementById('popoutBody'); body.innerHTML = "";
    var mCol = document.getElementById('mainCol').cloneNode(true); var nCol = document.getElementById('nodeCol').cloneNode(true);
    mCol.querySelector('table').id = "popMainTable"; nCol.querySelector('table').id = "popNodeTable";
    mCol.querySelectorAll('th').forEach(function(th, i) {
        if(i===1) th.onclick = function() { toggleCols('popMainTable', 'show-ip', this, 'MAC ADDRESS', 'IP ADDRESS'); };
        else if(i===4) th.onclick = function() { toggleCols('popMainTable', 'show-iface', this, 'SSID', 'IFACE'); };
        else th.onclick = function() { sortTable(i, 'popMainTable'); };
    });
    nCol.querySelectorAll('th').forEach(function(th, i) {
        if(i===1) th.onclick = function() { toggleCols('popNodeTable', 'show-ip', this, 'MAC ADDRESS', 'IP ADDRESS'); };
        else if(i===4) th.onclick = function() { toggleCols('popNodeTable', 'show-iface', this, 'SSID', 'IFACE'); };
        else th.onclick = function() { sortTable(i, 'popNodeTable'); };
    });
    body.appendChild(mCol); body.appendChild(nCol); document.getElementById('popoutModal').style.display = 'flex';
}
function closePopout() { document.getElementById('popoutModal').style.display = 'none'; }
</script>
</head>
<body onload="initial();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<table class="content" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td width="17">&nbsp;</td>
    <td valign="top" width="202"><div id="mainMenu"></div><div id="subMenu"></div></td>
    <td valign="top">
      <div id="tabMenu" class="submenuBlock"></div>
      <div id="wifiReportContainer" style="padding:10px;">
        <h1 class="report-header-main">WIRELESS REPORT</h1>
        <div class="total-count">Total Wireless Devices: <span class="count-highlight">$GRAND_TOTAL</span></div>
        <div class="quality-bar">
          <div class="q-box sig-exc">Excellent: <span style="background:#30d158; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_EXC</span></div>
          <div class="q-box sig-good">Good: <span style="background:#0096ff; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_GOOD</span></div>
          <div class="q-box sig-fair" style="color:#ffd60a;">Fair: <span style="background:#ffd60a; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_FAIR</span></div>
          <div class="q-box sig-poor" style="color:#ff453a;">Poor: <span style="background:#ff453a; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_POOR</span></div>
          <div class="row-break"></div>
          <div class="q-box" style="padding:0 5px; display:inline-flex; align-items:center;">
            <button class="btn-manual btn-black-blue" style="border:none; height:100%; line-height:inherit; padding:0 8px;" onclick="triggerRefresh()">Refresh</button>
            <span style="font-size:10px; margin-left:5px;">Auto: </span>
            <select id="refreshRate" onchange="localStorage.setItem('wifiReportAutoRefresh', this.value); initAutoRefresh(parseInt(this.value));" style="background:#000; color:#0096ff; border:1px solid #444; margin-left:2px; font-size:10px; height:20px;">
                <option value="0">Off</option><option value="30">30s</option><option value="60">1m</option>
            </select><span id="countdown"></span>
          </div>
          <button id="btnMain" class="btn-black-blue active" onclick="switchTab('split')">Main View</button>
          <button id="btnAll" class="btn-black-blue" onclick="switchTab('all')">All Devices</button>
          <button class="btn-black-blue" onclick="openPopout()">Comparison View ⇗</button>
        </div>
        <div class="grid-container">
          <div id="splitView" style="display:flex; flex-direction:column; gap:15px; width:100%;">
              <div id="mainCol" class="report-column">
                <div class="section-header">
                  $MAIN_LABEL<br>
                  <span style="font-size:11px; font-weight:normal;">Updated: $CUR_TIME</span>
                  <hr class="sep-line">
                  <div class="header-stats-row">Temp: <span class="$MC_T">$M_TEMP</span> • Load: <span class="$MC_L">$M_LOAD</span> • Devices: <span class="val-blue">$M_TOTAL</span></div>
                </div>
                <table id="mainTable" class="report_table show-ip">
                  <thead><tr>
                    <th onclick="sortTable(0, 'mainTable')">HOSTNAME</th>
                    <th onclick="toggleCols('mainTable', 'show-ip', this, 'MAC ADDRESS', 'IP ADDRESS')">IP ADDRESS ⇅</th>
                    <th onclick="sortTable(2, 'mainTable')">RSSI</th>
                    <th onclick="sortTable(3, 'mainTable')">RX / TX</th>
                    <th onclick="toggleCols('mainTable', 'show-iface', this, 'SSID', 'IFACE')">SSID ⇅</th>
                    <th onclick="sortTable(5, 'mainTable')">BAND</th>
                    <th onclick="sortTable(6, 'mainTable')">UPTIME</th>
                  </tr></thead>
                  <tbody>$(cat $MAIN_ROWS)</tbody>
                  <tfoot><tr><td colspan="7" style="text-align: center !important;">Uptime: <span class="f-res">$M_UPTIME_STR</span> • Reboot: <span class="f-res">$M_BOOT_TIME</span></td></tr></tfoot>
                </table>
              </div>
              <div id="nodeCol" class="report-column">
                <div class="section-header">
                  $N_NAMES <span class="router-branding">$N_SUFFIX</span><br>
                  <span style="font-size:11px; font-weight:normal;">Updated: $CUR_TIME</span>
                  <hr class="sep-line">
                  <div class="header-stats-row">Temp: <span class="val-blue">${N_TEMPS:-0}</span> • Load: <span class="val-blue">${N_LOADS:-0}</span> • Devices: <span class="val-blue">$N_TOTAL</span> <span class="dash-sep">—›</span> $N_SPLIT_COUNTS</div>
                </div>
                <table id="nodeTable" class="report_table show-ip">
                  <thead><tr>
                    <th onclick="sortTable(0, 'nodeTable')">HOSTNAME</th>
                    <th onclick="toggleCols('nodeTable', 'show-ip', this, 'MAC ADDRESS', 'IP ADDRESS')">IP ADDRESS ⇅</th>
                    <th onclick="sortTable(2, 'nodeTable')">RSSI</th>
                    <th onclick="sortTable(3, 'nodeTable')">RX / TX</th>
                    <th onclick="toggleCols('nodeTable', 'show-iface', this, 'SSID', 'IFACE')">SSID ⇅</th>
                    <th onclick="sortTable(5, 'nodeTable')">BAND</th>
                    <th onclick="sortTable(6, 'nodeTable')">UPTIME</th>
                  </tr></thead>
                  <tbody>$(cat $NODE_ROWS)</tbody>
                  <tfoot><tr><td colspan="7" style="text-align: center !important;">$( [ -n "$N_UPTIMES" ] && echo "Uptime: $N_UPTIMES • Reboot: $N_BOOTS" || echo "Offline" )</td></tr></tfoot>
                </table>
              </div>
          </div>
          <div id="allCol" class="report-column">
            <div class="section-header">
              $BRAND_LINE_ALL<br>
              <span style="font-size:11px; font-weight:normal;">Updated: $CUR_TIME</span>
              <hr class="sep-line">
              <div class="header-stats-row">Temp: $CONSOLIDATED_T • Load: $CONSOLIDATED_L • $FULL_DEVICE_BREAKDOWN</div>
            </div>
            <table id="allTable" class="report_table show-ip">
              <thead><tr>
                <th onclick="sortTable(0, 'allTable')">HOSTNAME</th>
                <th onclick="toggleCols('allTable', 'show-ip', this, 'MAC ADDRESS', 'IP ADDRESS')">IP ADDRESS ⇅</th>
                <th onclick="sortTable(2, 'allTable')">RSSI</th>
                <th onclick="sortTable(3, 'allTable')">RX / TX</th>
                <th onclick="toggleCols('allTable', 'show-iface', this, 'SSID', 'IFACE')">SSID ⇅</th>
                <th onclick="sortTable(5, 'allTable')">BAND</th>
                <th onclick="sortTable(6, 'allTable')">UPTIME</th>
              </tr></thead>
              <tbody>$(cat $ALL_ROWS)</tbody>
              <tfoot><tr><td colspan="7" style="text-align: center !important;">Uptime: $CONSOLIDATED_U • Reboot: $CONSOLIDATED_B</td></tr></tfoot>
            </table>
          </div>
        </div>
      </div>
    </td>
  </tr>
</table>
<div id="footer"></div>
<div id="popoutModal" class="modal-overlay" onclick="closePopout()">
  <div class="modal-content" onclick="event.stopPropagation()">
    <span class="close-x" onclick="closePopout()">&times;</span>
    <h2 style="color:#0096ff; margin:0 0 10px 0; text-align:center; text-shadow: 0 0 15px rgba(0,150,255,0.7);">Network Comparison View</h2>
    <div id="popoutBody" class="modal-grid"></div>
  </div>
</div>
</body>
</html>
HTML
rm -f $SEEN_MACS $ARP_CACHE $YAZ_CACHE $MAIN_ROWS $NODE_ROWS $ALL_ROWS $Q_RELAY