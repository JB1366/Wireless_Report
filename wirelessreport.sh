#!/bin/sh
#=================================================================#
#                                                                 #
#                                                                 #
#  ██╗    ██╗██╗██████╗ ███████╗██╗     ███████╗███████╗███████╗  #
#  ██║    ██║██║██╔══██╗██╔════╝██║     ██╔════╝██╔════╝██╔════╝  #
#  ██║ █╗ ██║██║██████╔╝█████╗  ██║     █████╗  ███████╗███████╗  #
#  ██║███╗██║██║██╔══██╗██╔══╝  ██║     ██╔══╝  ╚════██║╚════██║  #
#  ╚███╔███╔╝██║██║  ██║███████╗███████╗███████╗███████║███████║  #
#   ╚══╝╚══╝ ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝  #
#                                                                 #
#       ██████╗ ███████╗██████╗  ██████╗ ██████╗ ████████╗        #
#       ██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝        #
#       ██████╔╝█████╗  ██████╔╝██║   ██║██████╔╝   ██║           #
#	    ██╔══██╗██╔══╝  ██╔═══╝ ██║   ██║██╔══██╗   ██║           #
#	    ██║  ██║███████╗██║     ╚██████╔╝██║  ██║   ██║           #
#       ╚═╝  ╚═╝╚══════╝╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝           #
#                                                                 #
#                                                                 #
#=================================================================#
#                                                                 #
#        Copyright (c) 2026 JB_1366 - All Rights Reserved         #
#           https://github.com/JB1366/Wireless_Report             #
#                                                                 #
#                    Browser/API Version                          #
#                API coded by ExtremeFiretop                      #
#=================================================================#
#        shellcheck shell=sh disable=SC2086,SC2155,SC3043         #
#=================================================================#

SCRIPT_VERSION="3.1.9"
INSTALL_DIR="/jffs/addons/wireless_report"
REPORT_SCRIPT="$INSTALL_DIR/wirelessreport.sh"
CONFIG="$INSTALL_DIR/webui.conf"
SYSTEM_MENU="/www/require/modules/menuTree.js"
TEMP_MENU="/tmp/menuTree.js"
WEB_PAGE="/tmp/wireless.asp"
if [ -f "$CONFIG" ]; then . "$CONFIG"; fi
export PATH="/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
unset LD_LIBRARY_PATH

#==================#
#  Script Install  #
#==================#
show_header() {
	clear; menu_vars
	#=======================================================================#
	echo -e "                                                               "
	echo -e " ██╗    ██╗██╗██████╗ ███████╗██╗     ███████╗███████╗███████╗ "
	echo -e " ██║    ██║██║██╔══██╗██╔════╝██║     ██╔════╝██╔════╝██╔════╝ "
	echo -e " ██║ █╗ ██║██║██████╔╝█████╗  ██║     █████╗  ███████╗███████╗ "
	echo -e " ██║███╗██║██║██╔══██╗██╔══╝  ██║     ██╔══╝  ╚════██║╚════██║ "
	echo -e " ╚███╔███╔╝██║██║  ██║███████╗███████╗███████╗███████║███████║ "
	echo -e "  ╚══╝╚══╝ ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝ "
	echo -e "                                                               "
	echo -e "      ██████╗ ███████╗██████╗  ██████╗ ██████╗ ████████╗       "
	echo -e "      ██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝       "
	echo -e "      ██████╔╝█████╗  ██████╔╝██║   ██║██████╔╝   ██║          "
	echo -e "      ██╔══██╗██╔══╝  ██╔═══╝ ██║   ██║██╔══██╗   ██║          "
	echo -e "      ██║  ██║███████╗██║     ╚██████╔╝██║  ██║   ██║          "
	echo -e "      ╚═╝  ╚═╝╚══════╝╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝          "
	echo -e "                                                               "
    echo -e "      Copyright (c) 2026 JB_1366 - All Rights Reserved         "
    echo -e "         $JB1366                                               "
    echo -e "                                                               "
    #=======================================================================#
}

install_menu() {
	while true; do
		show_header
		echo -e "${BL}=================================================="
		check_version
		echo -e "${BL}=================================================="
		echo -e "                                                       "
		echo -e "  $N1  Install/Update                                  "
		echo -e "  $N2  Uninstall                                       "
		echo -e "  $N3  Edit Date/Time ($DU) ($CT)                      "
		echo -e "  $N4  Edit Device Nicknames                           "
        echo -e "  $N5  Edit Device Colors                              "
		echo -e "  $N6  Configure Display Options ($TM_STAT)            "
		echo -e "  $NE  Exit                                            "
		echo -e "                                                       "
		echo -e "${BL}=================================================="
		while true; do
			printf "\n ${NC}Selection: ${BL}"; read -r choice
			case "$choice" in
				1) do_install; break ;;
				2|3|4|5|6)
                    freeze || continue
					case "$choice" in
						2) do_uninstall ;;
						3) set_date_time ;;
						4) set_nicknames ;;
						5) set_colors ;;
						6) set_options ;;
					esac
					break ;;
				e|E) clear; hasta; exit 0 ;;
				*) freeze2; continue ;;
			esac
		done
	done
}

check_version() {
    local mode="$1" version_cmp=""; freeze() { return 0; }
    if [ ! -f "$REPORT_SCRIPT" ]; then STATE="NOT_INSTALLED"; freeze() { freeze2; return 1; }
    elif [ -z "$REMOTE_VERSION" ]; then STATE="OFFLINE"
    else
        version_cmp=$(version_compare "$SCRIPT_VERSION" "$REMOTE_VERSION")
        case "$version_cmp" in -1|0|1) ;; *) version_cmp=0 ;; esac
        if [ "$version_cmp" -gt 0 ]; then  STATE="UP_TO_DATE"
        elif [ "$version_cmp" -lt 0 ]; then STATE="OUTDATED"
        elif [ -n "$REMOTE_HASH" ] && [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then  STATE="HASH_DIFF"
        else STATE="UP_TO_DATE"; fi
    fi
    case "$mode" in
        header_box)
            case "$STATE" in
                OUTDATED)      HOVER_TEXT="Current v$SCRIPT_VERSION <br> New Version v$REMOTE_VERSION available"
                               VERSION_HASH=" [$REMOTE_VERSION]"; HEADER_TITLE="header-title2" ;;
                HASH_DIFF)     HOVER_TEXT="Current v$SCRIPT_VERSION <br> Hash Update available"
                               VERSION_HASH=" [Hash]"; HEADER_TITLE="header-title2" ;;
                UP_TO_DATE|*)  HOVER_TEXT="Current v$SCRIPT_VERSION"
                               VERSION_HASH=""; HEADER_TITLE="header-title" ;;
            esac ;;
        do_install)
            case "$STATE" in
                OUTDATED)      echo -e "\n${GR}[i] A new version (${NC}v$REMOTE_VERSION${GR}) is available!${NC}\n"
                               UP="update version?" ;;
                HASH_DIFF)     echo -e "\n${GR}[i] There is a Hash Update for (${NC}v$SCRIPT_VERSION${GR}).${NC}\n"
                               UP="update Hash?" ;;
                UP_TO_DATE|*)  echo -e "\n${GR}[i] You are already on the latest version (${NC}v$SCRIPT_VERSION${GR}).${NC}\n"
                               UP="reinstall/overwrite anyway?";;
            esac ;;
        *)
            case "$STATE" in
                OFFLINE)       echo -e "$STATUS ${RD}[Offline]${NC} Could not reach GitHub" ;;
                NOT_INSTALLED) echo -e "$STATUS ${RD}[Not Installed]${NC} Latest Available: ${GR}v$REMOTE_VERSION${NC}"; N1="${BL}(1)" ;;
                OUTDATED)      echo -e "$STATUS [v$REMOTE_VERSION Available] $CURRENT" ;;
                HASH_DIFF)     echo -e "$STATUS [Hash Update Available] $CURRENT" ;;
                UP_TO_DATE|*)  echo -e "$STATUS [Up to date] $CURRENT" ;;
            esac ;;
    esac
}

version_compare() {
    awk -v left="$1" -v right="$2" '
        function num(part) { return (part ~ /^[0-9]+$/) ? part + 0 : 0 }
        BEGIN {
            lc = split(left, L, "."); rc = split(right, R, ".")
            max = (lc > rc) ? lc : rc
            for (i = 1; i <= max; i++) {
                lv = (i <= lc) ? num(L[i]) : 0
                rv = (i <= rc) ? num(R[i]) : 0
                if (lv < rv) { print -1; exit }
                if (lv > rv) { print 1; exit }
            }
            print 0
        }'
}

menu_vars() {
    if [ -f "$CONFIG" ]; then . "$CONFIG"; fi
    freeze2() { printf "\033[2A\033[J"; }; freeze3() { printf "\033[3A\033[J"; }
	trap 'printf "\033[0m"' 0; trap 'exit 130' INT TERM HUP
    UL='\033[4m'; WH='\e[1;37m'; YL='\033[0;33m'; NC='\033[0m'
    BL='\033[38;5;39m'; GR='\033[0;32m'; RD='\033[0;31m'
    JB1366="${GR}${UL}https://github.com/JB1366/Wireless_Report${NC}"
	N0="${BL}(0)${NC}"; N1="${BL}(1)${NC}"; N2="${BL}(2)${NC}"; N3="${BL}(3)${NC}"; N4="${BL}(4)${NC}"
	N5="${BL}(5)${NC}"; N6="${BL}(6)${NC}"; N7="${BL}(7)${NC}"; N8="${BL}(8)${NC}"; echo -e "${BL}"
	NE="${BL}(e)${NC}"; NQ="${BL}(c)${NC}"; ON="${GR}ON${NC}"; OFF="${RD}OFF${NC}"
    : "${MAIN_COLOR:=#0096ff}"
    : "${NODE_COLORS:=#30d158 #bf40bf #ffd60a #64d2ff #ff9500 #ff453a #ffffff #ff70a6 #64ffda}"
	STATUS=" ${BL}STATUS:${NC}"; CURRENT="${GR}Current: v$SCRIPT_VERSION${NC}"
    SS_FILE="/jffs/scripts/services-start"
    DU="${REPORT_UNIT:-USA}"; DATE_USA="${GR}$(date +"%b-%-d %-H:%M:%S")${NC}"
    DATE_INTL="${GR}$(date +"%-d-%b %-H:%M:%S")${NC}"; DATE_ISO="${GR}$(date +"%Y-%m-%d %H:%M:%S")${NC}"
    if [ "$REPORT_UNIT" = "ISO" ]; then DU="${GR}ISO${NC}"; CT="$DATE_ISO"
    elif [ "$REPORT_UNIT" = "INTL" ]; then DU="${GR}INTL${NC}"; CT="$DATE_INTL"
    else DU="${GR}USA${NC}"; CT="$DATE_USA"; fi
    RTIME=${RTIME:-1}; if [ "$RTIME" = "0" ]; then RT_STAT="$OFF"; else RT_STAT="$ON"; fi
    PULSE_MINS=${PULSE_MINS:-15}
    if [ "$PULSE_MINS" = "0" ]; then UP_STAT="$OFF"; else UP_STAT="${GR}${PULSE_MINS} Mins${NC}"; fi
    RS_HIST=${RS_HIST:-0}; case "$RS_HIST" in 0|1) ;; *) RS_HIST=0 ;; esac
    RS_HIST_ENTRIES=${RS_HIST_ENTRIES:-5}
    case "$RS_HIST_ENTRIES" in ""|*[!0-9]*) RS_HIST_ENTRIES=5 ;; esac
    if [ "$RS_HIST_ENTRIES" -lt 5 ] || [ "$RS_HIST_ENTRIES" -gt 20 ]; then RS_HIST_ENTRIES=5; fi
    RS_HIST_DATE=${RS_HIST_DATE:-0}; case "$RS_HIST_DATE" in 0|1) ;; *) RS_HIST_DATE=0 ;; esac
    CUR_RS_HIST=${CUR_RS_HIST:-$RS_HIST}
	CUR_ENTRIES=${CUR_ENTRIES:-$RS_HIST_ENTRIES}
	CUR_DATE=${CUR_DATE:-$RS_HIST_DATE}; CE="${GR}$CUR_ENTRIES${NC}"
    if [ "$RS_HIST" = "1" ]; then RH_STAT="$ON"; else RH_STAT="$OFF"; fi
	if [ "$CUR_RS_HIST" = "1" ]; then CH="$ON"; else CH="$OFF"; fi
	if [ "$CUR_DATE" = "1" ]; then TS="$ON"; else TS="$OFF"; fi
    THEME=${THEME:-ORIGINAL}; TM_STAT="${GR}$THEME${NC}"
	IPPAD=${IPPAD:-1}
	if [ "$IPPAD" = "2" ]; then PD_STAT="${GR}Last 2 Octets${NC}"
	elif [ "$IPPAD" = "1" ]; then PD_STAT="${BL}Last Octet${NC}"
	else PD_STAT="${RD}Disabled${NC}"; fi
	HOST_COLOR=${HOST_COLOR:-0}
	if [ "$HOST_COLOR" = "1" ]; then HN_STAT="${BL}Colored${NC}"
	else HN_STAT="${GR}Numbered${NC}"; fi
}

do_install() {
	mkdir -p "$INSTALL_DIR" 2>/dev/null
    if [ ! -f "$CONFIG" ]; then touch "$CONFIG"; fi
	local is_update=0
	if [ -f "$REPORT_SCRIPT" ]; then is_update=1; fi
	if [ "$is_update" = "1" ]; then
        while true; do
            check_version do_install
            printf "Do you want to $UP (y/n): "; read -r update
            case "$update" in [yY]) break ;; [nN]) return ;; *) printf "\033[4A\033[J" ;; esac; done
    fi
    do_update || return 1
    echo -e "\n${GR}[+] Downloading latest version (${NC}v$REMOTE_VERSION${GR})${NC}"
	if [ "$is_update" = "1" ]; then
		echo -e "\n${BL}[✓] Wireless Report successfully installed.${NC}"
		printf "\nPress ${BL}[Enter]${NC} to apply changes & restart script..."; read -r discard
        logger -p user.info -t "Wireless_Report" "(v$REMOTE_VERSION) successfully installed."
        exec "$REPORT_SCRIPT" install "$@"
		echo -e "${RD}Error: Failed to restart script!${NC}" >&2
		exit 1
	fi
    if [ "$(nvram get jffs2_scripts)" != "1" ]; then
        echo -e "${RD}[!] ERROR: JFFS custom scripts not enabled.${NC}"
        pause; return 1
    fi
    echo -e "\n${GR}[+] Processing Wireless Report Files...${NC}\n"
    echo -e "${GR}[+] Mounting Menu [Wireless] Tab [Wireless Report]${NC}\n"
    if [ ! -f "$SS_FILE" ]; then echo "#!/bin/sh" > "$SS_FILE"; fi
    sed -i "\|$REPORT_SCRIPT|d" "$SS_FILE" 2>/dev/null
    echo "$REPORT_SCRIPT inject & # Inject Wireless Report" >> "$SS_FILE"
    chmod +x "$SS_FILE"
    install=""; SCRIPT_VERSION="$REMOTE_VERSION"
    logger -p user.info -t "Wireless_Report" "(v$SCRIPT_VERSION) successfully installed."
    echo -e "${GR}[✓] SUCCESS: Installation complete!${NC}\n"
    echo -e "${YL}[i] To access Report, navigate to Advanced Settings > Wireless "
    echo -e "${YL}    in the ASUS WebGUI and select the Wireless Report tab on the far right.${NC}\n"
    pause
}

do_update() {
    TEMP_SCRIPT="/tmp/wirelessreport.sh"
    if curl -sfL --retry 3 "$GITHUB" -o "$TEMP_SCRIPT" && [ -s "$TEMP_SCRIPT" ]; then
        mv "$TEMP_SCRIPT" "$REPORT_SCRIPT"
        chmod +x "$REPORT_SCRIPT" 2>/dev/null
        inject_menu

        # the following 3-lines get deleted after a couple weeks, only for transition.
        SE_FILE="/jffs/scripts/service-event"; sed -i "/wireless_report/d" "$SE_FILE"
        get_usb
        case "$USB_PATH" in *wirelessreport*) rm -rf "$USB_PATH" 2>/dev/null ;; esac

        return 0
    else
        rm -f "$TEMP_SCRIPT"
        if [ ! -f "$0" ]; then
            echo -e "${RD}[!] Download failed. Aborting installation.${NC}"
            return 1
        fi
        local CURRENT_PATH; local TARGET_PATH
        CURRENT_PATH=$(readlink -f "$0" 2>/dev/null)
        [ -z "$CURRENT_PATH" ] && CURRENT_PATH="$0"
        TARGET_PATH=$(readlink -f "$REPORT_SCRIPT" 2>/dev/null)
        [ -z "$TARGET_PATH" ] && TARGET_PATH="$REPORT_SCRIPT"
        if [ "$CURRENT_PATH" != "$TARGET_PATH" ]; then
            echo -e "\n${YL}[!] GitHub unreachable. Installing current local copy...${NC}\n"
            cp "$0" "$REPORT_SCRIPT"
            chmod +x "$REPORT_SCRIPT" 2>/dev/null
            return 0
        else
            echo -e "${RD}[!] GitHub unreachable and script is already in place.${NC}"
            return 1
        fi
    fi
}

ScriptUpdateFromAMTM() {
    doScriptUpdateFromAMTM=true
    if [ "$doScriptUpdateFromAMTM" != "true" ]; then
        printf "Automatic updates via AMTM are currently disabled."
        return 1
    fi
    if [ "$1" = "check" ]; then return 0; fi
	check_github
    if do_update; then
        echo -e "  [+] Downloading latest version (v$REMOTE_VERSION)\n\n"
        echo -e "  [✓] Wireless Report successfully updated.\n"
		logger -p user.info -t "Wireless_Report" "AMTM Update: (v$REMOTE_VERSION) successfully installed."
		return 0
    else
        return 1
    fi
}

wr_sha256() {
    local file="$1" hash=""
    [ -f "$file" ] || return 1
    if command -v sha256sum >/dev/null 2>&1; then
        hash=$(sha256sum "$file" 2>/dev/null | awk '{print $1}')
    elif command -v busybox >/dev/null 2>&1 && busybox sha256sum "$file" >/dev/null 2>&1; then
        hash=$(busybox sha256sum "$file" 2>/dev/null | awk '{print $1}')
    elif command -v openssl >/dev/null 2>&1; then
        hash=$(openssl dgst -sha256 "$file" 2>/dev/null | awk '{print $NF}')
    fi
    [ "${#hash}" -eq 64 ] || return 1
    printf '%s\n' "$hash"
}

check_github() {
    GITHUB="https://raw.githubusercontent.com/JB1366/Wireless_Report/main/wirelessreport.sh"
    REMOTE_TMP="/tmp/wr_remote.tmp"
    LOCAL_HASH=""; REMOTE_HASH=""
    if curl -sfL --retry 3 "$GITHUB" -o "$REMOTE_TMP" 2>/dev/null && [ -s "$REMOTE_TMP" ]; then
        REMOTE_VERSION=$(grep "SCRIPT_VERSION=" "$REMOTE_TMP" | head -n 1 | cut -d'"' -f2 | tr -cd '0-9.')
        LOCAL_HASH=$(wr_sha256 "$REPORT_SCRIPT" 2>/dev/null)
        REMOTE_HASH=$(wr_sha256 "$REMOTE_TMP" 2>/dev/null)
        if [ -z "$LOCAL_HASH" ] || [ -z "$REMOTE_HASH" ]; then
            if [ -f "$REPORT_SCRIPT" ]; then
                if cmp -s "$REPORT_SCRIPT" "$REMOTE_TMP"; then
                    LOCAL_HASH="same"
                    REMOTE_HASH="same"
                else
                    LOCAL_HASH="local"
                    REMOTE_HASH="remote"
                fi
            fi
        fi
    else
        REMOTE_VERSION=""; REMOTE_HASH=""
    fi
    rm -f "$REMOTE_TMP"
}
# this function gets deleted after a couple weeks, only for transition.
get_usb() {
	if [ -n "$USB_PATH" ]; then return; fi
	read -r uptime_val _ < /proc/uptime
	local BUP="${uptime_val%%.*}"
    local mount
    local FOUND=0
    local attempt=0
    while [ "$attempt" -lt 2 ]; do
        for mount in /tmp/mnt/*; do
            [ -d "$mount" ] || continue
            if [ -d "$mount/wirelessreport" ]; then
                USB_PATH="$mount/wirelessreport"
                FOUND=1
                break 2
            fi
        done
        attempt=$((attempt + 1))
        if [ "$FOUND" -eq 0 ] && [ "$BUP" -lt 300 ] && [ "$attempt" -eq 1 ]; then sleep 2
        else break; fi
    done
    if [ "$FOUND" -eq 1 ] && [ -d "$INSTALL_DIR/data" ] && [ ! -L "$INSTALL_DIR/data" ]; then
        [ -n "$(ls -A "$INSTALL_DIR/data")" ] && cp -a "$INSTALL_DIR/data/." "$USB_PATH/"
        rm -rf "$INSTALL_DIR/data"
    fi
    if [ "$FOUND" -eq 0 ]; then
        local ROOT_PATH
        ROOT_PATH=$(ls -d /tmp/mnt/*/ 2>/dev/null | grep -v "defaults" | head -n 1 | sed 's/\/$//')
        if [ -n "$ROOT_PATH" ]; then
            USB_PATH="$ROOT_PATH/wirelessreport"
        else
            USB_PATH="$INSTALL_DIR/data"
        fi
    fi
}

mesh_init() {
	VALID_NODES=""
	local ASUS_DEVICE_LIST MAIN_IP
	MAIN_IP=$(nvram get lan_ipaddr)
	ASUS_DEVICE_LIST=$(nvram get asus_device_list)
	MESH_NODES=$(printf '%s\n' "$ASUS_DEVICE_LIST" | sed 's/</\n/g' | \
		awk -F '>' -v main_ip="$MAIN_IP" '
			NF >= 4 && $2 != "" && $3 != "" && $3 != main_ip && $NF == "2" && !seen[$3]++ {
				print $2 "|" $3
			}
		' | sort -t . -k 4,4n)
}

inject_menu() {
	source /usr/sbin/helper.sh
	TAB_LABEL="Wireless Report"
	if [ -f "$CONFIG" ]; then sed -i '/^INSTALLED_PAGE=/d' "$CONFIG"; else touch "$CONFIG"; fi
    if ! nvram get rc_support | grep -q am_addons; then echo -e "\n${RD}[!] ERROR: This firmware does not support addons!${NC}"; exit 5; fi
    if [ ! -f "$WEB_PAGE" ]; then echo "<html><body>$TAB_LABEL Loading...</body></html>" > "$WEB_PAGE"; fi
	LOCKFILE=/tmp/addonwebui.lock; FD=386; eval exec "$FD>$LOCKFILE"; flock -x "$FD"
    am_get_webui_page "$WEB_PAGE"
	if [ "$am_webui_page" = "none" ]; then echo -e "\n${RD}[!] ERROR: Unable to install $TAB_LABEL.${NC}"; flock -u "$FD"; exit 5; fi
	cp "$WEB_PAGE" "/www/user/$am_webui_page" 2>/dev/null
	echo "INSTALLED_PAGE=$am_webui_page" >> "$CONFIG"
	if [ ! -f "$TEMP_MENU" ]; then cp "$SYSTEM_MENU" /tmp/; mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"; fi
	sed -i 'N; /menuName: "Wireless Report"/ { N; N; N; N; N; N; d; }; P; D' "$TEMP_MENU" 2>/dev/null
	sed -i '/tabName:[[:space:]]*"Wireless Report"/d' "$TEMP_MENU" 2>/dev/null
	if [ "$INJECT" = "2" ]; then
		INSERT_DATA="{\
		\nmenuName: \"$TAB_LABEL\",\
		\nindex: \"menu_AiMesh\",\
		\ntab: [\
		\n{url: \"$am_webui_page\", tabName: \"$TAB_LABEL\"},\
		\n{url: \"NULL\", tabName: \"__INHERIT__\"}\
		\n]\
		\n},"
		sed -i "/^.*{[[:space:]]*$/ { N; /menuName: \"<#1558#>\",/ i $INSERT_DATA
		}" "$TEMP_MENU"
		logger -p user.info -t "Wireless_Report" "Mounting Menu [$TAB_LABEL] as $am_webui_page"
	else
		sed -i "/index: \"menu_Wireless\"/,/{url: \"NULL\", tabName: \"__INHERIT__\"}/ s|{url: \"NULL\", tabName: \"__INHERIT__\"}|{url: \"$am_webui_page\", tabName: \"$TAB_LABEL\"},\n&|" "$TEMP_MENU"
		logger -p user.info -t "Wireless_Report" "Mounting Menu [Wireless] TAB [$TAB_LABEL] as $am_webui_page"
	fi
	umount "$SYSTEM_MENU" && mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"
	umount "/www/user/$am_webui_page" 2>/dev/null
	mount -o bind "$WEB_PAGE" "/www/user/$am_webui_page"
	flock -u "$FD"; restart_httpd
    if [ "$NOLOADSCRIPT" = "1" ]; then exit 0
    else "$REPORT_SCRIPT" & fi
}

do_uninstall() {
    echo -e "\n${RD}[!] WARNING: Removing Wireless Report...${NC}\n"
    while true; do
        printf "Are you sure? (y/n): "; read -r confirm
        case "$confirm" in [yY]) break ;; [nN]) return ;; *) printf "\033[1A\033[J" ;; esac; done
	if [ -f "$CONFIG" ]; then . "$CONFIG"; fi
	if mount | grep -q "menuTree.js"; then
		umount -l "$SYSTEM_MENU" >/dev/null 2>&1
		sed -i 'N; /menuName: "Wireless Report"/ { N; N; N; N; N; N; d; }; P; D' "$TEMP_MENU" 2>/dev/null
		sed -i '/tabName:[[:space:]]*"Wireless Report"/d' "$TEMP_MENU" 2>/dev/null
		mount --bind "$TEMP_MENU" "$SYSTEM_MENU"
		logger -p user.info -t "Wireless_Report" "Unmounting Wireless Report Tab."
		echo -e "\n${BL}[*] Removing Wireless Report Tab and restoring defaults...${NC}\n"
	fi
	if [ -n "$INSTALLED_PAGE" ]; then
		umount -l "/www/user/$INSTALLED_PAGE" >/dev/null 2>&1
		rm -f /www/user/"${INSTALLED_PAGE}" >/dev/null 2>&1
	fi
	sed -i "\|$REPORT_SCRIPT|d" "$SS_FILE"
	restart_httpd
    nvram unset wirelessreport_gen >/dev/null 2>&1
	sed -i "\|$REPORT_SCRIPT|d" "$SS_FILE"

    # the following 3-lines get deleted after a couple weeks, only for transition.
	get_usb; SE_FILE="/jffs/scripts/service-event"
    sed -i "/wireless_report/d" "$SE_FILE"
    case "$USB_PATH" in *wirelessreport*) rm -rf "$USB_PATH" 2>/dev/null ;; esac

    restart_httpd
	rm -rf "$INSTALL_DIR" "$WEB_PAGE" 2>/dev/null
	logger -p user.info -t "Wireless_Report" "(v$SCRIPT_VERSION) successfully uninstalled."
    unset RTIME CUR_DATE RS_HIST_DATE RS_HIST CUR_RS_HIST CUR_ENTRIES REPORT_UNIT
    unset THEME IPPAD PULSE_MINS DISPLAY_UNIT HOST_COLOR MAIN_COLOR NODE_COLORS
	echo -e "${GR}[+] Success: Wireless Report uninstalled.${NC}\n"
	pause
}

set_date_time() {
    while true; do
        show_header
        echo -e "${BL}=================================================="
        echo -e "${NC}                  Set Date/Time                   "
        echo -e "${BL}=================================================="
        echo -e "${NC}  Format: $DU         Current: $CT                "
        echo -e "${BL}=================================================="
        echo -e "                                                       "
        echo -e "  $N1  USA                   ($DATE_USA)               "
        echo -e "  $N2  INTERNATIONAL         ($DATE_INTL)              "
        echo -e "  $N3  ISO                   ($DATE_ISO)               "
        echo -e "                                                       "
        echo -e "  $NE  Exit back to main menu                          "
        echo -e "                                                       "
		echo -e "${BL}=================================================="
        while true; do
            printf "\n ${NC}Selection: ${BL}"; read -r t_choice
            case "$t_choice" in
                1) NEW_UNIT="USA" ;;
                2) NEW_UNIT="INTL" ;;
                3) NEW_UNIT="ISO" ;;
                e|E) return ;;
                *) freeze2; continue ;;
            esac
            sed -i '/REPORT_UNIT=/d' "$CONFIG"
            echo "REPORT_UNIT=\"$NEW_UNIT\"" >> "$CONFIG"
            REPORT_UNIT="$NEW_UNIT"
            break
        done
        run_report
    done
}

set_nicknames() {
    while true; do
        show_header
        echo -e "${BL}=================================================="
        echo -e "${NC}               Set Device Nicknames               "
        echo -e "${BL}=================================================="
        echo -e "                                                       "
		echo -e "  $N1 Defaults Nicknames                               "
		echo -e "  $N2 Location Nicknames                               "
		echo -e "  $N3 Manual Nicknames                                 "
		echo -e "                                                       "
        echo -e "  $NE Exit back to main menu                           "
		echo -e "                                                       "
        echo -e "${BL}=================================================="
        MAIN_ROUTER=$(nvram get productid); MAIN_IP=$(nvram get lan_ipaddr)
        MAIN_CLR=$(hex_to_ansi "$MAIN_COLOR")
        echo -e "\n  ${MAIN_CLR}Main $MAIN_IP -> ${MAIN_NICK:-$MAIN_ROUTER}${NC}"
        if [ -n "$MESH_NODES" ] && [ "$MESH_NODES" != " " ]; then
            VALID_NODES=$(echo "$MESH_NODES" | tr ' ' '\n' | grep '|')
            get_node_color() { local idx="$1"; echo "$NODE_COLORS" | awk -v i="$idx" '{print $i}'; }
            node_idx=1
            for node in $VALID_NODES; do
                MODEL=$(echo "$node" | cut -d'|' -f1)
                IP=$(echo "$node" | cut -d'|' -f2)
                CLEAN_IP=$(echo "$IP" | tr '.' '_')
                eval SAVED_NICK=\$NODE_NICK_$CLEAN_IP
                HEX_CLR=$(get_node_color "$node_idx")
                NODE_CLR=$(hex_to_ansi "$HEX_CLR")
                echo -e "  ${NODE_CLR}Node $IP -> ${SAVED_NICK:-$MODEL}${NC}"
                node_idx=$((node_idx + 1))
            done
        fi
        echo -e "\n${BL}=================================================="
        while true; do
            printf "\n ${NC}Selection: ${BL}"; read -r input_main
            case "$input_main" in
                1)
                    echo -e "\n${BL}[+] Resetting to hardware defaults...${NC}\n"
                    OLD_NAME="${MAIN_NICK:-$MAIN_ROUTER}"
                    sed -i '/^MAIN_NICK=/d' "$CONFIG"
                    unset MAIN_NICK
                    echo -e "    ${MAIN_CLR}$OLD_NAME -> $MAIN_ROUTER${NC}"; sleep 1
                    if [ -n "$MESH_NODES" ] && [ "$MESH_NODES" != " " ]; then
                        node_idx=1
                        for node in $VALID_NODES; do
                            MODEL="${node%%|*}"; IP="${node#*|}"
                            CLEAN_IP="${IP//./_}"
                            eval OLD_NICK=\$NODE_NICK_$CLEAN_IP
                            sed -i "/^NODE_NICK_$CLEAN_IP=/d" "$CONFIG"
                            eval "unset NODE_NICK_$CLEAN_IP"
                            HEX_CLR=$(echo "$NODE_COLORS" | awk -v i="$node_idx" '{print $i}')
                            NODE_CLR=$(hex_to_ansi "$HEX_CLR")
                            echo -e "    ${NODE_CLR}${OLD_NICK:-$MODEL} -> $MODEL${NC}"; sleep 1
                            node_idx=$((node_idx + 1))
                        done
                    fi
                    echo -e "\n${GR}[+] Default hardware models restored.${NC}"
                    pause; break ;;
                2)
                    echo -e "\n${BL}[*] Updating nicknames with Locations...${NC}\n"
                    OLD_NAME="${MAIN_NICK:-$MAIN_ROUTER}"
                    NEW_LOC=$(nvram get cfg_alias)
                    sed -i '/^MAIN_NICK=/d' "$CONFIG"
                    if [ -n "$NEW_LOC" ]; then
                        echo "MAIN_NICK=\"$NEW_LOC\"" >> "$CONFIG"
                        echo -e "    ${MAIN_CLR}$OLD_NAME -> $NEW_LOC${NC}"; sleep 1
                    else
                        unset MAIN_NICK
                        echo -e "    ${MAIN_CLR}$OLD_NAME -> $MAIN_ROUTER (Default)${NC}"; sleep 1
                    fi
                    node_idx=1
                    for node in $VALID_NODES; do
                        MODEL="${node%%|*}"; IP="${node#*|}"
                        CLEAN_IP="${IP//./_}"
                        eval OLD_NICK=\$NODE_NICK_$CLEAN_IP
                        NODE_LOC=$(cat /jffs/.sys/cfg_mnt/re.info 2>/dev/null | sed 's/},/}\n/g' | grep "$IP" | sed -n 's/.*"alias":"\([^"]*\)".*/\1/p')
                        sed -i "/^NODE_NICK_$CLEAN_IP=/d" "$CONFIG"
                        HEX_CLR=$(echo "$NODE_COLORS" | awk -v i="$node_idx" '{print $i}')
                        NODE_CLR=$(hex_to_ansi "$HEX_CLR")
                        if [ -n "$NODE_LOC" ]; then
                            echo "NODE_NICK_$CLEAN_IP=\"$NODE_LOC\"" >> "$CONFIG"
                            echo -e "    ${NODE_CLR}${OLD_NICK:-$MODEL} -> $NODE_LOC${NC}"; sleep 1
                        else
                            eval "unset NODE_NICK_$CLEAN_IP"
                            echo -e "    ${NODE_CLR}${OLD_NICK:-$MODEL} -> $MODEL (Default)${NC}"; sleep 1
                        fi
                        node_idx=$((node_idx + 1))
                    done
                    echo -e "\n${GR}[+] Nicknames updated to Locations...${NC}"
                    pause; break ;;
                3)
                    echo -e "\n${BL}[*] Manual Entry Mode${NC}\n"
                    OLD_MAIN="${MAIN_NICK:-$MAIN_ROUTER}"
                    printf "  ${MAIN_CLR}Main $MAIN_IP [$OLD_MAIN]:${NC} "; read -r manual_main
                    if [ -n "$manual_main" ]; then
                        manual_main="${manual_main:0:25}"
                        sed -i '/^MAIN_NICK=/d' "$CONFIG"
                        echo "MAIN_NICK=\"$manual_main\"" >> "$CONFIG"
                    fi
                    node_idx=1
                    for node in $VALID_NODES; do
                        MODEL="${node%%|*}"; IP="${node#*|}"
                        CLEAN_IP="${IP//./_}"
                        eval OLD_NICK=\$NODE_NICK_$CLEAN_IP
                        HEX_CLR=$(echo "$NODE_COLORS" | awk -v i="$node_idx" '{print $i}')
                        NODE_CLR=$(hex_to_ansi "$HEX_CLR")
                        printf "  ${NODE_CLR}Node $IP [${OLD_NICK:-$MODEL}]:${NC} "; read -r input_node
                        if [ -n "$input_node" ]; then
                            input_node="${input_node:0:25}"
                            sed -i "/^NODE_NICK_$CLEAN_IP=/d" "$CONFIG"
                            echo "NODE_NICK_$CLEAN_IP=\"$input_node\"" >> "$CONFIG"
                        fi
                        node_idx=$((node_idx + 1))
                    done
                    echo -e "\n${GR}[+] Manual nicknames saved (max 25 chars).${NC}"
                    pause; break ;;
                e|E)
                    return ;;
                *)
                    freeze2; continue ;;
            esac
        done
        run_report
    done
}

hex_to_ansi() {
    NB='\033[38;5;39m'; LG='\033[38;5;82m'; MP='\033[38;5;133m'; RD='\033[38;5;196m'; PK='\033[38;5;211m'
    YW='\033[38;5;226m'; SB='\033[38;5;75m'; OR='\033[38;5;208m'; WT='\033[38;5;231m'; MT='\033[38;5;86m'
    case "$1" in
        "#0096ff") echo -e "$NB" ;;
        "#30d158") echo -e "$LG" ;;
        "#bf40bf") echo -e "$MP" ;;
        "#ffd60a") echo -e "$YW" ;;
        "#64d2ff") echo -e "$SB" ;;
        "#ff9500") echo -e "$OR" ;;
        "#ff453a") echo -e "$RD" ;;
        "#ffffff") echo -e "$WT" ;;
        "#ff70a6") echo -e "$PK" ;;
        "#64ffda") echo -e "$MT" ;;
        *)         echo -e "$NC" ;;
    esac
}

get_node_nick() {
    local node_ip="$1" key
    key="NODE_NICK_$(printf '%s' "$node_ip" | tr '.' '_')"
    [ -f "$CONFIG" ] || return 0
    awk -v key="$key" '
        index($0, key "=\"") == 1 {
            value = substr($0, length(key) + 3)
            sub(/\"$/, "", value)
            print value
            exit
        }
    ' "$CONFIG" 2>/dev/null
}

set_colors() {
    local main_name=$(nvram get productid); local main_ip=$(nvram get lan_ipaddr)
    local m_color_hex="" current_colors=""
    if [ -f "$CONFIG" ]; then
        m_color_hex=$(grep "^MAIN_COLOR=" "$CONFIG" | cut -d'"' -f2)
        current_colors=$(grep "^NODE_COLORS=" "$CONFIG" | cut -d'"' -f2)
    fi
    [ -z "$m_color_hex" ] && m_color_hex="$MAIN_COLOR"
    [ -z "$current_colors" ] && current_colors="$NODE_COLORS"
    local total_nodes=0
    for node in $MESH_NODES; do total_nodes=$((total_nodes + 1)); done
    local working_colors="" i=1
    while [ $i -le $total_nodes ]; do
        local c_color=$(echo "$current_colors" | awk -v col="$i" '{print $col}')
        working_colors="${working_colors:+$working_colors }$c_color"
        i=$((i + 1))
    done
    while true; do
        show_header
        echo -e "${BL}=================================================="
        echo -e "${NC}                Set Device Colors                 "
        echo -e "${BL}=================================================="
        echo -e "${NC}\n Current Device Configuration:\n"
        local main_display_name="${MAIN_NICK:-$main_name}"
        local main_display_color=$(hex_to_ansi "$m_color_hex")
        local formatted_main_ip=$(printf "(%s)" "$main_ip")
        printf "  ${BL}(0) %b%-14s %-16s (Main)${NC}\n" \
            "$main_display_color" "$main_display_name" "$formatted_main_ip"
        local idx=1
        for node in $MESH_NODES; do
            local node_ip="${node#*|}"
            local default_nick="${node%%|*}"
            local active_color=$(echo "$working_colors" | awk -v col="$idx" '{print $col}')
            local node_display_name=$(get_node_nick "$node_ip")
            node_display_name="${node_display_name:-$default_nick}"
            local display_color=$(hex_to_ansi "$active_color")
            local formatted_ip=$(printf "(%s)" "$node_ip")
            printf "  ${BL}(%s) %b%-14s %-16s (Node)${NC}\n" \
                "$idx" "$display_color" "$node_display_name" "$formatted_ip"
            idx=$((idx + 1))
        done
        echo -e "\n  $NQ Cancel and Discard Changes"
        echo -e "  $NE Exit and Save Changes"
        echo -e "\n${BL}==============================================${NC}"
        while true; do
            printf "\n ${NC}Select a Device number to change color ${BL}(0-$total_nodes): "; read -r node_choice
            case "$node_choice" in c|C) return 0 ;; e|E) break 2 ;; esac
            if ! [ "$node_choice" -ge 0 ] 2>/dev/null || ! [ "$node_choice" -le "$total_nodes" ] 2>/dev/null; then
                freeze2; continue
            fi
            local target_name="" target_hex=""
            if [ "$node_choice" -eq 0 ]; then
                target_name="${MAIN_NICK:-$main_name}"
                target_hex="$m_color_hex"
            else
                local target_node=$(printf '%s\n' "$MESH_NODES" | awk -v n="$node_choice" 'NR == n { print; exit }')
                local target_ip=$(printf '%s\n' "$target_node" | cut -d'|' -f2)
                target_name=$(get_node_nick "$target_ip")
                target_name="${target_name:-$(printf '%s\n' "$target_node" | cut -d'|' -f1)}"
                target_hex=$(echo "$working_colors" | awk -v col="$node_choice" '{print $col}')
            fi
            local target_prompt_color=$(hex_to_ansi "$target_hex")
            echo -e "\n ${NC}Select a new color for ${target_prompt_color}[${target_name}]${NC}:\n"
            echo -e "${NB}  (1) Neon-Blue (#0096ff)"
            echo -e "${LG}  (2) Lime-Green (#30d158)"
            echo -e "${MP}  (3) Medium-Purple (#bf40bf)"
            echo -e "${YW}  (4) Yellow (#ffd60a)"
            echo -e "${SB}  (5) SkyBlue (#64d2ff)"
            echo -e "${OR}  (6) Orange (#ff9500)"
            echo -e "${RD}  (7) Red (#ff453a)"
            echo -e "${WT}  (8) White (#ffffff)"
            echo -e "${PK}  (9) Light-Pink (#ff70a6)"
            echo -e "${MT} (10) Mint-Green (#64ffda)"
            echo -e "${NC}"
            local selected_hex=""
            while true; do
                printf "${NC} Choose option ${BL}(1-10): "; read -r color_choice
                case "$color_choice" in
                    1) selected_hex="#0096ff"; break ;;
                    2) selected_hex="#30d158"; break ;;
                    3) selected_hex="#bf40bf"; break ;;
                    4) selected_hex="#ffd60a"; break ;;
                    5) selected_hex="#64d2ff"; break ;;
                    6) selected_hex="#ff9500"; break ;;
                    7) selected_hex="#ff453a"; break ;;
                    8) selected_hex="#ffffff"; break ;;
                    9) selected_hex="#ff70a6"; break ;;
                    10) selected_hex="#64ffda"; break ;;
                    *) printf "\033[1A\033[2K\r"; continue ;;
                esac
            done
            if [ "$node_choice" -eq 0 ]; then
                m_color_hex="$selected_hex"
            else
                local new_string="" step=1
                for hex in $working_colors; do
                    [ "$step" -eq "$node_choice" ] && hex="$selected_hex"
                    new_string="${new_string:+$new_string }$hex"
                    step=$((step + 1))
                done
                working_colors="$new_string"
            fi
            break
        done
    done
    update_config_var() {
        local var_name="$1" var_val="$2"
        if grep -q "^${var_name}=" "$CONFIG" 2>/dev/null; then
            sed -i "s|^${var_name}=.*|${var_name}=\"${var_val}\"|" "$CONFIG"
        else
            echo "${var_name}=\"${var_val}\"" >> "$CONFIG"
        fi
    }
    update_config_var "MAIN_COLOR" "$m_color_hex"
    update_config_var "NODE_COLORS" "$working_colors"
    run_report
    echo -e "\n${BL}Device colors successfully saved to CONFIG.${NC}"
    pause
}

set_options() {
    while true; do
        show_header
        echo -e "${BL}=================================================="
        echo -e "${NC}                  Set Options                     "
        echo -e "${BL}=================================================="
        echo -e "                                                       "
        echo -e "  $N1  Toggle Runtime Tracking: ($RT_STAT)             "
        echo -e "  $N2  Configure Uptime Alert Pulse: ($UP_STAT)        "
        echo -e "  $N3  Configure RSSI History: ($RH_STAT)              "
        echo -e "  $N4  Set Theme: ($TM_STAT)                           "
        echo -e "  $N5  Toggle IP Padding: ($PD_STAT)                   "
        echo -e "  $N6  Toggle Node Hostname Display: ($HN_STAT)        "
        echo -e "                                                       "
        echo -e "  $NE  Exit back to main menu                          "
        echo -e "                                                       "
        echo -e "${BL}=================================================="
        while true; do
            printf "\n ${NC}Selection: ${BL}"; read -r t_choice
            case "$t_choice" in
                1)
                    if grep -q "RTIME=" "$CONFIG"; then
                        if [ "$RTIME" = "1" ]; then sed -i 's/RTIME=.*/RTIME="0"/' "$CONFIG"
                        else sed -i 's/RTIME=.*/RTIME="1"/' "$CONFIG"; fi
                    else echo 'RTIME="0"' >> "$CONFIG"; fi
                    break ;;
                2)
                    while true; do
                        echo -e "\n (${GR}0${NC}) disable (${GR}15${NC}) def (${GR}1440${NC}) max "
                        printf " ${BL}Enter alert interval in mins:${GR} "; read -r user_mins
                        case "$user_mins" in ""|*[!0-9]*) freeze3; continue ;; esac
                        if [ "$user_mins" -le 1440 ]; then
                            if grep -q "PULSE_MINS=" "$CONFIG"; then
                                sed -i "s/PULSE_MINS=.*/PULSE_MINS=\"$user_mins\"/" "$CONFIG"
                            else
                                echo "PULSE_MINS=\"$user_mins\"" >> "$CONFIG"
                            fi
                            break 2
                        fi
                        freeze3
                    done
                    pause; break ;;
                3)
                    rssi_submenu; break ;;
                4)
                    theme_submenu; break ;;
                5)
                    if grep -q "IPPAD=" "$CONFIG"; then
                        if [ "$IPPAD" = "1" ]; then
                            echo -e "\n${RD}[-] Disabled:${NC} 192.168.050.003 --> ${RD}192.168.50.3${NC}"
                            NEW_PAD="0"; pause
                        elif [ "$IPPAD" = "0" ]; then
                            echo -e "\n${GR}[+] Mode 2:${NC} 192.168.50.3 --> ${GR}192.168.050.003${NC} (Last 2 Octets)"
                            NEW_PAD="2"; pause
                        else
                            echo -e "\n${GR}[+] Mode 1:${NC} 192.168.50.3 --> ${GR}192.168.50.003${NC} (Last Octet Only)"
                            NEW_PAD="1"; pause
                        fi
                        sed -i "s/IPPAD=.*/IPPAD=\"$NEW_PAD\"/" "$CONFIG"
                    else
                        echo -e "\n${RD}[-] Disabled:${NC} 192.168.050.003 --> ${RD}192.168.50.3${NC}"
                        echo 'IPPAD="0"' >> "$CONFIG"
                        NEW_PAD="0"; pause
                    fi
                    break ;;
                6)
                    if grep -q "HOST_COLOR=" "$CONFIG"; then
                        if [ "$HOST_COLOR" = "1" ]; then NEW_HC="0"; else NEW_HC="1"; fi
                        sed -i "s/HOST_COLOR=.*/HOST_COLOR=\"$NEW_HC\"/" "$CONFIG"
                    else
                        echo 'HOST_COLOR="1"' >> "$CONFIG"
                    fi
                    break ;;
                e|E)
                    return 0 ;;
                *)
                    freeze2; continue ;;
            esac
        done
        if [ "$RR" = "0" ]; then RR="1"; continue
        else run_report; fi
    done
}

rssi_submenu() {
    while true; do
        show_header
        echo -e "${BL}=================================================="
        echo -e "${NC}           RSSI History Configuration             "
        echo -e "${BL}=================================================="
        echo -e "                                                       "
        echo -e "  $N1 Toggle RSSI History: [$CH]                       "
        echo -e "  $N2 Set History Depth:   [$CE] entries               "
        echo -e "  $N3 Toggle Timestamps:   [$TS]                       "
        echo -e "                                                       "
        echo -e "  $NQ Cancel and Discard Changes                       "
        echo -e "  $NE Exit and Save Changes                            "
        echo -e "                                                       "
        echo -e "${BL}=================================================="
        while true; do
            printf "\n ${NC}Selection: ${BL}"; read -r sub_choice
            case "$sub_choice" in
                1)
                    if [ "$CUR_RS_HIST" = "1" ]; then CUR_RS_HIST="0"; else CUR_RS_HIST="1"; fi
                    break ;;
                2)
                    while true; do
                        printf "\n ${NC}Enter new depth (${BL}5-20${NC}) [Current: $CE]: "; read -r new_depth
                        case "$new_depth" in *[!0-9]*|"") freeze2; continue ;; esac
                        if [ "$new_depth" -ge 5 ] && [ "$new_depth" -le 20 ]; then
                            CUR_ENTRIES="$new_depth"
                            break 2
                        else
                            freeze2; continue
                        fi
                    done ;;
                3)
                    if [ "$CUR_DATE" = "1" ]; then CUR_DATE="0"; else CUR_DATE="1"; fi
                    break ;;
                c|C)
                    unset CUR_RS_HIST CUR_ENTRIES CUR_DATE
                    RR="0"; return 0 ;;
                e|E)
                    RS_HIST="$CUR_RS_HIST"
                    RS_HIST_ENTRIES="$CUR_ENTRIES"
                    RS_HIST_DATE="$CUR_DATE"
                    for var in RS_HIST RS_HIST_ENTRIES RS_HIST_DATE; do
                        eval "val=\$${var}"
                        if grep -q "^$var=" "$CONFIG"; then
                            sed -i "s|^$var=.*|$var=\"$val\"|" "$CONFIG"
                        else
                            echo "$var=\"$val\"" >> "$CONFIG"
                        fi
                    done
                    echo -e "\n${GR}[+] RSSI history configuration saved.${NC}"
                    unset CUR_RS_HIST CUR_ENTRIES CUR_DATE
                    pause; return 0 ;;
                *)
                    freeze2; continue ;;
            esac
        done
    done
}

theme_submenu() {
    while true; do
        show_header
        echo -e "${BL}=================================================="
        echo -e "${NC}  Set Theme                    Current: $TM_STAT  "
        echo -e "${BL}=================================================="
        echo -e "                                                       "
        echo -e "  $N1 Original Theme                                   "
        echo -e "  $N2 Darkmode Theme                                   "
        echo -e "  $N3 Asus WebUI Theme                                 "
        echo -e "                                                       "
        echo -e "  $NE Exit back to Set Options                         "
        echo -e "                                                       "
        echo -e "${BL}=================================================="
        while true; do
            printf "\n ${NC}Selection: ${BL}"; read -r theme_choice
            case "$theme_choice" in
                1)
                    if grep -q "^THEME=" "$CONFIG"; then sed -i "s/^THEME=.*/THEME=\"ORIGINAL\"/" "$CONFIG"
                    else echo 'THEME="ORIGINAL"' >> "$CONFIG"; fi
                    break ;;
                2)
                    if grep -q "^THEME=" "$CONFIG"; then sed -i "s/^THEME=.*/THEME=\"DARKMODE\"/" "$CONFIG"
                    else echo 'THEME="DARKMODE"' >> "$CONFIG"; fi
                    break ;;
                3)
                    if grep -q "^THEME=" "$CONFIG"; then sed -i "s/^THEME=.*/THEME=\"ASUS_WEBUI\"/" "$CONFIG"
                    else  echo 'THEME="ASUS_WEBUI"' >> "$CONFIG"; fi
                    break ;;
                e|E)
                    RR="0"; return 0 ;;
                *)
                    freeze2; continue ;;
            esac
        done
        run_report
    done
}

set_theme() {
    THEME="${THEME:-ORIGINAL}"
    case "$THEME" in
        "ASUS_WEBUI")
            RT_TOOLTIP="#3A4042"
            THEME_CSS=".top-header { background-color: #4D595D; }
            .header-box { background: #3A4042; }
            .section-header { background: #4D595D; }
            .report-column { background: #3A4042; }
            table.report_table td { background: #1c232b; } /* Table Background */
            table.report_table tfoot td { background: #3A4042; }
            table.report_table thead th { background: #3A4042; } /* Column Headers */
            table.report_table th:hover { background: #77A5C6; }
            .separator-line { border: 0; border-top: 1px solid black; }
            #refresh-option:focus { background: #3A4042; }
            .rssi-tooltip { background: #1c232b; }
            .button-auto-refresh { background: #3A4042; }
            .button-tables { background: #3A4042; }
            .button-tables.active, .button-tables.active:hover { color: white !important; } /* EXTRA */" ;;
        "DARKMODE")
            RT_TOOLTIP="#000000"
            THEME_CSS=".top-header { background: transparent !important; }
            .header-box { background: rgba(0,0,0,0.9); }
            .section-header { background: transparent !important; }
            .report-column { background: transparent !important; }
            table.report_table td { background: transparent !important; }
            table.report_table tfoot td { background: #171b1f; }
            table.report_table thead th { background: linear-gradient(to bottom, #0096ff, #0056b3); }
            table.report_table th:hover { background: #00e5ff; }
            .separator-line { border: 0; border-top: 1px solid #475a68; }
            #refresh-option:focus { background: #000; }
            .rssi-tooltip { background: #000; }
            .button-auto-refresh { background: transparent !important; }
            .button-tables { background: transparent !important; }" ;;
        "ORIGINAL"|*)
            RT_TOOLTIP="#000000"
            THEME_CSS=".top-header { background: transparent !important; }
            .header-box { background: rgba(0,0,0,0.9); }
            .section-header { background: linear-gradient(to bottom, #171b1f, #354961); }
            .report-column { background: #1c232b; }
            table.report_table td { background: #1c232b; }
            table.report_table tfoot td { background: #171b1f; }
            table.report_table thead th { background: linear-gradient(to bottom, #0096ff, #0056b3); }
            table.report_table th:hover { background: #00e5ff; }
            .separator-line { border: 0; border-top: 1px solid #475a68; }
            #refresh-option:focus { background: #000; }
            .rssi-tooltip { background: #000; }
            .button-auto-refresh { background: transparent !important; }
            .button-tables { background: transparent !important; }" ;;
    esac
    THEME_CSS=$(echo "$THEME_CSS" | sed 's/^        //')
}

hasta() {
echo -e "\n\n\n${BL}" #===========================================================================================================
echo -e "                                                                                                                        "
echo -e "                                                                                                                        "
echo -e "             ██╗  ██╗ █████╗ ███████╗████████╗ █████╗      ██╗      █████╗      ██╗   ██╗██╗███████╗████████╗ █████╗    "
echo -e "    ██╗      ██║  ██║██╔══██╗██╔════╝╚══██╔══╝██╔══██╗     ██║     ██╔══██╗     ██║   ██║██║██╔════╝╚══██╔══╝██╔══██╗   "
echo -e "             ███████║███████║███████╗   ██║   ███████║     ██║     ███████║     ██║   ██║██║███████╗   ██║   ███████║   "
echo -e "    ██║      ██╔══██║██╔══██║╚════██║   ██║   ██╔══██║     ██║     ██╔══██║     ╚██╗ ██╔╝██║╚════██║   ██║   ██╔══██║   "
echo -e "    ██║      ██║  ██║██║  ██║███████║   ██║   ██║  ██║     ███████╗██║  ██║      ╚████╔╝ ██║███████║   ██║   ██║  ██║   "
echo -e "    ██║      ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝     ╚══════╝╚═╝  ╚═╝       ╚═══╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝   "
echo -e "    ╚═╝                                                                                                                 "
echo -e "                                                                                                                        "
echo -e "${NC}\n\n\n" #===========================================================================================================
}

restart_httpd() { service restart_httpd >/dev/null 2>&1; killall -HUP httpd >/dev/null 2>&1; }

pause() { printf "\nPress ${BL}[Enter]${NC} to return..."; read -r discard; }

mesh_init; check_github; hex_to_ansi

run_report() {
#======================================#
#  Browser/API Report Page Preparation #
#======================================#
# The generated page uses the browser's
# already-authenticated primary-router WebUI session:
#   /appGet.cgi
#   /get_diag_latest_content_data.cgi   (3006/newer)
#   /get_diag_content_data.cgi          (388 legacy diagnostic fallback)
# All client/node refreshes happen in-page with same-origin fetch() calls.

if [ -f "$CONFIG" ]; then . "$CONFIG"; fi
WR_GENERATION=$(nvram get wirelessreport_gen 2>/dev/null)
case "$WR_GENERATION" in ""|*[!0-9]*) WR_GENERATION=0 ;; esac
WR_GENERATION=$((WR_GENERATION + 1))

: "${MAIN_COLOR:=#0096ff}"
: "${NODE_COLORS:=#30d158 #bf40bf #ffd60a #64d2ff #ff9500 #ff453a #ffffff #ff70a6 #64ffda}"
NODE_NICK_JS=""
if [ -f "$CONFIG" ]; then
	while IFS='=' read -r nick_key nick_value; do
		case "$nick_key" in NODE_NICK_*) ;; *) continue ;; esac
		nick_ip=${nick_key#NODE_NICK_}
		nick_ip=$(printf '%s' "$nick_ip" | tr '_' '.')
		nick_value=${nick_value#\"}; nick_value=${nick_value%\"}
		nick_value=$(printf '%s' "$nick_value" | sed "s/\\\\/\\\\\\\\/g; s/'/\\\\'/g; s#</#<\\\\/#g")
		NODE_NICK_JS="${NODE_NICK_JS}WR_CUSTOM_NODE_NAMES['${nick_ip}']='${nick_value}';"
	done < "$CONFIG"
fi
NODE_COLOR_JS=""
node_color_idx=1
for node in $MESH_NODES; do
    node_ip=${node#*|}
    node_hex=$(printf '%s\n' "$NODE_COLORS" | awk -v i="$node_color_idx" '{print $i}')
    [ -z "$node_hex" ] && node_hex="#30d158"
    case "$node_ip" in
        *[!0-9.]*|'') ;;
        *) NODE_COLOR_JS="${NODE_COLOR_JS}WR_NODE_COLOR_BY_IP['${node_ip}']='${node_hex}';" ;;
    esac
    node_color_idx=$((node_color_idx + 1))
done

IPPAD=${IPPAD:-1}; HOST_COLOR=${HOST_COLOR:-0}; PULSE_MINS=${PULSE_MINS:-15}
ROUTER=$(nvram get productid); MAIN_NAME="${MAIN_NICK:-${ROUTER:-Main Router}}"
MAIN_NAME="<span id='wr-main-name' class='router-style'>${MAIN_NAME}</span>"
MAIN_CPU="<span id='wr-main-cpu' class='stat-cool'>--</span>"
MAIN_MEMORY="<span id='wr-main-memory' class='stat-cool'>--</span>"
MAIN_DEVICE_TOTAL="<span id='wr-main-count' class='main-color'>0</span>"
MAIN_UPTIME="<span id='wr-main-uptime' class='main-color'>--</span>"
MAIN_REBOOT="<span id='wr-main-reboot' class='main-color'>--</span>"

NODE_NAMES="<span id='wr-node-names' class='router-style'>AiMesh nodes</span>"
NODE_CPU="<span id='wr-node-cpu' class='stat-cool'>--</span>"
NODE_MEMORY="<span id='wr-node-memory' class='stat-cool'>--</span>"
NODE_DEVICE_TOTAL="<span id='wr-node-count' class='stat-cool'>0</span>"
NODE_FOOTER="<span id='wr-node-diag'>Controller telemetry pending...</span>"

ALL_NAMES="<span id='wr-all-names' class='router-style'>Loading...</span>"
ALL_CPU="<span id='wr-all-cpu'>--</span>"
ALL_MEMORY="<span id='wr-all-memory'>--</span>"
ALL_DEVICES="<span id='wr-all-count' class='stat-cool'>0</span>"
ALL_FOOTER="<span id='wr-all-footer' class='main-color'>Controller telemetry pending...</span>"

GRAND_TOTAL_DEVICES="<span id='wr-grand-total' class='count-highlight'>0</span>"
UPDATED_TIME="<span class='wr-updated-time total-count'>Loading controller data...</span>"
MAIN_ROWS=""; NODE_ROWS=""; ALL_ROWS=""

RSSI_BOXES="<div class='rssi-quality-box rssi-excl'>Excellent: <span style='background:#30d158;' class='rssi-font wr-rssi-excellent'>0</span></div>
    <div class='rssi-quality-box rssi-good'>Good: <span style='background:#64d2ff;' class='rssi-font wr-rssi-good'>0</span></div>
    <div class='rssi-quality-box rssi-fair'>Fair: <span style='background:#ffd60a;' class='rssi-font wr-rssi-fair'>0</span></div>
    <div class='rssi-quality-box rssi-poor'>Poor: <span style='background:#ff453a;' class='rssi-font wr-rssi-poor'>0</span></div>"

set_theme; check_version header_box

#=================#
#  Generate HTML  #
#=================#
/usr/bin/printf '\xEF\xBB\xBF' > "$WEB_PAGE"
cat <<HTML >> "$WEB_PAGE"
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" />
<title>Wireless Report $SCRIPT_VERSION$VERSION_HASH</title>
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
<script src="/validator.js"></script>
<style>
	#wifiReportContainer { color: #f2f2f7; font-size: 12px; font-family: Arial, sans-serif; width: 97% !important; margin: 0 !important; padding: 0 !important; position: relative; cursor: pointer !important; -webkit-tap-highlight-color: transparent !important; }
    .grid-container { display: flex; flex-direction: column; gap: 15px; align-items: center; width: 100%; }
    .top-header { width: 100%; padding: 1px; border-radius: 8px; margin-bottom: 2px; text-align: center; }
    .header-title { display: inline-block; text-align: center; color: #0096ff; margin: 0; font-size: 24px; font-weight: bold; position: static; }
    .header-title2 { display: inline-block; text-align: center; color: #0096ff; margin: 0; font-size: 24px; font-weight: bold; position: static; animation: pulse-twice 1.2s ease-in-out 2; }
    @keyframes pulse-twice { 0%, 100% { color: #0096ff; text-shadow: 0 0 0px transparent; } 50% { color: #66c2ff; text-shadow: 0 0 8px #0096ff; } }
    .top-buttons { display: flex; justify-content: center; gap: 8px; width: 100%; margin: 0 0 12px 0; }
	.total-count { text-align: center; color: #f2f2f7; margin-bottom: 12px; font-size: 13px; font-weight: bold; letter-spacing: 0.5px; }
	.count-highlight { background: #0096ff; color: #000; padding: 1px 6px; border-radius: 3px; margin-left: 4px; font-weight: 900; }
	.header-wrap { text-align: center; width: 100%; margin: 10px 0; }
	.header-box { visibility: hidden; width: max-content; min-width: 120px; background: rgba(0,0,0,0.9); color: white; text-align: center; border: 1px solid #475a68; border-radius: 6px; padding: 8px; position: absolute; z-index: 999; bottom: 135%; left: 50%; transform: translateX(-50%); opacity: 0; transition: opacity 0.6s cubic-bezier(0.4, 0, 0.2, 1), bottom 0.6s cubic-bezier(0.4, 0, 0.2, 1); font-size: 0.85rem; font-weight: bold; box-shadow: 0 4px 12px #000; pointer-events: none; line-height: 1.4; }
	.header-tooltip { position: relative; display: inline-block; }
	.header-tooltip:hover .header-box { visibility: visible; opacity: 1; bottom: 145%; }
    .section-header { color: #ffffff; font-weight: bold; padding: 12px; text-align: center; border-bottom: 1px solid #475a68; }
    .report-column { width: 100%; border-radius: 8px; border: 1px solid #475a68; overflow: hidden; display: flex; flex-direction: column; }
	.rssi-quality-bar { display: flex; justify-content: center; gap: 12px; align-items: center; width: 100%; margin: -5px auto -5px auto; padding: 0; background: transparent; border: none; height: auto; }
	.rssi-quality-box { display: inline-block; height: 28px; line-height: 26px; text-align: center; padding: 0 12px; border-radius: 4px; background: rgba(0,0,0,0.4); border: 1px solid #475a68; font-weight: bold; box-sizing: border-box; transition: all 0.2s ease; }
	.rssi-quality-box:hover { border-color: var(--hover-color, #0096ff); box-shadow: 0 0 10px var(--glow-color, rgba(0,150,255,0.4)); }
    .rssi_bars { font-family: monospace; font-weight: 900; width: 40px; display: inline-block; text-align: right; margin-right: 5px; }
    .rssi-font { color:#000; padding:1px 5px; border-radius:3px; margin-left:4px; }
    .rssi-excl { color: #30d158; --hover-color: #30d158; --glow-color: rgba(48,209,88,0.4); }
    .rssi-good { color: #64d2ff; --hover-color: #64d2ff; --glow-color: rgba(100,210,255,0.4); }
    .rssi-fair { color: #ffd60a; --hover-color: #ffd60a; --glow-color: rgba(255,214,10,0.4); }
    .rssi-poor { color: #ff453a; --hover-color: #ff453a; --glow-color: rgba(255,69,58,0.4); }
    .rssi-container { position: relative; vertical-align: middle; }
	.rssi-tooltip { visibility: hidden; position: fixed; z-index: 99999; color: #fff; padding: 10px; border-radius: 8px; border: 1px solid #0096ff; opacity: 0; transition: opacity .3s; font: 1.1em monospace; white-space: pre; width: max-content; pointer-events: none; text-align: left !important; }
	.rssi-container:hover .rssi-tooltip { visibility: visible; opacity: 1; }
    .button-refresh { display: inline-flex; align-items: center; height: 28px; line-height: 26px; text-align: center; padding: 0 5px; border-radius: 4px; border: 1px solid #475a68; font-weight: bold; transition: all 0.2s ease; }
    .button-refresh:hover { border-color: #0096ff; box-shadow: 0 0 10px rgba(0,150,255,0.4); }
    .right-arrow { color: #ffffff; font-size: 0.9em; margin: 0 4px; animation: right-arrow-glow 3s infinite ease-in-out; }
	@keyframes right-arrow-glow { 0%, 100% { color: rgba(255,255,255,0.2); } 50% { color: #ffffff; text-shadow: 0 0 8px rgba(255,255,255,0.8); } }
    .refresh-pulse { animation: refresh-pulse-blue 1.5s infinite ease-in-out !important; pointer-events: none; }
    @keyframes refresh-pulse-blue { 0%, 100% { color: #0044cc; text-shadow: 0 0 2px #0044cc; } 50% { color: #0096ff; text-shadow: 0 0 10px #0096ff; } }
	.pulse-blue { color: #00e5ff !important; font-weight: bold; animation: pulse-blue-glow 2s infinite; }
	@keyframes pulse-blue-glow { 0% { opacity: 1; } 50% { opacity: 0.5; } 100% { opacity: 1; } }
    .new-device-row { background-color: rgba(0, 229, 255, 0.1) !important; animation: pulse-blue-glow 2s infinite; }
    .button-auto-refresh { display: inline-flex; align-items: center; padding: 0 5px; height: 28px; border: 0; margin-left: -4px; border-top-left-radius: 0 !important; border-bottom-left-radius: 0 !important; border-top-right-radius: 4px; border-bottom-right-radius: 4px; color: #0096ff; font-size: 12px; font-weight: bold; cursor: pointer !important; }
    .button-auto-refresh > span { color: #0096ff; font-weight: bold; pointer-events: none; user-select: none; }
    .button-auto-refresh:hover, .button-auto-refresh.active { border-color: #0096ff; box-shadow: 0 0 25px rgba(0,150,255,0.6); color: #0096ff; position: relative; z-index: 5 }
    .button-auto-refresh.active { background: rgba(0,150,255,0.15); }
    .button-tables.button-trigger { color: #0096ff; border: none; border-top-right-radius: 0; border-bottom-right-radius: 0; height: 100%; line-height: inherit; padding: 0 5px; }
    .button-tables.button-trigger span { color: white !important; }
    .button-tables { border: 1px solid #475a68; color: white; padding: 0 12px; font-size: 12px; border-radius: 4px; font-weight: bold; height: 28px; cursor: pointer !important; line-height: 26px; transition: all 0.2s ease; box-sizing: border-box; }
    .button-tables:hover, .button-tables.active { color: #0096ff; border-color: #0096ff; box-shadow: 0 0 25px rgba(0,150,255,0.6); position: relative; z-index: 5 }
    .button-tables.active { background: rgba(0,150,255,0.15); }
    #refresh-option { color: #ffffff; background: transparent; border: none; outline: none; font-weight: bold; cursor: pointer; padding: 0; margin: 0; font-family: inherit; font-size: inherit; }
    #refresh-option option { font-weight: bold; }
    #refresh-option:focus { outline: none; border: none; }
    #refresh-countdown { color: #0096ff; font-weight: bold; }
    ${THEME_CSS}
	.report_table tbody tr:hover td { background-color: rgba(0, 123, 255, 0.15) !important; }
	table.report_table { width: 100%; border-collapse: collapse; }
	table.report_table .mac-val {}
	table.report_table .ip-val {}
	table.report_table.show-ip .mac-val { display: none !important; }
	table.report_table.show-ip .ip-val { display: inline !important; }
	table.report_table.show-mac .mac-val { display: inline !important; }
	table.report_table.show-mac .ip-val { display: none !important; }
	table.report_table.show-iface .ssid-val { display: none !important; }
	table.report_table.show-iface .iface-val { display: inline !important; color: #64d2ff; }
    table.report_table td { padding: 6px; border-bottom: 1px solid #3d454b; vertical-align: middle; text-align: center; }
    table.report_table tfoot td { border-top: 1px solid #475a68; padding: 12px 10px !important; font-weight: bold; color: #fff; }
    table.report_table thead th { position: sticky; top: 0; z-index: 10; color: #fff; padding: 8px; text-align: center; border-right: 1px solid rgba(255,255,255,0.1); }
    table.report_table th:hover { color: #000; text-shadow: 0 0 10px rgba(0,229,255,0.8); }
    table.report_table td:nth-child(7) { font-weight: normal; }
	.mac-val, .ssid-val { display: inline; }
    .ip-val, .iface-val { display: none; }
    tfoot td { text-align: center; }
    tfoot td > span:not(:last-child) { margin-right: 6px; }
	#splitView { display: flex; flex-direction: column; gap: 15px; width: 100%; }
    #allCol { display: none; width: 100% ; align-self: flex-start; }
    .router-style { color: $MAIN_COLOR; font-size: 20px; font-weight: bold; text-transform: uppercase; display: inline-block; margin-bottom: 4px; }
    .temp-load-row { display: block; font-size: 14px; color: #f2f2f7; margin-top: 11px; font-weight: bold; white-space: nowrap; width: 100%; overflow: visible !important; text-align: center; justify-content: center; }
    .temp-load-row > span:not(:last-child) { margin-right: 1px; }
	.uptime-row { text-align: center; justify-content: center; font-size: 14px; }
    .stat-cool { color: #0096ff !important; font-weight: bold; }
    .stat-warm { color: #ffa500 !important; font-weight: bold; }
	.stat-hot { color: #ff453a !important; font-weight: bold; }
    .main-color { color: $MAIN_COLOR !important; font-weight: bold; }
    .band-24g { color: #0096ff !important; font-weight: bold; }
	.band-5g { color: #30d158 !important; font-weight: bold; }
	.band-6g { color: #bf40bf !important; font-weight: bold; }
    .hidden-node-number { position:absolute; width:0; height:0; overflow:hidden; opacity:0; pointer-events:none; }
    .separator-line { margin: 8px -12px; width: calc(100% + 24px); display: block; }
    sup { font-size: 0.6em; margin-left: 2px; }
    .sup-header { font-size:14px; font-weight:bold; margin-left:2px; }
    .button-refresh:hover select, .button-refresh:hover .button-trigger { color: #0096ff !important; }
    .button-refresh, .button-refresh select, .button-refresh .button-trigger { position: relative; display: inline-block; }
    .button-refresh select, .button-refresh .button-trigger { position: relative; display: inline-block; }
    .button-refresh:before, .button-refresh .button-trigger:before, .button-refresh select:before { position: absolute; height: 28px; line-height: 28px; padding: 0 15px; background: $RT_TOOLTIP; color: white; font-size: 12px; font-weight: bold; border: 1.5px solid #0096ff; border-radius: 20px; box-shadow: 0 0 10px rgba(0,150,255,0.3); white-space: nowrap; opacity: 0; visibility: hidden; transition: all 0.3s ease; z-index: 100; pointer-events: none; }
    .button-refresh:after, .button-refresh .button-trigger:after, .button-refresh select:after { content: ""; position: absolute; width: 4px; height: 4px; background: #0096ff; border-radius: 50%; opacity: 0; visibility: hidden; transition: all 0.3s ease; z-index: 101; pointer-events: none; }
    .button-refresh:before { content: var(--avg-text, "Avg: calculating..."); left: -90px; bottom: 185%; background: $RT_TOOLTIP; }
    .button-refresh .button-trigger:before, .button-refresh select:before { content: var(--highlow-text, "High: 0s   Low: 0s"); left: -94px; top: 185%; background: $RT_TOOLTIP; }
    .button-refresh:after { left: 15px; bottom: 130%; box-shadow: -12px -12px 0 1.5px #0096ff; }
    .button-refresh .button-trigger:after, .button-refresh select:after { left: 11px; top: 130%; box-shadow: -12px 12px 0 1.5px #0096ff; }
    .button-refresh:hover:before, .button-refresh:hover .button-trigger:before { opacity: 1; visibility: visible; }
    .button-refresh:hover:after, .button-refresh:hover .button-trigger:after { opacity: 1; visibility: visible; }
    .button-refresh:hover:before { bottom: 190%; }
    .button-refresh:hover .button-trigger:before { top: 190%; }
    .button-refresh .button-trigger:not([style*="--highlow-text"]):before,
    .button-refresh .button-trigger:not([style*="--highlow-text"]):after { display: none !important; }
    .button-refresh:not([style*="--avg-text"]):before,
    .button-refresh:not([style*="--avg-text"]):after { display: block !important; visibility: hidden !important; opacity: 0 !important; content: "" !important; }
    /* Wide View keeps the normal ASUS page available, but lets the report itself use
    the complete browser viewport when more horizontal room is useful. */
    body.wr-wide-mode { overflow: hidden !important; }
    body.wr-wide-mode #wifiReportContainer { position: fixed !important; inset: 0 !important; z-index: 9000 !important; width: 100vw !important; height: 100vh !important; max-width: none !important; margin: 0 !important; padding: 4px 18px 24px 18px !important; box-sizing: border-box !important; overflow: auto !important; background: rgba(0,0,0,0.98); }
    body.wr-wide-mode #wifiReportContainer .grid-container,
    body.wr-wide-mode #wifiReportContainer #splitView,
    body.wr-wide-mode #wifiReportContainer #allCol { width: 100% !important; max-width: none !important; }
    body.wr-wide-mode #wifiReportContainer table.report_table { min-width: 900px; }
    body.wr-wide-mode #wifiReportContainer table.report_table tbody td { font-size: 13px; }
    body.wr-wide-mode #wifiReportContainer table.report_table thead th { font-size: 13px; }
    body.wr-wide-mode #wifiReportContainer .router-style { font-size: 22px; }
    body.wr-wide-mode #btnWide { color: #0096ff; border-color: #0096ff; box-shadow: 0 0 25px rgba(0,150,255,0.6); background: rgba(0,150,255,0.15); }
    /* Roomier column hints for Wide View and Side-by-Side.  These are minimums,
       not fixed widths, so larger displays can continue to expand naturally. */
    body.wr-wide-mode table.report_table th:nth-child(1), #popoutModal table.report_table th:nth-child(1) { min-width: 100px; }
    body.wr-wide-mode table.report_table th:nth-child(2), #popoutModal table.report_table th:nth-child(2) { min-width: 100px; }
    body.wr-wide-mode table.report_table th:nth-child(3), #popoutModal table.report_table th:nth-child(3) { min-width: 75px; }
    body.wr-wide-mode table.report_table th:nth-child(4), #popoutModal table.report_table th:nth-child(4) { min-width: 75px; }
    body.wr-wide-mode table.report_table th:nth-child(5), #popoutModal table.report_table th:nth-child(5) { min-width: 75px; }
    body.wr-wide-mode table.report_table th:nth-child(6), #popoutModal table.report_table th:nth-child(6) { min-width: 75px; }
    body.wr-wide-mode table.report_table th:nth-child(7), #popoutModal table.report_table th:nth-child(7) { min-width: 75px; }
    .popout-overlay { display: none; position: fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.4); z-index:9999; align-items: center; justify-content: center; backdrop-filter: blur(8px); }
    .popout-content { background: rgba(0, 0, 0, 0.2); width: fit-content; max-width: 98vw; max-height: 95vh; margin: auto; padding: 12px; box-sizing: border-box; border-radius: 15px; border: 1px solid rgba(0, 150, 255, 0.4); position: relative; overflow-y: auto; box-shadow: 0 0 40px rgba(0,0,0,0.6); backdrop-filter: blur(20px); overflow-x: hidden !important; }
    .popout-close-x { position: absolute; top: 8px; right: 20px; color: #fff; font-size: 30px; font-weight: bold; }
    .popout-grid { display: flex; width: 100%; gap: 10px; margin-top: 2px; align-items: flex-start; justify-content: center; }
    .popout-grid > .report-column, .popout-grid > .popout-main-wrapper { flex: 1 1 0; min-width: 0; max-width: none; overflow-x: auto !important; -webkit-overflow-scrolling: touch; }
    .popout-main-wrapper { display: flex; flex-direction: column; }
    .popout-main-wrapper > .report-column { flex: none !important; width: 100% !important; max-width: 100% !important; box-sizing: border-box; }
    #popoutModal .separator-line { margin: 8px -12px; display: block; width: calc(100% + 24px); }
    #popoutModal table.report_table tbody td { white-space: nowrap; height: 25px !important; line-height: 25px !important; padding: 0 4px !important; }
    #popoutModal table.report_table tbody td:not([style*="font-weight: bold"]) { font-size: 12px !important; font-weight: normal !important; }
    #popoutModal table.report_table tbody td[style*="font-weight: bold"] { font-size: 12px !important; }
    #popoutModal table.report_table tbody td:nth-child(7) { font-weight: normal !important; }
    #popoutModal table.report_table thead th { font-size: 12px !important; font-weight: bold !important; white-space: nowrap; vertical-align: middle !important; height: 32px !important; padding: 0 4px !important; }
    #popoutModal .report-column .section-header .temp-load-row { margin-top: -2px !important; margin-bottom: -2px !important; display: block !important; }
    #popoutModal .report-column .section-header .temp-load-row span { font-size: 14px !important; font-weight: bold !important; }
    #popoutModal .report-column div:last-child, #popoutModal .table-footer, #popoutModal tfoot td { font-size: 12px !important; font-weight: bold !important; line-height: normal !important; padding-top: 12px !important; padding-bottom: 12px !important; background: transparent !important; white-space: nowrap !important; }
    #popoutModal .rssi-container { position: relative !important; }
    #popoutModal .rssi-tooltip { position: absolute !important; bottom: 100% !important; left: 50% !important; top: auto !important; right: auto !important; transform: translateX(-50%) !important; margin-bottom: 6px !important; z-index: 999999 !important; }
    #popoutModal, #popoutModal * { cursor: pointer !important; -webkit-tap-highlight-color: transparent !important; }
    @media (min-width: 992px) { #popoutModal .separator-line { min-width: 815px; } #popoutModal table.report_table { min-width: 815px !important; } @media (orientation: landscape) { .popout-grid > .report-column::-webkit-scrollbar, .popout-grid > .popout-main-wrapper::-webkit-scrollbar { display: none !important; width: 0 !important; height: 0 !important; } .popout-grid > .report-column, .popout-grid > .popout-main-wrapper { -ms-overflow-style: none; scrollbar-width: none; } } @media (orientation: portrait) { #popoutModal table.report_table { width: max-content !important; } .popout-grid .report-column { scrollbar-width: auto !important; -ms-overflow-style: auto !important; } } }
    @media (max-width: 991px) { .popout-grid > .report-column, .popout-grid > .popout-main-wrapper { display: block !important; } #popoutModal table.report_table { min-width: 100% !important; width: max-content !important; display: block !important; } #popoutModal .separator-line { min-width: max-content !important; width: calc(100% + 24px) !important; display: inline-block !important; } }
</style>
<script>
var WR_CUSTOM_NODE_NAMES = {};
$NODE_NICK_JS
var WR_NODE_COLOR_BY_IP = {};
$NODE_COLOR_JS

var WR_CONFIG = {
    mainColor: "$MAIN_COLOR",
    nodeColors: String("$NODE_COLORS").trim().split(/\s+/).filter(Boolean),
    hostColor: Number("${HOST_COLOR:-0}") || 0,
    pulseMins: Number("${PULSE_MINS:-15}") || 15,
    reportUnit: String("${REPORT_UNIT:-USA}"),
    runtimeTracking: Number("${RTIME:-1}") || 0,
    ipPad: Number("${IPPAD:-1}") || 0,
    rssiHistory: Number("${RS_HIST:-0}") || 0,
    rssiHistoryEntries: Number("${RS_HIST_ENTRIES:-5}") || 5,
    rssiHistoryDate: Number("${RS_HIST_DATE:-0}") || 0
};

var WR_PAGE_GENERATION = "$WR_GENERATION";
var WR_LIVE_WATCH_TIMER = null;
var WR_LIVE_CHECKING = false;
var WR_LIVE_RELOADING = false;

function wrNavigateToFreshGeneration(generation) {
    if (WR_LIVE_RELOADING) return;
    WR_LIVE_RELOADING = true;
    try {
        var url = new URL(window.location.href);
        url.searchParams.set('wr_live', String(generation));
        console.info('Wireless Report: applying WebUI generation ' + generation);
        window.location.replace(url.toString());
    } catch (e) {
        window.location.href = window.location.pathname + '?wr_live=' + encodeURIComponent(String(generation));
    }
}

async function wrCheckLiveGeneration() {
    if (WR_LIVE_CHECKING || WR_LIVE_RELOADING) return;
    WR_LIVE_CHECKING = true;
    try {
        var state = await wrAppGet('nvram_get(wirelessreport_gen);');
        var generation = String((state && state.wirelessreport_gen) || '');
        if (generation && generation !== String(WR_PAGE_GENERATION)) {
            wrNavigateToFreshGeneration(generation);
        }
    } catch (_) {
        // Ignore transient/session errors; normal report refresh handles them.
    } finally {
        WR_LIVE_CHECKING = false;
    }
}

function wrStartLiveReloadWatcher() {
    if (WR_LIVE_WATCH_TIMER) return;
    setTimeout(wrCheckLiveGeneration, 750);
    WR_LIVE_WATCH_TIMER = setInterval(wrCheckLiveGeneration, 2000);
}

function wrRemoveLiveCacheBuster() {
    try {
        var url = new URL(window.location.href);
        if (!url.searchParams.has('wr_live')) return;
        url.searchParams.delete('wr_live');
        window.history.replaceState(null, document.title, url.pathname + url.search + url.hash);
    } catch (_) {}
}

function update_time() {
    const now = new Date();
    const day = now.getDate();
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    const month = months[now.getMonth()];
    const year = now.getFullYear();
    const hours = now.getHours();
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const seconds = String(now.getSeconds()).padStart(2, '0');
    let formattedTime = '';

    if (WR_CONFIG.reportUnit === 'ISO') {
        const mm = String(now.getMonth() + 1).padStart(2, '0');
        const dd = String(day).padStart(2, '0');
        formattedTime = year + '-' + mm + '-' + dd + ' ' + String(hours).padStart(2, '0') + ':' + minutes + ':' + seconds;
    } else if (WR_CONFIG.reportUnit === 'INTL') {
        formattedTime = day + '-' + month + ' ' + hours + ':' + minutes + ':' + seconds;
    } else {
        formattedTime = month + '-' + day + ' ' + hours + ':' + minutes + ':' + seconds;
    }
    document.querySelectorAll('.wr-updated-time').forEach(function(el) {
        el.textContent = 'Updated: ' + formattedTime;
    });

    // Handle boot time calculation dynamically using the uptime span value
    const uptimeEl = document.getElementById('wr-main-uptime');
    const bootEl = document.getElementById('wr-main-reboot');
    if (bootEl && uptimeEl) {
        const uptimeText = uptimeEl.textContent.trim();
        let totalSeconds = 0;
        const dMatch = uptimeText.match(/(\d+)d/);
        const hMatch = uptimeText.match(/(\d+)h/);
        const mMatch = uptimeText.match(/(\d+)m/);
        if (dMatch) totalSeconds += parseInt(dMatch[1], 10) * 86400;
        if (hMatch) totalSeconds += parseInt(hMatch[1], 10) * 3600;
        if (mMatch) totalSeconds += parseInt(mMatch[1], 10) * 60;
        if (totalSeconds > 0) {
            const bootDate = new Date(now.getTime() - (totalSeconds * 1000));
            const bDay = bootDate.getDate();
            const bMonth = months[bootDate.getMonth()];
            const bYear = bootDate.getFullYear();
            const bHours = bootDate.getHours();
            const bMinutes = String(bootDate.getMinutes()).padStart(2, '0');
            let formattedBoot = '';

            if (WR_CONFIG.reportUnit === 'ISO') {
                const bMm = String(bootDate.getMonth() + 1).padStart(2, '0');
                const bDd = String(bDay).padStart(2, '0');
                formattedBoot = bYear + '-' + bMm + '-' + bDd + ' ' + String(bHours).padStart(2, '0') + ':' + bMinutes;
            } else if (WR_CONFIG.reportUnit === 'INTL') {
                formattedBoot = bDay + '-' + bMonth + ' ' + bHours + ':' + bMinutes;
            } else {
                formattedBoot = bMonth + '-' + bDay + ' ' + bHours + ':' + bMinutes;
            }
            bootEl.textContent = formattedBoot;
        }
    }
}

var WR_STA_COLUMNS = [
    'data_time', 'node_type', 'node_ip', 'node_mac', 'sta_mac',
    'sta_band', 'sta_rssi', 'sta_active', 'sta_tx', 'sta_rx',
    'sta_tbyte', 'sta_rbyte', 'conn_time', 'tx_mcs', 'rx_mcs',
    'tx_nss', 'rx_nss', 'bw', 'conn_if', 'conn_if_idx', 'conn_if_vidx'
];

function wrNormMac(mac) {
    return String(mac || '').split(String.fromCharCode(92)).join('').trim().toUpperCase();
}

function wrIsMac(mac) {
    return /^[0-9A-F]{2}(?::[0-9A-F]{2}){5}$/.test(wrNormMac(mac));
}

function wrEscape(value) {
    return String(value == null ? '' : value)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#39;');
}

function wrNumber(value) {
    if (value === undefined || value === null || String(value).trim() === '') return null;
    var n = Number(value);
    return Number.isFinite(n) ? n : null;
}

function wrFirst(obj, keys) {
    for (var i = 0; i < keys.length; i++) {
        if (obj && obj[keys[i]] !== undefined && obj[keys[i]] !== null && obj[keys[i]] !== '') {
            return obj[keys[i]];
        }
    }
    return '';
}

function wrNodeColor(index, node) {
    // Shell color choices are tied to the IP-sorted node inventory. ASUS'
    // get_cfg_clientlist() does not guarantee that same order, so resolve the
    // configured color by node IP first. Positional lookup remains a fallback
    // for older/generated pages without the keyed map.
    var ip = String(wrFirst(node, ['ip', 'ip_addr', 'ipAddr']) || '').trim();
    if (ip && WR_NODE_COLOR_BY_IP[ip]) return WR_NODE_COLOR_BY_IP[ip];
    if (!WR_CONFIG.nodeColors.length) return '#30d158';
    return WR_CONFIG.nodeColors[index % WR_CONFIG.nodeColors.length] || '#30d158';
}

function wrIpSort(ip) {
    var parts = String(ip || '').split('.');
    if (parts.length !== 4) return '999999999999';
    return parts.map(function(p) {
        var n = parseInt(p, 10);
        return Number.isFinite(n) ? String(n).padStart(3, '0') : '999';
    }).join('');
}

function wrDisplayIp(ip) {
    var parts = String(ip || '').split('.');
    if (parts.length !== 4 || WR_CONFIG.ipPad === 0) return String(ip || '');
    if (WR_CONFIG.ipPad === 1) {
        parts[3] = String(parseInt(parts[3], 10)).padStart(3, '0');
    } else if (WR_CONFIG.ipPad === 2) {
        parts[2] = String(parseInt(parts[2], 10)).padStart(3, '0');
        parts[3] = String(parseInt(parts[3], 10)).padStart(3, '0');
    }
    return parts.join('.');
}

function wrFormatSeconds(value) {
    var sec = wrNumber(value);
    if (!Number.isFinite(sec) || sec < 0) return "<span data-sort='0'>---</span>";
    var d = Math.floor(sec / 86400);
    var h = Math.floor((sec % 86400) / 3600);
    var m = Math.floor((sec % 3600) / 60);
    var text = d > 0
        ? String(d).padStart(2, '0') + 'd ' + String(h).padStart(2, '0') + 'h'
        : h > 0
            ? String(h).padStart(2, '0') + 'h ' + String(m).padStart(2, '0') + 'm'
            : '00h ' + String(m).padStart(2, '0') + 'm';
    var pulse = WR_CONFIG.pulseMins > 0 && sec < WR_CONFIG.pulseMins * 60 ? 'pulse-blue' : '';
    return "<span class='" + pulse + "' data-sort='" + Math.floor(sec) + "'>" + text + "</span>";
}

function wrFormatConnection(value) {
    if (value !== undefined && value !== null && String(value).trim() !== '') {
        var strVal = String(value).trim();
        // Check if it's a colon-separated time format like HH:MM:SS or MM:SS
        if (strVal.includes(':')) {
            var parts = strVal.split(':').map(Number);
            var sec = 0;
            if (parts.length === 3) {
                sec = parts[0] * 3600 + parts[1] * 60 + parts[2];
            } else if (parts.length === 2) {
                sec = parts[0] * 60 + parts[1];
            }
            if (!isNaN(sec) && sec >= 0) return wrFormatSeconds(sec);
        }
    }

    var sec = wrNumber(value);
    if (Number.isFinite(sec) && sec >= 0) return wrFormatSeconds(sec);
    if (value !== undefined && value !== null && String(value).trim() !== '') {
        return "<span data-sort='0'>" + wrEscape(String(value)) + "</span>";
    }
    return "<span data-sort='0'>---</span>";
}

function wrFormatRouterUptime(value) {
    var sec = wrNumber(value);
    if (!Number.isFinite(sec) || sec < 0) return '--';
    var d = Math.floor(sec / 86400);
    var h = Math.floor((sec % 86400) / 3600);
    var m = Math.floor((sec % 3600) / 60);
    if (d > 0) return d + 'd ' + h + 'h ' + m + 'm';
    if (h > 0) return h + 'h ' + m + 'm';
    return m + 'm';
}

function wrParseUptime(raw) {
    if (raw === undefined || raw === null) return null;
    if (typeof raw === 'number') return raw;
    var text = String(raw);
    var m = text.match(/\(([0-9]+)\s+secs since boot\)/);
    if (m) return Number(m[1]);
    m = text.match(/^([0-9]+(?:\.[0-9]+)?)$/);
    return m ? Number(m[1]) : null;
}
function wrPad2(value) {
    return String(value).padStart(2, '0');
}

function wrMetricClass(value) {
    var n = Number(value);
    if (!Number.isFinite(n)) return 'stat-cool';
    if (n >= 85) return 'stat-hot';
    if (n >= 60) return 'stat-warm';
    return 'stat-cool';
}

function wrBandName(band) {
    var map = {
        '2G': '2.4G',
        '5G': '5G',
        '5G1': '5G-2',
        '5G2': '5G-3',
        '6G': '6G',
        '6G1': '6G-2',
        '6G2': '6G-3'
    };
    return map[String(band || '')] || String(band || '');
}

function wrNormalizeBand(band) {
    var value = String(band || '').trim().toUpperCase();
    if (value === '2G' || value === '2.4G') return '2G';
    if (value === '5G') return '5G';
    if (value === '5G1' || value === '5G-2') return '5G1';
    if (value === '5G2' || value === '5G-3') return '5G2';
    if (value === '6G') return '6G';
    if (value === '6G1' || value === '6G-2') return '6G1';
    if (value === '6G2' || value === '6G-3') return '6G2';
    return value;
}

function wrClientBandHint(client) {
    if (!client) return '';

    // On the affected 388 client list, isWL remains tied to the actual
    // association while conn_diag/stainfo can intermittently surface a stale
    // active sample from another radio. Only use the two values proven on this
    // firmware family; leave unknown/tri-band values to stainfo unchanged.
    var raw = client.isWL;
    if (raw !== undefined && raw !== null && raw !== '') {
        var value = String(raw).trim();
        if (value === '1') return '2G';
        if (value === '2') return '5G';
    }

    var named = wrNormalizeBand(wrFirst(client, ['band', 'wlBand']));
    return named || '';
}

function wrWidth(code) {
    var map = { 0: '', 1: '20', 2: '40', 3: '80', 4: '160', 5: '320' };
    var n = Number(code);
    return Object.prototype.hasOwnProperty.call(map, n) ? map[n] : '';
}

function wrMeshUplinkBand(node) {
    // AiMesh node-self rows in get_clientlist() are backhaul pseudo-clients,
    // not ordinary station associations. ASUS' AiMesh WebUI determines the
    // selected uplink from get_cfg_clientlist().re_path instead of isWL/stainfo.
    var path = Number(node && node.re_path);
    if (!Number.isFinite(path) || path <= 0) return '';

    // ASUS uses these re_path values for wired/alternate wired paths.
    if (path === 1 || path === 16 || path === 32 || path === 64) return '';
    if (path === 2) return '2G';
    if (path === 128) return '6G';
    if (path === 512) return 'MLO';

    // Remaining positive wireless re_path values are the 5 GHz uplink path.
    return '5G';
}

function wrMeshUplinkRssi(node) {
    var path = Number(node && node.re_path);
    if (!Number.isFinite(path) || path <= 0) return null;
    if (path === 1 || path === 16 || path === 32 || path === 64 || path === 512) return null;
    if (path === 2) return wrNumber(node.rssi2g);
    if (path === 128) return wrNumber(node.rssi6g);
    return wrNumber(node.rssi5g);
}

function wrItemRssi(item) {
    if (!item) return null;

    // A node-self pseudo-client can expose RSSI/isWL for a different radio than
    // its active backhaul. Keep all row/history/count consumers on the same
    // re_path-selected AiMesh RSSI source instead of falling back to client.rssi.
    if (item.meshLinkNode) return wrMeshUplinkRssi(item.meshLinkNode);

    if (item.sta && item.sta.sta_rssi !== undefined) return wrNumber(item.sta.sta_rssi);
    return wrNumber(item.client && item.client.rssi);
}

function wrResolvedBandContext(sta, client, meshLinkNode, node, fallbackBand) {
    // Keep every BAND consumer on the same priority chain so the rendered table
    // and RSSI history cannot disagree when stainfo is missing. Controller API
    // generation and node telemetry generation are deliberately separate: a
    // 3006 controller can manage a 388 node whose live isWL semantics remain
    // useful for rejecting stale stainfo radio samples.
    if (meshLinkNode) {
        return { band: wrNormalizeBand(wrMeshUplinkBand(meshLinkNode)), mismatch: false };
    }

    var staBand = wrNormalizeBand(sta && sta.sta_band);
    var useLegacyHint = node ? wrNodeLegacySemantics(node) : WR_DIAG_API === 'legacy';
    var clientBand = useLegacyHint ? wrClientBandHint(client) : '';
    if (!clientBand && !staBand && node) clientBand = wrNodeClientBandFallback(node, client);

    var mismatch = Boolean(staBand && clientBand && staBand !== clientBand);
    var selectedBand = mismatch ? clientBand : (staBand || clientBand);
    if (!selectedBand) selectedBand = wrNormalizeBand(fallbackBand);
    if (!selectedBand) selectedBand = wrNormalizeBand(wrFirst(client, ['band', 'wlBand']));

    return { band: selectedBand || '', mismatch: mismatch };
}

function wrBandHtml(sta, client, meshLinkNode, node, fallbackBand) {
    var resolved = wrResolvedBandContext(sta, client, meshLinkNode, node, fallbackBand);
    var normalizedBand = resolved.band;
    var band = normalizedBand ? wrBandName(normalizedBand) : '';
    var width = '';

    // A mismatched legacy stainfo sample can carry the other radio's channel
    // width too. Do not display that width if the live client band disagrees.
    if (!meshLinkNode) width = sta && !resolved.mismatch ? wrWidth(sta.bw) : '';

    // Unknown telemetry is unknown; never manufacture a 2.4 GHz/20 MHz result.
    var label = (band + (width ? ' (' + width + ')' : '')).trim() || '--';

    var cls = '';
    var sort = '0';
    if (/2\.4|2G/i.test(band)) { cls = 'band-24g'; sort = '2.4'; }
    else if (/5/.test(band)) { cls = 'band-5g'; sort = '5'; }
    else if (/6/.test(band)) { cls = 'band-6g'; sort = '6'; }
    return "<td data-sort='" + sort + "' style='text-align:center;'><span class='" + cls + "'>" + wrEscape(label) + "</span></td>";
}

function wrQuality(rssi) {
    var n = Number(rssi);
    if (!Number.isFinite(n) || n >= 0 || n < -120) return { key: '', bars: '', cls: '', style: '' };
    if (n >= -50) return { key: 'excellent', bars: '||||', cls: 'rssi-excl', style: 'color:#30d158;font-weight:bold;' };
    if (n >= -60) return { key: 'good', bars: '|||', cls: 'rssi-good', style: 'color:#64d2ff;font-weight:bold;' };
    if (n >= -70) return { key: 'fair', bars: '||', cls: 'rssi-fair', style: 'color:#ffd60a;font-weight:bold;' };
    return { key: 'poor', bars: '|', cls: 'rssi-poor', style: 'color:#ff453a;font-weight:bold;' };
}

function wrLoadJson(key, fallback) {
    try {
        var raw = localStorage.getItem(key);
        return raw ? JSON.parse(raw) : fallback;
    } catch (_) {
        return fallback;
    }
}

function wrRssiHistoryEntries(raw) {
    if (Array.isArray(raw)) {
        return raw.filter(function(entry) {
            return entry && Number.isFinite(wrNumber(entry.rssi));
        }).map(function(entry) {
            return {
                rssi: wrNumber(entry.rssi),
                name: String(entry.name || ''),
                band: String(entry.band || ''),
                time: Number.isFinite(wrNumber(entry.time)) ? wrNumber(entry.time) : null
            };
        });
    }

    // stored just one numeric RSSI value per MAC. Preserve that
    // value as the first browser-history sample when upgrading to the richer model.
    var legacy = wrNumber(raw);
    if (Number.isFinite(legacy)) {
        return [{ rssi: legacy, name: '', band: '', time: null }];
    }
    return [];
}

function wrRssiHistorySignature() {
    return [
        WR_CONFIG.rssiHistory ? 1 : 0,
        WR_CONFIG.rssiHistoryEntries,
        WR_CONFIG.rssiHistoryDate ? 1 : 0
    ].join('|');
}

function wrPrepareRssiHistoryStorage() {
    var sigKey = 'wirelessReportRssiHistoryConfig';
    var current = wrRssiHistorySignature();
    var previous = localStorage.getItem(sigKey);

    // mirror v2.1.0 behavior: changing history settings starts clean.
    if (previous !== null && previous !== current) {
        localStorage.removeItem('wirelessReportRssiHistory');
    }
    localStorage.setItem(sigKey, current);
}

function wrRssiHistoryBand(item) {
    if (!item) return '';
    var resolved = wrResolvedBandContext(item.sta, item.client, item.meshLinkNode, item.node, item.wrFallbackBand);
    return resolved.band ? wrBandName(resolved.band) : '';
}

function wrRssiHistoryLocation(item) {
    if (item && item.meshLinkNode) return wrNodeDisplayName(item.meshLinkNode);
    if (item && item.node) return wrNodeDisplayName(item.node);
    var el = document.getElementById('wr-main-name');
    return el && el.textContent.trim() ? el.textContent.trim() : 'Main Router';
}

function wrRssiHistoryEntry(item, rssi, nowMs) {
    return {
        rssi: wrNumber(rssi),
        name: wrRssiHistoryLocation(item),
        band: wrRssiHistoryBand(item),
        time: Number(nowMs) || Date.now()
    };
}

function wrRssiHistoryStyle(rssi) {
    var quality = wrQuality(rssi);
    return quality.style || 'color:#fff;font-weight:bold;';
}

function wrGetTrend(item, rssi, history) {
    var mac = item.mac;
    var now = wrNumber(rssi);
    var entries = wrRssiHistoryEntries(history[mac]);
    var old = entries.length ? wrNumber(entries[entries.length - 1].rssi) : null;
    var icon = "<span class='trend-box'>•</span>";
    if (Number.isFinite(now) && Number.isFinite(old)) {
        if (now > old) icon = "<span class='trend-box trend-up rssi-excl'>↑</span>";
        else if (now < old) icon = "<span class='trend-box trend-down rssi-poor'>↓</span>";
    }
    if (!WR_CONFIG.rssiHistory || !Number.isFinite(now)) return icon;
    var current = wrRssiHistoryEntry(item, now, item.historyTime || Date.now());
    var display = entries.concat([current]);
    var depth = Math.max(5, Math.min(20, Number(WR_CONFIG.rssiHistoryEntries) || 5));
    if (display.length > depth) display = display.slice(display.length - depth);
    var tooltip = display.map(function(entry) {
        var text = String(entry.rssi) +
            ' [' + wrEscape(entry.name || '--') + ']' +
            ' [' + wrEscape(entry.band || '--') + ']';
        if (WR_CONFIG.rssiHistoryDate && Number.isFinite(wrNumber(entry.time))) {
            var d = new Date(Number(entry.time));
            var day = d.getDate();
            var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
            var month = months[d.getMonth()];
            var year = d.getFullYear();
            var hours = String(d.getHours()).padStart(2, '0');
            var minutes = String(d.getMinutes()).padStart(2, '0');
            var seconds = String(d.getSeconds()).padStart(2, '0');
            var formattedTime = '';
            if (typeof WR_CONFIG !== 'undefined' && WR_CONFIG.reportUnit === 'ISO') {
                var mm = String(d.getMonth() + 1).padStart(2, '0');
                var dd = String(day).padStart(2, '0');
                formattedTime = year + '-' + mm + '-' + dd + ' ' + hours + ':' + minutes + ':' + seconds;
            } else if (typeof WR_CONFIG !== 'undefined' && WR_CONFIG.reportUnit === 'INTL') {
                formattedTime = day + '-' + month + ' ' + hours + ':' + minutes + ':' + seconds;
            } else {
                formattedTime = month + '-' + day + ' ' + hours + ':' + minutes + ':' + seconds;
            }
            text += ' ' + wrEscape(formattedTime);
        }
        return "<span style='" + wrRssiHistoryStyle(entry.rssi) + "'>" + text + "</span>";
    }).join('<br>');
    return icon + "<span class='rssi-tooltip'>" + tooltip + "</span>";
}

function wrStoreRssiHistory(item, rssi, history) {
    var now = wrNumber(rssi);
    if (!Number.isFinite(now)) return;
    var entry = wrRssiHistoryEntry(item, now, item.historyTime || Date.now());
    if (!WR_CONFIG.rssiHistory) {
        history[item.mac] = [entry];
        return;
    }
    var entries = wrRssiHistoryEntries(history[item.mac]);
    entries.push(entry);
    var depth = Math.max(5, Math.min(20, Number(WR_CONFIG.rssiHistoryEntries) || 5));
    if (entries.length > depth) entries = entries.slice(entries.length - depth);
    history[item.mac] = entries;
}

function wrClientName(mac, liveClient, savedClient) {
    return wrFirst(liveClient, ['nickName', 'name']) ||
           wrFirst(savedClient, ['nickName', 'name']) ||
           mac;
}

function wrSavedClient(saved, macRaw, mac) {
    return saved[macRaw] || saved[mac] || saved[String(mac).toLowerCase()] || {};
}

function wrNodeFirmwareFamily(node) {
    // The diagnostic endpoint is selected by the controller, but client-radio
    // semantics belong to the individual AiMesh node. Prefer the node's own
    // firmware family and use capability[26] only as a positive latest-family
    // fallback when ASUS omits an identifiable firmware string.
    var fw = String(wrFirst(node, ['fwver', 'firmware', 'newfwver']) || '').trim();
    if (/^3\.0\.0\.4\./.test(fw)) return 'legacy';
    if (/^3\.0\.0\.6\./.test(fw)) return 'latest';

    var cap26 = node && node.capability && node.capability['26'];
    if (cap26 && cap26.wifi_band && typeof cap26.wifi_band === 'object') return 'latest';
    return '';
}

function wrNodeLegacySemantics(node) {
    var family = wrNodeFirmwareFamily(node);
    if (family) return family === 'legacy';
    // Preserve legacy-controller compatibility for older node inventories that do
    // not expose a recognizable firmware string. Never use a latest controller
    // alone as evidence that a node itself has latest telemetry semantics.
    return WR_DIAG_API === 'legacy';
}

function wrPositiveGuestIndex(client) {
    if (!client) return null;
    var raw = client.isGN === true ? 1 : client.isGN;
    if (raw === undefined || raw === null || String(raw).trim() === '') return null;
    var value = Number(raw);
    if (!Number.isFinite(value) || Math.floor(value) !== value || value <= 0 || value > 9) return null;
    return value;
}

function wrIfaceUnit(iface) {
    var match = String(iface || '').trim().match(/^wl([0-9]+)(?:\.[0-9]+)?$/i);
    return match ? Number(match[1]) : null;
}

function wrSsidEquivalent(a, b) {
    // get_clientlist() has been observed truncating otherwise-correct SSIDs by
    // one character. Accept only symmetric prefix matches long enough to be
    // meaningful; callers still require a unique match before using the result.
    a = String(a || '').trim();
    b = String(b || '').trim();
    if (!a || !b) return false;
    if (a === b) return true;
    if (Math.min(a.length, b.length) < 8) return false;
    return a.indexOf(b) === 0 || b.indexOf(a) === 0;
}

function wrNodeFrontHaulSsid(node, band) {
    band = wrNormalizeBand(band);
    if (band === '2G') return wrFirst(node, ['ap2g_ssid_fh', 'ap2g_ssid']);
    if (band === '5G') return wrFirst(node, ['ap5g_ssid_fh', 'ap5g_ssid']);
    if (band === '5G1') return wrFirst(node, ['ap5g1_ssid_fh', 'ap5g1_ssid']);
    if (band === '5G2') return wrFirst(node, ['ap5g2_ssid_fh', 'ap5g2_ssid', 'ap5g1_ssid_fh', 'ap5g1_ssid']);
    if (band === '6G') return wrFirst(node, ['ap6g_ssid_fh', 'ap6g_ssid']);
    if (band === '6G1') return wrFirst(node, ['ap6g1_ssid_fh', 'ap6g1_ssid']);
    if (band === '6G2') return wrFirst(node, ['ap6g2_ssid_fh', 'ap6g2_ssid', 'ap6g1_ssid_fh', 'ap6g1_ssid']);
    return '';
}

function wrNodeFrontHauls(node) {
    if (!node) return [];
    var defs = [
        ['2G', 'ap2g_fh'],
        ['5G', 'ap5g_fh'],
        ['5G1', 'ap5g1_fh'],
        ['5G2', 'ap5g2_fh'],
        ['6G', 'ap6g_fh'],
        ['6G1', 'ap6g1_fh'],
        ['6G2', 'ap6g2_fh']
    ];
    return defs.map(function(def) {
        var bssid = wrNormMac(node[def[1]] || '');
        return {
            band: def[0],
            bssid: bssid,
            ssid: String(wrNodeFrontHaulSsid(node, def[0]) || '').trim()
        };
    }).filter(function(entry) { return wrIsMac(entry.bssid); });
}

function wrClientRadioUnitFromIsWL(client) {
    // Compatibility conversion for the legacy/dual-band fallback only. Modern
    // AiMesh nodes can expose logical isWL values that do not equal physical wl
    // unit + 1, so capability-aware node mapping is attempted before this path.
    if (!client) return null;

    var wlRaw = client.isWL;
    var wl = Number(wlRaw);
    var wlValid = wlRaw !== undefined && wlRaw !== null && String(wlRaw).trim() !== '' &&
        Number.isFinite(wl) && Math.floor(wl) === wl && wl >= 1 && wl <= 4;
    return wlValid ? wl - 1 : null;
}

function wrLegacyClientRadioUnit(client) {
    // Primary-router legacy fallbacks remain legacy-only because they can resolve
    // reconstructed wlX[.Y] against the primary router's own NVRAM inventory.
    if (WR_DIAG_API !== 'legacy') return null;
    return wrClientRadioUnitFromIsWL(client);
}

function wrLegacyClientIfaceFallback(client) {
    // For legacy primary clients, a positive isGN is an observed VIF suffix and
    // can still reconstruct wlX.Y from the validated legacy isWL ordinal. Blank
    // isGN does not identify a main-BSS suffix and is intentionally left to the
    // authoritative FH-BSSID -> wifi_detect fallback instead of returning bare wlX.
    var unit = wrLegacyClientRadioUnit(client);
    if (unit === null) return '';

    var guest = wrPositiveGuestIndex(client);
    if (guest === null) return '';
    return 'wl' + unit + '.' + guest;
}

function wrCapabilityBand(mask) {
    var map = {
        1: '2G',
        2: '5G',
        4: '5G1',
        8: '5G2',
        16: '6G',
        32: '6G1',
        64: '6G2'
    };
    var value = Number(mask);
    return Object.prototype.hasOwnProperty.call(map, value) ? map[value] : '';
}

function wrNodeCapabilityRadios(node) {
    // 3006 nodes advertise an explicit logical-band -> VIF inventory in
    // capability["26"].wifi_band. The VIF prefix carries the actual physical
    // wl unit, which is safer than assuming isWL-1 on models with reordered radios.
    var cap26 = node && node.capability && node.capability['26'];
    var wifiBand = cap26 && cap26.wifi_band;
    if (!wifiBand || typeof wifiBand !== 'object') return null;

    var radios = [];
    Object.keys(wifiBand).forEach(function(key) {
        var entry = wifiBand[key];
        if (!entry || typeof entry !== 'object') return;

        var band = wrCapabilityBand(entry.band);
        if (!band) return;

        var units = new Set();
        var vifs = entry.vif;
        if (vifs && typeof vifs === 'object') {
            Object.keys(vifs).forEach(function(vifKey) {
                var vif = vifs[vifKey] || {};
                var prefix = String(vif.prefix || vifKey || '').trim();
                var match = prefix.match(/^wl([0-9]+)(?:\.[0-9]+)?$/i);
                if (match) units.add(Number(match[1]));
            });
        }

        if (units.size !== 1) return;
        radios.push({ band: band, unit: Array.from(units)[0] });
    });

    return radios;
}

function wrNodeClientBandHint(client) {
    if (!client) return '';

    // Prefer an explicit named band. Without that, only isWL=1/2 are treated as
    // cross-generation band hints. Modern BE clients have been observed using
    // higher logical isWL values (including 4 and 5) for the same 6 GHz radio,
    // so those values must not be translated into a physical radio or band here.
    var named = wrNormalizeBand(wrFirst(client, ['band', 'wlBand']));
    if (/^(?:2G|5G|5G1|5G2|6G|6G1|6G2)$/.test(named)) return named;

    var raw = client.isWL;
    if (raw === undefined || raw === null) return '';
    var value = String(raw).trim();
    if (value === '1') return '2G';
    if (value === '2') return '5G';
    return '';
}

function wrNodeBandInfoUnits(node) {
    var bandInfo = node && node.band_info;
    if (!bandInfo || typeof bandInfo !== 'object') return [];

    var units = new Set();
    Object.keys(bandInfo).forEach(function(key) {
        var unit = Number(bandInfo[key] && bandInfo[key].unit);
        if (Number.isFinite(unit) && Math.floor(unit) === unit && unit >= 0) units.add(unit);
    });
    return Array.from(units).sort(function(a, b) { return a - b; });
}

function wrNodeClientRadioContext(node, client, preferredBand) {
    if (!node || !client) return null;

    var bandHint = wrNormalizeBand(preferredBand) || wrNodeClientBandHint(client);
    var capabilityRadios = wrNodeCapabilityRadios(node);

    if (capabilityRadios !== null) {
        // Capability data is authoritative when present. Require one exact logical
        // band match; if the inventory is malformed/ambiguous, return unknown
        // rather than falling through to an unsafe physical-unit guess.
        if (!bandHint) return null;
        var matches = capabilityRadios.filter(function(radio) {
            return radio.band === bandHint;
        });
        return matches.length === 1
            ? { unit: matches[0].unit, band: matches[0].band, source: 'capability' }
            : null;
    }

    var expectedUnit = wrClientRadioUnitFromIsWL(client);
    if (expectedUnit === null) return null;

    var units = wrNodeBandInfoUnits(node);
    if (units.indexOf(expectedUnit) === -1) return null;

    // A node's firmware determines whether the ordinal isWL -> wlX conversion is
    // valid, not the controller's diagnostic endpoint. Preserve all validated 388
    // units even behind a 3006 primary. Unknown/latest no-capability nodes remain
    // conservative and only use the established dual-radio 2G/5G mapping.
    if (!wrNodeLegacySemantics(node) && !(units.length === 2 && expectedUnit <= 1)) return null;

    return { unit: expectedUnit, band: bandHint, source: wrNodeLegacySemantics(node) ? 'legacy' : 'compat' };
}

function wrNodeClientRadioUnit(node, client) {
    var context = wrNodeClientRadioContext(node, client);
    return context ? context.unit : null;
}

function wrNodeClientIfaceFallback(node, client, preferredBand) {
    // A positive isGN value is an observed VIF slot and can safely be appended
    // after the node's physical radio has been resolved. Blank/zero isGN carries
    // no suffix semantics: captures prove normal front-haul clients can be .1 on
    // 388 nodes and .2 on 3006 nodes, so blank isGN must use discovered FH data.
    var guest = wrPositiveGuestIndex(client);
    if (guest === null) return '';

    var context = wrNodeClientRadioContext(node, client, preferredBand);
    if (!context) return '';
    return 'wl' + context.unit + '.' + guest;
}

function wrNodeClientBandFallback(node, client) {
    var context = wrNodeClientRadioContext(node, client);
    return context && context.band ? context.band : '';
}

function wrStaIface(sta, client, node, fallbackIface) {
    // Prefer ASUS' explicit interface string whenever stainfo supplies it.
    var direct = String(sta && sta.conn_if || '').trim();
    if (direct) return direct;

    // conn_if_idx/vidx belong to the station's reporting node. A 388 node behind
    // a 3006 controller still uses legacy index semantics, so key this decision
    // to the node family rather than WR_DIAG_API. Primary-router reconstruction
    // remains controller-family based because the primary owns the endpoint.
    var legacyIndexes = node ? wrNodeLegacySemantics(node) : WR_DIAG_API === 'legacy';
    if (legacyIndexes && sta) {
        var idxRaw = sta.conn_if_idx;
        var vidxRaw = sta.conn_if_vidx;
        var idx = Number(idxRaw);
        var vidx = Number(vidxRaw);
        var idxValid = idxRaw !== undefined && idxRaw !== null && String(idxRaw).trim() !== '' &&
            Number.isFinite(idx) && Math.floor(idx) === idx && idx >= 0;
        var vidxValid = vidxRaw !== undefined && vidxRaw !== null && String(vidxRaw).trim() !== '' &&
            Number.isFinite(vidx) && Math.floor(vidx) === vidx && vidx >= 0;
        if (idxValid) return 'wl' + idx + (vidxValid && vidx > 0 ? '.' + vidx : '');
    }

    var liveIface = String(wrFirst(client, ['ifname', 'interface']) || '').trim();
    if (liveIface && !legacyIndexes) return liveIface;

    // Explicit positive isGN can reconstruct a guest VIF once the physical radio
    // is known. Blank isGN deliberately cannot synthesize bare wlX or wlX.1/.2.
    var nodeFallback = wrNodeClientIfaceFallback(node, client, sta && sta.sta_band);
    if (nodeFallback) return nodeFallback;

    // Asynchronous authoritative discovery (FH BSSID/driver BSSID -> wifi_detect)
    // is prepared on the item before render and supplied here as the final safe
    // recovery before legacy primary-only inference.
    fallbackIface = String(fallbackIface || '').trim();
    if (/^wl[0-9]+(?:\.[0-9]+)?$/i.test(fallbackIface)) return fallbackIface;

    if (liveIface) return liveIface;

    if (!node) {
        var primaryFallback = wrLegacyClientIfaceFallback(client);
        if (primaryFallback) return primaryFallback;
    }

    return '';
}

function wrStaSsidNvramKey(sta, client, fallbackIface) {
    var iface = wrStaIface(sta, client, null, fallbackIface);
    if (!/^wl[0-9]+(?:\.[0-9]+)?$/i.test(iface)) return '';
    return iface.toLowerCase() + '_ssid';
}

function wrLegacyGuestSsidNvramKey(client) {
    // This key addresses the PRIMARY router's NVRAM namespace, not the node's
    // local wlX numbering. Preserve the established legacy-controller fallback,
    // where the synchronized primary/node radio ordering has already been used
    // successfully. A 388 node behind a 3006 primary must not substitute its
    // node-local isWL ordinal into the primary's potentially reordered BE/AX wlX
    // namespace; that mixed-generation case stays unknown unless an authoritative
    // primary-band -> VIF translation is available.
    if (WR_DIAG_API !== 'legacy') return '';

    var guest = wrPositiveGuestIndex(client);
    if (guest === null) return '';
    var unit = wrLegacyClientRadioUnit(client);
    if (unit === null) return '';
    return 'wl' + unit + '.' + guest + '_ssid';
}

function wrNodeBandSsid(node, sta, client) {
    if (!node) return '';
    // Do not replace a guest/SDN SSID with the radio's normal front-haul SSID.
    if (wrPositiveGuestIndex(client) !== null) return '';

    var band = wrNodeLegacySemantics(node) ? wrClientBandHint(client) : '';
    if (!band) band = wrNormalizeBand(sta && sta.sta_band);
    if (!band) band = wrNodeClientBandFallback(node, client);
    return wrNodeFrontHaulSsid(node, band);
}

function wrExtractAssignedArray(source, name) {
    // ajax_wificlients.asp returns JavaScript assignments such as
    // dataarray1=[...] and wificlients1=[[...],...]. Extract the final
    // assignment without executing the response as script.
    source = String(source || '');
    name = String(name || '');
    var searchFrom = 0;
    var result = null;

    while (name) {
        var hit = source.indexOf(name, searchFrom);
        if (hit === -1) break;

        var before = hit > 0 ? source[hit - 1] : '';
        var after = source[hit + name.length] || '';
        if (/[A-Za-z0-9_$]/.test(before) || /[A-Za-z0-9_$]/.test(after)) {
            searchFrom = hit + name.length;
            continue;
        }

        var pos = hit + name.length;
        while (pos < source.length && /\s/.test(source[pos])) pos++;
        if (source[pos] !== '=') {
            searchFrom = hit + name.length;
            continue;
        }
        pos++;
        while (pos < source.length && /\s/.test(source[pos])) pos++;
        if (source[pos] !== '[') {
            searchFrom = hit + name.length;
            continue;
        }

        var start = pos;
        var depth = 0;
        var quote = '';
        var escaped = false;
        var end = -1;

        for (var i = start; i < source.length; i++) {
            var ch = source[i];
            if (quote) {
                if (escaped) {
                    escaped = false;
                    continue;
                }
                if (ch.charCodeAt(0) === 92) {
                    escaped = true;
                    continue;
                }
                if (ch === quote) quote = '';
                continue;
            }
            if (ch === '"' || ch === "'") {
                quote = ch;
                continue;
            }
            if (ch === '[') {
                depth++;
                continue;
            }
            if (ch === ']') {
                depth--;
                if (depth === 0) {
                    end = i;
                    break;
                }
            }
        }

        if (end === -1) break;
        try {
            result = JSON.parse(source.slice(start, end + 1));
        } catch (e) {
            console.warn('Wireless Report could not parse ' + name + ' from Wireless Log data', e);
        }
        searchFrom = end + 1;
    }

    return result;
}

async function wrGetPrimaryDriverInventory() {
    // ASUS' native Wireless Log is backed by the wireless driver's per-VIF
    // authenticated station lists. Preserve the existing driver-backed SSID
    // behavior and also retain each radio's AP BSSID so missing-stainfo IFACE/BAND
    // can be discovered through an exact wifi_detect query without assuming radio
    // order on tri-/quad-band AX/BE hardware.
    var r = await fetch('/ajax_wificlients.asp?_wr=' + Date.now(), {
        method: 'GET',
        credentials: 'same-origin',
        cache: 'no-store'
    });
    if (!r.ok) throw new Error('ajax_wificlients.asp HTTP ' + r.status);

    var source = await r.text();
    var units = new Set();
    var unitMatcher = /\bwificlients([0-9]+)\s*=/g;
    var unitMatch;
    while ((unitMatch = unitMatcher.exec(source)) !== null) units.add(Number(unitMatch[1]));

    var radios = new Map();
    var candidates = new Map();
    units.forEach(function(unit) {
        var radio = wrExtractAssignedArray(source, 'dataarray' + unit);
        var clients = wrExtractAssignedArray(source, 'wificlients' + unit);
        if (!Array.isArray(clients)) return;

        var mainSsid = Array.isArray(radio) ? String(radio[0] || '').trim() : '';
        var apBssid = Array.isArray(radio) ? wrNormMac(radio[5] || '') : '';
        radios.set(unit, {
            unit: unit,
            ssid: mainSsid,
            bssid: wrIsMac(apBssid) ? apBssid : ''
        });

        clients.forEach(function(row) {
            if (!Array.isArray(row)) return;
            var mac = wrNormMac(row[0]);
            if (!wrIsMac(mac)) return;

            // ASUS leaves row[12]/row[13] empty for the main BSS. On a guest
            // VIF they contain that VIF's SSID and VLAN respectively.
            var guestSsid = String(row[12] || '').trim();
            var ssid = guestSsid || mainSsid;
            if (!ssid) return;

            var list = candidates.get(mac) || [];
            list.push({
                ssid: ssid,
                unit: unit,
                guest: Boolean(guestSsid),
                vlan: String(row[13] || '').trim(),
                apBssid: wrIsMac(apBssid) ? apBssid : '',
                mainSsid: mainSsid
            });
            candidates.set(mac, list);
        });
    });

    var clients = new Map();
    candidates.forEach(function(list, mac) {
        if (list.length === 1) clients.set(mac, list[0]);
    });
    return { clients: clients, radios: radios };
}

async function wrGetPrimaryDriverSsidMap() {
    return (await wrGetPrimaryDriverInventory()).clients;
}

function wrPrimaryDriverAssociation(item, driverMap) {
    if (!item || item.node || item.meshLinkNode || !(driverMap instanceof Map)) return null;

    // MLO candidates can occasionally point at equivalent driver rows. Collapse
    // identical associations by their radio/VIF identity and reject genuinely
    // ambiguous multi-radio results rather than selecting one arbitrarily.
    var unique = new Map();
    wrGetMloCandidates(item.mac, item.client, item.saved).forEach(function(mac) {
        var found = driverMap.get(mac);
        if (!found) return;
        var sig = [found.unit, found.ssid, found.guest ? 1 : 0, found.vlan, found.apBssid].join('|');
        unique.set(sig, found);
    });
    return unique.size === 1 ? Array.from(unique.values())[0] : null;
}

function wrPrimaryDriverSsid(item, driverMap) {
    var found = wrPrimaryDriverAssociation(item, driverMap);
    return found ? String(found.ssid || '').trim() : '';
}

function wrIsPrimaryMediaBridge(item) {
    // ASUS Media Bridge mode (opMode=4) can expose the bridge's management/base
    // MAC in get_clientlist() while the wireless driver authenticates a different
    // radio/STA MAC. Gate this narrowly so ordinary clients, AiMesh nodes and
    // offline Network Map records never enter the alias resolver.
    if (!item || item.node || item.meshLinkNode) return false;
    var client = item.client || {};
    if (String(client.opMode || '').trim() !== '4') return false;
    return client.isOnline === true || String(client.isOnline || '').trim() === '1';
}

async function wrResolvePrimaryMediaBridge(item, mainMac, driverMap) {
    if (!wrIsPrimaryMediaBridge(item) || !(driverMap instanceof Map)) return null;
    if (!wrIsMac(wrNormMac(mainMac))) return null;

    // Normal exact/MLO association always wins. This helper exists only for the
    // measured Media Bridge case where the displayed management MAC is absent from
    // both the driver station map and stainfo.
    if (wrPrimaryDriverAssociation(item, driverMap)) return null;

    var ssid = String(
        wrFirst(item.client, ['ssid']) || wrFirst(item.saved, ['ssid']) || ''
    ).trim();
    if (!ssid) return null;

    // Do not infer the radio MAC from an ASUS MAC offset/prefix. Instead require
    // exactly one currently authenticated driver station whose effective SSID is
    // equivalent to the Media Bridge SSID. wrSsidEquivalent also tolerates the
    // one-character Network Map truncation observed on 3006.
    var matches = [];
    driverMap.forEach(function(association, mac) {
        if (!association) return;
        var driverSsid = String(association.ssid || '').trim();
        var driverMac = wrNormMac(mac);
        if (!driverSsid || !wrIsMac(driverMac) || !wrSsidEquivalent(ssid, driverSsid)) return;
        matches.push({ mac: driverMac, association: association });
    });
    if (matches.length !== 1) return null;

    var match = matches[0];
    var sta = await wrGetSta(mainMac, match.mac);
    if (!sta) return null;

    // The alias is accepted only when exact active stainfo proves a usable band
    // and interface for that driver MAC. Ambiguous/malformed cases stay unknown.
    var band = wrNormalizeBand(sta.sta_band);
    var iface = String(sta.conn_if || '').trim();
    if (!band || !/^wl[0-9]+(?:\.[0-9]+)?$/i.test(iface)) return null;

    return {
        mac: match.mac,
        association: match.association,
        sta: sta,
        source: 'media-bridge-ssid'
    };
}

function wrDecodeAsusRuleList(raw) {
    // appGet/nvram data has been observed both as literal <...> rule strings and
    // as numeric entities without semicolons (&#60 / &#62). Decode only the rule
    // delimiters we need; do not execute or broadly HTML-decode router content.
    return String(raw || '')
        .split('&#60;').join('<').split('&#62;').join('>')
        .split('&#60').join('<').split('&#62').join('>');
}

function wrParseApWifiRuleList(raw) {
    var decoded = wrDecodeAsusRuleList(raw);
    if (!decoded) return [];
    return decoded.split('<').filter(Boolean).map(function(entry) {
        var fields = entry.split('>');
        var ifaces = String(fields[1] || '').split(',').map(function(value) {
            return String(value || '').trim();
        }).filter(function(iface) {
            return /^wl[0-9]+(?:\.[0-9]+)?$/i.test(iface);
        });
        return {
            profile: String(fields[0] || '').trim(),
            ifaces: ifaces,
            sdnIdx: String(fields[2] || '').trim()
        };
    }).filter(function(rule) { return rule.ifaces.length > 0; });
}

function wrPrimaryGuestIface(association, client, radio, apWifiRules) {
    if (!association || !association.guest || !radio || !radio.iface) return '';
    var unit = wrIfaceUnit(radio.iface);
    if (unit === null) return '';

    // ap_wifi_rl's third field is the SDN index in the measured 3006 layout.
    // Only trust a live SDN index when the driver's VLAN agrees with the live
    // client VLAN (when both are available), then require one matching interface
    // on the physical radio discovered from the driver's AP BSSID.
    var driverVlan = String(association.vlan || '').trim();
    var liveVlan = String(wrFirst(client, ['vlan_id', 'vlanId']) || '').trim();
    var vlanAgrees = !driverVlan || !liveVlan || driverVlan === liveVlan;
    var sdnIdx = vlanAgrees ? String(wrFirst(client, ['sdn_idx', 'sdnIdx']) || '').trim() : '';

    if (sdnIdx && Array.isArray(apWifiRules)) {
        var matches = new Set();
        apWifiRules.forEach(function(rule) {
            if (!rule || String(rule.sdnIdx) !== sdnIdx) return;
            (rule.ifaces || []).forEach(function(iface) {
                if (wrIfaceUnit(iface) === unit) matches.add(iface);
            });
        });
        if (matches.size === 1) return Array.from(matches)[0];
    }

    // Positive isGN values were measured as the actual VIF suffix on both node
    // and primary 3006 clients. Use this only after the physical unit came from
    // the authoritative driver AP-BSSID -> wifi_detect mapping.
    var guest = wrPositiveGuestIndex(client);
    return guest === null ? '' : 'wl' + unit + '.' + guest;
}

async function wrResolveNodeFrontHaul(item) {
    if (!item || !item.node || !item.nodeMac || item.meshLinkNode) return null;
    if (wrPositiveGuestIndex(item.client) !== null) return null;

    var frontHauls = wrNodeFrontHauls(item.node);
    if (!frontHauls.length) return null;

    var selected = null;
    var staBand = wrNormalizeBand(item.sta && item.sta.sta_band);
    var legacyBand = wrNodeLegacySemantics(item.node) ? wrClientBandHint(item.client) : '';
    var trustedBand = staBand && legacyBand && staBand !== legacyBand
        ? legacyBand
        : (staBand || legacyBand || wrNodeClientBandHint(item.client));

    // Radio telemetry outranks Network Map SSID because the latter is the source
    // known to retain stale/truncated SDN metadata. This mirrors stale-stainfo
    // rejection on legacy nodes: when legacy live band and stainfo disagree, use
    // the validated live legacy band to select the node's advertised FH BSSID.
    if (trustedBand) {
        var bandMatches = frontHauls.filter(function(fh) { return fh.band === trustedBand; });
        if (bandMatches.length === 1) selected = bandMatches[0];
    }

    if (!selected) {
        var liveSsid = String(wrFirst(item.client, ['ssid']) || '').trim();
        var savedSsid = String(wrFirst(item.saved, ['ssid']) || '').trim();
        var ssid = liveSsid || savedSsid;
        if (ssid) {
            var ssidMatches = frontHauls.filter(function(fh) {
                return fh.ssid && wrSsidEquivalent(ssid, fh.ssid);
            });
            if (ssidMatches.length === 1) selected = ssidMatches[0];
        }
    }

    if (selected) {
        try {
            var detected = await wrWifiDetectBssid(item.nodeMac, selected.bssid);
            if (!detected) return null;
            return {
                band: detected.band || selected.band,
                iface: detected.iface,
                bssid: selected.bssid,
                ssid: selected.ssid,
                source: 'fh-bssid'
            };
        } catch (e) {
            console.warn('Wireless Report FH wifi_detect lookup failed for ' + selected.bssid, e);
            return null;
        }
    }

    // A legacy node can expose a blank client SSID while isWL still identifies
    // the physical radio. If no band label selected an FH entry, discover the
    // advertised FH mappings and require exactly one whose actual wl unit equals
    // the validated legacy ordinal. This preserves tri-radio 388 recovery without
    // pretending the ordinal itself tells us whether that radio is 5G-2 or 6G.
    if (wrNodeLegacySemantics(item.node)) {
        var expectedUnit = wrClientRadioUnitFromIsWL(item.client);
        if (expectedUnit !== null && wrNodeBandInfoUnits(item.node).indexOf(expectedUnit) !== -1) {
            var unitMatches = [];
            for (var i = 0; i < frontHauls.length; i++) {
                try {
                    var found = await wrWifiDetectBssid(item.nodeMac, frontHauls[i].bssid);
                    if (found && wrIfaceUnit(found.iface) === expectedUnit) {
                        unitMatches.push({ fh: frontHauls[i], detected: found });
                    }
                } catch (e) {
                    console.warn('Wireless Report legacy FH wifi_detect lookup failed for ' + frontHauls[i].bssid, e);
                }
            }
            if (unitMatches.length === 1) {
                var match = unitMatches[0];
                return {
                    band: match.detected.band || match.fh.band,
                    iface: match.detected.iface,
                    bssid: match.fh.bssid,
                    ssid: match.fh.ssid,
                    source: 'fh-unit'
                };
            }
        }
    }
    return null;
}

async function wrResolveFallbackTelemetry(items, mainMac, mainNode, primaryInventory, apWifiRuleRaw) {
    primaryInventory = primaryInventory || { clients: new Map(), radios: new Map() };
    var driverMap = primaryInventory.clients instanceof Map ? primaryInventory.clients : new Map();
    var apWifiRules = wrParseApWifiRuleList(apWifiRuleRaw);

    // Keep exact topology discovery sequential. wifi_detect can be a constrained
    // diagnostic CGI just like stainfo; the cache makes later clients/refreshes
    // reuse the first successful BSSID mapping without additional requests.
    for (var i = 0; i < items.length; i++) {
        var item = items[i];
        if (!item || item.meshLinkNode) continue;

        if (item.node) {
            var nodeFh = await wrResolveNodeFrontHaul(item);
            if (nodeFh) {
                item.wrFrontHaul = nodeFh;
                item.wrFallbackBand = nodeFh.band || '';
                item.wrFallbackIface = nodeFh.iface || '';
                // For an exact station interface, SSID correction must first prove
                // that conn_if is this discovered FH BSS (wrNodeMainSsidFromSta).
                // Only missing-interface cases may consume the FH SSID directly.
                if (!String(item.sta && item.sta.conn_if || '').trim()) {
                    item.wrFallbackSsid = nodeFh.ssid || '';
                }
            }
            continue;
        }

        if (WR_DIAG_API === 'legacy') {
            // A legacy primary can have the same blank-isGN ambiguity as a legacy
            // node. Treat its get_cfg_clientlist entry as the BSS owner and use
            // the identical advertised-FH BSSID discovery instead of bare wlX.
            if (mainNode && wrPositiveGuestIndex(item.client) === null) {
                var primaryFhItem = Object.assign({}, item, { node: mainNode, nodeMac: mainMac });
                var primaryFh = await wrResolveNodeFrontHaul(primaryFhItem);
                if (primaryFh) {
                    item.wrFallbackBand = primaryFh.band || '';
                    item.wrFallbackIface = primaryFh.iface || '';
                    if (!String(item.sta && item.sta.conn_if || '').trim()) {
                        item.wrFallbackSsid = primaryFh.ssid || '';
                    }
                }
            }
            continue;
        }

        if (WR_DIAG_API !== 'latest') continue;
        var association = wrPrimaryDriverAssociation(item, driverMap);

        // Media Bridge mode can use a management/base MAC in Network Map while the
        // primary wireless driver/stainfo use another radio STA MAC. If normal
        // exact/MLO association failed, resolve that identity only when the bridge
        // is online, opMode=4, one driver station uniquely matches its SSID, and an
        // exact active stainfo row validates that station. Keep the displayed MAC
        // unchanged and use the alias only as authoritative wireless telemetry.
        if (!association && wrIsPrimaryMediaBridge(item)) {
            try {
                var bridge = await wrResolvePrimaryMediaBridge(item, mainMac, driverMap);
                if (bridge) {
                    item.wrTelemetryMac = bridge.mac;
                    item.sta = bridge.sta;
                    association = bridge.association;
                    item.wrFallbackSsid = String(bridge.association.ssid || '').trim();
                }
            } catch (e) {
                console.warn('Wireless Report Media Bridge telemetry lookup failed for ' + item.mac, e);
            }
        }

        if (!association) continue;
        item.wrPrimaryDriver = association;

        // Existing exact stainfo remains authoritative. Only spend a wifi_detect
        // lookup when IFACE/BAND recovery is actually needed.
        var staIface = String(item.sta && item.sta.conn_if || '').trim();
        var staBand = wrNormalizeBand(item.sta && item.sta.sta_band);
        if (staIface && staBand) continue;
        if (!association.apBssid) continue;

        try {
            var radio = await wrWifiDetectBssid(mainMac, association.apBssid);
            if (!radio) continue;
            item.wrFallbackBand = radio.band || '';

            if (!association.guest) {
                item.wrFallbackIface = radio.iface || '';
            } else {
                item.wrFallbackIface = wrPrimaryGuestIface(
                    association, item.client, radio, apWifiRules
                );
            }
        } catch (e) {
            console.warn('Wireless Report primary driver BSSID lookup failed for ' + association.apBssid, e);
        }
    }
}

function wrNodeMainSsidFromSta(item) {
    if (!item || !item.node || !item.sta) return '';

    var iface = String(item.sta.conn_if || '').trim();
    var band = wrNormalizeBand(item.sta.sta_band);

    // When asynchronous FH discovery has already identified the station's exact
    // front-haul BSS, compare interfaces directly. This is generation-independent
    // and correctly handles .1 on the tested 388 AX92U and .2 on the 3006 BE92U.
    if (item.wrFrontHaul && item.wrFrontHaul.iface && iface === item.wrFrontHaul.iface) {
        return String(item.wrFrontHaul.ssid || wrNodeFrontHaulSsid(item.node, band) || '').trim();
    }

    // Preserve the established v3.1.9 exact wlX.1 stale-SSID repair when an
    // authoritative FH mapping could not be prepared. Blank isGN itself never
    // implies .1; this compatibility path starts from an exact stainfo conn_if.
    // When FH discovery did succeed and points elsewhere (for example .2 on the
    // tested BE92U), the mismatch above intentionally prevents this fallback.
    if (!item.wrFrontHaul && /^wl[0-9]+\.1$/i.test(iface)) {
        return wrNodeFrontHaulSsid(item.node, band);
    }
    return '';
}

async function wrResolveClientSsids(items, allNodes, mainMac, primaryDriverSsids) {
    // On 3006/latest firmware prefer ASUS' driver-backed Wireless Log inventory
    // for primary-router clients. AiMesh-node main/FH SSIDs can be recognized by
    // the authoritative BSSID -> wifi_detect interface prepared before this pass;
    // legacy exact wlX.1 remains only as a compatibility fallback.
    if (!(primaryDriverSsids instanceof Map)) {
        primaryDriverSsids = new Map();
        if (WR_DIAG_API === 'latest') {
            try {
                primaryDriverSsids = await wrGetPrimaryDriverSsidMap();
            } catch (e) {
                console.warn('Wireless Report driver-backed primary SSID lookup failed', e);
            }
        }
    }

    var mainNode = (allNodes || []).find(function(node) {
        return wrNormMac(node && (node.mac || node.mac_addr)) === wrNormMac(mainMac);
    }) || null;

    var primaryMissing = [];
    var nodeGuestMissing = [];
    var primaryKeys = new Set();

    items.forEach(function(item) {
        // The node-self entry represents the AiMesh uplink itself, not a client
        // associated to an advertised SSID. Keep that row intentionally blank.
        if (item.meshLinkNode) {
            item.resolvedSsid = '';
            return;
        }

        var driverSsid = WR_DIAG_API === 'latest'
            ? wrPrimaryDriverSsid(item, primaryDriverSsids)
            : '';
        if (driverSsid) {
            item.resolvedSsid = driverSsid;
            return;
        }

        var nodeMainSsid = wrNodeMainSsidFromSta(item);
        if (nodeMainSsid) {
            item.resolvedSsid = nodeMainSsid;
            return;
        }

        if (item.wrFallbackSsid) {
            item.resolvedSsid = item.wrFallbackSsid;
            return;
        }

        var direct = wrFirst(item.client, ['ssid']) || wrFirst(item.saved, ['ssid']);
        item.resolvedSsid = direct || '';
        if (item.resolvedSsid) return;

        if (item.node) {
            var guestKey = wrLegacyGuestSsidNvramKey(item.client);
            if (guestKey) {
                // AiMesh propagates the configured guest SSID from the primary.
                // Use live isWL/isGN to select that exact guest slot without
                // depending on intermittent node stainfo/conn_if data.
                item.guestSsidKey = guestKey;
                nodeGuestMissing.push(item);
                primaryKeys.add(guestKey);
                return;
            }
            item.resolvedSsid = wrNodeBandSsid(item.node, item.sta, item.client) || '';
            return;
        }

        // Primary-router interface names belong to the primary, so an exact
        // <conn_if>_ssid lookup is valid here and retains guest/virtual SSIDs.
        primaryMissing.push(item);
        var key = wrStaSsidNvramKey(item.sta, item.client, item.wrFallbackIface);
        if (key) primaryKeys.add(key);
    });

    var nvramSsids = {};
    if (primaryKeys.size) {
        var hook = Array.from(primaryKeys).map(function(key) {
            return 'nvram_get(' + key + ');';
        }).join('');
        try {
            nvramSsids = await wrAppGet(hook);
        } catch (e) {
            console.warn('Wireless Report primary SSID interface lookup failed', e);
        }
    }

    nodeGuestMissing.forEach(function(item) {
        var key = item.guestSsidKey || '';
        var fromGuest = key ? String(nvramSsids[key] || '').trim() : '';
        if (fromGuest) item.resolvedSsid = fromGuest;
        delete item.guestSsidKey;
    });

    primaryMissing.forEach(function(item) {
        var sta = item.sta;
        // Preserve the live client hint here too: when stainfo is absent, the
        // primary IFACE fallback needs isWL/isGN to recover wlX[.Y].
        var key = wrStaSsidNvramKey(sta, item.client, item.wrFallbackIface);
        var fromIface = key ? String(nvramSsids[key] || '').trim() : '';
        if (fromIface) {
            item.resolvedSsid = fromIface;
            return;
        }

        // Never replace a virtual-interface SSID with the main radio's SSID if
        // the exact primary NVRAM lookup failed. For a non-virtual interface,
        // the primary's advertised band SSID is a safe final fallback.
        var iface = wrStaIface(sta, item.client, null, item.wrFallbackIface);
        var vidx = wrNumber(sta && sta.conn_if_vidx);
        var isVirtual = iface.indexOf('.') !== -1 || (Number.isFinite(vidx) && vidx > 0);
        if (!isVirtual) item.resolvedSsid = wrNodeBandSsid(mainNode, sta, item.client) || '';
    });
}

function wrGetMloCandidates(mac, liveClient, savedClient) {
    var candidates = new Set();
    function add(value) {
        if (!value) return;
        if (typeof value === 'string') {
            var matches = value.match(/[0-9A-Fa-f]{2}(?::[0-9A-Fa-f]{2}){5}/g);
            if (matches) matches.forEach(function(x) { candidates.add(wrNormMac(x)); });
        }
    }
    add(mac);
    [
        savedClient && savedClient.mlo_2G_mac,
        savedClient && savedClient.mlo_5G_mac,
        savedClient && savedClient.mlo_5G1_mac,
        savedClient && savedClient.mlo_6G_mac,
        savedClient && savedClient.mlo_6G1_mac,
        savedClient && savedClient.mlo_all_mac
    ].forEach(add);
    if (liveClient && liveClient.mlo_links) {
        try { add(JSON.stringify(liveClient.mlo_links)); } catch (_) {}
    }
    return Array.from(candidates);
}

async function wrAppGet(hook) {
    var r = await fetch('/appGet.cgi', {
        method: 'POST',
        credentials: 'same-origin',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ hook: hook })
    });
    if (!r.ok) throw new Error('appGet.cgi HTTP ' + r.status);
    return r.json();
}

async function wrDiagLatest(db, content, filter) {
    var r = await fetch('/get_diag_latest_content_data.cgi', {
        method: 'POST',
        credentials: 'same-origin',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ db: db, content: content, filter: filter || '' })
    });
    if (!r.ok) throw new Error('latest diagnostic API HTTP ' + r.status);
    return r.json();
}

function wrDiagLegacyDuration(db) {
    // stainfo is sampled frequently and can become large over a long window.
    // Ten minutes is ample for current client telemetry while keeping 388
    // responses bounded. sys_detect is much smaller, so retain a one-hour
    // window for node CPU/memory/temperature reporting tolerance.
    return db === 'stainfo' ? 600 : 3600;
}

async function wrDiag388(db, content, filter) {
    var params = new URLSearchParams({
        db: db,
        content: content,
        ts: Math.floor(Date.now() / 1000),
        duration: wrDiagLegacyDuration(db),
        filter: filter || ''
    });
    var r = await fetch('/get_diag_content_data.cgi?' + params.toString(), {
        method: 'GET',
        credentials: 'same-origin',
        cache: 'no-store'
    });
    if (!r.ok) throw new Error('legacy diagnostic API HTTP ' + r.status);

    var data = await r.json();
    // The 388 endpoint returns historical rows. Keep them newest-first so
    // callers that need one row see current data, while batch callers can
    // still collapse the full result by station MAC.
    if (data && Array.isArray(data.contents)) {
        data.contents = data.contents.slice().sort(function(a, b) {
            return Number((b && b[0]) || 0) - Number((a && a[0]) || 0);
        });
    }
    return data;
}

// Diagnostic telemetry is exposed through different WebUI CGI endpoints by
// firmware generation. Detect the working endpoint once per page session.
// Promise sharing is important on 388 because several AiMesh node/station
// requests are launched together during report refresh.
var WR_DIAG_API = 'unknown'; // unknown | latest | legacy
var WR_DIAG_PROBE_PROMISE = null;

// wifi_detect BSSID mappings describe router/node BSS topology, not an
// individual station. Cache successful exact lookups for the lifetime of the
// generated page. A changed BSSID naturally creates a new cache key, while
// promise sharing prevents simultaneous clients from duplicating the same CGI
// request during the first refresh.
var WR_WIFI_BSSID_CACHE = new Map();
var WR_WIFI_BSSID_PENDING = new Map();
var WR_WIFI_BSSID_FAILURES = new Map();

function wrDiagRequestKey(db, content, filter) {
    return String(db) + '\n' + String(content) + '\n' + String(filter || '');
}

async function wrProbeDiagApi(db, content, filter) {
    if (WR_DIAG_API !== 'unknown') {
        return { api: WR_DIAG_API, key: '', result: null };
    }

    if (!WR_DIAG_PROBE_PROMISE) {
        var probeKey = wrDiagRequestKey(db, content, filter);
        WR_DIAG_PROBE_PROMISE = (async function() {
            try {
                var latestResult = await wrDiagLatest(db, content, filter);
                WR_DIAG_API = 'latest';
                return { api: 'latest', key: probeKey, result: latestResult };
            } catch (latestError) {
                try {
                    var legacyResult = await wrDiag388(db, content, filter);
                    WR_DIAG_API = 'legacy';
                    console.info('Wireless Report: using 388 legacy diagnostic API.');
                    return { api: 'legacy', key: probeKey, result: legacyResult };
                } catch (legacyError) {
                    var error = new Error('No supported diagnostic API responded');
                    error.latestError = latestError;
                    error.legacyError = legacyError;
                    throw error;
                }
            }
        })();
    }

    try {
        return await WR_DIAG_PROBE_PROMISE;
    } catch (e) {
        // Permit a future refresh to retry after a transient httpd/network error.
        WR_DIAG_API = 'unknown';
        WR_DIAG_PROBE_PROMISE = null;
        throw e;
    }
}

async function wrDiag(db, content, filter) {
    if (WR_DIAG_API === 'latest') return wrDiagLatest(db, content, filter);
    if (WR_DIAG_API === 'legacy') return wrDiag388(db, content, filter);

    var key = wrDiagRequestKey(db, content, filter);
    var probe = await wrProbeDiagApi(db, content, filter);
    if (probe.key === key) return probe.result;

    return probe.api === 'legacy'
        ? wrDiag388(db, content, filter)
        : wrDiagLatest(db, content, filter);
}

async function wrWifiDetectBssid(nodeMac, bssid) {
    var targetNode = wrNormMac(nodeMac);
    var targetBssid = wrNormMac(bssid);
    if (!wrIsMac(targetNode) || !wrIsMac(targetBssid)) return null;

    var key = targetNode + '|' + targetBssid;
    if (WR_WIFI_BSSID_CACHE.has(key)) return WR_WIFI_BSSID_CACHE.get(key);
    if (WR_WIFI_BSSID_PENDING.has(key)) return WR_WIFI_BSSID_PENDING.get(key);

    // Do not turn one transient/empty topology lookup into N identical CGI calls
    // for N clients on the same BSS. Suppress failures briefly, then allow a later
    // refresh to retry without requiring a page reload.
    var failedAt = Number(WR_WIFI_BSSID_FAILURES.get(key) || 0);
    if (failedAt && Date.now() - failedAt < 5000) return null;

    var promise = (async function() {
        try {
            var columns = ['data_time', 'node_type', 'node_ip', 'node_mac', 'band', 'ifname', 'mac'];
            var filter =
                'node_mac>txt>' + targetNode + '>0;' +
                'mac>txt>' + targetBssid + '>0;';
            var data = await wrDiag('wifi_detect', columns.join(';'), filter);
            var rows = data && Array.isArray(data.contents) ? data.contents : [];
            var best = null;

            rows.forEach(function(row) {
                if (!Array.isArray(row)) return;
                var rowNode = wrNormMac(row[3]);
                var rowMac = wrNormMac(row[6]);
                var iface = String(row[5] || '').trim();
                if (rowNode !== targetNode || rowMac !== targetBssid ||
                    !/^wl[0-9]+(?:\.[0-9]+)?$/i.test(iface)) return;

                var candidate = {
                    time: Number(row[0]) || 0,
                    nodeMac: rowNode,
                    bssid: rowMac,
                    band: wrNormalizeBand(row[4]),
                    iface: iface
                };
                if (!best || candidate.time > best.time) best = candidate;
            });

            if (best) {
                WR_WIFI_BSSID_CACHE.set(key, best);
                WR_WIFI_BSSID_FAILURES.delete(key);
            } else {
                WR_WIFI_BSSID_FAILURES.set(key, Date.now());
            }
            return best;
        } catch (e) {
            WR_WIFI_BSSID_FAILURES.set(key, Date.now());
            throw e;
        }
    })();

    WR_WIFI_BSSID_PENDING.set(key, promise);
    try {
        return await promise;
    } finally {
        WR_WIFI_BSSID_PENDING.delete(key);
    }
}

function wrNodeDiagFromRow(row) {
    if (!row) return null;
    return {
        timestamp: Number(row[0]),
        nodeType: row[1],
        ip: row[2],
        mac: wrNormMac(row[3]),
        cpuUsage: wrNumber(row[4]),
        memoryUsage: wrNumber(row[5]),
        cpuTemp: wrNumber(row[6])
    };
}

async function wrGetNodeDiag(mac) {
    var cols = ['data_time', 'node_type', 'node_ip', 'node_mac', 'cpu_usage', 'mem_usage', 'cpu_temp'];
    var targetMac = wrNormMac(mac);
    var data = await wrDiag(
        'sys_detect',
        cols.join(';'),
        'node_mac>txt>' + targetMac + '>0;'
    );
    var rows = data && Array.isArray(data.contents) ? data.contents : [];
    var latest = null;
    rows.forEach(function(row) {
        if (!row || wrNormMac(row[3]) !== targetMac) return;
        if (!latest || Number(row[0]) > Number(latest[0])) latest = row;
    });
    return wrNodeDiagFromRow(latest);
}

function wrCpuUsageBetween(first, second) {
    var totalDelta = 0;
    var usageDelta = 0;
    first = first || {};
    second = second || {};

    // GT-BE98 Pro cpu_usage() schema:
    // cpu_usage.cpu0.total / cpu_usage.cpu0.usage, etc.
    Object.keys(second).forEach(function(key) {
        if (!/^cpu[0-9]+$/.test(key)) return;
        var before = first[key] || {};
        var after = second[key] || {};
        var beforeTotal = wrNumber(before.total);
        var afterTotal = wrNumber(after.total);
        var beforeUsage = wrNumber(before.usage);
        var afterUsage = wrNumber(after.usage);
        if (!Number.isFinite(beforeTotal) || !Number.isFinite(afterTotal) ||
            !Number.isFinite(beforeUsage) || !Number.isFinite(afterUsage)) return;
        var td = afterTotal - beforeTotal;
        var ud = afterUsage - beforeUsage;
        if (td > 0 && ud >= 0) {
            totalDelta += td;
            usageDelta += ud;
        }
    });
    return totalDelta > 0 ? Math.round((usageDelta / totalDelta) * 100) : null;
}

function wrMemoryUsage(memory) {
    memory = memory || {};
    var total = wrNumber(memory.total);
    // ASUS exposes raw used (includes reclaimable cache) and simple_used.
    // simple_used is the useful human-facing utilization value.
    var used = wrNumber(memory.simple_used);
    if (!Number.isFinite(used)) used = wrNumber(memory.used);
    if (!Number.isFinite(total) || total <= 0 || !Number.isFinite(used)) return null;
    return Math.round((used / total) * 100);
}

async function wrGetMainMemoryUsage() {
    // Keep the primary-router memory source aligned with ASUS' human-facing
    // memory_usage().simple_used value. sys_detect is used for CPU consistency,
    // but this direct memory hook has already proven to match the native WebUI.
    var response = await wrAppGet('memory_usage();');
    var memory = (response && response.memory_usage) || {};
    var usage = wrMemoryUsage(memory);
    if (usage === null) {
        throw new Error('primary memory response did not contain usable counters');
    }
    return usage;
}

async function wrGetMainCpuFallback() {
    // sys_detect is the preferred CPU source for both the controller and nodes.
    // If a firmware does not publish a controller row, take two nearby counter
    // samples instead. Never span the full report refresh, which measures the
    // CPU work caused by Wireless Report itself and inflates the displayed load.
    async function sample() {
        var response = await wrAppGet('cpu_usage();');
        return (response && response.cpu_usage) || {};
    }

    var first = await sample();
    await new Promise(function(resolve) { setTimeout(resolve, 500); });
    var second = await sample();
    var cpu = wrCpuUsageBetween(first, second);
    if (cpu === null) {
        throw new Error('primary CPU fallback did not contain usable counters');
    }
    return cpu;
}

function wrNodeIsExplicitlyOffline(node) {
    if (!node) return false;

    // Match the original v2.1.0 presentation behavior: an unavailable node is
    // omitted from the report rather than shown with a status label. ASUS's
    // AiMesh inventory exposes the online field; use only explicit boolean-style
    // state signals here. Do not interpret the generic status field as an enum.
    if (node.online !== undefined && node.online !== null && node.online !== '') {
        return String(node.online) !== '1';
    }
    if (node.isOnline !== undefined && node.isOnline !== null && node.isOnline !== '') {
        var raw = String(node.isOnline).toLowerCase();
        if (node.isOnline === false || raw === 'false' || raw === '0') return true;
        if (node.isOnline === true || raw === 'true' || raw === '1') return false;
    }

    // If ASUS omits the explicit state flag, keep the node rather than risk
    // hiding a healthy node because a firmware exposes a different schema.
    return false;
}

function wrStaFromRow(row) {
    if (!row) return null;
    var obj = {};
    WR_STA_COLUMNS.forEach(function(name, i) { obj[name] = row[i]; });
    return obj;
}

async function wrGetStaRows(nodeMac) {
    try {
        var targetNode = wrNormMac(nodeMac);
        var filter = 'node_mac>txt>' + targetNode + '>0;sta_active>txt>1>0;';
        var data = await wrDiag('stainfo', WR_STA_COLUMNS.join(';'), filter);
        var rows = data && Array.isArray(data.contents) ? data.contents : [];
        var latestBySta = new Map();

        // 3006/latest may return only one latest broad-match row; 388/history
        // may return many samples per station. In either case expose at most the
        // newest active sample for each station to the rest of the report.
        rows.forEach(function(row) {
            var obj = wrStaFromRow(row);
            if (!obj || wrNormMac(obj.node_mac) !== targetNode || String(obj.sta_active) !== '1') return;
            var staMac = wrNormMac(obj.sta_mac);
            if (!staMac) return;
            var old = latestBySta.get(staMac);
            if (!old || Number(obj.data_time) > Number(old.data_time)) latestBySta.set(staMac, obj);
        });
        return Array.from(latestBySta.values());
    } catch (e) {
        console.warn('STAINFO batch query failed for ' + nodeMac, e);
        return [];
    }
}

async function wrGetSta(nodeMac, staMac, expectedBand) {
    try {
        var targetNode = wrNormMac(nodeMac);
        var targetSta = wrNormMac(staMac);
        var targetBand = wrNormalizeBand(expectedBand);
        var filter =
            'node_mac>txt>' + targetNode + '>0;' +
            'sta_mac>txt>' + targetSta + '>0;' +
            'sta_active>txt>1>0;';
        var data = await wrDiag('stainfo', WR_STA_COLUMNS.join(';'), filter);
        var rows = data && Array.isArray(data.contents) ? data.contents : [];
        var latest = null;
        var latestBandMatch = null;

        rows.forEach(function(row) {
            var obj = wrStaFromRow(row);
            if (!obj || wrNormMac(obj.node_mac) !== targetNode ||
                wrNormMac(obj.sta_mac) !== targetSta || String(obj.sta_active) !== '1') return;
            if (!latest || Number(obj.data_time) > Number(latest.data_time)) latest = obj;
            if (targetBand && wrNormalizeBand(obj.sta_band) === targetBand &&
                (!latestBandMatch || Number(obj.data_time) > Number(latestBandMatch.data_time))) {
                latestBandMatch = obj;
            }
        });
        return latestBandMatch || latest;
    } catch (_) {
        return null;
    }
}

function wrIndexSta(rows) {
    var map = new Map();
    rows.forEach(function(sta) {
        var mac = wrNormMac(sta.sta_mac);
        if (!mac) return;
        var old = map.get(mac);
        if (!old || Number(sta.data_time) > Number(old.data_time)) map.set(mac, sta);
    });
    return map;
}

function wrLooksWireless(c) {
    if (!c) return false;
    // Network Map can retain an old SSID/RSSI/rates/isWL tuple after a station
    // disconnects. An explicit offline state therefore wins over those cached
    // fields; driver/stainfo absence must not be backfilled from stale telemetry.
    if (c.isOnline !== undefined && (c.isOnline === false || String(c.isOnline) === '0')) return false;
    if (c.isWL !== undefined && c.isWL !== null && c.isWL !== '') {
        var w = Number(c.isWL);
        if (Number.isFinite(w)) return w > 0;
    }
    return Boolean(c.ssid || c.wlAuth || c.amesh_papMac || c.amesh_pap_mac);
}

function wrNodeDisplayName(node) {
    var ip = String(wrFirst(node, ['ip', 'ip_addr', 'ipAddr']) || '');
    var custom = WR_CUSTOM_NODE_NAMES[ip];
    return custom || wrFirst(node, ['name', 'nickName', 'model_name', 'product_id', 'alias']) || ip || wrNormMac(wrFirst(node, ['mac', 'mac_addr']));
}

function wrRenderRow(item, history, known, firstHistoryLoad) {
    var c = item.client;
    var saved = item.saved;
    var sta = item.sta;
    var mac = item.mac;
    var rawIp = wrFirst(c, ['ip']) || '';
    var rawName = wrClientName(mac, c, saved);
    var rawSsid = item.resolvedSsid || wrFirst(c, ['ssid']) || wrFirst(saved, ['ssid']) || '';
    var ip = rawIp.length > 15 ? rawIp.slice(0, 15) : rawIp;
    var name = rawName.length > 20 ? rawName.slice(0, 20) : rawName;
    var ssid = rawSsid;
    var iface = wrStaIface(sta, c, item.node, item.wrFallbackIface);
    var rssi = wrItemRssi(item);
    var rx = sta && sta.sta_rx !== undefined ? Math.round(wrNumber(sta.sta_rx)) : Math.round(wrNumber(c.curRx));
    var tx = sta && sta.sta_tx !== undefined ? Math.round(wrNumber(sta.sta_tx)) : Math.round(wrNumber(c.curTx));
    var connected = sta && sta.conn_time !== undefined ? sta.conn_time : c.wlConnectTime;
    var quality = wrQuality(rssi);
    var trend = wrGetTrend(item, rssi, history);
    var isNew = !firstHistoryLoad && !known[mac] ? 'new-device-row' : '';
    var ipColorStyle = (WR_CONFIG.hostColor === 1) ? "" : "color: #64d2ff;";
    var macColorStyle = (WR_CONFIG.hostColor === 1) ? "color: #64d2ff;" : "";
    var nodeMarker = '';

    if (item.node) {
        var markerColor = wrNodeColor(item.nodeIndex, item.node);
        var hiddenNodeNum = "<span class='hidden-node-number' style='display:none;'>" + (item.nodeIndex + 1) + "</span>";
        var nodeMarker = "<sup style='color:" + markerColor + ";'>" + (item.nodeIndex + 1) + "</sup>";
        if (WR_CONFIG.hostColor) {
            name = "<span style='color:" + markerColor + ";'>" + wrEscape(name) + "</span>" + hiddenNodeNum;
        } else {
            name = "<span style='color:#ffffff;'>" + wrEscape(name) + "</span>" + nodeMarker + hiddenNodeNum;
        }
    } else if (WR_CONFIG.hostColor) {
        name = "<span style='color:" + WR_CONFIG.mainColor + ";'>" + wrEscape(name) + "</span>";
    } else {
        name = wrEscape(name);
    }

    var rxText = Number.isFinite(rx) && rx >= 0 ? rx : 1;
    if (rxText === 0) rxText = 1;
    var txText = Number.isFinite(tx) && tx >= 0 ? tx : 1;
    if (txText === 0) txText = 1;
    if (rxText === 1 && txText === 1) {
        rxText = 1;
        txText = 72;
    }

    if (rxText > txText) {
        var T = rxText;
        rxText = txText;
        txText = T;
    }

    var rateText = rxText + ' / ' + txText;
    var rateSort = txText;
    var rssiText = Number.isFinite(rssi) && rssi < 0 && rssi >= -120 ? rssi : '--';
    var bars = quality.bars ? "<span class='rssi_bars " + quality.cls + "'>" + quality.bars + "</span>" : '';

    return "<tr class='" + isNew + "'>" +
        "<td style='text-align:left;'>" + name + "</td>" +
        "<td><span class='mac-val' style='" + macColorStyle + "' data-sort='" + wrEscape(mac) + "'>" + wrEscape(mac) + "</span>" +
        "<span class='ip-val' style='" + ipColorStyle + "' data-sort='" + wrIpSort(ip) + "'>" + wrEscape(wrDisplayIp(ip) || '--') + "</span></td>" +
        "<td data-sort='" + (Number.isFinite(rssi) ? rssi : -999) + "' class='rssi-container'>" +
            bars + " <span style='" + quality.style + "'>" + rssiText + "</span> " + trend + "</td>" +
        "<td data-sort='" + rateSort + "' style='" + quality.style + "text-align:center;'>" + wrEscape(rateText) + "</td>" +
        "<td><span class='ssid-val' data-sort='" + wrEscape(ssid) + "'>" + wrEscape(ssid || '--') + "</span>" +
        "<span class='iface-val' data-sort='" + wrEscape(iface) + "'>" + wrEscape(iface || '--') + "</span></td>" +
        wrBandHtml(sta, c, item.meshLinkNode, item.node, item.wrFallbackBand) +
        "<td>" + wrFormatConnection(connected) + "</td>" +
        "</tr>";
}

function wrApplyRssiCounts(items) {
    var counts = { excellent: 0, good: 0, fair: 0, poor: 0 };
    items.forEach(function(item) {
        var rssi = wrItemRssi(item);
        var q = wrQuality(rssi);
        if (q.key) counts[q.key]++;
    });
    Object.keys(counts).forEach(function(key) {
        document.querySelectorAll('.wr-rssi-' + key).forEach(function(el) {
            el.textContent = counts[key];
        });
    });
}

function wrSetHtml(id, html) {
    var el = document.getElementById(id);
    if (el) el.innerHTML = html;
}

function wrSetText(id, text) {
    var el = document.getElementById(id);
    if (el) el.textContent = text;
}

function wrSetMetric(id, value, suffix) {
    var el = document.getElementById(id);
    if (!el) return;
    el.className = wrMetricClass(value);
    el.textContent = value === null || value === undefined ? '--' : value + (suffix || '');
}

function wrRestoreTableState() {
    var ids = ['allTable', 'mainTable', 'nodeTable', 'popMainTable', 'popNodeTable'];
    ids.forEach(function(id) {
        var tableObj = document.getElementById(id);
        if (!tableObj || !tableObj.rows || tableObj.rows.length <= 1) return;
        var ipState = localStorage.getItem('toggle_' + id + '_show-ip');
        var ipHeader = tableObj.querySelector('thead th:nth-child(2)');
        if (ipState === 'true' || ipState === null) {
            tableObj.classList.add('show-ip');
            if (ipHeader) ipHeader.innerHTML = 'IP ADDRESS ⇅';
        } else {
            tableObj.classList.remove('show-ip');
            if (ipHeader) ipHeader.innerHTML = 'MAC ADDRESS ⇅';
        }
        var ifaceState = localStorage.getItem('toggle_' + id + '_show-iface');
        var ifaceHeader = tableObj.querySelector('thead th:nth-child(5)');
        if (ifaceState === 'true') {
            tableObj.classList.add('show-iface');
            if (ifaceHeader) ifaceHeader.innerHTML = 'IFACE ⇅';
        } else {
            tableObj.classList.remove('show-iface');
            if (ifaceHeader) ifaceHeader.innerHTML = 'SSID ⇅';
        }
        var savedCol = localStorage.getItem('savedSortCol_' + id);
        var savedDir = localStorage.getItem('savedSortDir_' + id);
        try {
            if (savedCol !== null) sortTable(parseInt(savedCol, 10), id, true, savedDir === 'desc');
            else sortTable(2, id, false, true);
        } catch (e) {
            console.warn('Sort restore failed for ' + id, e);
        }
    });
}

async function wrResolveSta(item, staMaps) {
    var nodeMac = item.nodeMac;
    if (!nodeMac) return null;
    var map = staMaps.get(nodeMac);
    var candidates = wrGetMloCandidates(item.mac, item.client, item.saved);
    var expectedBand = '';
    if (item.node) {
        if (wrNodeLegacySemantics(item.node)) expectedBand = wrClientBandHint(item.client);
    } else if (WR_DIAG_API === 'legacy') {
        expectedBand = wrClientBandHint(item.client);
    }
    var best = null;
    if (map) {
        candidates.forEach(function(candidate) {
            var found = map.get(candidate);
            if (found && (!best || Number(found.data_time) > Number(best.data_time))) best = found;
        });
    }

    // On some 388 AiMesh nodes conn_diag can leave more than one radio sample
    // marked active for the same station. The broad node query then occasionally
    // hands us the other radio (for example 2G while get_clientlist().isWL still
    // identifies the client as 5G). Accept the batch fast-path only when its band
    // agrees with that live-client hint; otherwise do the exact per-client query
    // and prefer the newest row from the expected band.
    if (best && (!expectedBand || wrNormalizeBand(best.sta_band) === expectedBand)) return best;

    var fallback = best;

    // ASUS get_diag_latest_content_data.cgi returns only one/latest matching
    // stainfo row for a broad node_mac query on the tested GT-BE98 Pro.
    // Therefore the batch map is only a fast-path hint, not a complete station
    // inventory. Fall back to the proven per-client node_mac + sta_mac query
    // for BOTH primary-router and AiMesh-node clients when the batch map misses
    // or a legacy batch row disagrees with the live-client band.
    best = null;
    for (var i = 0; i < candidates.length; i++) {
        var found = await wrGetSta(nodeMac, candidates[i], expectedBand);
        if (found && (!best || Number(found.data_time) > Number(best.data_time))) best = found;
    }
    return best || fallback;
}

async function loadWirelessReport() {
    // Primary memory remains a direct WebUI measurement. Start it alongside the
    // client inventory so it does not add latency to the normal report refresh.
    var mainMemoryPromise = wrGetMainMemoryUsage().catch(function(e) {
        console.warn('Primary memory query failed', e);
        return null;
    });

    var base = await wrAppGet(
        'get_cfg_clientlist();' +
        'get_clientlist();' +
        'get_clientlist_from_json_database();' +
        'nvram_get(productid);' +
        'nvram_get(lan_hwaddr);' +
        'nvram_get(ap_wifi_rl);' +
        'uptime();'
    );

    var live = base.get_clientlist || {};
    var saved = base.get_clientlist_from_json_database || {};
    var allNodes = Array.isArray(base.get_cfg_clientlist) ? base.get_cfg_clientlist : [];
    var mainMac = wrNormMac(base.lan_hwaddr || '');
    var discoveredNodes = allNodes.filter(function(n) {
        var mac = wrNormMac(n.mac || n.mac_addr);
        return wrIsMac(mac) && (!mainMac || mac !== mainMac);
    });

    // v2.1.0 omitted unreachable nodes because failed node collection produced
    // no node output. Recreate that presentation with the controller's explicit
    // online flag. Track omitted-node MACs so stale clients from those nodes are
    // omitted too instead of falling through into the primary-router table.
    var offlineNodeMacs = new Set();
    var nodes = discoveredNodes.filter(function(node) {
        if (!wrNodeIsExplicitlyOffline(node)) return true;
        var mac = wrNormMac(node.mac || node.mac_addr);
        if (mac) offlineNodeMacs.add(mac);
        return false;
    });

    // Match the shell menus' deterministic IP order. get_cfg_clientlist() can
    // return AiMesh nodes in a different order, which previously juxtaposed
    // node names, numeric markers and positional colors in the WebUI.
    nodes.sort(function(a, b) {
        var aip = String(wrFirst(a, ['ip', 'ip_addr', 'ipAddr']) || '');
        var bip = String(wrFirst(b, ['ip', 'ip_addr', 'ipAddr']) || '');
        var cmp = wrIpSort(aip).localeCompare(wrIpSort(bip));
        if (cmp) return cmp;
        return wrNormMac(a.mac || a.mac_addr).localeCompare(wrNormMac(b.mac || b.mac_addr));
    });

    var nodeByMac = new Map();
    nodes.forEach(function(node, index) {
        var mac = wrNormMac(node.mac || node.mac_addr);
        nodeByMac.set(mac, { node: node, index: index });
    });

    var staTargets = [];
    if (mainMac) staTargets.push(mainMac);
    nodes.forEach(function(node) {
        var mac = wrNormMac(node.mac || node.mac_addr);
        if (mac && staTargets.indexOf(mac) === -1) staTargets.push(mac);
    });

    var staResults = await Promise.all(staTargets.map(function(mac) { return wrGetStaRows(mac); }));
    var staMaps = new Map();
    staTargets.forEach(function(mac, i) { staMaps.set(mac, wrIndexSta(staResults[i] || [])); });
    var items = [];
    Object.entries(live).forEach(function(entry) {
        var macRaw = entry[0];
        var c = entry[1] || {};
        var mac = wrNormMac(macRaw);
        if (!wrIsMac(mac) || !wrLooksWireless(c)) return;
        var parent = wrNormMac(c.amesh_papMac || c.amesh_pap_mac);
        if (parent && offlineNodeMacs.has(parent)) return;
        var nodeInfo = nodeByMac.get(parent);
        // If the live-client MAC is itself an AiMesh node MAC, this row is the
        // node/backhaul pseudo-client. Keep it distinct from item.node, which
        // continues to mean an ordinary client associated through that node.
        var meshLinkInfo = nodeByMac.get(mac);
        var savedClient = wrSavedClient(saved, macRaw, mac);
        items.push({
            mac: mac,
            client: c,
            saved: savedClient,
            node: nodeInfo ? nodeInfo.node : null,
            nodeIndex: nodeInfo ? nodeInfo.index : -1,
            nodeMac: nodeInfo ? parent : mainMac,
            meshLinkNode: meshLinkInfo ? meshLinkInfo.node : null
        });
    });

    // Keep per-client stainfo fallback sequential. The diagnostic endpoint may
    // return only one/latest row for a broad node query, so every client missing
    // from the batch fast-path is resolved individually without flooding the CGI.
    for (var itemIndex = 0; itemIndex < items.length; itemIndex++) {
        // Node-self pseudo-clients are not ordinary stainfo stations. Even if a
        // firmware build happens to return a row, its radio need not be the
        // active backhaul selected by re_path, so keep this source isolated.
        if (items[itemIndex].meshLinkNode) {
            items[itemIndex].sta = null;
            continue;
        }
        items[itemIndex].sta = await wrResolveSta(items[itemIndex], staMaps);
    }

    // Reuse one driver-backed Wireless Log snapshot for both primary SSID and
    // missing-stainfo telemetry recovery. Node BSS topology is discovered from
    // advertised FH BSSIDs. Primary radio topology is discovered from dataarrayN
    // AP BSSIDs. Both routes use exact wifi_detect and cached results instead of
    // assuming wl order or a universal .1/.2 main-BSS suffix.
    var mainInventoryNode = allNodes.find(function(node) {
        return wrNormMac(node && (node.mac || node.mac_addr)) === mainMac;
    }) || null;
    var primaryDriverInventory = { clients: new Map(), radios: new Map() };
    if (WR_DIAG_API === 'latest') {
        try {
            primaryDriverInventory = await wrGetPrimaryDriverInventory();
        } catch (e) {
            console.warn('Wireless Report driver-backed primary inventory lookup failed', e);
        }
    }
    await wrResolveFallbackTelemetry(items, mainMac, mainInventoryNode, primaryDriverInventory, base.ap_wifi_rl);

    // SSID compatibility reuses the same current driver snapshot. For nodes, the
    // discovered FH interface also generalizes the v3.1.9 stale-main-SSID repair
    // beyond wlX.1 while retaining that exact legacy fallback for older nodes.
    await wrResolveClientSsids(items, allNodes, mainMac, primaryDriverInventory.clients);

    // Match v2.1.0's report-wide sample time so the Main, Node and All views show
    // the same timestamp for a given refresh and the persisted sample matches it.
    var historySampleTime = Date.now();
    items.forEach(function(item) { item.historyTime = historySampleTime; });
    var mainItems = items.filter(function(item) { return !item.node; });
    var nodeItems = items.filter(function(item) { return !!item.node; });

    // Use the same ASUS sys_detect CPU telemetry for the primary router and
    // AiMesh nodes. This keeps the values comparable and avoids measuring the
    // controller's CPU across Wireless Report's own refresh workload.
    var diagMacs = [];
    if (mainMac) diagMacs.push(mainMac);
    nodes.forEach(function(node) {
        var mac = wrNormMac(node.mac || node.mac_addr);
        if (mac && diagMacs.indexOf(mac) === -1) diagMacs.push(mac);
    });

    var diagPairs = await Promise.all(diagMacs.map(async function(mac) {
        try { return [mac, await wrGetNodeDiag(mac)]; }
        catch (e) {
            console.warn((mac === mainMac ? 'Primary' : 'Node') + ' diagnostic query failed for ' + mac, e);
            return [mac, null];
        }
    }));

    var diagByMac = new Map(diagPairs);
    var history = wrLoadJson('wirelessReportRssiHistory', {});
    var known = wrLoadJson('wirelessReportKnownMacs', {});
    var firstHistoryLoad = Object.keys(known).length === 0;
    var mainRows = mainItems.map(function(item) { return wrRenderRow(item, history, known, firstHistoryLoad); }).join('');
    var nodeRows = nodeItems.map(function(item) { return wrRenderRow(item, history, known, firstHistoryLoad); }).join('');
    var allRows = items.map(function(item) { return wrRenderRow(item, history, known, firstHistoryLoad); }).join('');
    document.querySelector('#mainTable tbody').innerHTML = mainRows || "<tr><td colspan='7'>No wireless clients reported on the primary router.</td></tr>";
    document.querySelector('#nodeTable tbody').innerHTML = nodeRows || "<tr><td colspan='7'>No AiMesh-node wireless clients reported.</td></tr>";
    document.querySelector('#allTable tbody').innerHTML = allRows || "<tr><td colspan='7'>No active wireless clients reported.</td></tr>";
    items.forEach(function(item) {
        var rssi = wrItemRssi(item);
        wrStoreRssiHistory(item, rssi, history);
        known[item.mac] = 1;
    });

    localStorage.setItem('wirelessReportRssiHistory', JSON.stringify(history));
    localStorage.setItem('wirelessReportKnownMacs', JSON.stringify(known));
    wrApplyRssiCounts(items);
    wrSetText('wr-grand-total', items.length);
    wrSetText('wr-main-count', mainItems.length);
    wrSetText('wr-node-count', nodeItems.length);
    wrSetText('wr-all-count', items.length);
    var mainDiag = diagByMac.get(mainMac) || null;
    var mainCpu = mainDiag && Number.isFinite(mainDiag.cpuUsage)
        ? Math.round(mainDiag.cpuUsage)
        : null;
    if (mainCpu === null) {
        try {
            mainCpu = await wrGetMainCpuFallback();
        } catch (e) {
            console.warn('Primary CPU fallback query failed', e);
        }
    }
    var mainMemory = await mainMemoryPromise;

    // Preserve a useful value if memory_usage() is unavailable on an unusual
    // firmware build; sys_detect already carries the same percentage for nodes.
    if (mainMemory === null && mainDiag && Number.isFinite(mainDiag.memoryUsage)) {
        mainMemory = Math.round(mainDiag.memoryUsage);
    }
    var mainHealth = { cpuUsage: mainCpu, memoryUsage: mainMemory };

    var mainNameEl = document.getElementById('wr-main-name');
    if (mainNameEl && !mainNameEl.textContent.trim()) mainNameEl.textContent = base.productid || 'Main Router';

    // Set Main Router specific metrics only here
    wrSetMetric('wr-main-cpu', mainHealth.cpuUsage, '%');
    wrSetMetric('wr-main-memory', mainHealth.memoryUsage, '%');
    var uptimeSecs = wrParseUptime(base.uptime);
    wrSetText('wr-main-uptime', wrFormatRouterUptime(uptimeSecs));
    var nodeNamesHtml = [];
    var cpuHtml = [];
    var memHtml = [];
    var nodeCountParts = [];
    var nodeDiagParts = [];

    // BUILD MAIN ROUTER DIAGNOSTIC DETAILS
    var mainNameText = mainNameEl ? mainNameEl.textContent.trim() : (base.productid || 'Main Router');
    var mainIp = String(wrFirst(base, ['lan_ipaddr', 'lan_ip', 'ip']) || window.location.hostname || '');

    if (typeof window._cachedMainFw === 'undefined' || !window._cachedMainFw) {
        var rawFw = wrFirst(base, ['firmver', 'buildno', 'extendno', 'version'])
            || window.firmware || window.firmver || '';
        var detectedFw = (rawFw && typeof rawFw === 'object') ? (rawFw.textContent || '') : String(rawFw || '');
        if (!detectedFw && typeof firmver !== 'undefined' && typeof buildno !== 'undefined') {
            detectedFw = firmver + '_' + buildno;
            if (typeof extendno !== 'undefined' && extendno) detectedFw += '_' + extendno;
        }
        if (detectedFw) {
            detectedFw = detectedFw.split('-')[0];
            window._cachedMainFw = detectedFw;
        }
    }
    var mainFw = window._cachedMainFw || '';

    var mainDiag = "<span class='main-color'>" + wrEscape(mainNameText) + "</span>";
    if (mainIp) mainDiag += " <span style='color:white;'>•</span> <span style='color:white;'>" + wrEscape(mainIp) + "</span>";
    if (mainFw) mainDiag += " <span style='color:white;'>•</span> <span class='main-color'>FW</span> <span style='color:white;'>" + wrEscape(mainFw) + "</span>";

    nodes.forEach(function(node, index) {
        var mac = wrNormMac(node.mac || node.mac_addr);
        var ip = String(wrFirst(node, ['ip', 'ip_addr', 'ipAddr']) || '');
        var name = wrNodeDisplayName(node);
        var color = wrNodeColor(index, node);
        var marker = (WR_CONFIG.hostColor === 0 && nodes.length > 1) ? '<sup>' + (index + 1) + '</sup>' : '';
        var diag = diagByMac.get(mac);
        var nodeClientCount = nodeItems.filter(function(item) { return item.nodeIndex === index; }).length;
        nodeNamesHtml.push("<span style='color:" + color + ";'>" + wrEscape(name) + marker + "</span>");
        nodeCountParts.push("<span style='color:" + color + ";'>" + nodeClientCount + "</span>");
        if (diag && diag.cpuUsage !== null) {
            cpuHtml.push("<span class='" + wrMetricClass(diag.cpuUsage) + "'>" + diag.cpuUsage + "%" + "</span>");
        } else {
            cpuHtml.push("<span style='color:" + color + ";'>--" + "</span>");
        }
        if (diag && diag.memoryUsage !== null) {
            memHtml.push("<span class='" + wrMetricClass(diag.memoryUsage) + "'>" + diag.memoryUsage + "%" + "</span>");
        } else {
            memHtml.push("<span style='color:" + color + ";'>--" + "</span>");
        }
        var firmware = wrFirst(node, ['firmware', 'fwver', 'fw_version', 'version']);
        if (firmware) {
            firmware = String(firmware);
            var dashIndex = firmware.indexOf('-');
            if (dashIndex !== -1) {
                firmware = firmware.substring(0, dashIndex);
            }
        }
        var details = "<span style='color:" + color + ";'>" + wrEscape(name) + "</span>";
        if (ip) details += " <span style='color:white;'>•</span> <span style='color:white;'>" + wrEscape(ip) + "</span>";
        if (firmware) details += " <span style='color:white;'>•</span> <span style='color:" + color + ";'>FW</span> <span style='color:white;'>" + wrEscape(firmware) + "</span>";
        nodeDiagParts.push(details);
    });

    var bullet = " <span style='color:white;'>•</span> ";

    wrSetHtml('wr-node-names', nodeNamesHtml.length ? nodeNamesHtml.join(bullet) : 'No AiMesh nodes detected');
    wrSetHtml('wr-node-cpu', cpuHtml.length ? cpuHtml.join(bullet) : '--');
    wrSetHtml('wr-node-memory', memHtml.length ? memHtml.join(bullet) : '--');
    wrSetHtml('wr-node-count', nodes.length > 1 && nodeCountParts.length ? nodeItems.length + " <span class='right-arrow'>—›</span> " + nodeCountParts.join(bullet) : nodeItems.length);
    wrSetHtml('wr-node-diag', nodeDiagParts.length ? nodeDiagParts.join('<br>') : 'No node diagnostic telemetry available.');

    // ASSEMBLED ALL-DEVICES COMBINED METRICS
    var allCpuCombined = [
        "<span class='" + wrMetricClass(mainHealth.cpuUsage) + "'>" + (mainHealth.cpuUsage !== null ? mainHealth.cpuUsage + "%" : "--") + "</span>"
    ].concat(cpuHtml);
    wrSetHtml('wr-all-cpu', allCpuCombined.join(bullet));
    var allMemCombined = [
        "<span class='" + wrMetricClass(mainHealth.memoryUsage) + "'>" + (mainHealth.memoryUsage !== null ? mainHealth.memoryUsage + "%" : "--") + "</span>"
    ].concat(memHtml);
    wrSetHtml('wr-all-memory', allMemCombined.join(bullet));
    var mainColoredCount = "<span class='main-color'>" + mainItems.length + "</span>";
    var allDeviceParts = [mainColoredCount].concat(nodeCountParts);
    wrSetHtml('wr-all-count', nodes.length > 1 && nodeCountParts.length ? items.length + " <span class='right-arrow'>—›</span> " + allDeviceParts.join(bullet) : items.length);
    var allNames = ["<span style='color:" + WR_CONFIG.mainColor + ";'>" + wrEscape(document.getElementById('wr-main-name').textContent) + "</span>"];
    allNames = allNames.concat(nodeNamesHtml);
    wrSetHtml('wr-all-names', allNames.join(bullet));
    var allDiagParts = [mainDiag].concat(nodeDiagParts.slice());
    wrSetHtml('wr-all-footer', allDiagParts.length ? allDiagParts.join('<br>') : 'No diagnostic telemetry available.');

    var nodeCol = document.getElementById('nodeCol');
    if (nodeCol) nodeCol.style.display = nodes.length ? 'flex' : 'none';

    // Apply dynamic font sizing based on node count (TEMP_STYLE)
    var nodeCount = nodes.length;
    var tempStyle = "";
    if (nodeCount > 4) {
        tempStyle = "text-align: center; justify-content: flex-start; font-size: 10px;";
    } else if (nodeCount === 4) {
        tempStyle = "text-align: center; justify-content: flex-start; font-size: 13px;";
    } else {
        tempStyle = "text-align: center; justify-content: center;";
    }

    ['wr-all-cpu', 'wr-all-memory', 'wr-node-cpu', 'wr-node-memory'].forEach(function(id) {
        var el = document.getElementById(id);
        if (el) {
            el.style.cssText += tempStyle;
        }
    });

    wrRestoreTableState();
    if (localStorage.getItem('wifiReportPopoutOpen') === 'true') {
        openPopout();
        wrRestoreTableState();
    }
}

async function initial() {
    show_menu();
    wrRemoveLiveCacheBuster();
    wrStartLiveReloadWatcher();
    wrPrepareRssiHistoryStorage();
    var savedView = localStorage.getItem('wifiReportView') || 'split';
    switchTab(savedView);
    var selectEl = document.getElementById('refresh-option');
    var savedRate = localStorage.getItem('wifiReportAutoRefresh') || '0';
    if (selectEl) selectEl.value = savedRate;
    initAutoRefresh(parseInt(savedRate, 10));
    await triggerRefresh();
}

var timeLeft = 0;
var refreshTimer = null;
var isRefreshing = false;

if (typeof WR_CONFIG !== 'undefined') {
    if (!WR_CONFIG.runtimeTracking) {
        localStorage.removeItem('wirelessReportRuntimeStats');
        var wrapper = document.querySelector('.button-refresh');
        var btn = document.querySelector('.button-trigger');
        if (wrapper) wrapper.style.removeProperty('--avg-text');
        if (btn) btn.style.removeProperty('--highlow-text');
    }
}

async function triggerRefresh() {
    if (isRefreshing) return;
    isRefreshing = true;
    var btn = document.querySelector('.button-trigger');
    var started = (window.performance && performance.now) ? performance.now() : Date.now();
    if (btn) {
        btn.innerText = 'Refreshing...';
        btn.classList.add('refresh-pulse');
    }
    try {
        await loadWirelessReport();
        update_time();
    } catch (e) {
        console.error('Wireless Report refresh failed', e);
        document.querySelectorAll('.wr-updated-time').forEach(function(el) { el.textContent = 'Unable to read controller APIs. Verify the primary WebUI session and reload.'; });
    } finally {
        var ended = (window.performance && performance.now) ? performance.now() : Date.now();
        var seconds = Math.max(0, (ended - started) / 1000);
        if (typeof WR_CONFIG !== 'undefined' && WR_CONFIG.runtimeTracking) {
            var currentSec = parseFloat(seconds) || 0.34;
            var stats = wrLoadJson('wirelessReportRuntimeStats', { total: 0, count: 0, min: null, max: 0 });
            stats.total += currentSec;
            stats.count += 1;
            stats.min = stats.min === null ? currentSec : Math.min(stats.min, currentSec);
            stats.max = Math.max(stats.max, currentSec);
            localStorage.setItem('wirelessReportRuntimeStats', JSON.stringify(stats));
            var avg = stats.total / stats.count;
            var wrapper = document.querySelector('.button-refresh');
            if (wrapper) {
                wrapper.style.setProperty('--avg-text', '"Avg: ' + avg.toFixed(2) + 's over ' + stats.count + ' scans"');
            }
            if (btn) {
                btn.classList.remove('refresh-pulse');
                btn.innerHTML = 'Refresh <span>' + currentSec.toFixed(2) + 's';
                btn.style.setProperty('--highlow-text', '"High: ' + stats.max.toFixed(2) + 's   Low: ' + stats.min.toFixed(2) + 's"');
            }
        } else {
            localStorage.removeItem('wirelessReportRuntimeStats');
            var wrapper = document.querySelector('.button-refresh');
            if (wrapper) wrapper.style.removeProperty('--avg-text');
            if (btn) {
                btn.classList.remove('refresh-pulse');
                btn.innerText = 'Refresh';
                btn.style.removeProperty('--highlow-text');
            }
        }
        isRefreshing = false;
    }
}

document.addEventListener("DOMContentLoaded", function() {
    if (typeof WR_CONFIG !== 'undefined' && WR_CONFIG.runtimeTracking) {
        var stats = wrLoadJson('wirelessReportRuntimeStats', { total: 0, count: 0, min: null, max: 0 });
        if (stats.count > 0) {
            var avg = stats.total / stats.count;
            var wrapper = document.querySelector('.button-refresh');
            var btn = document.querySelector('.button-trigger');
            if (wrapper) wrapper.style.setProperty('--avg-text', '"Avg: ' + avg.toFixed(2) + 's over ' + stats.count + ' scans"');
            if (btn) btn.style.setProperty('--highlow-text', '"High: ' + stats.max.toFixed(2) + 's   Low: ' + stats.min.toFixed(2) + 's"');
            if (btn) btn.innerHTML = 'Refresh ' + stats.max.toFixed(2) + 's';
        }
    }
});

function initAutoRefresh(seconds) {
    clearInterval(refreshTimer);
    timeLeft = Number(seconds) || 0;
    var countdown = document.getElementById('refresh-countdown');
    if (countdown) countdown.innerHTML = timeLeft > 0 ? '&nbsp;' + timeLeft + 's' : '';
    if (timeLeft <= 0) return;
    refreshTimer = setInterval(function() {
        timeLeft--;
        if (timeLeft <= 0) {
            timeLeft = Number(seconds) || 0;
            triggerRefresh();
        }
        if (countdown) countdown.innerHTML = '&nbsp;' + timeLeft + 's';
    }, 1000);
}

window.addEventListener('DOMContentLoaded', function() {
    var selectEl = document.getElementById('refresh-option');
    if (selectEl) {
        selectEl.addEventListener('change', function() {
            localStorage.setItem('wifiReportAutoRefresh', this.value);
            initAutoRefresh(parseInt(this.value, 10));
        });
    }
});

function switchTab(view) {
    localStorage.setItem('wifiReportView', view);
    var split = document.getElementById('splitView');
    var all = document.getElementById('allCol');
    var btnMain = document.getElementById('btnMain');
    var btnAll = document.getElementById('btnAll');
	var allBar = document.getElementById('allDevicesQualityBar');
    if(view === 'all') {
        if (split) split.style.display = 'none';
        if (all) all.style.display = 'flex';
		if (allBar) allBar.style.display = 'flex';
        if (btnAll) btnAll.classList.add('active');
        if (btnMain) btnMain.classList.remove('active');
    } else {
        if (split) split.style.display = 'flex';
        if (all) all.style.display = 'none';
		if (allBar) allBar.style.display = 'none';
        if (btnMain) btnMain.classList.add('active');
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
            h.innerHTML = "RSSI<span class='sup-header'>ᵈᴮᵐ</span>";
        } else if (txt.includes("RX/TX")) {
            h.innerHTML = "RX/TX<span class='sup-header'>ᵐᵇᵖˢ</span>";
        } else if (txt.includes("BAND")) {
            h.innerHTML = "BAND<span class='sup-header'>ᵐʰᶻ</span>";
        } else if (idx === 4) {
            h.innerHTML = table.classList.contains('show-iface') ? "IFACE ⇵" : "SSID ⇵";
        }
    });

    rows.sort(function(a, b) {
        var valA, valB;
        var cellA = a.cells[n];
        var cellB = b.cells[n];
        if (n === 0) {
            var getNodeNum = function(cell) {
                var hiddenSpan = cell.querySelector('.hidden-node-number');
                if (hiddenSpan) {
                    var text = hiddenSpan.innerText || hiddenSpan.textContent;
                    var numMatch = text.match(/\d+/);
                    if (numMatch) return parseInt(numMatch[0], 10);
                }
                var txt = cell.innerText.trim().toLowerCase();
                // If it's the main router or doesn't explicitly look like a node/ap, keep it at the top
                if (!txt.includes('node') && !txt.includes('ap') && !txt.includes('router')) {
                    return -1;
                }
                var match = txt.match(/\d+/);
                return match ? parseInt(match[0], 10) : -1;
            };

			var getCleanTxt = function(cell) {
				return cell.innerText.trim();
			};

			var isRightClick = (window.event && window.event.type === 'contextmenu');
			var isNodeModeSaved = (localStorage.getItem('savedSortNodeMode_' + tId) === 'true');
			if (isRightClick || isNodeModeSaved) {
				var nodeA = getNodeNum(cellA);
				var nodeB = getNodeNum(cellB);
				if (nodeA !== nodeB) {
					return dir === "asc" ? nodeA - nodeB : nodeB - nodeA;
				}
			}
			var txtA = getCleanTxt(cellA);
			var txtB = getCleanTxt(cellB);
			return dir === "asc" ? txtA.localeCompare(txtB) : txtB.localeCompare(txtA);
		}

        if (n === 1) {
            var sel = table.classList.contains('show-ip') ? '.ip-val' : '.mac-val';
            valA = cellA.querySelector(sel).getAttribute('data-sort');
            valB = cellB.querySelector(sel).getAttribute('data-sort');
            if (sel === '.mac-val') {
                return dir === "asc" ? valA.localeCompare(valB) : valB.localeCompare(valA);
            }
        } else if (n === 4) {
            var sel = table.classList.contains('show-iface') ? '.iface-val' : '.ssid-val';
            valA = cellA.querySelector(sel).innerText.trim().toLowerCase();
            valB = cellB.querySelector(sel).innerText.trim().toLowerCase();
        } else if (n === 6) {
            var spanA = cellA.querySelector('span[data-sort]');
            valA = spanA ? parseInt(spanA.getAttribute('data-sort'), 10) : 0;
            var spanB = cellB.querySelector('span[data-sort]');
            valB = spanB ? parseInt(spanB.getAttribute('data-sort'), 10) : 0;
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

function setWideButtonState(active) {
    var button = document.getElementById('btnWide');
    if (!button) return;
    button.textContent = active ? 'Exit Wide ⛶' : 'Wide View ⛶';
    button.classList.toggle('active', !!active);
}

function toggleWideView(forceState) {
    var active = document.body.classList.contains('wr-wide-mode');
    var next = (typeof forceState === 'boolean') ? forceState : !active;
    document.body.classList.toggle('wr-wide-mode', next);
    setWideButtonState(next);
    var container = document.getElementById('wifiReportContainer');
    if (next && container) container.scrollTop = 0;
}

function openPopout() {
    localStorage.setItem('wifiReportPopoutOpen', 'true');
    var body = document.getElementById('popoutBody'); body.innerHTML = "";
    var mCol = document.getElementById('mainCol');
    var nCol = document.getElementById('nodeCol');
    if (!mCol || !nCol) return;
    mCol = mCol.cloneNode(true);
    nCol = nCol.cloneNode(true);
    [mCol, nCol].forEach(c => {
        let h = c.querySelector('.temp-load-row'), s = c.querySelector('.section-header'), r = c.querySelector('.separator-line');
        if(h) Object.assign(h.style, { fontSize: "14px", lineHeight: "1.1", padding: "1px 0", margin: "0", height: "auto" });
        if(s) Object.assign(s.style, { paddingBottom: "0px", height: "auto" });
        if(r) Object.assign(r.style, { margin: "8px -11px 2px -11px" });
    });

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

    var mainWrapper = document.createElement('div');
    mainWrapper.className = 'popout-main-wrapper';
    Object.assign(mCol.style, { maxWidth: "100%", width: "100%", overflowX: "auto", WebkitOverflowScrolling: "touch" });
    mainWrapper.appendChild(mCol);
    var originalBar = document.querySelector('.rssi-quality-bar');
    if (originalBar) {
        var popoutBar = originalBar.cloneNode(true);
        popoutBar.id = "popoutQualityBar";
        Object.assign(popoutBar.style, { display: "flex", justifyContent: "center", margin: "15px auto 0 auto", width: "100%" });
        mainWrapper.appendChild(popoutBar);
    }
    body.appendChild(mainWrapper);
    body.appendChild(nCol);
    document.getElementById('popoutModal').style.display = 'flex';
}

function closePopout() {
    document.getElementById('popoutModal').style.display = 'none';
    localStorage.setItem('wifiReportPopoutOpen', 'false');
}

document.addEventListener('keydown', function(e) {
    if (e.key !== 'Escape') return;
    var modal = document.getElementById('popoutModal');
    if (modal && modal.style.display === 'flex') {
        closePopout();
        return;
    }
    if (document.body.classList.contains('wr-wide-mode')) {
        toggleWideView(false);
    }
});

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

document.addEventListener('mouseover', function(e) {
    const container = e.target.closest('.rssi-container');
    if (container) {
        const tooltip = container.querySelector('.rssi-tooltip');
        if (tooltip) {
            tooltip.style.visibility = 'visible';
            tooltip.style.opacity = '1';
        }
    }
});

document.addEventListener('mousemove', function(e) {
    const container = e.target.closest('.rssi-container');
    if (container) {
        const tooltip = container.querySelector('.rssi-tooltip');
        if (tooltip) {
            tooltip.style.left = (e.clientX + 15) + 'px';
            tooltip.style.top = (e.clientY - tooltip.offsetHeight - 15) + 'px';
        }
    }
});

document.addEventListener('mouseout', function(e) {
    const container = e.target.closest('.rssi-container');
    if (container) {
        const tooltip = container.querySelector('.rssi-tooltip');
        if (tooltip) {
            tooltip.style.visibility = 'hidden';
            tooltip.style.opacity = '0';
        }
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
                <div id="wifiReportContainer">
                    <div class="top-header">
                        <div class="header-wrap">
                            <div class="header-tooltip">
                                <h1 class="$HEADER_TITLE">WIRELESS REPORT</h1>
                                <span class="header-box">$HOVER_TEXT</span>
                            </div>
                        </div>
                        <div class="total-count">Total Wireless Devices: $GRAND_TOTAL_DEVICES</div>
                        <div class="top-buttons">
                            <div class="button-refresh">
                                <button class="button-trigger button-tables" onclick="triggerRefresh()">
                                Refresh
                                </button>
                                <div class="button-auto-refresh">
                                    <span>Auto:</span>
                                    <select id="refresh-option">
                                        <option value="0">Off</option>
                                        <option value="30">30s</option>
                                        <option value="60">1m</option>
                                        <option value="120">2m</option>
                                        <option value="300">5m</option>
                                        <option value="600">10m</option>
                                        <option value="1200">20m</option>
                                        <option value="1800">30m</option>
                                    </select>
                                    <span id="refresh-countdown"></span>
                                </div>
                            </div>
                            <button id="btnMain" class="button-tables active" onclick="switchTab('split')">Main</button>
                            <button id="btnAll" class="button-tables" onclick="switchTab('all')">All Devices</button>
                            <button class="button-tables" onclick="openPopout()" style="">Side by Side ⇗</button>
                            <button id="btnWide" class="button-tables" onclick="toggleWideView()">Wide View ⛶</button>
                        </div>
                    </div>
                    <div class="grid-container">
                        <div id="splitView">
                            <div id="mainCol" class="report-column">
                                <div class="section-header">
                                    $MAIN_NAME<br>
                                    $UPDATED_TIME
                                    <hr class="separator-line">
                                    <div class="temp-load-row">
                                        <span>CPU: $MAIN_CPU</span>
                                        <span>Memory: $MAIN_MEMORY</span>
                                        <span>Devices: $MAIN_DEVICE_TOTAL</span>
                                    </div>
                                </div>
                                <table id="mainTable" class="report_table show-ip">
                                    <thead><tr>
                                        <th onclick="sortTable(0, 'mainTable')">HOSTNAME</th>
                                        <th onclick="toggleCols('mainTable', 'show-ip', this, 'MAC ADDRESS', 'IP ADDRESS')">IP ADDRESS</th>
                                        <th onclick="sortTable(2, 'mainTable')">RSSI</th>
                                        <th onclick="sortTable(3, 'mainTable')">RX/TX PHY</th>
                                        <th onclick="toggleCols('mainTable', 'show-iface', this, 'SSID', 'IFACE')">SSID</th>
                                        <th onclick="sortTable(5, 'mainTable')">BAND</th>
                                        <th onclick="sortTable(6, 'mainTable')">UPTIME</th>
                                    </tr></thead>
                                    <tbody>$MAIN_ROWS</tbody>
                                    <tfoot>
                                        <tr>
                                            <td colspan="7" class="uptime-row">
                                                <span>Uptime: $MAIN_UPTIME</span>
                                                <span>Reboot: $MAIN_REBOOT</span>
                                            </td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                            <div class="rssi-quality-bar">
                                $RSSI_BOXES
                            </div>
                            <div id="nodeCol" class="report-column">
                                <div class="section-header">
                                    $NODE_NAMES<br>
                                    $UPDATED_TIME
                                    <hr class="separator-line">
                                    <div class="temp-load-row">
                                        <span>CPU: $NODE_CPU</span>
                                        <span>Memory: $NODE_MEMORY</span>
                                        <span>Devices: $NODE_DEVICE_TOTAL</span>
                                    </div>
                                </div>
                                <table id="nodeTable" class="report_table show-ip">
                                    <thead><tr>
                                        <th onclick="sortTable(0, 'nodeTable')">HOSTNAME</th>
                                        <th onclick="toggleCols('nodeTable', 'show-ip', this, 'MAC ADDRESS', 'IP ADDRESS')">IP ADDRESS</th>
                                        <th onclick="sortTable(2, 'nodeTable')">RSSI</th>
                                        <th onclick="sortTable(3, 'nodeTable')">RX/TX PHY</th>
                                        <th onclick="toggleCols('nodeTable', 'show-iface', this, 'SSID', 'IFACE')">SSID</th>
                                        <th onclick="sortTable(5, 'nodeTable')">BAND</th>
                                        <th onclick="sortTable(6, 'nodeTable')">UPTIME</th>
                                    </tr></thead>
                                    <tbody>$NODE_ROWS</tbody>
                                    <tfoot>
                                        <tr>
                                            <td colspan="7" class="uptime-row">
                                                $NODE_FOOTER
                                            </td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                        </div>
                        <div id="allCol" class="report-column">
                            <div class="section-header">
                                $ALL_NAMES<br>
                                $UPDATED_TIME
                                <hr class="separator-line">
                                <div class="temp-load-row">
                                    <span>CPU: $ALL_CPU</span>
                                    <span>Memory: $ALL_MEMORY</span>
                                    <span>Devices: $ALL_DEVICES</span>
                                </div>
                            </div>
                            <table id="allTable" class="report_table show-ip">
                                <thead><tr>
                                    <th onclick="sortTable(0, 'allTable')">HOSTNAME</th>
                                    <th onclick="toggleCols('allTable', 'show-ip', this, 'MAC ADDRESS', 'IP ADDRESS')">IP ADDRESS</th>
                                    <th onclick="sortTable(2, 'allTable')">RSSI</th>
                                    <th onclick="sortTable(3, 'allTable')">RX/TX PHY</th>
                                    <th onclick="toggleCols('allTable', 'show-iface', this, 'SSID', 'IFACE')">SSID</th>
                                    <th onclick="sortTable(5, 'allTable')">BAND</th>
                                    <th onclick="sortTable(6, 'allTable')">UPTIME</th>
                                </tr></thead>
                                <tbody>$ALL_ROWS</tbody>
                                <tfoot>
                                    <tr>
                                        <td colspan="7" class="uptime-row">
                                            $ALL_FOOTER
                                        </td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>
                        <div id="allDevicesQualityBar" class="rssi-quality-bar">
                            $RSSI_BOXES
                        </div>
                    </div>
                </div>
            </td>
        </tr>
    </table>
    <div id="footer"></div>
    <div id="popoutModal" class="popout-overlay" onclick="closePopout()">
        <div class="popout-content" onclick="event.stopPropagation()">
            <div style="height: 40px; position: relative;">
                <span class="popout-close-x" onclick="closePopout()">&times;</span>
            </div>
            <div id="popoutBody" class="popout-grid"></div>
        </div>
    </div>
</body>
HTML
    nvram set wirelessreport_gen="$WR_GENERATION" >/dev/null 2>&1
}
case "$1" in
    install)
        # Install/Uninstall options
        install_menu
        ;;
    inject|inject1|inject2|inject3)
        case "$1" in
            inject)  ;; # Called by services-start to mount tab
            inject1) NOLOADSCRIPT="1" ;; # Manual Tab Injection
            inject2) INJECT="2" ;; # Called by services-start to mount menu
            inject3) NOLOADSCRIPT="1"; INJECT="2" ;; # Manual Menu Injection
        esac
        inject_menu
        ;;
    amtmupdate)
        # Called by AMTM for autoupdates
		shift
        ScriptUpdateFromAMTM "$@"
        exit "$?"
        ;;
	*)
        # Run (Scans)
		run_report
        ;;
esac