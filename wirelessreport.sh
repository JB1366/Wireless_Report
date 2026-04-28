#!/bin/sh
#################################################################################
#                                                                               #
#       __      __ __               __                                          #
#      /  \    /  \__|______  ____ |  |   ____   ______ ______                  #
#      \   \/\/   /  \_  __ \/ __ \|  | _/ __ \ /  ___//  ___/                  #
#       \        /|  ||  | \/\  ___/|  |_\  ___/ \___ \ \___ \                  #
#        \__/\  / |__||__|    \___  >____/\___  >____  >____  >                 #
#             \/                  \/          \/     \/     \/                  #
#                __________                           __                        #
#                \______   \ ____ ______   __________/  |__                     #
#                 |       _// __ \\  __ \ /  _ \_  __ \   _\                    #
#                 |    |   \  ___/|  |_> >  <_> )  | \/|  |                     #
#                 |____|_  /\___  >   __/ \____/|__|   |__|                     #
#                        \/     \/|__|                                          #
#                             _____   __                       __               #
#                            /  _  \ |__|__   _    ____  _____|  |__            #
#                           /  /_\  \|  /  \ / \__/ __ \/  ___/  |  \           #
#                          /    |    \  |  Y Y  \  ___/ \___ \|   Y  \          #
#                          \____|__  /__|__|_|  /\___  >____  >___|  /          #
#                                  \/         \/     \/     \/     \/           #
#                                                                               #
#                                                                               #
#################################################################################
# Author: JB_1366                                                               #
# shellcheck shell=sh disable=SC2086,SC2155,SC3043                              #                  
# amtm NoMD5check                                                               #
#################################################################################

SCRIPT_VERSION="1.5.8"
INSTALL_DIR="/jffs/addons/wireless_report"; REPORT_SCRIPT="$INSTALL_DIR/wirelessreport.sh"
CONF_FILE="$INSTALL_DIR/webui.conf"; [ -f "$CONF_FILE" ] && . "$CONF_FILE"
USB_PATH=$(ls -d /tmp/mnt/*/wirelessreport 2>/dev/null | head -n 1); BUP=$(cut -d. -f1 /proc/uptime)
[ -z "$USB_PATH" ] && [ "$BUP" -lt 300 ] && sleep 2
[ -z "$USB_PATH" ] && USB_PATH=$(ls -d /tmp/mnt/*/ 2>/dev/null | grep -v "defaults" | head -n 1 | sed 's/\/$//')/wirelessreport
[ -z "$USB_PATH" ] || [ "$USB_PATH" = "/wirelessreport" ] && USB_PATH="$INSTALL_DIR/data"; mkdir -p "$USB_PATH"
KNOWN_DB="$USB_PATH/known_macs.db"; HISTORY_DB="$USB_PATH/rssi_history.db"
BSS_LOG="$USB_PATH/bssroam.log"; [ ! -d "$(dirname "$BSS_LOG")" ] && mkdir -p "$(dirname "$BSS_LOG")"
SKIP_DB="$USB_PATH/mac_skip.db"; [ ! -f "$SKIP_DB" ] && touch "$SKIP_DB"
OUT_FILE="/tmp/wireless.asp"; NEW_HISTORY="/tmp/rssi_new.db"; SEEN_MACS="/tmp/seen_macs.txt"
YAZ_CLIENTS="/jffs/addons/YazDHCP.d/DHCP_clients"; YAZ_CACHE="/tmp/yaz_cache.tmp"
ARP_CACHE="/tmp/arp_cache.tmp"; Q_RELAY="/tmp/q_relay.tmp"; doScriptUpdateFromAMTM=true
MAIN_ROWS="/tmp/main_rows.tmp"; NODE_ROWS="/tmp/node_rows.tmp"; ALL_ROWS="/tmp/all_rows.tmp"
CYAN='\033[0;36m'; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
[ -f "/tmp/home/root/.ssh/id_dropbear" ] && SSH_KEY="/tmp/home/root/.ssh/id_dropbear" || SSH_KEY="/jffs/.ssh/id_dropbear"
SSH_PORT=$(nvram get sshd_port); [ -z "$SSH_PORT" ] && SSH_PORT=22; NODE_USER=$(nvram get http_username)
GITHUB="https://raw.githubusercontent.com/JB1366/Wireless_Report/main/wirelessreport.sh"
REMOTE_VER=$(curl -sfL --retry 3 "$GITHUB" | grep "SCRIPT_VERSION=" | head -n 1 | cut -d'"' -f2 | tr -cd '0-9.')
[ -n "$REMOTE_VER" ] && [ "$REMOTE_VER" != "$SCRIPT_VERSION" ] && HOVER_TEXT="Current Script v$SCRIPT_VERSION <br> New Version v$REMOTE_VER available" || HOVER_TEXT="SCRIPT v$SCRIPT_VERSION"; [ ${#HOVER_TEXT} -le 14 ] && V_WIDTH="100px" || V_WIDTH="190px"
export PATH="/usr/sbin:/usr/bin:/sbin:/bin:$PATH"; unset LD_LIBRARY_PATH

####################
#  Script Install  #
####################
check_version() {
    if [ -f "$REPORT_SCRIPT" ]; then
        LOCAL_VER=$(grep "SCRIPT_VERSION=" "$REPORT_SCRIPT" | head -n 1 | cut -d'"' -f2 2>/dev/null)
    else
        LOCAL_VER="NOT INSTALLED"
    fi
    echo -e "${CYAN}==================================================${NC}"
    echo -e "${CYAN}              Wireless Report AiMesh              ${NC}"
    echo -e "${CYAN}==================================================${NC}"
    if [ -z "$REMOTE_VER" ]; then
        echo -e " STATUS: ${RED}[Offline]${NC} Could not reach GitHub"
    elif [ "$LOCAL_VER" = "NOT INSTALLED" ]; then
        echo -e " STATUS: [Ready] Latest available is v$REMOTE_VER"
    elif [ "$LOCAL_VER" != "$REMOTE_VER" ]; then
        echo -e " STATUS: ${RED}[UPDATE AVAILABLE] v$REMOTE_VER${NC} ${GREEN}(Current: v$LOCAL_VER)${NC}"
    else
        echo -e " STATUS: [Up to date] ${GREEN}v$LOCAL_VER${NC}"
    fi
    echo -e "${CYAN}==================================================${NC}"
}

show_menu() {
    [ -f "$CONF_FILE" ] && . "$CONF_FILE"; update_time
	[ "$REPORT_UNIT" = "ISO" ] && DISPLAY_UNIT="C" || DISPLAY_UNIT="$REPORT_UNIT"
	echo -e ""
    echo -e "  (1)  Install/Update"
    echo -e "  (2)  Uninstall"
    echo -e "  (3)  Temp/Date (${GREEN}Current: °$DISPLAY_UNIT${NC}) (${GREEN}$CUR_TIME${NC})"
    echo -e "  (4)  Router/Node Nicknames"
    if [ -z "$ROAM_THRESHOLD" ] || [ "$ROAM_THRESHOLD" = "0" ]; then
        echo -e "  (5)  RSSI Threshold (${RED}Current: Disabled${NC})"
    else
        echo -e "  (5)  RSSI Threshold (${GREEN}Current: -${ROAM_THRESHOLD} dBm${NC})"
    fi
    echo -e "  (e)  Exit"
    echo -e ""
    echo -e "${CYAN}==================================================${NC}"
    printf " Selection: "
}

install_menu() {
	while true; do
		clear; check_version; show_menu; read choice
		case "$choice" in
			1) do_install ;;
			2) do_uninstall ;;
			3) set_temp_date ;;
			4) set_nicknames ;;
			5) set_threshold ;;
			e|E) exit 0 ;;
			*) echo -e "${RED}Invalid selection.${NC}"; sleep 1 ;;
		esac
	done
}

check_installed() {
    if [ ! -f "$REPORT_SCRIPT" ]; then
        echo -e "${RED}[!] ERROR: Wireless Report script not found.${NC}"
        echo -e "${YELLOW}[i] You must successfully run Option 1 (Install) before changing settings.${NC}"
        pause
        return 1
    fi
    [ ! -f "$CONF_FILE" ] && touch "$CONF_FILE"
    return 0
}

do_install() {
	mkdir -p "$INSTALL_DIR" 2>/dev/null
    if [ -f "$REPORT_SCRIPT" ]; then
        if [ "$LOCAL_VER" = "$REMOTE_VER" ] && [ -n "$REMOTE_VER" ]; then
            echo -e "\n${GREEN}[i] You are already on the latest version (v$LOCAL_VER).${NC}"
            printf " Do you want to reinstall/overwrite anyway? (y/n): "
            read -r confirm_reinstall
            if [ "$confirm_reinstall" != "y" ] && [ "$confirm_reinstall" != "Y" ]; then
                return
            fi
        fi
		if do_update; then
            echo -e "\n${GREEN}Wireless Report successfully installed.${NC}"
			service restart_httpd >/dev/null 2>&1
            pause
            return 0
        fi
	fi
    if [ "$(nvram get jffs2_scripts)" != "1" ]; then
        echo -e "${RED}[!] ERROR: JFFS custom scripts not enabled.${NC}"
        pause
		return 1
    fi
    check_storage
    check_ssh_environment || return 1
    echo -e "${CYAN}[*] Processing Wireless Report Files...${NC}"
	echo -e ""
    if ! grep -q "REPORT_UNIT=" "$CONF_FILE" 2>/dev/null; then 
        echo "REPORT_UNIT=F" >> "$CONF_FILE"
    fi
    [ -f "/tmp/menuTree.js" ] && sed -i '/Wireless Report/d' /tmp/menuTree.js 2>/dev/null
    if [ -f "$CONF_FILE" ]; then
        OLD_PAGE=$(grep "INSTALLED_PAGE=" "$CONF_FILE" | cut -d'=' -f2)
        if [ -n "$OLD_PAGE" ]; then
            umount -l "/www/user/$OLD_PAGE" 2>/dev/null
            rm -f "/www/user/$OLD_PAGE"
        fi
    fi
    curl -sfL --retry 3 "$GITHUB" -o "$REPORT_SCRIPT"
	if [ ! -s "$REPORT_SCRIPT" ]; then
        echo -e "${YELLOW}[!] GitHub unreachable. Installing current local copy...${NC}"
        cp "$0" "$REPORT_SCRIPT"
    fi
    chmod +x "$REPORT_SCRIPT" 2>/dev/null
    if [ -f "$REPORT_SCRIPT" ]; then
        inject_menu
        [ ! -f "/jffs/scripts/services-start" ] && echo "#!/bin/sh" > /jffs/scripts/services-start
        sed -i "\|$REPORT_SCRIPT|d" /jffs/scripts/services-start
        echo "sh $REPORT_SCRIPT inject # Inject Wireless Report" >> /jffs/scripts/services-start
        chmod +x /jffs/scripts/services-start
        [ ! -f "/jffs/scripts/service-event" ] && echo "#!/bin/sh" > /jffs/scripts/service-event
        sed -i "/wireless_report/d" /jffs/scripts/service-event
        echo 'if [ "$1" = "restart" ] && [ "$2" = "wireless_report" ]; then sh '$REPORT_SCRIPT'; fi # Wireless Report' >> /jffs/scripts/service-event
        chmod +x /jffs/scripts/service-event
        service restart_httpd >/dev/null 2>&1 || killall -HUP httpd >/dev/null 2>&1
        echo -e "\n${GREEN}SUCCESS: Installation complete!${NC}"
        echo -e "${CYAN}[i] Use Option 4 if you wish to set custom nicknames.${NC}"
    else
        echo -e "${RED}[!] ERROR: Download failed.${NC}"
    fi
    pause
}

do_update(){
	curl -sfL --retry 3 "$GITHUB" -o "$REPORT_SCRIPT"
	chmod +x "$REPORT_SCRIPT" 2>/dev/null
	echo -e "\n${GREEN}Downloading latest version (v$REMOTE_VER)${NC}"
}

check_storage() {
    echo -e "${CYAN}[*] Checking for Storage...${NC}"
    if echo "$USB_PATH" | grep -q "/tmp/mnt/"; then
        echo -e "${GREEN}[+] USB Found: Using $USB_PATH for reports and history.${NC}"
		echo -e ""
    else
        echo -e "${YELLOW}[!] No USB detected: Using JFFS at $USB_PATH.${NC}"
    fi
    mkdir -p "$USB_PATH" 2>/dev/null
	if [ -n "$USB_PATH" ]; then
        touch "$USB_PATH/rssi_history.db"
        touch "$USB_PATH/known_macs.db"
    fi
}

check_ssh_environment() {
	[ ! -f "$CONF_FILE" ] && touch "$CONF_FILE"
    echo -e "${CYAN}[*] Verifying Passwordless SSH Environment...${NC}"
	if [ ! -f "$SSH_KEY" ]; then
        echo -e "${YELLOW}[i] No SSH Key found. Skipping node authentication...${NC}"
		echo -e "${YELLOW}[i] Proceeding with Router-only setup...${NC}"
		echo -e ""
    else
        NODE_IPS=$(nvram get asus_device_list | sed 's/</\n/g' | grep '>2$' | awk -F '>' '{print $2 "|" $3}' | sort -t . -k 4,4n)
        if [ -z "$NODE_IPS" ]; then
            echo -e "${YELLOW}[i] No nodes in Asus device list. Checking dhcp_staticlist...${NC}"
            NODE_IPS=$(nvram get dhcp_staticlist | sed 's/</\n/g' | awk -F'>' '{print $3 "|" $2}' | grep -v "|^$")
        fi
        if [ -z "$NODE_IPS" ]; then
            echo -e "${YELLOW}[i] No AiMesh Nodes detected. Proceeding with Router-only setup.${NC}"
			echo -e ""
        else
            any_success=0
            VALID_NODES=""
            for line in $NODE_IPS; do
                ALIAS=$(echo "$line" | cut -d'|' -f1)
                IP=$(echo "$line" | cut -d'|' -f2)
                [ -z "$ALIAS" ] && ALIAS="Node_$IP"
                echo -ne "[*] Testing Passwordless SSH to $ALIAS ($IP) on port $SSH_PORT... "
                /usr/bin/ssh -p "$SSH_PORT" -i "$SSH_KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=10 -o BatchMode=yes "${NODE_USER}@${IP}" "exit" >/dev/null 2>&1
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}AUTHENTICATED${NC}"
                    any_success=1
                    VALID_NODES="$VALID_NODES $ALIAS|$IP"
                else
                    echo -e "${RED}FAILED${NC}"
                fi
            done
        fi
    fi
	sed -i '/SSH_NODES=/d' "$CONF_FILE"
    if [ -z "$VALID_NODES" ]; then
        echo "SSH_NODES=\" \"" >> "$CONF_FILE"
    else
        echo "SSH_NODES=\"$VALID_NODES\"" >> "$CONF_FILE"
    fi
    echo -e "${GREEN}[*] SSH Environment check complete.${NC}"
	echo -e ""
}

inject_menu() {
	source /usr/sbin/helper.sh
	SYSTEM_MENU="/www/require/modules/menuTree.js"
	TEMP_MENU="/tmp/menuTree.js"; TAB_LABEL="Wireless Report"
	WEB_PAGE="$INSTALL_DIR/wireless.asp"; RAM_PAGE="/tmp/wireless.asp"
	[ -f "$CONF_FILE" ] && sed -i '/^INSTALLED_PAGE=/d' "$CONF_FILE"
	nvram get rc_support | grep -q am_addons
	if [ $? != 0 ]; then
		logger -t "Wireless Report" "This firmware does not support addons!"
		exit 5
	fi
	if [ ! -f "$RAM_PAGE" ]; then
		echo "<html><body>Wireless Report Placeholder...</body></html>" > "$RAM_PAGE"
	fi
	if [ ! -f "$WEB_PAGE" ]; then
		echo -e "${CYAN}[*] Mounting Menu[Wireless] Tab[Wireless Report]${NC}"
		echo "<html><body>Wireless Report Placeholder...</body></html>" > "$WEB_PAGE"
	fi
	[ -f "$CONF_FILE" ] && sed -i '/^INSTALLED_PAGE=/d' "$CONF_FILE"
	am_get_webui_page "$WEB_PAGE"
	if [ "$am_webui_page" = "none" ]; then
		logger -t "Wireless Report" "Unable to install Wireless Report"
		exit 5
	fi
	cp "$WEB_PAGE" "/www/user/$am_webui_page"
	rm -f "$WEB_PAGE"
	[ -f "/tmp/menuTree.js" ] && sed -i '/Wireless Report/d' /tmp/menuTree.js 2>/dev/null
	if [ -f "$CONF_FILE" ]; then
		echo "INSTALLED_PAGE=$am_webui_page" >> "$CONF_FILE"
	else
		echo "INSTALLED_PAGE=$am_webui_page" > "$CONF_FILE"
	fi
	if [ ! -f "$TEMP_MENU" ]; then
		cp "$SYSTEM_MENU" /tmp/
		mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"
	fi
	sed -i "/index: \"menu_Wireless\"/,/{url: \"NULL\", tabName: \"__INHERIT__\"}/ {/{url: \"NULL\", tabName: \"__INHERIT__\"}/i \\
	{url: \"$am_webui_page\", tabName: \"$TAB_LABEL\"},
	}" "$TEMP_MENU"
	logger -t "Wireless Report" "Mounting Menu[Wireless] TAB[Wireless Report] as $am_webui_page"
	umount "$SYSTEM_MENU" && mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"
	umount "/www/user/$am_webui_page" 2>/dev/null
	mount -o bind "$RAM_PAGE" "/www/user/$am_webui_page"
	service restart_httpd >/dev/null 2>&1 || killall -HUP httpd >/dev/null 2>&1
	"$INSTALL_DIR/wirelessreport.sh" &
}

do_uninstall() {
    if [ ! -d "$INSTALL_DIR" ]; then
        echo -e "\n${RED}[!] Wireless Report is not installed.${NC}"
        pause
        return
    fi
    echo -e "\n${RED}[!] WARNING: Removing Wireless Report...${NC}"
    printf " Are you sure? (y/n): "
    read confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        [ -f "$CONF_FILE" ] && . "$CONF_FILE"
        if mount | grep -q "menuTree.js"; then
            umount -l /www/require/modules/menuTree.js >/dev/null 2>&1
            sed -i '/tabName:[[:space:]]*"Wireless Report"/d' /tmp/menuTree.js
            if grep -q "tabName" /tmp/menuTree.js; then
                mount --bind /tmp/menuTree.js /www/require/modules/menuTree.js
            else
                echo -e "${CYAN}[*] Wireless Menu restored to default.${NC}"
            fi
        fi
        if [ -n "$INSTALLED_PAGE" ]; then
            logger -t "Wireless Report" "Unmounting Wireless Report Tab."
			umount -l "/www/user/$INSTALLED_PAGE" >/dev/null 2>&1
			rm -f "/www/user/$INSTALLED_PAGE" >/dev/null 2>&1
			echo -e "${CYAN}[*] Removing Wireless Report Tab...${NC}"
        fi
        sed -i "\|$REPORT_SCRIPT|d" /jffs/scripts/services-start
        sed -i "/wireless_report/d" /jffs/scripts/service-event
        service restart_httpd >/dev/null 2>&1 || killall -HUP httpd >/dev/null 2>&1
        rm -rf "$INSTALL_DIR" 2>/dev/null
        rm -f /tmp/wireless.asp 2>/dev/null
		case "$USB_PATH" in *wirelessreport|*data) rm -rf "$USB_PATH" 2>/dev/null ;; esac
        echo -e "${GREEN}[+] Success: Wireless Report uninstalled.${NC}"
    fi
    pause
}

set_temp_date() {
    check_installed || return 1
    while true; do
        [ -f "$CONF_FILE" ] && . "$CONF_FILE"; update_time
        [ "$REPORT_UNIT" = "ISO" ] && DISPLAY_UNIT="C" || DISPLAY_UNIT="$REPORT_UNIT"
        DATE_USA=$(date +"%b-%d"); DATE_INTL=$(date +"%d-%b"); DATE_ISO=$(date +"%Y-%m-%d")
        clear
        echo -e "${CYAN}==================================================${NC}"
        echo -e "${CYAN}                Set Temperature/Date                ${NC}"
        echo -e "${CYAN}==================================================${NC}"
        echo -e "   Unit: ${GREEN}°$DISPLAY_UNIT${NC}            Date: ${GREEN}$CUR_TIME${NC}"
        echo -e "${CYAN}==================================================${NC}"
        echo ""
        echo "  (1)  Fahrenheit (°F) / USA  ($DATE_USA)"
        echo "  (2)  Celsius    (°C) / INTL ($DATE_INTL)"
        echo "  (3)  Technical  (°C) / TECH ($DATE_ISO)"
        echo "  (e)  Exit to main menu"
        echo ""
        printf " Selection: "
        read t_choice
        case "$t_choice" in
            1) NEW_UNIT="F" ;;
            2) NEW_UNIT="C" ;;
            3) NEW_UNIT="ISO" ;;
            e|E) return ;;
            *) echo -e "${RED}Invalid selection.${NC}"; sleep 1; continue ;;
        esac
        sed -i '/REPORT_UNIT=/d' "$CONF_FILE"
        echo "REPORT_UNIT=\"$NEW_UNIT\"" >> "$CONF_FILE"
        REPORT_UNIT="$NEW_UNIT"
        echo -e "${GREEN}[+] Settings updated to $NEW_UNIT${NC}"
        sleep 1
    done
}

set_nicknames() {
    check_installed || return 1
    clear; [ -f "$CONF_FILE" ] && . "$CONF_FILE"
    RAW_NODES=$(nvram get asus_device_list | sed 's/</\n/g' | grep '>2$')
    if [ -z "$RAW_NODES" ]; then
        RAW_NODES=$(nvram get dhcp_staticlist | sed 's/</\n/g' | awk -F'>' '{print $1">"$2">"$3">2"}')
    fi
    MAIN_IP=$(nvram get lan_ipaddr)
    MAIN_HW_MODEL=$(nvram get modelid)
    [ -z "$MAIN_HW_MODEL" ] && MAIN_HW_MODEL=$(nvram get productid)
    echo -e "${CYAN}==================================================${NC}"
    echo -e "${CYAN}              Router Nickname Setup               ${NC}"
    echo -e "${CYAN}==================================================${NC}"
	echo -e "      (Press [Enter] to keep the current name)     "
    echo -e "      (Press [0] for default names [e] to Exit)        "
    echo -e "${CYAN}==================================================${NC}"
    echo -e ""
    CURRENT_MAIN_NICK=${MAIN_NICK:-"$MAIN_HW_MODEL"}
    printf " Main $MAIN_IP [$CURRENT_MAIN_NICK]: "
    read input_main
    if [ "$input_main" = "e" ] || [ "$input_main" = "E" ]; then
        return
    elif [ "$input_main" = "0" ]; then
        echo -e "${YELLOW}[!] Resetting all nicknames to defaults...${NC}"
        sed -i '/^MAIN_NICK=/d' "$CONF_FILE"
        sed -i '/^NODE_NICK_/d' "$CONF_FILE"
        unset MAIN_NICK
        echo -e "${GREEN}[+] Defaults restored.${NC}"
        pause
        return
    fi
    MAIN_NICK=${input_main:-"$CURRENT_MAIN_NICK"}
    sed -i '/^MAIN_NICK=/d' "$CONF_FILE"
    echo "MAIN_NICK=\"$MAIN_NICK\"" >> "$CONF_FILE"
    if [ -n "$SSH_NODES" ] && [ "$SSH_NODES" != " " ]; then
        VALID_NODES=$(echo "$SSH_NODES" | tr ' ' '\n' | grep '|')
        for node in $VALID_NODES; do
            ALIAS=$(echo "$node" | cut -d'|' -f1)
            IP=$(echo "$node" | cut -d'|' -f2)
            CLEAN_IP=$(echo "$IP" | tr '.' '_')
            unset NODE_NICK_$CLEAN_IP
            [ -f "$CONF_FILE" ] && . "$CONF_FILE"
            eval SAVED_NICK=\$NODE_NICK_$CLEAN_IP
            CURRENT_DISPLAY=${SAVED_NICK:-"$ALIAS"}
            printf " Node $IP [$CURRENT_DISPLAY]: "
            read input_node
            if [ "$input_node" = "e" ] || [ "$input_node" = "E" ]; then
                return
            elif [ "$input_node" = "0" ]; then
                sed -i '/^MAIN_NICK=/d' "$CONF_FILE"
                sed -i '/^NODE_NICK_/d' "$CONF_FILE"
                unset MAIN_NICK
                echo -e "${GREEN}[+] Defaults restored.${NC}"
                pause
                return
            fi
            NEW_NICK=${input_node:-"$CURRENT_DISPLAY"}
            sed -i "/^NODE_NICK_$CLEAN_IP=/d" "$CONF_FILE"
            echo "NODE_NICK_$CLEAN_IP=\"$NEW_NICK\"" >> "$CONF_FILE"
        done
    fi
    echo -e "\n${GREEN}[+] Nicknames updated successfully.${NC}"
    pause
}

set_threshold() {
    check_installed || return 1
    while true; do
        if [ -z "$ROAM_THRESHOLD" ] || [ "$ROAM_THRESHOLD" -eq 0 ]; then
            CUR_VAL="${RED}Disabled"
        else
            CUR_VAL="${GREEN}-$(echo "$ROAM_THRESHOLD" | tr -d '"') dBm"
        fi
        clear
        echo -e "${CYAN}==================================================${NC}"
        echo -e "${CYAN}            RSSI Kick Threshold Setup             ${NC}"
        echo -e "               (Current: $CUR_VAL${NC})           "
        echo -e "${CYAN}==================================================${NC}"
        echo -e " (Type [0] to Disable / [Enter] Asus Default 70)  "
        echo -e "${CYAN}==================================================${NC}"
        echo -e ""
        echo -e "  [1] Set Kick Threshold (60-85)"
        echo -e "  [2] Manage [MAC] Skip List"
        echo -e "  [3] View Kick Log"
        echo -e ""
        echo -e "  [e] Exit"
        echo -e ""
        printf " Selection: "
        read -r choice
        [ -z "$choice" ] && choice="1_default"
        [ "$choice" = "0" ] && choice="1_disable"
        case "$choice" in
            [eE]) return 0 ;;
            1|1_default|1_disable)
                if [ "$choice" = "1_default" ]; then
                    threshold_input=70
                elif [ "$choice" = "1_disable" ]; then
                    threshold_input=0
                else
                    echo -e "\n Enter a value between 60 and 85 (or [0] to Disable):"
                    printf " Selection [Enter for 70]: "
                    read -r threshold_input
                    [ -z "$threshold_input" ] && threshold_input=70
                fi
                if [ "$threshold_input" = "0" ]; then
                    sed -i '/ROAM_THRESHOLD=/d' "$CONF_FILE"
                    ROAM_THRESHOLD=""
                    echo -e "\n ${GREEN}RSSI Kick Threshold set to: Disabled${NC}"
                elif echo "$threshold_input" | grep -qE '^[0-9]+$'; then
                    if [ "$threshold_input" -lt 60 ] || [ "$threshold_input" -gt 85 ]; then
                        threshold_input=70
                        echo -e "\n ${YELLOW}Out of range. Using 70.${NC}"
                    fi
                    sed -i '/ROAM_THRESHOLD=/d' "$CONF_FILE"
                    echo "ROAM_THRESHOLD=$threshold_input" >> "$CONF_FILE"
                    ROAM_THRESHOLD="$threshold_input"
                    echo -e "\n ${GREEN}RSSI Kick Threshold set to -$threshold_input dBm.${NC}"
                else
                    echo -e "\n ${RED}Invalid input.${NC}"
                fi
                sleep 2
                ;;
            2)
                while true; do
                    clear
                    echo -e "${CYAN}==================================================${NC}"
                    echo -e "${CYAN}           RSSI Kick Skip List Manager            ${NC}"
                    echo -e "${CYAN}==================================================${NC}"
                    echo -e " Current VIP Devices (Will NOT be kicked):"
                    if [ -s "$SKIP_DB" ]; then
                        while read -r smac; do
                            S_NAME=$(get_name "$smac")
                            echo -e "  • $smac - $S_NAME"
                        done < "$SKIP_DB"
                    else
                        echo "  (No devices currently skipped)"
                    fi
                    echo -e "${CYAN}==================================================${NC}"
                    echo -e " [1] Add Device (From Known List)"
                    echo -e " [2] Remove Device"
                    echo -e " [3] Manual Add (Enter MAC)"
                    echo -e " [e] Back to Menu"
                    echo -e "${CYAN}==================================================${NC}"
                    printf " Selection: "
                    read -r sub_choice
                    case "$sub_choice" in
                        [eE]) break ;;
                        1) 
                            clear
                            echo -e "${CYAN}--- Select a Device to Protect ---${NC}"
                            if [ -s "$KNOWN_DB" ]; then
                                i=1
                                rm -f /tmp/known_map
                                while read -r kline; do
                                    kmac=$(echo "$kline" | awk -F'|' '{print $1}')
                                    kname=$(get_name "$kmac")
                                    if ! grep -qi "$kmac" "$SKIP_DB" 2>/dev/null; then
                                        echo -e "  [$i] $kmac - $kname"
                                        echo "$i|$kmac" >> /tmp/known_map
                                        i=$((i + 1))
                                    fi
                                done < "$KNOWN_DB"
                                if [ "$i" -eq 1 ]; then
                                    echo " (No new devices to add)"
                                    sleep 2; continue
                                fi
                                echo -ne "\n Select number to protect (or [e] to cancel): "
                                read -r k_num
                                [ "$k_num" = "e" ] && continue
                                target_mac=$(grep "^$k_num|" /tmp/known_map | cut -d'|' -f2)
                                if [ -n "$target_mac" ]; then
                                    echo "$target_mac" >> "$SKIP_DB"
                                    echo -e "\n ${GREEN}Protected: $(get_name "$target_mac")${NC}"
                                else
                                    echo -e "\n ${RED}Invalid selection.${NC}"
                                fi
                            else
                                echo -e "\n ${RED}No known devices found.${NC}"
                            fi
                            sleep 2
                            ;;
                        2) 
                            while true; do
                                clear
                                echo -e "${CYAN}--- Remove from VIP ---${NC}"
                                if [ -s "$SKIP_DB" ]; then
                                    i=1
                                    rm -f /tmp/rem_map
                                    while read -r smac; do
                                        sname=$(get_name "$smac")
                                        echo -e "  [$i] $smac - $sname"
                                        echo "$i|$smac" >> /tmp/rem_map
                                        i=$((i + 1))
                                    done < "$SKIP_DB"
                                    echo -ne "\n Select number to remove ([e] to go back): "
                                    read -r r_num
                                    if [ -z "$r_num" ] || [ "$r_num" = "e" ] || [ "$r_num" = "E" ]; then
                                        break 
                                    fi
                                    target_mac=$(grep "^$r_num|" /tmp/rem_map | cut -d'|' -f2)
                                    if [ -n "$target_mac" ]; then
                                        sed -i "/$target_mac/d" "$SKIP_DB"
                                        echo -e "\n ${GREEN}Removed: $(get_name "$target_mac")${NC}"
                                        sleep 2
                                    else
                                        echo -e "\n ${RED}Invalid selection.${NC}"
                                        sleep 1
                                    fi
                                else
                                    echo " (VIP list is empty)"
                                    sleep 2
                                    break
                                fi
                            done
                            ;;
                        3) 
                            echo -ne "\n Enter MAC Address: "
                            read -r manual_mac
                            manual_mac=$(echo "$manual_mac" | tr '[:lower:]' '[:upper:]' | tr -cd '0-9A-F:')
                            if ! echo "$manual_mac" | grep -qE '^([0-9A-F]{2}:){5}[0-9A-F]{2}$'; then
                                echo -e "\n ${RED}Invalid format.${NC}"
                            else
                                echo "$manual_mac" >> "$SKIP_DB"
                                echo -e "\n ${GREEN}Protected: $manual_mac${NC}"
                            fi
                            sleep 2
                            ;;
                    esac
                done
                ;;
            3)
                while true; do
                    clear
                    echo -e "${CYAN}==================================================${NC}"
                    echo -e "${CYAN}        RSSI THRESHOLD KICK LOG                   ${NC}"
                    echo -e "${CYAN}==================================================${NC}"
                    if [ -s "$BSS_LOG" ]; then
                        cat "$BSS_LOG"
                        echo -e "${CYAN}==================================================${NC}"
                        echo -e " [c] Clear Log | [any other key] Return to Menu "
                    else
                        echo -e "\n          (No kick events logged yet)"
                        echo -e "${CYAN}==================================================${NC}"
                        echo -e " [any key] Return to Menu"
                    fi
                    printf " Selection: "
                    read -r log_choice
                    if [ "$log_choice" = "c" ] || [ "$log_choice" = "C" ]; then
                        > "$BSS_LOG"
                        echo -e "\n ${GREEN}Log cleared.${NC}"
                        sleep 1
                    else
                        break
                    fi
                done
                ;;
            *)
                echo -e "\n ${RED}Invalid selection.${NC}"
                sleep 1
                ;;
        esac
    done
}

ScriptUpdateFromAMTM() {
    if ! "$doScriptUpdateFromAMTM"
    then
        printf "Automatic updates via AMTM are currently disabled.\n\n"
        return 1
    fi
    if [ $# -gt 0 ] && [ "$1" = "check" ]
    then return 0
    fi
    do_update
	echo -e "\n${GREEN}Wireless Report successfully updated${NC}"
    return "$?"
}

pause() { printf "\nPress [Enter] to return..."; read discard; }

######################
#  Report Functions  #
######################
update_time() {
    if [ "$REPORT_UNIT" = "ISO" ]; then T_FMT="+%Y-%m-%d %H:%M:%S"; D_FMT="+%Y-%m-%d %H:%M"; TEMP_UNIT="C"
    elif [ "$REPORT_UNIT" = "C" ]; then T_FMT="+%-d-%b %-H:%M:%S";  D_FMT="+%-d-%b %-H:%M"; TEMP_UNIT="C"
    else T_FMT="+%b-%-d %-H:%M:%S"; D_FMT="+%b-%-d %-H:%M"; TEMP_UNIT="F"; fi
    CUR_TIME=$(date "$T_FMT")
}

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

get_name() {
    local mac=$(echo "$1" | tr '[:lower:]' '[:upper:]')
    local name=""
    [ -f "$YAZ_CACHE" ] && name=$(grep -i "$mac" "$YAZ_CACHE" | awk -F'|' '{print $3}' | head -n 1)
    if [ -z "$name" ] || [ "$name" = "*" ]; then
        name=$(nvram get custom_clientlist | sed 's/</\n/g' | grep -i "$mac" | awk -F'>' '{print $1}' | head -n 1)
    fi
    if [ -z "$name" ] || [ "$name" = "*" ]; then
        if [ -f "/jffs/nmp_cl_json.js" ]; then
            local entry=$(sed 's/},"/ \n"/g' /jffs/nmp_cl_json.js | grep -i "$mac" | head -n 1)
            local parent_mac=$(echo "$entry" | sed -n 's/.*"mac":"\([^"]*\)".*/\1/p' | tr '[:lower:]' '[:upper:]')
            if [ -n "$parent_mac" ] && [ "$parent_mac" != "$mac" ]; then
                echo "SWAP_TO|$parent_mac"
                return
            fi
            name=$(echo "$entry" | sed -n 's/.*"name":"\([^"]*\)".*/\1/p')
        fi
    fi
    [ -z "$name" ] && [ -f "$ARP_CACHE" ] && name=$(grep -i "$mac" "$ARP_CACHE" | cut -d'|' -f2 | head -n 1)
    [ -z "$name" ] || [ "$name" = "*" ] && name="$mac"
    echo "$name"
}

check_new_mac() {
	local mac=$(echo "$1" | tr '[:lower:]' '[:upper:]')
    [ ! -f "$KNOWN_DB" ] && touch "$KNOWN_DB"
    if ! grep -qi "$mac" "$KNOWN_DB"; then echo "$mac" >> "$KNOWN_DB"; echo "new-device-row"; fi
}

ip_to_num() { echo "$1" | awk -F. '{if(NF==4) printf "%03d%03d%03d%03d", $1,$2,$3,$4; else printf "000000000000";}' ; }

get_band() {
    local iface=$1; local width=$2; local model=$3
    local w_text=""; [ -n "$width" ] && w_text=" ($width)"
    local Label="Unknown"

    # Quad-Band Mapping
    # Models: GT-BE98(Pro), BQ16, GT-AXE16000, GT-BE25000
    if echo "$model" | grep -qiE "BE98|BQ16|AXE16000|BE25000"; then
		case "$iface" in
			wl0*|eth7*) Label="5G" ;;
			wl1*|eth8*) echo "$model" | grep -qiE "PRO|BQ16" && Label="6G-1" || Label="5G-2" ;;
			wl2*|eth9*) echo "$model" | grep -qiE "PRO|BQ16" && Label="6G-2" || Label="6G" ;;
			wl3*|eth10*) Label="2.4G" ;;
		esac

    # Tri-Band Mapping (2.4G,5G,6G)
	# Models: RT-BE96U, RT-BE92U, GT-BE19000, GS-BE18000, GS-BE12000, BT6, BT8, BT10, 
    #         RT-AXE7800, GT-AXE11000, ET8, ET9, ET12
    elif echo "$model" | grep -qiE "BE96U|BE92U|BE19000|BE18000|BE12000|BT6|BT8|BT10|AXE7800|AXE11000|ET8|ET9|ET12"; then
        case "$iface" in
            wl0*|eth1*|eth4*|eth8*) Label="2.4G" ;; 
            wl1*|eth2*|eth5*|eth7*|eth10*) Label="5G" ;;
            wl2*|eth6*|eth9*) Label="6G" ;; 
        esac
        
    # Tri-Band Mapping (2.4G,5G-1,5G-2)
    # Models:  RT-AX92U, GT6, XT8, XT9, XT12
    elif echo "$model" | grep -qiE "AX92U|GT6|XT8|XT9|XT12"; then
        case "$iface" in
            wl0*|eth1*|eth4*|eth8*) Label="2.4G" ;; 
            wl1*|eth2*|eth5*|eth7*|eth10*) Label="5G-1" ;;
            wl2*|eth6*|eth9*) Label="5G-2" ;; 
        esac    

    # Dual-Band Mapping
    else
        case "$iface" in
            wl0*|eth1*|eth4*|eth6*|eth8*|ath0*) Label="2.4G" ;;
            wl1*|eth2*|eth5*|eth7*|eth10*|ath1*) Label="5G" ;;
            *)                                   Label="Unknown" ;;
        esac
    fi
    
    # Band UI Renderer
    local class="" sort="0"
    case "$Label" in
        "2.4G")             class="text-24"; sort="2.4" ;;
        "5G"|"5G-1"|"5G-2") class="text-5g"; sort="5"   ;;
        "6G"|"6G-1"|"6G-2") class="text-6g"; sort="6"   ;;
    esac
    echo "<td data-sort='$sort' style='text-align:center;'><span class='$class'>$Label$w_text</span></td>"
}

fmt_time() {
    T=$1; [ -z "$T" ] || ! echo "$T" | grep -qE '^[0-9]+$' && echo "<span data-sort='0'>---</span>" && return
    local pulse=""; [ "$T" -lt 900 ] && pulse="pulse-blue"
    echo "$T" | awk -v p="$pulse" '{d=int($1/86400); h=int(($1%86400)/3600); m=int(($1%3600)/60); printf "<span class=\""p"\" data-sort=\"%s\">", $1; if(d>0) printf "%02dd %02dh", d, h; else if(h>0) printf "%02dh %02dm", h, m; else printf "00h %02dm", m; printf "</span>";}'
}

temp_cf() {
    local raw_c=$1
    [ -z "$raw_c" ] || ! echo "$raw_c" | grep -qE '^-?[0-9]+$' && echo "--" && return
    if [ "$TEMP_UNIT" = "C" ]; then
        echo "${raw_c}°C"
    else
        echo "$raw_c" | awk '{printf "%.0f°F", ($1 * 1.8) + 32}'
    fi
}

get_temp_class() {
    local temp_str=$1
    [ "$temp_str" = "--" ] && echo "val-blue" && return
    local val=$(echo "$temp_str" | sed 's/[^0-9.]//g')
    if [ "$REPORT_UNIT" = "C" ]; then
        awk -v t="$val" 'BEGIN { if(t>75) print "stat-hot"; else if(t>68) print "stat-warm"; else print "val-blue"; }'
    else
        awk -v t="$val" 'BEGIN { if(t>167) print "stat-hot"; else if(t>155) print "stat-warm"; else print "val-blue"; }'
    fi
}
 
get_load_class() {
    local l=$1; [ "$l" = "--" ] && { echo "val-blue"; return; }
    awk -v l="$l" 'BEGIN { print (l>2.0 ? "stat-hot" : (l>1.0 ? "stat-warm" : "val-blue")) }'
}

get_mhz_width() {
    local raw_info="$1"
    local width=""
    width=$(echo "$raw_info" | sed -n 's/.*chanspec.*\/\([0-9]*\).*/\1/p')
    if [ -z "$width" ]; then
        local hex=$(echo "$raw_info" | grep -o '0x[0-9a-fA-F]*')
        case "$hex" in
            0x10*) width="20" ;;
            0x11*) width="40" ;;
            0xd0*) width="20" ;;
            0xd1*) width="40" ;;
            0xe0*) width="80" ;;
            0xe8*) width="160" ;;
			0xe9*) width="160" ;;
            0xf0*) width="320" ;;
            *)     width="20" ;;
        esac
    fi
    echo "$width"
}

log_kick() {
    local MSG="$1"
    local LOGTIME=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$LOGTIME] $MSG" >> "$BSS_LOG"
    logger -t "Wireless Report" "$MSG"
}

run_report() {

###############
#  Main Scan  #
###############
update_time; grep "0x2" /proc/net/arp | awk '{print toupper($4)"|"$1}' > "$ARP_CACHE"
[ -f "$YAZ_CLIENTS" ] && awk -F',' '{print toupper($1) "|" $2 "|" $3}' "$YAZ_CLIENTS" > $YAZ_CACHE || > $YAZ_CACHE
M_T=$(($(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0) / 1000))
M_TEMP=$(temp_cf "$M_T"); M_LOAD=$(cat /proc/loadavg | awk '{print $1}')
MC_TEMP=$(get_temp_class "$M_TEMP"); MC_LOAD=$(get_load_class "$M_LOAD")
M_UPTIME=$(awk -v s=$(cat /proc/uptime | cut -d. -f1) 'BEGIN {d=int(s/86400); h=int((s%86400)/3600); m=int((s%3600)/60); if(d>0) printf "%dd %dh %dm", d, h, m; else if(h>0) printf "%dh %dm", h, m; else printf "%dm", m}')
M_BOOT=$(date -d @$(( $(date +%s) - $(cut -d. -f1 /proc/uptime) )) "$D_FMT")
MAIN_PFX=$(nvram get lan_hwaddr | cut -c 1-13 | tr '[:lower:]' '[:upper:]')
NODE_PFX=$(nvram get cfg_relist | sed 's/[<>]/ /g' | tr ' ' '\n' | grep ":" | cut -c 1-13 | sort -u | tr '[:lower:]' '[:upper:]')
ROUTER_IP=$(nvram get lan_ipaddr); DEVICE_LIST=$(nvram get cfg_device_list)
M_ALIAS=$(echo "$DEVICE_LIST" | sed 's/</\n/g' | grep ">$ROUTER_IP>" | awk -F'>' '{print $1}')
M_NAME="${MAIN_NICK:-${M_ALIAS:-"Main Router"}}"; [ ${#M_NAME} -gt 25 ] && M_NAME="${M_NAME:0:25}"
MAIN_LABEL="<span class='router-branding'>$M_NAME<!--(MAIN)--></span>"
RSSI_UNIT="<span style='font-size:14px; font-weight:bold; margin-left:2px;'>ᵈᴮᵐ</span>"
MBPS_UNIT="<span style='font-size:14px; font-weight:bold; margin-left:2px;'>ᵐᵇᵖˢ</span>"
MHZ_UNIT="<span style='font-size:14px; font-weight:bold; margin-left:2px;'>ᵐʰᶻ</span>"
> $SEEN_MACS; > $MAIN_ROWS; > $NODE_ROWS; > $ALL_ROWS; > $NEW_HISTORY; > $Q_RELAY
T_EXC=0; T_GOOD=0; T_FAIR=0; T_POOR=0; M_TOTAL=0; N_TOTAL=0
KICK_SAFETY="OFF"; [ "$BUP" -lt 300 ] && KICK_SAFETY="ON"
if [ "$KICK_SAFETY" = "OFF" ] && [ -s "$BSS_LOG" ]; then
    LAST_KICK=$(tail -n 1 "$BSS_LOG" | sed -n 's/^\[\([0-9: -]*\)\].*/\1/p')
    LAST_SEC=$(date -d "$LAST_KICK" +%s 2>/dev/null || echo 0)
    [ "$LAST_SEC" -ne 0 ] && [ $(( $(date +%s) - LAST_SEC )) -lt 600 ] && KICK_SAFETY="ON"
fi
WL_BASES=$(nvram get wl_ifnames)
WL0_PHYS=$(echo "$WL_BASES" | awk '{print $1}'); WL1_PHYS=$(echo "$WL_BASES" | awk '{print $2}')
WL2_PHYS=$(echo "$WL_BASES" | awk '{print $3}'); WL3_PHYS=$(echo "$WL_BASES" | awk '{print $4}')
for base in $WL_BASES; do
	IFACE_LIST="$IFACE_LIST $base"
	SUBS=$(ifconfig -a | grep -oE "${base}\.[0-9]+" | sort -u | xargs)
	IFACE_LIST="$IFACE_LIST $SUBS"
done
SDN_IFACES=$(ifconfig -a | grep -oE "wl[0-9]+\.[0-9]+" | sort -u | xargs)
IFACE_LIST=$(echo "$IFACE_LIST $SDN_IFACES" | tr ' ' '\n' | sort -u | xargs)
for iface in $IFACE_LIST; do
	case "$iface" in lo|eth0|eth1|eth2|eth3) continue ;; esac
	case "$iface" in
		"$WL0_PHYS"*) data_iface="wl0" ;;
		"$WL1_PHYS"*) data_iface="wl1" ;;
		"$WL2_PHYS"*) data_iface="wl2" ;;
		"$WL3_PHYS"*) data_iface="wl3" ;;
		*) data_iface="$iface" ;;
	esac
    WL_ALIVE=0
    wl -i "$iface" assoclist >/dev/null 2>&1 && WL_ALIVE=1
    SNAME=$(nvram get "${iface}_ssid")
	if [ -z "$SNAME" ] || echo "$SNAME" | grep -qE '^[0-9A-Fa-f]{16,}$'; then
		idx=${iface#*.}
		[ "$idx" != "$iface" ] && SNAME=$(nvram get "gnp_name_$idx")
	fi
	[ -z "$SNAME" ] && [ -n "$data_iface" ] && SNAME=$(nvram get "${data_iface}_ssid")
	[ -z "$SNAME" ] && SNAME=$(nvram get "${iface%.*}_ssid")
	[ -z "$SNAME" ] && [ -n "$data_iface" ] && SNAME=$(nvram get "${data_iface%.*}_ssid")
	[ -z "$SNAME" ] && SNAME="Wireless"
	MAC_LIST=$(wl -i "$iface" assoclist 2>/dev/null | awk '{print $2}')
	if [ -z "$MAC_LIST" ]; then
		BRIDGE=$(brctl show 2>/dev/null | grep "$iface" | awk '{print $1}')
		[ -z "$BRIDGE" ] && BRIDGE=$(brctl show 2>/dev/null | grep -B1 "$iface" | grep -v "\-\-" | head -n1 | awk '{print $1}')
		if [ -n "$BRIDGE" ]; then
			MAC_LIST=$(brctl showmacs "$BRIDGE" 2>/dev/null | grep -v "yes" | awk '{print $2}')
		fi
	fi
	for mac in $MAC_LIST; do
		[ -z "$mac" ] || [ "$mac" = "mac" ] && continue
		m_live=$(echo "$mac" | tr '[:lower:]' '[:upper:]')
		m_prefix=$(echo "$m_live" | cut -c 1-13 | tr '[:lower:]' '[:upper:]')
		if [ "$m_prefix" = "$MAIN_PFX" ] || echo "$NODE_PFX" | grep -q "$m_prefix"; then
			continue
		fi
		if grep -qi "$m_live" "$SEEN_MACS"; then
			continue
		fi
		lookup=$(get_name "$m_live")
		if echo "$lookup" | grep -q "SWAP_TO|"; then
			m_live=$(echo "$lookup" | cut -d'|' -f2)
			name=$(get_name "$m_live")
		else
			name="$lookup"
		fi
		[ "$name" = "SKIP_MLO" ] && continue
		yaz_entry=$(grep -i "^$m_live|" "$YAZ_CACHE" | head -n 1)
		if [ -n "$yaz_entry" ]; then
			m_up=$(echo "$yaz_entry" | cut -d'|' -f1 | tr '[:lower:]' '[:upper:]')
			ip=$(echo "$yaz_entry" | cut -d'|' -f2)
			[ "$name" = "$m_live" ] && name=$(echo "$yaz_entry" | cut -d'|' -f3)
		else
			m_up="$m_live"
			ip=$(grep -ih "$m_up" "$ARP_CACHE" "$YAZ_CACHE" | cut -d'|' -f2 | head -n 1)
			lan_pfx=$(nvram get lan_ipaddr | cut -d'.' -f1,2)
			[ -z "$ip" ] && ip=$(cat /var/lib/misc/dnsmasq*.leases 2>/dev/null | grep -i "$m_live" | awk -v pfx="$lan_pfx" '{for(i=1;i<=NF;i++) if($i ~ "^"pfx"\\.") {print $i; exit}}')
		fi
		[ -z "$ip" ] && ip="---" || ip=$(printf "%s.%03d" "${ip%.*}" "${ip##*.}")
		{ [ -z "$name" ] || [ "$name" = "*" ]; } && name="$m_up"
		rssi=$(wl -i "$iface" rssi "$mac" 2>/dev/null | awk '{print $1}')
		if [ -f "$SKIP_DB" ] && grep -qi "$m_up" "$SKIP_DB"; then
			continue 
		fi
		[ -z "$rssi" ] || ! echo "$rssi" | grep -qE '^-[0-9]+$' && rssi=$(wl -i "$data_iface" rssi "$mac" 2>/dev/null | awk '{print $1}')
		if ! echo "$rssi" | grep -qE '^-[0-9]+$'; then
			[ "$WL_ALIVE" -eq 1 ] && continue
			rssi="-99"
		fi
		[ "$rssi" -ge -20 ] || [ "$rssi" -le -100 ] || grep -qi "$m_up" "$SEEN_MACS" && continue
		echo "$m_up" | grep -qE '^([0-9A-F]{2}:){5}[0-9A-F]{2}$' && echo "$m_up" >> "$SEEN_MACS"
		if [ -n "$ROAM_THRESHOLD" ]; then
			ROAM_THRESHOLD=$(echo "$ROAM_THRESHOLD" | tr -d '"' | xargs)
			case "$ROAM_THRESHOLD" in
				*[!0-9]*) INVALID=true ;;
				*) INVALID=false ;;
			esac
			if [ "$INVALID" = "true" ] || [ "$ROAM_THRESHOLD" -lt 60 ] || [ "$ROAM_THRESHOLD" -gt 85 ]; then
				sed -i '/ROAM_THRESHOLD=/d' "$CONF_FILE"
				ROAM_THRESHOLD=""
				logger -t "Wireless Report" "CRITICAL: Invalid Roaming Threshold detected. Feature DISABLED for safety."
			fi
		fi
		if [ "$KICK_SAFETY" = "OFF" ] && [ -n "$ROAM_THRESHOLD" ] && [ "$rssi" -le -"$ROAM_THRESHOLD" ]; then
			log_kick "[$M_NAME] Kicking $m_up on $iface ($rssi dBm)"
			wl -i "$iface" deauthenticate "$m_up" >/dev/null 2>&1
			hostapd_cli -i "$iface" disassociate "$m_up" >/dev/null 2>&1
			iw dev "$iface" station del "$m_up" >/dev/null 2>&1
		fi
		raw_info=$(wl -i "$iface" sta_info "$mac" 2>/dev/null)
		[ -z "$raw_info" ] && raw_info=$(wl -i "$data_iface" sta_info "$mac" 2>/dev/null)
		rx_raw=$(echo "$raw_info" | grep "rate of last rx pkt" | awk '{print $6/1000}')
		tx_raw=$(echo "$raw_info" | grep "rate of last tx pkt" | awk -F': ' '{print $2}' | awk '{print $1/1000}')
		max_raw=$(echo "$raw_info" | grep "Max Rate =" | awk '{print $4}')
		mhz_width=$(get_mhz_width "$raw_info")
		[ -z "$rx_raw" ] || [ "$rx_raw" = "0" ] && rx_disp="?" || rx_disp="${rx_raw%.*}"
		[ -z "$tx_raw" ] || [ "$tx_raw" = "0" ] && tx_disp="${max_raw:-?}" || tx_disp="${tx_raw%.*}"
		[ "$rx_disp" = "?" ] && rx_disp="1"; [ "$tx_disp" = "?" ] && tx_disp="1"
		l_rate_disp="${rx_disp} / ${tx_disp}"
		V1=$(echo "$rx_disp" | tr -dc '0-9'); V2=$(echo "$tx_disp" | tr -dc '0-9')
		[ -n "$V1" ] && [ -n "$V2" ] && [ "$V1" -gt "$V2" ] 2>/dev/null && { T=$rx_disp; rx_disp=$tx_disp; tx_disp=$T; l_rate_disp="$rx_disp / $tx_disp"; }
		[ "$rx_disp" = "---" ] && [ "$tx_disp" = "---" ] && l_rate_disp="---"
		l_rate_val=${tx_disp:-0}; is_new=$(check_new_mac "$m_up")
		trend=$(get_trend "$m_up" "$rssi"); bars=$(get_bars "$rssi")
		rssi_style=$(get_rssi_style "$rssi")
		uptime=$(echo "$raw_info" | grep 'in network' | awk '{print $3}')
		[ ${#name} -gt 20 ] && name="${name:0:20}"
		display_ssid="$SNAME"; [ ${#display_ssid} -gt 15 ] && display_ssid="${display_ssid:0:15}"
		ip_s=$(ip_to_num "$ip"); band_td=$(get_band "$iface" "$mhz_width" "$M_ALIAS")
		if [ "$rssi" -ge -50 ]; then T_EXC=$((T_EXC+1)); elif [ "$rssi" -ge -60 ]; then T_GOOD=$((T_GOOD+1)); elif [ "$rssi" -ge -70 ]; then T_FAIR=$((T_FAIR+1)); else T_POOR=$((T_POOR+1)); fi
		ROW_STR="<tr class='$is_new'><td style='text-align:left;'>$name</td><td class='toggle-cell'><span class='m-val' data-sort='$m_up'>$m_up</span><span class='i-val' data-sort='$ip_s'>$ip</span></td><td data-sort='$rssi'>$bars <span style='$rssi_style'>$rssi</span> $trend</td><td data-sort='$l_rate_val' style='$rssi_style; text-align:center;'>$l_rate_disp</td><td class='toggle-ssid'><span class='s-val' data-sort='$SNAME'>$display_ssid</span><span class='if-val' data-sort='$iface'>$iface</span></td>$band_td<td>$(fmt_time "$uptime")</td></tr>"
		echo "$ROW_STR" >> $MAIN_ROWS; echo "$ROW_STR" >> $ALL_ROWS
		M_TOTAL=$((M_TOTAL + 1))
	done
done
CONSOLIDATED_T="<span class='${MC_TEMP}'>${M_TEMP}</span>"
CONSOLIDATED_L="<span class='${MC_LOAD}'>${M_LOAD}</span>"
CONSOLIDATED_U="<span class='val-blue'>${M_UPTIME}</span>"
CONSOLIDATED_B="<span class='val-blue'>${M_BOOT}</span>"

####################
#  Node Scan Loop  #
####################
[ -n "$SSH_NODES" ] && TARGET_LIST="$SSH_NODES" || TARGET_LIST=$(nvram get asus_device_list | sed 's/</\n/g' | grep '>2$' | awk -F '>' '{print $1"|"$2"|"$3}' | sort -t '|' -k 1,1 | awk -F '|' '{print $2"|"$3}')
for line in $TARGET_LIST; do ALIAS="${line%|*}"; IP="${line#*|}"; done
NODE_DATA="$TARGET_LIST"; NODE_COUNT_TOTAL=$(echo "$NODE_DATA" | grep -v "^$" | wc -l)
# [ "$NODE_COUNT_TOTAL" -gt 1 ] && N_SUFFIX="(NODES)" || N_SUFFIX="(NODE)"
NODE_COLORS="#64d2ff #30d158 #ffd60a #bf40bf #ff9500 #ff453a"; PIPE=" <span style='color:white;'>|</span> "
N_NAMES=""; N_TEMPS=""; N_LOADS=""; N_BOOTS=""; N_UPTIMES=""; N_SPLIT_COUNTS=""; COLOR_IDX=0; ACTIVE_NODES=0
for line in $TARGET_LIST; do
	NODE_OUT=""
	IP=$(echo "$line" | cut -d'|' -f2); ALIAS=$(echo "$line" | cut -d'|' -f1)
	[ -z "$IP" ] && continue
	CLEAN_IP=$(echo "$IP" | tr '.' '_'); eval CUSTOM_NICK=\$NODE_NICK_$CLEAN_IP
	NODE_DISPLAY_NAME="${CUSTOM_NICK:-${ALIAS:-$IP}}"; [ ${#NODE_DISPLAY_NAME} -gt 25 ] && NODE_DISPLAY_NAME="${NODE_DISPLAY_NAME:0:25}"
	NODE_OUT=$(/usr/bin/ssh -p "$SSH_PORT" -i "$SSH_KEY" -o StrictHostKeyChecking=no "${NODE_USER}@${IP}" "
		UP_SEC=\$(cut -d. -f1 /proc/uptime)
		F_UP=\$(awk -v s=\"\$UP_SEC\" 'BEGIN {d=int(s/86400); h=int((s%86400)/3600); m=int((s%3600)/60); if(d>0) printf \"%dd %dh %dm\", d, h, m; else if(h>0) printf \"%dh %dm\", h, m; else printf \"%dm\", m}')
		NODE_COUNT=0
		ALL_IFACES=\$(ifconfig -a | grep -oE \"(wl|ath|eth6|eth7|eth8|eth9|eth10)[0-9]*(\.[0-9]+)?\")
		for iface in \$ALL_IFACES; do
			case \"\$iface\" in wl0.0|wl1.0|wl2.0|wl3.0) continue ;; esac
			SN=\$(nvram get \"\${iface}_ssid\")
			if [ -z \"\$SN\" ]; then
				case \"\$iface\" in
					eth6|eth8) SN=\$(nvram get wl0_ssid) ;;
					eth7|eth10) SN=\$(nvram get wl1_ssid) ;;
					eth9) SN=\$(nvram get wl2_ssid) ;;
				esac
			fi
			[ -z \"\$SN\" ] && SN=\$(nvram get \"\${iface%.*}_ssid\")
			if echo \"\$SN\" | grep -qE '^[0-9A-Fa-f]{16,}$'; then continue; fi
			if echo "\$iface" | grep -q "ath"; then
				SN=\$(iw dev "\$iface" info 2>/dev/null | grep ssid | awk '{print \$2}')
				[ -z "\$SN" ] && SN=\$(nvram get "\${iface}_ssid")
				MACS=\$(wlanconfig "\$iface" list 2>/dev/null | awk 'NR>1 {print \$1}' | grep ":")
				for mac in \$MACS; do
					ROW=\$(wlanconfig "\$iface" list 2>/dev/null | grep -i "\$mac")
					RSSI=\$(echo \"\$ROW\" | awk '{print \$7}')
					TX=\$(echo \"\$ROW\" | awk '{print \$5}' | tr -dc '0-9')
					RX=\$(echo \"\$ROW\" | awk '{print \$6}' | tr -dc '0-9')
					HB=\"2.4GHz\"; echo \"\$iface\" | grep -q \"ath1\" && HB=\"5GHz\"
					W="20"
					echo "\$iface" | grep -q "ath1" && W="80"
					LRD=\"\${RX} / \${TX}\"
					echo \"DATA|\$mac|\$RSSI|\$iface|UP_REQ|\$SN|\$TX|\$LRD|\$W|\$HB\"
					NODE_COUNT=\$((NODE_COUNT + 1))
				done
			else
				for mac in \$(wl -i \"\$iface\" assoclist 2>/dev/null | awk '{print \$2}'); do
					RAW=\$(wl -i \"\$iface\" sta_info \"\$mac\" 2>/dev/null)
					RSSI=\$(wl -i \"\$iface\" rssi \"\$mac\" 2>/dev/null | awk '{print \$1}')
					W=\$(echo \"\$RAW\" | sed -n 's/.*chanspec.*\\/\\([0-9]*\\).*/\\1/p')
					if [ -z \"\$W\" ]; then
						HEX=\$(echo \"\$RAW\" | grep -o '0x[0-9a-fA-F]*' | head -n1)
						case \"\$HEX\" in 
							0x10*|0xd0*) W=\"20\" ;; 
							0x11*|0xd1*) W=\"40\" ;; 
							0xe0*) W=\"80\" ;; 
							0xe8*) W=\"160\" ;;
							0xe9*) W=\"160\" ;;
							0xf*) W=\"320\" ;; 
							*) W=\"20\" ;; 
						esac
					fi
					RX=\$(echo \"\$RAW\" | grep \"rate of last rx pkt\" | awk '{print \$6/1000}')
					TX=\$(echo \"\$RAW\" | grep \"rate of last tx pkt\" | awk -F': ' '{print \$2}' | awk '{print \$1/1000}')
					MX=\$(echo \"\$RAW\" | grep \"Max Rate =\" | awk '{print \$4}')
					HB=\$(wl -i \"\$iface\" band | awk '{print \$1}')
					RXD=\$(echo \"\$RX\" | awk '{if (\$1==0) print \"1\"; else printf \"%.0f\", \$1}')
					TXD=\$(echo \"\$TX\" | awk -v m=\"\$MX\" '{if (\$1==0) print \"1\"; else printf \"%.0f\", \$1}')
					[ \"\$RXD\" = \"1\" ] && [ \"\$TXD\" = \"1\" ] && LRD=\"1\" || LRD=\"\${RXD} / \${TXD}\"
					V1=\$(echo \"\$RXD\" | tr -dc '0-9'); V2=\$(echo \"\$TXD\" | tr -dc '0-9')
					[ -n \"\$V1\" ] && [ -n \"\$V2\" ] && [ \"\$V1\" -gt \"\$V2\" ] 2>/dev/null && { T=\$RXD; RXD=\$TXD; TXD=\$T; LRD=\"\$RXD / \$TXD\"; }
					echo \"DATA|\$mac|\$RSSI|\$iface|\$(echo \"\$RAW\" | grep \"in network\" | awk '{print \$3}')|\$SN|\$TX|\$LRD|\$W|\$HB\"
					NODE_COUNT=\$((NODE_COUNT + 1))
				done
			fi
		done
		echo \"TEMP|\$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | cut -c1-2)\"
		echo \"LOAD|\$(cat /proc/loadavg | awk '{print \$1}')\"
		echo \"UPTIME_VAL|\$F_UP\"; echo \"UPTIME_RAW|\$UP_SEC\"; echo \"COUNT|\$NODE_COUNT\"
	" 2>/dev/null)
	
		if [ -n "$NODE_OUT" ]; then
        ACTIVE_NODES=$((ACTIVE_NODES + 1)); COLOR_IDX=$((COLOR_IDX + 1))
        CUR_COLOR=$(echo $NODE_COLORS | cut -d' ' -f$((COLOR_IDX))); [ -z "$CUR_COLOR" ] && CUR_COLOR="#ffffff"
        STAR_HTML="<span style='color:$CUR_COLOR;'><sup>$ACTIVE_NODES</sup></span>"
        NODE_BRAND="<span class='router-branding' style='color:$CUR_COLOR;'>${NODE_DISPLAY_NAME}<sup>$ACTIVE_NODES</sup></span>"
        [ -z "$N_NAMES" ] && N_NAMES="$NODE_BRAND" || N_NAMES="$N_NAMES$PIPE$NODE_BRAND"
		N_TEMP_RAW=$(echo "$NODE_OUT" | grep "TEMP|" | cut -d'|' -f2)
        [ ${#N_TEMP_RAW} -gt 3 ] && N_TEMP_RAW=$((N_TEMP_RAW / 1000))
        N_TEMP=$(temp_cf "$N_TEMP_RAW"); N_LOAD=$(echo "$NODE_OUT" | grep "LOAD|" | cut -d'|' -f2)
		NC_TEMP=$(get_temp_class "$N_TEMP"); NC_LOAD=$(get_load_class "$N_LOAD")
        N_UPTIME_RAW=$(echo "$NODE_OUT" | grep "UPTIME_RAW|" | cut -d'|' -f2)
		N_UPTIME=$(echo "$NODE_OUT" | grep "UPTIME_VAL|" | cut -d'|' -f2)
		N_BOOT=$(date -d @$(( $(date +%s) - ${N_UPTIME_RAW:-0} )) "$D_FMT")
		CONSOLIDATED_T="$CONSOLIDATED_T | <span class='${NC_TEMP}'>${N_TEMP}</span>"
        CONSOLIDATED_L="$CONSOLIDATED_L | <span class='${NC_LOAD}'>${N_LOAD}</span>"
        CONSOLIDATED_U="$CONSOLIDATED_U | <span style='color:$CUR_COLOR;'>${N_UPTIME}</span>"
        CONSOLIDATED_B="$CONSOLIDATED_B | <span style='color:$CUR_COLOR;'>${N_BOOT}</span>"
		N_TEMPS="${N_TEMPS}${N_TEMPS:+$PIPE}<span class='${NC_TEMP}'>$N_TEMP</span>"
		N_LOADS="${N_LOADS}${N_LOADS:+$PIPE}<span class='${NC_LOAD}'>$N_LOAD</span>"
        N_UPTIMES="${N_UPTIMES}${N_UPTIMES:+$PIPE}<span style='color:$CUR_COLOR;'>$N_UPTIME</span>"
		N_BOOTS="${N_BOOTS}${N_BOOTS:+$PIPE}<span style='color:$CUR_COLOR;'>$N_BOOT</span>"
        NODE_DISPLAY_COUNT=0; JSON_FILE="/jffs/wlcnt.json"
		while read -r dline; do
			[ -z "$dline" ] && continue
			m_live=$(echo "$dline" | cut -d'|' -f2 | tr '[:lower:]' '[:upper:]')
			r_raw=$(echo "$dline" | cut -d'|' -f3)
			i_raw=$(echo "$dline" | cut -d'|' -f4); u_raw=$(echo "$dline" | cut -d'|' -f5)
			m_prefix=$(echo "$m_live" | cut -c 1-13 | tr '[:lower:]' '[:upper:]')
			if [ "$m_prefix" = "$MAIN_PFX" ] || echo "$NODE_PFX" | grep -q "$m_prefix"; then
				continue
			fi
			if grep -qi "$m_live" "$SEEN_MACS"; then
				continue
			fi
			lookup=$(get_name "$m_live")
			if echo "$lookup" | grep -q "SWAP_TO|"; then
				m_live=$(echo "$lookup" | cut -d'|' -f2)
				n_name=$(get_name "$m_live")
			else
				n_name="$lookup"
			fi
			[ "$n_name" = "SKIP_MLO" ] && continue
			IS_VIP=false
			if [ -f "$SKIP_DB" ] && grep -qi "$m_live" "$SKIP_DB"; then
				IS_VIP=true
			fi
			if [ "$KICK_SAFETY" = "OFF" ] && [ "$IS_VIP" = "false" ] && [ -n "$ROAM_THRESHOLD" ] && [ "$r_raw" -le -"$ROAM_THRESHOLD" ]; then
				log_kick "[$NODE_DISPLAY_NAME] Kicking $m_live on $i_raw ($r_raw dBm)"
				ssh -p "$SSH_PORT" -i "$SSH_KEY" "${NODE_USER}@${IP}" "
					if command -v service >/dev/null 2>&1; then
						service \"kick_client $m_live $i_raw\" >/dev/null 2>&1
					fi
					if command -v wl >/dev/null 2>&1; then
						wl -i $i_raw deauthenticate $m_live >/dev/null 2>&1
					fi	
					if command -v hostapd_cli >/dev/null 2>&1; then
						hostapd_cli -i $i_raw deauthenticate $m_live >/dev/null 2>&1
						hostapd_cli -i $i_raw disassociate $m_live >/dev/null 2>&1
					fi
					if command -v iw >/dev/null 2>&1; then
						iw dev $i_raw station del $m_live >/dev/null 2>&1
					fi
				" >/dev/null 2>&1
			fi
			yaz_entry=$(grep -i "^$m_live|" "$YAZ_CACHE" | head -n 1)
			if [ -n "$yaz_entry" ]; then
				m_up=$(echo "$yaz_entry" | cut -d'|' -f1 | tr '[:lower:]' '[:upper:]')
				n_ip=$(echo "$yaz_entry" | cut -d'|' -f2)
				[ "$n_name" = "$m_live" ] && n_name=$(echo "$yaz_entry" | cut -d'|' -f3)
			else
				m_up="$m_live"
				n_ip=$(grep -ih "$m_up" "$ARP_CACHE" "$YAZ_CACHE" | cut -d'|' -f2 | head -n 1)
				lan_pfx=$(nvram get lan_ipaddr | cut -d'.' -f1,2)
				[ -z "$n_ip" ] && n_ip=$(cat /var/lib/misc/dnsmasq*.leases 2>/dev/null | grep -i "$m_live" | awk -v pfx="$lan_pfx" '{for(i=1;i<=NF;i++) if($i ~ "^"pfx"\\.") {print $i; exit}}')
			fi
			[ -z "$n_ip" ] && n_ip="---" || n_ip=$(printf "%s.%03d" "${n_ip%.*}" "${n_ip##*.}")
			{ [ -z "$n_name" ] || [ "$n_name" = "*" ]; } && n_name="$m_up"
			grep -qi "$m_up" "$SEEN_MACS" && continue
			echo "$m_up" | grep -qE '^([0-9A-F]{2}:){5}[0-9A-F]{2}$' && echo "$m_up" >> "$SEEN_MACS"
            N_TOTAL=$((N_TOTAL + 1)); NODE_DISPLAY_COUNT=$((NODE_DISPLAY_COUNT + 1))
			if [ "$r_raw" -ge -50 ]; then echo "EXC" >> "$Q_RELAY"
            elif [ "$r_raw" -ge -60 ]; then echo "GOOD" >> "$Q_RELAY"
            elif [ "$r_raw" -ge -70 ]; then echo "FAIR" >> "$Q_RELAY"
            else echo "POOR" >> "$Q_RELAY"; fi
			if [ "$u_raw" = "UP_REQ" ] && echo "$i_raw" | grep -q "ath"; then
				NOW=$(date +%s)
				CLEAN_MAC=$(echo "$dline" | cut -d'|' -f2 | tr -d '<> ' | awk '{print toupper($0)}')
				START_TS=$(jq -r ".\"$CLEAN_MAC\".start // 0" "$JSON_FILE")
				if [ "$START_TS" -gt 0 ]; then
					u_raw=$((NOW - START_TS))
					[ "$u_raw" -lt 0 ] && u_raw=$((START_TS - NOW))
				else
					u_raw="0"
				fi
			fi
			s_name=$(echo "$dline" | cut -d'|' -f6); display_s_name="$s_name"
            [ ${#display_s_name} -gt 15 ] && display_s_name="${display_s_name:0:15}"
            l_rate_val=$(echo "$dline" | cut -d'|' -f7); l_rate_disp_n=$(echo "$dline" | cut -d'|' -f8)
			w_raw=$(echo "$dline" | cut -d'|' -f9); hb_raw=$(echo "$dline" | cut -d'|' -f10)
            is_new=$(check_new_mac "$m_up"); trend=$(get_trend "$m_up" "$r_raw")
			bars_n=$(get_bars "$r_raw"); rssi_style_n=$(get_rssi_style "$r_raw")
            [ ${#n_name} -gt 20 ] && n_name="${n_name:0:20}"
            ip_ns=$(ip_to_num "$n_ip"); band_td_n=$(get_band "$i_raw" "$w_raw" "$ALIAS")
            N_ROW="<tr class='$is_new'><td style='text-align:left;'>$n_name$STAR_HTML</td><td class='toggle-cell'><span class='m-val' data-sort='$m_up'>$m_up</span><span class='i-val' data-sort='$ip_ns'>$n_ip</span></td><td data-sort='$r_raw'>$bars_n <span style='$rssi_style_n'>$r_raw</span> $trend</td><td data-sort='$l_rate_val' style='$rssi_style_n; text-align:center;'>$l_rate_disp_n</td><td class='toggle-ssid'><span class='s-val' data-sort='$s_name'>$display_s_name</span><span class='if-val' data-sort='$i_raw'>$i_raw</span></td>$band_td_n<td>$(fmt_time "$u_raw")</td></tr>"
            echo "$N_ROW" >> $NODE_ROWS; echo "$N_ROW" >> $ALL_ROWS
        done <<EOF
$(echo "$NODE_OUT" | grep "DATA|")
EOF
N_SPLIT_COUNTS="${N_SPLIT_COUNTS}${N_SPLIT_COUNTS:+ | }<span style='color:$CUR_COLOR;'>$NODE_DISPLAY_COUNT</span>"
    fi
done
T_EXC=$((T_EXC + $(grep -c "EXC" "$Q_RELAY"))); T_GOOD=$((T_GOOD + $(grep -c "GOOD" "$Q_RELAY")))
T_FAIR=$((T_FAIR + $(grep -c "FAIR" "$Q_RELAY"))); T_POOR=$((T_POOR + $(grep -c "POOR" "$Q_RELAY")))
GRAND_TOTAL=$((M_TOTAL + N_TOTAL)); BRAND_LINE_ALL="<span class='router-branding'>$M_NAME</span> | $N_NAMES"
[ "$ACTIVE_NODES" -gt 0 ] && R_TITLE="Wireless Report AiMesh" || R_TITLE="Wireless Report"
[ "$ACTIVE_NODES" -ge 1 ] && FULL_DEVICE_BREAKDOWN="Devices: <span class='val-blue'>$GRAND_TOTAL</span> <span class='dash-sep'>—›</span> <span class='val-blue'>$M_TOTAL</span> | $N_SPLIT_COUNTS" || FULL_DEVICE_BREAKDOWN="Devices: <span class='val-blue'>$M_TOTAL</span>"
mv "$NEW_HISTORY" "$HISTORY_DB"

##########
#  HTML  #
##########
/usr/bin/printf '\xEF\xBB\xBF' > $OUT_FILE
cat <<HTML >> $OUT_FILE
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" />
<title>ASUS Wireless Router $M_NAME - Wireless Report</title>
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" href="index_style.css" />
<link rel="stylesheet" href="form_style.css" />
<link rel="stylesheet" href="usp_style.css" />
<link rel="stylesheet" href="other.css" />
<script src="/js/jquery.js"></script>
<script src="/state.js"></script>
<script src="/general.js"></script>
<script src="/popup.js"></script>
<script src="/help.js"></script>
<style>
		#wifiReportContainer { color: #f2f2f7; font-size: 12px; font-family: Arial, sans-serif; width: 97% !important; margin: 0 !important; padding: 0 !important; position: relative; }
		.report-header-main { text-align: center; color: #0096ff; margin: 0 0 10px 0; font-size: 1.8em; font-weight: bold; width: 100%; position: static; margin-left: 0; }
		.top-controls { display: flex; justify-content: center; gap: 8px; width: 100%; margin: 0 0 12px 0; }
		.total-count { text-align: center; color: #f2f2f7; margin-bottom: 12px; font-size: 11px; font-weight: bold; letter-spacing: 0.5px; }
		.count-highlight { background: #0096ff; color: #000; padding: 1px 6px; border-radius: 3px; margin-left: 4px; font-weight: 900; }
		.v-wrap { text-align: center; width: 100%; margin: 10px 0; }
		.v-tip { position: relative; cursor: pointer; display: inline-block; }
		.v-box { visibility: hidden; width: var(--v-width, 190px); background: #1c232b; color: #3498db; text-align: center; border: 1px solid #475a68; border-radius: 6px; padding: 8px; position: absolute; z-index: 999; bottom: 135%; left: 50%; transform: translateX(-50%); opacity: 0; transition: opacity 0.6s cubic-bezier(0.4, 0, 0.2, 1), bottom 0.6s cubic-bezier(0.4, 0, 0.2, 1); font-size: 0.85rem; font-weight: bold; box-shadow: 0 4px 12px #000; pointer-events: none; line-height: 1.4; }
		.v-tip:hover .v-box { visibility: visible; opacity: 1; bottom: 145%; }
		.quality-bar { display: flex; justify-content: center; gap: 12px; align-items: center; width: 100%; margin: -5px auto -5px auto; padding: 0; background: transparent; border: none; height: auto; }
		.q-box { display: inline-block; height: 28px; line-height: 26px; text-align: center; padding: 0 12px; border-radius: 4px; background: rgba(0,0,0,0.4); border: 1px solid #475a68; font-weight: bold; box-sizing: border-box; transition: all 0.2s ease; }
		.q-box:hover { border-color: #0096ff; box-shadow: 0 0 10px rgba(0,150,255,0.4); cursor: pointer; }
		.q-box:hover select, .q-box:hover .btn-manual { color: #0096ff !important; }
		.btn-black-blue { background: rgba(0,0,0,0.6); border: 1px solid #475a68; color: #0096ff; cursor: pointer; padding: 0 12px; font-size: 12px; border-radius: 4px; font-weight: bold; height: 28px; line-height: 26px; transition: all 0.2s ease; box-sizing: border-box; }
		.btn-black-blue:hover, .btn-black-blue.active { border-color: #0096ff; box-shadow: 0 0 10px rgba(0,150,255,0.4); color: #0096ff; }
		.btn-black-blue.active { background: rgba(0,150,255,0.15); }
		#countdown { margin-left: 6px; font-weight: bold; }
		#refreshRate:focus { outline: none; border: none; background: #000; }
		.grid-container { display: flex; flex-direction: column; gap: 15px; align-items: center; width: 100%; }
		.report-column { width: 100%; background: #1c232b; border-radius: 8px; border: 1px solid #475a68; overflow: hidden; display: flex; flex-direction: column; }
		.report_table tbody tr:hover td { background-color: rgba(0, 123, 255, 0.15) !important; cursor: pointer; }
		table.report_table { width: 100%; border-collapse: collapse; }
		table.report_table.show-ip .m-val { display: none !important; } 
		table.report_table.show-ip .i-val { display: inline !important; color: #64d2ff; }
		table.report_table.show-iface .s-val { display: none !important; } 
		table.report_table.show-iface .if-val { display: inline !important; color: #64d2ff; }
		table.report_table thead th { position: sticky; top: 0; z-index: 10; background: linear-gradient(to bottom, #0096ff, #0056b3); color: #fff; padding: 8px; cursor: pointer; text-align: center; border-right: 1px solid rgba(255,255,255,0.1); }
		table.report_table th:hover { background: #00e5ff; color: #000; text-shadow: 0 0 10px rgba(0,229,255,0.8); }
		table.report_table td { padding: 6px; border-bottom: 1px solid #3d454b; background: #1c232b; vertical-align: middle; text-align: center; }
		table.report_table td:nth-child(1) { max-width: 150px; white-space: nowrap; overflow: hidden; text-overflow: clip; }
		table.report_table td:nth-child(5) { max-width: 100px; white-space: nowrap; overflow: hidden; text-overflow: clip; }
		table.report_table tr td:first-child { text-align: left; padding-left: 10px; }
		table.report_table thead th:first-child { text-align: left; padding-left: 10px; }
		table.report_table tfoot td { border-top: 1px solid #475a68; padding: 12px 10px !important; font-weight: bold; background: #171b1f; color: #fff; }
		.f-res { color: #0096ff; }
		.pulse-blue { color: #00e5ff !important; font-weight: bold; animation: pulse-blue-glow 2s infinite; }
		@keyframes pulse-blue-glow { 0% { opacity: 1; } 50% { opacity: 0.5; } 100% { opacity: 1; } }
		.new-device-row { background-color: rgba(0, 229, 255, 0.1) !important; animation: pulse-blue-glow 2s infinite; }
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
		#popoutModal th, #popoutModal td { white-space: nowrap; height: 25px !important; line-height: 25px !important; padding: 0 4px !important; }
		.dash-sep { color: rgba(255,255,255,0.4); font-size: 0.9em; margin: 0 4px; animation: sep-glow 3s infinite ease-in-out; }
		@keyframes sep-glow { 0% { color: rgba(255,255,255,0.2); } 50% { color: #0096ff; text-shadow: 0 0 5px #0096ff; } 100% { color: rgba(255,255,255,0.2); } }
		#allCol { display: none; width: 100% ; align-self: flex-start; }
		.row-break { flex-basis: 100%; height: 0; margin: 0; }
		sup { font-size: 0.6em; margin-left: 2px; }
</style>
<script>
function initial() {
    show_menu();
    var savedView = localStorage.getItem('wifiReportView') || 'split';
    switchTab(savedView);
    if (localStorage.getItem('wifiReportPopoutOpen') === 'true') {
        openPopout();
    }
    var savedRate = localStorage.getItem('wifiReportAutoRefresh') || "0";
    document.getElementById('refreshRate').value = savedRate;
    initAutoRefresh(parseInt(savedRate));
    var ids = ['allTable', 'mainTable', 'nodeTable', 'popMainTable', 'popNodeTable'];
    ids.forEach(function(id) {
        var tableObj = document.getElementById(id);
        if (tableObj && tableObj.rows && tableObj.rows.length > 1) {
            var ipState = localStorage.getItem('toggle_' + id + '_show-ip');
            var ipHeader = tableObj.querySelector('thead th:nth-child(2)');
            if (ipState === "true") {
                tableObj.classList.add('show-ip');
                if (ipHeader) ipHeader.innerHTML = "IP ADDRESS ⇅";
            } else {
                tableObj.classList.remove('show-ip');
                if (ipHeader) ipHeader.innerHTML = "MAC ADDRESS ⇅";
            }
            var ifaceState = localStorage.getItem('toggle_' + id + '_show-iface');
            var ifaceHeader = tableObj.querySelector('thead th:nth-child(5)');
            if (ifaceState === "true") {
                tableObj.classList.add('show-iface');
                if (ifaceHeader) ifaceHeader.innerHTML = "IFACE ⇅";
            } else {
                tableObj.classList.remove('show-iface');
                if (ifaceHeader) ifaceHeader.innerHTML = "SSID ⇅";
            }
            var savedCol = localStorage.getItem('savedSortCol_' + id);
            var savedDir = localStorage.getItem('savedSortDir_' + id);
            if (savedCol !== null) {
                try {
                    sortTable(parseInt(savedCol), id, true, (savedDir === 'desc'));
                } catch (e) {
                    console.error("Sort failed for " + id, e);
                }
            } else {
                try {
                    sortTable(2, id, false, true);
                } catch (e) {
                    console.error("Default sort failed for " + id, e);
                }
            }
        }
    });
}
var timeLeft = 0; var refreshTimer = null; var isRefreshing = false;
function triggerRefresh() {
    if (isRefreshing) return; isRefreshing = true;
    var btn = document.querySelector('.btn-manual');
    if (btn) btn.innerText = "Refreshing...";
    var expires = new Date(Date.now() + 30000).toUTCString();
    document.cookie = "report_done=true; expires=" + expires + "; path=/";
    fetch('/apply.cgi', { 
        method: 'POST', 
        body: 'action_mode=apply&rc_service=restart_wireless_report&current_page=$INSTALLED_PAGE&next_page=$INSTALLED_PAGE' 
    }).then(function() { 
        setTimeout(function() { window.location.reload(); }, 9000); 
    });
}
window.addEventListener('load', function() {
    if (document.cookie.indexOf("report_done=true") === -1) {
        triggerRefresh();
    } else {
        console.log("Cookie found: Skipping auto-refresh to prevent loop.");
    }
});
function initAutoRefresh(seconds) {
    clearInterval(refreshTimer);
    if (seconds > 0) {
        timeLeft = seconds;
        refreshTimer = setInterval(function() { timeLeft--; if (timeLeft <= 0) { triggerRefresh(); clearInterval(refreshTimer); } document.getElementById('countdown').innerHTML = "&nbsp;" + timeLeft + "s"; }, 1000);
    } else { document.getElementById('countdown').innerHTML = ""; }
}
function switchTab(view) {
    localStorage.setItem('wifiReportView', view);
    var split = document.getElementById('splitView');
    var all = document.getElementById('allCol');
    var btnStack = document.getElementById('btnStack');
    var btnAll = document.getElementById('btnAll');
    if(view === 'all') {
        if (split) split.style.display = 'none'; 
        if (all) all.style.display = 'flex';
        if (btnAll) btnAll.classList.add('active'); 
        if (btnStack) btnStack.classList.remove('active');
    } else {
        if (split) split.style.display = 'flex'; 
        if (all) all.style.display = 'none';
        if (btnStack) btnStack.classList.add('active'); 
        if (btnAll) btnAll.classList.remove('active');
    }
}
function toggleCols(tId, cls, header, labelA, labelB) { 
    var table = document.getElementById(tId); 
    if(!table) return;
    var isActive = table.classList.toggle(cls); 
    header.innerHTML = (isActive ? labelB : labelA) + " ⇅";
    localStorage.setItem('toggle_' + tId + '_' + cls, isActive ? "true" : "false");
    var colIdx = (cls === 'show-ip') ? 1 : 4; 
    sortTable(colIdx, tId, true);
}
function sortTable(n, tId, keepDir, forceDesc) {
    var table = document.getElementById(tId);
    if (!table) return;
    var tbody = table.tBodies[0];
    var rows = Array.prototype.slice.call(tbody.rows);
    if (!rows.length) return;
    var dir = table.getAttribute("data-dir-" + n) || "asc";
    if (forceDesc) {
        dir = "desc";
    } else if (!keepDir) {
        dir = (dir === "asc") ? "desc" : "asc";
    }
    table.setAttribute("data-dir-" + n, dir);
    localStorage.setItem('savedSortCol_' + tId, n);
    localStorage.setItem('savedSortDir_' + tId, dir);
    if (window.event && window.event.type === 'contextmenu' && n === 0) {
        localStorage.setItem('savedSortNodeMode_' + tId, 'true');
    } else if (window.event && window.event.type === 'click') {
        localStorage.removeItem('savedSortNodeMode_' + tId);
    }
    var headers = table.querySelectorAll('th');
    headers.forEach(function(h, idx) {
        var txt = h.innerText.toUpperCase();
        if (idx === 1) {
            h.innerHTML = table.classList.contains('show-ip') ? "IP ADDRESS ⇵" : "MAC ADDRESS ⇵";
        } else if (txt.includes("RSSI")) {
            h.innerHTML = "RSSI" + "${RSSI_UNIT}";
        } else if (txt.includes("RX/TX")) {
            h.innerHTML = "RX/TX" + "${MBPS_UNIT}";
        } else if (txt.includes("BAND")) {
            h.innerHTML = "BAND" + "${MHZ_UNIT}";
        } else if (idx === 4) {
            h.innerHTML = table.classList.contains('show-iface') ? "IFACE ⇵" : "SSID ⇵";
        } else {
            h.innerHTML = h.innerHTML.replace(/[▼▲▾▴]/g, "").trim();
        }
    });
    rows.sort(function(a, b) {
        var valA, valB;
        var cellA = a.cells[n];
        var cellB = b.cells[n];
        if (n === 0) {
            var txtA = cellA.innerText.trim();
            var txtB = cellB.innerText.trim();
            var isRightClick = (window.event && window.event.type === 'contextmenu');
            var isNodeModeSaved = (localStorage.getItem('savedSortNodeMode_' + tId) === 'true');

            if (isRightClick || (isNodeModeSaved && n === 0)) {
                var nodeA = txtA.slice(-1);
                var nodeB = txtB.slice(-1);
                if (nodeA !== nodeB) {
                    return dir === "asc" ? nodeA.localeCompare(nodeB) : nodeB.localeCompare(nodeA);
                }
            }
            return dir === "asc" ? txtA.localeCompare(txtB) : txtB.localeCompare(txtA);
        }
        if (n === 1) {
            var sel = table.classList.contains('show-ip') ? '.i-val' : '.m-val';
            valA = cellA.querySelector(sel).getAttribute('data-sort');
            valB = cellB.querySelector(sel).getAttribute('data-sort');
            if (sel === '.m-val') {
                return dir === "asc" ? valA.localeCompare(valB) : valB.localeCompare(valA);
            }
        } else if (n === 4) {
            var sel = table.classList.contains('show-iface') ? '.if-val' : '.s-val';
            valA = cellA.querySelector(sel).innerText.trim().toLowerCase();
            valB = cellB.querySelector(sel).innerText.trim().toLowerCase();
        } else if (n === 6) {
            var parseTime = function(s) {
                var d = s.match(/(\d+)d/) ? parseInt(s.match(/(\d+)d/)[1]) : 0;
                var h = s.match(/(\d+)h/) ? parseInt(s.match(/(\d+)h/)[1]) : 0;
                var m = s.match(/(\d+)m/) ? parseInt(s.match(/(\d+)m/)[1]) : 0;
                return (d * 1440) + (h * 60) + m;
            };
            valA = parseTime(cellA.innerText);
            valB = parseTime(cellB.innerText);
        } else if (cellA.hasAttribute('data-sort')) {
            valA = cellA.getAttribute('data-sort');
            valB = cellB.getAttribute('data-sort');
        } else {
            valA = cellA.innerText.trim();
            valB = cellB.innerText.trim();
        }
        var numA = parseFloat(valA);
        var numB = parseFloat(valB);
        if (!isNaN(numA) && !isNaN(numB)) {
            return dir === "asc" ? numA - numB : numB - numA;
        }
        return dir === "asc" ? valA.localeCompare(valB) : valB.localeCompare(valA);
    });
    rows.forEach(function(r) {
        tbody.appendChild(r);
    });
}
function openPopout() {
    localStorage.setItem('wifiReportPopoutOpen', 'true');
    var body = document.getElementById('popoutBody'); body.innerHTML = "";
    var mCol = document.getElementById('mainCol').cloneNode(true); 
    var nCol = document.getElementById('nodeCol').cloneNode(true);
    mCol.querySelector('table').id = "popMainTable"; 
    nCol.querySelector('table').id = "popNodeTable";
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
    body.appendChild(mCol); body.appendChild(nCol); 
    document.getElementById('popoutModal').style.display = 'flex';
}
function closePopout() { 
    document.getElementById('popoutModal').style.display = 'none'; 
    localStorage.setItem('wifiReportPopoutOpen', 'false');
}
document.addEventListener('contextmenu', function(e) {
    var h = e.target.closest('th');
    if (h && Array.prototype.indexOf.call(h.parentNode.children, h) === 0) {
        var table = h.closest('table');
        if (!table) return;
        if (table.closest('#mainCol')) {
            return;
        }
        e.preventDefault(); 
        sortTable(0, table.id, false, false); 
    }
});
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
      <div class="v-wrap"><div class="v-tip" style="--v-width: $V_WIDTH;"><h1 id="v-header" class="report-header-main" style="margin:0; display:inline-block;">$R_TITLE</h1><span class="v-box">$HOVER_TEXT</span></div></div>
        <div class="total-count">Total Wireless Devices: <span class="count-highlight">$GRAND_TOTAL</span></div>
		<div class="top-controls">
			<div class="q-box" style="padding:0 5px; display:inline-flex; align-items:center;">
			<button class="btn-manual btn-black-blue" style="border:none; height:100%; line-height:inherit; padding:0 8px;" onclick="triggerRefresh()">Refresh</button>
				<span style="font-size:12px; margin-left:5px;">Auto: </span>
				<select id="refreshRate" onchange="localStorage.setItem('wifiReportAutoRefresh', this.value); initAutoRefresh(parseInt(this.value));" style="background:#000; color:#0096ff; border:0px solid #444; margin-left:2px; font-size:12px; height:20px;">
					<option value="0">Off</option><option value="30">30s</option><option value="60">1m</option><option value="120">2m</option><option value="300">5m</option><option value="600">10m</option><option value="1200">20m</option><option value="1800">30m</option>
				</select><span id="countdown"></span>
			</div>
HTML
if [ "$ACTIVE_NODES" -gt 0 ]; then
cat <<NODEBUTTONS >> $OUT_FILE			
			<button id="btnStack" class="btn-black-blue active" onclick="switchTab('split')">Stacked</button>
			<button id="btnAll" class="btn-black-blue" onclick="switchTab('all')">All Devices</button>
			<button class="btn-black-blue" onclick="openPopout()">Side by Side ⇗</button>
NODEBUTTONS
fi
cat <<HTML >> $OUT_FILE		
		</div>
          <div class="grid-container">
          <div id="splitView" style="display:flex; flex-direction:column; gap:15px; width:100%;">
              <div id="mainCol" class="report-column">
                <div class="section-header">
                  $MAIN_LABEL<br>
                  <span style="font-size:11px; font-weight:bold;">Updated: $CUR_TIME</span>
                  <hr class="sep-line">
                  <div class="header-stats-row">Temp: <span class="$MC_TEMP">$M_TEMP</span> • Load: <span class="$MC_LOAD">$M_LOAD</span> • Devices: <span class="val-blue">$M_TOTAL</span></div>
                </div>
                <table id="mainTable" class="report_table show-ip">
                  <thead><tr>
                    <th onclick="sortTable(0, 'mainTable')">HOSTNAME</th>
                    <th onclick="toggleCols('mainTable', 'show-ip', this, 'MAC ADDRESS', 'IP ADDRESS')">IP ADDRESS</th>
					<th onclick="sortTable(2, 'mainTable')">RSSI</th>
					<th onclick="sortTable(3, 'mainTable')">RX/TX</th>
                    <th onclick="toggleCols('mainTable', 'show-iface', this, 'SSID', 'IFACE')">SSID</th>
                    <th onclick="sortTable(5, 'mainTable')">BAND</th>
                    <th onclick="sortTable(6, 'mainTable')">UPTIME</th>
                  </tr></thead>
                  <tbody>$(cat $MAIN_ROWS)</tbody>
                  <tfoot><tr><td colspan="7" style="text-align: center !important;">Uptime: <span class="f-res">$M_UPTIME</span> • Reboot: <span class="f-res">$M_BOOT</span></td></tr></tfoot>
                </table>
              </div>
			  <div class="quality-bar">
				  <div class="q-box sig-exc">Excellent: <span style="background:#30d158; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_EXC</span></div>
				  <div class="q-box sig-good">Good: <span style="background:#0096ff; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_GOOD</span></div>
				  <div class="q-box sig-fair" style="color:#ffd60a;">Fair: <span style="background:#ffd60a; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_FAIR</span></div>
				  <div class="q-box sig-poor" style="color:#ff453a;">Poor: <span style="background:#ff453a; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_POOR</span></div>
			  </div>
HTML
if [ "$ACTIVE_NODES" -gt 0 ]; then
cat <<NODEHTML >> $OUT_FILE
			  <div id="nodeCol" class="report-column">
                <div class="section-header">
                  $N_NAMES <span class="router-branding"><!--$N_SUFFIX--></span><br>
                  <span style="font-size:11px; font-weight:bold;">Updated: $CUR_TIME</span>
                  <hr class="sep-line">
                  <div class="header-stats-row">Temp: <span class='${NC_TEMP}'>${N_TEMPS:-0}</span> • Load: <span class='${NC_LOAD}'>${N_LOADS:-0}</span> • Devices: <span class="val-blue">$N_TOTAL</span> <span class="dash-sep">—›</span> $N_SPLIT_COUNTS</div>
                </div>
                <table id="nodeTable" class="report_table show-ip">
                  <thead><tr>
                    <th onclick="sortTable(0, 'nodeTable')">HOSTNAME</th>
                    <th onclick="toggleCols('nodeTable', 'show-ip', this, 'MAC ADDRESS', 'IP ADDRESS')">IP ADDRESS</th>
                    <th onclick="sortTable(2, 'nodeTable')">RSSI</th>
                    <th onclick="sortTable(3, 'nodeTable')">RX/TX</th>
                    <th onclick="toggleCols('nodeTable', 'show-iface', this, 'SSID', 'IFACE')">SSID</th>
                    <th onclick="sortTable(5, 'nodeTable')">BAND</th>
                    <th onclick="sortTable(6, 'nodeTable')">UPTIME</th>
                  </tr></thead>
                  <tbody>$(cat $NODE_ROWS)</tbody>
                  <tfoot><tr><td colspan="7" style="text-align: center !important;">$( [ -n "$N_UPTIMES" ] && echo "Uptime: $N_UPTIMES • Reboot: $N_BOOTS" || echo "Offline" )</td></tr></tfoot>
                </table>
              </div>
NODEHTML
fi
cat <<HTML >> $OUT_FILE
          </div>
          <div id="allCol" class="report-column">
            <div class="section-header">
              $BRAND_LINE_ALL<br>
              <span style="font-size:11px; font-weight:bold;">Updated: $CUR_TIME</span>
              <hr class="sep-line">
              <div class="header-stats-row">Temp: $CONSOLIDATED_T • Load: $CONSOLIDATED_L • $FULL_DEVICE_BREAKDOWN</div>
            </div>
            <table id="allTable" class="report_table show-ip">
              <thead><tr>
                <th onclick="sortTable(0, 'allTable')">HOSTNAME</th>
                <th onclick="toggleCols('allTable', 'show-ip', this, 'MAC ADDRESS', 'IP ADDRESS')">IP ADDRESS</th>
                <th onclick="sortTable(2, 'allTable')">RSSI</th>
                <th onclick="sortTable(3, 'allTable')">RX/TX</th>
                <th onclick="toggleCols('allTable', 'show-iface', this, 'SSID', 'IFACE')">SSID</th>
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
    <h2 style="color:#0096ff; margin:0 0 10px 0; text-align:center; text-shadow: 0 0 15px rgba(0,150,255,0.7);">Wireless Network</h2>
    <div id="popoutBody" class="modal-grid"></div>
  </div>
</div>
</body>
</html>
HTML
rm -f $SEEN_MACS $ARP_CACHE $YAZ_CACHE $MAIN_ROWS $NODE_ROWS $ALL_ROWS $Q_RELAY
}

case "$1" in
    install)
        install_menu
        ;;
    inject)
        inject_menu
        ;;
    amtmupdate)
		shift
        ScriptUpdateFromAMTM "$@"
        exit "$?"
        ;;
    *)
		run_report
        ;;
esac