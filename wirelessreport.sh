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
#=================================================================#
#        shellcheck shell=sh disable=SC2086,SC2155,SC3043         #
#=================================================================#

SCRIPT_VERSION="2.0.0"
INSTALL_DIR="/jffs/addons/wireless_report"
REPORT_SCRIPT="$INSTALL_DIR/wirelessreport.sh"
CONFIG="$INSTALL_DIR/webui.conf"
WEB_PAGE="/tmp/wireless.asp"
NEW_HISTORY="/tmp/rssi_new.db"
SEEN_MACS="/tmp/seen_macs.txt"
YAZ_CACHE="/tmp/yaz_cache.tmp"
ARP_CACHE="/tmp/arp_cache.tmp"
KNOWN_CACHE="/tmp/known_macs.cache"
HISTORY_CACHE="/tmp/rssi_history.cache"
LEASES_CACHE="/tmp/dnsmasq_leases.cache"
DHCPSTATIC_CACHE="/tmp/dhcp_static.cache"
DEVICE_LIST_CACHE="/tmp/asus_device_list.cache"
CUSTOM_CLIENTS_CACHE="/tmp/custom_clients.cache"
if [ -f "$CONFIG" ]; then . "$CONFIG"; fi
doScriptUpdateFromAMTM=true
unset LD_LIBRARY_PATH
export PATH="/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

#==================#
#  Script Install  #
#==================#
show_header() {
	clear; menu_vars
	echo -e "${BL}" #========================================================
	echo -e "                                                               "
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
	echo -e "${NC}" #========================================================
}

install_menu() {
	while true; do
		show_header
		echo -e "${BL}==================================================${NC}"
		echo -e " Copyright (c) 2026 JB_1366 - All Rights Reserved           "
		echo -e "    $JB1366                                                 "
		echo -e "${BL}==================================================${NC}"
		check_version
		echo -e "${BL}==================================================${NC}"
		echo -e "                                                            "
		echo -e "  $N1  Install/Update                                       "
		echo -e "  $N2  Uninstall                                            "
		echo -e "  $N3  Temp/Date ($DU) ($CT)                                "
		echo -e "  $N4  Router/Node Nicknames                                "
		echo -e "  $N5  Set Options  RT:($RTM) BH:($WB_STAT) RH:($RH_STAT)   "
		echo -e "  $N6  Node Authentication                                  "
		echo -e "  $N7  Setup SSH Environment (SSH-KEY:$KEY)                 "
		echo -e "  $NE  Exit                                                 "
		echo -e "                                                            "
		echo -e "${BL}==================================================${NC}"
		printf "\n ${BL}Selection:${NC} "
		read -r choice
        case "$choice" in
            1) do_install ;;
            2) do_uninstall ;;
            3) set_temp_date ;;
            4) set_nicknames ;;
            5) set_options ;;
            6) node_auth "pause" ;;
            7) check_ssh "pause" ;;
            e|E) clear; hasta; exit 0 ;;
            *) ;;
        esac
	done
}

check_version() {
	if [ ! -f "$REPORT_SCRIPT" ]; then LOCAL_VERSION="Not Installed"; fi
	if [ -z "$REMOTE_VERSION" ]; then
        echo -e " ${BL}STATUS:${NC} ${RD}[Offline]${NC} Could not reach GitHub"
    elif [ "$LOCAL_VERSION" = "Not Installed" ]; then
        echo -e " ${BL}STATUS:${NC} ${RD}[Not Installed]${NC} Latest Available: ${GR}v$REMOTE_VERSION${NC}"
    elif [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
        echo -e " ${BL}STATUS:${NC} [v$REMOTE_VERSION Available] ${GR}Current: v$LOCAL_VERSION${NC}"
	elif [ -n "$REMOTE_HASH" ] && [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
		echo -e " ${BL}STATUS:${NC} [Hash Update Available] ${GR}Current: v$LOCAL_VERSION${NC}"
	else
        echo -e " ${BL}STATUS:${NC} [Up to date] ${GR}Current: v$LOCAL_VERSION${NC}"
    fi
}

menu_vars() {
    if [ -f "$CONFIG" ]; then . "$CONFIG"; fi
	if [ -z "$RS_HIST_ENTRIES" ] && [ -n "$RS_HIST_DAYS" ]; then
		RS_HIST_ENTRIES="$RS_HIST_DAYS"
		sed -i 's/RS_HIST_DAYS/RS_HIST_ENTRIES/g' "$CONFIG" 2>/dev/null
	fi
	update_time
	BL='\033[38;5;39m'; GR='\033[0;32m'; NC='\033[0m'; RD='\033[0;31m'
    UL='\033[4m'; WH='\e[1;37m'; YL='\033[0;33m'; BG="\e[42;37m"
	JB1366="${GR}${UL}https://github.com/JB1366/Wireless_Report${NC}"
	N0="${BL}(0)${NC}"; N1="${BL}(1)${NC}"; N2="${BL}(2)${NC}"; N3="${BL}(3)${NC}"
	N4="${BL}(4)${NC}"; N5="${BL}(5)${NC}"; N6="${BL}(6)${NC}"; N7="${BL}(7)${NC}"
	NE="${BL}(e)${NC}"; NQ="${BL}(c)${NC}"; ON="${GR}ON${NC}"; OFF="${RD}OFF${NC}"
    SYSTEM_MENU="/www/require/modules/menuTree.js"
	TEMP_MENU="/tmp/menuTree.js"
	SS_FILE="/jffs/scripts/services-start"
	SE_FILE="/jffs/scripts/service-event"
	if [ -z "$SSH_KEY" ]; then KEY="${RD}NO${NC}"; else KEY="${GR}YES${NC}"; fi
	PORT="${GR}$SSH_PORT${NC}"
    DISPLAY_UNIT="${REPORT_UNIT:-F}"
    if [ "$REPORT_UNIT" = "ISO" ]; then DISPLAY_UNIT="C"; fi
	DU="${GR}°$DISPLAY_UNIT${NC}"; CT="${GR}$CUR_TIME${NC}"
	DATE_USA=$(date +"%b-%d"); DATE_INTL=$(date +"%d-%b"); DATE_ISO=$(date +"%Y-%m-%d")
	RTIME=${RTIME:-1}
    if [ "$RTIME" = "0" ]; then RTM="$OFF"; else RTM="$ON"; fi
    BACKHAUL=${BACKHAUL:-no}
    if [ "$BACKHAUL" = "no" ]; then WB_STAT="$OFF"; else WB_STAT="$ON"; fi
    PULSE_MINS=${PULSE_MINS:-15}
    if [ "$PULSE_MINS" = "0" ]; then UP_STAT="$OFF"; else UP_STAT="${GR}${PULSE_MINS} Mins${NC}"; fi
    RS_HIST=${RS_HIST:-0}
    CUR_RS_HIST=${CUR_RS_HIST:-$RS_HIST}
	CUR_ENTRIES=${CUR_ENTRIES:-${RS_HIST_ENTRIES:-5}}
	CUR_DATE=${CUR_DATE:-${RS_HIST_DATE:-0}}
    if [ "$RS_HIST" = "1" ]; then RH_STAT="$ON"; else RH_STAT="$OFF"; fi
	if [ "$CUR_RS_HIST" = "1" ]; then CH="$ON"; else CH="$OFF"; fi
	if [ "$CUR_DATE" = "1" ]; then TS="$ON"; else TS="$OFF"; fi
	CE="${GR}$CUR_ENTRIES${NC}"
    DARKMODE=${DARKMODE:-0}
    if [ "$DARKMODE" = "1" ]; then DM_STAT="$ON"; else DM_STAT="$OFF"; fi
	IPPAD=${IPPAD:-1}
	if [ "$IPPAD" = "2" ]; then PD_STAT="${GR}Last 2 Octets${NC}"
	elif [ "$IPPAD" = "1" ]; then PD_STAT="${GR}Last Octet${NC}"
	else PD_STAT="${RD}Disabled${NC}"; fi
	HOST_COLOR=${HOST_COLOR:-0}
	if [ "$HOST_COLOR" = "1" ]; then HN_STAT="${GR}Colored${NC}"
	else HN_STAT="${BL}Numbered${NC}"; fi
}

check_installed() {
	if [ ! -f "$REPORT_SCRIPT" ]; then
        echo -e "\n${RD}[!] ERROR: Wireless Report not Installed.${NC}\n"
        echo -e "${YL}[i] You must successfully run 'Install/Update' before changing settings.${NC}"
        pause
        return 1
    fi
    if [ ! -f "$CONFIG" ]; then touch "$CONFIG"; fi
    return 0
}

do_install() {
	mkdir -p "$INSTALL_DIR" 2>/dev/null
    if [ ! -f "$CONFIG" ]; then touch "$CONFIG"; fi
	local is_update=0
	if [ -f "$REPORT_SCRIPT" ]; then is_update=1; fi
	if [ "$is_update" = "1" ]; then
		if [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ] && [ -n "$REMOTE_VERSION" ]; then
			echo -e "\n${GR}[i] A new version (${NC}v$REMOTE_VERSION${GR}) is available!${NC}\n"
			printf "Do you want to update version (y/n): "
			read -r update
			case "$update" in [yY]) ;; *) return ;; esac
		elif [ "$VERHASH" = "[Hash]" ]; then
			echo -e "\n${GR}[i] There is a Hash Update for (${NC}v$LOCAL_VERSION${GR}).${NC}\n"
			printf "Do you want to update Hash? (y/n): "
			read -r update
			case "$update" in [yY]) ;; *) return ;; esac
		else
			echo -e "\n${GR}[i] You are already on the latest version (${NC}v$LOCAL_VERSION${GR}).${NC}\n"
			printf "Do you want to reinstall/overwrite anyway? (y/n): "
			read -r reinstall
			case "$reinstall" in [yY]) ;; *) return ;; esac
		fi
	fi
	do_update || return 1
	if [ "$is_update" = "1" ]; then
		echo -e "\n${GR}[✓] Wireless Report successfully installed.${NC}"
		echo -e "\n${GR}[!] Restarting script to apply changes...${NC}\n"
		sleep 2
		logger -p user.info -t "Wireless_Report" "(v$REMOTE_VERSION) successfully installed."
		exec "$REPORT_SCRIPT" install "$@"
		echo "${RD}Error: Failed to restart script!${NC}" >&2
		exit 1
	fi
    if [ "$(nvram get jffs2_scripts)" != "1" ]; then
        echo -e "${RD}[!] ERROR: JFFS custom scripts not enabled.${NC}"
        pause
		return 1
    fi
	check_storage
	if [ -f "$SSH_KEY" ]; then
		node_auth
	else
		install="1"
		echo -e "\n${GR}[+] Select Option #1 to setup SSH Keys.${NC}\n"
		sleep 5
		check_ssh || return 1
	fi
    echo -e "\n${GR}[+] Processing Wireless Report Files...${NC}\n"
    if [ -f "$TEMP_MENU" ]; then sed -i '/Wireless Report/d' "$TEMP_MENU" 2>/dev/null; fi
    if [ -f "$CONFIG" ]; then
        OLD_PAGE=$(grep "INSTALLED_PAGE=" "$CONFIG" | cut -d'=' -f2)
        if [ -n "$OLD_PAGE" ]; then
            umount -l "/www/user/$OLD_PAGE" 2>/dev/null
            rm -f "/www/user/$OLD_PAGE"
        fi
    fi
    if [ -f "$REPORT_SCRIPT" ]; then
        inject_menu
		echo -e "${GR}[+] Mounting Menu [Wireless] Tab [Wireless Report]${NC}\n"
        if [ ! -f "$SS_FILE" ]; then echo "#!/bin/sh" > "$SS_FILE"; fi
        sed -i "\|$REPORT_SCRIPT|d" "$SS_FILE"
        echo "sh $REPORT_SCRIPT inject # Inject Wireless Report" >> "$SS_FILE"
        chmod +x "$SS_FILE"
        if [ ! -f "$SE_FILE" ]; then echo "#!/bin/sh" > "$SE_FILE"; fi
        sed -i "/wireless_report/d" "$SE_FILE"
        echo 'if [ "$1" = "restart" ] && [ "$2" = "wireless_report" ]; then sh '$REPORT_SCRIPT'; fi # Wireless Report' >> "$SE_FILE"
        chmod +x "$SE_FILE"
		install=""; LOCAL_VERSION="$REMOTE_VERSION"
		logger -p user.info -t "Wireless_Report" "(v$REMOTE_VERSION) successfully installed."
        echo -e "${GR}[✓] SUCCESS: Installation complete!${NC}\n"
		echo -e "${YL}[i] To access Report, navigate to Advanced Settings > Wireless ${NC}"
		echo -e "${YL}    in the ASUS WebGUI and select the Wireless Report tab on the far right.${NC}\n"
		echo -e "${BL}[i] Tip: On router only install, you can add node(s) later.${NC}"
        echo -e "${BL}         Use option #6 in main menu to authenticate new node(s).${NC}\n"
		echo -e "${YL}[i] Use Option 4 if you wish to set custom nicknames.${NC}"
	else
        echo -e "${RD}[!] ERROR: Download failed.${NC}"
    fi
	pause
}

do_update() {
    local prefix="\n"
    if [ "$amtm" = "1" ]; then prefix="\n${BG} wr${NC} "; fi
    echo -e "${prefix}${GR}[+] Downloading latest version (${NC}v$REMOTE_VERSION${GR})${NC}"
    if curl -sfL --retry 3 "$GITHUB" -o "$REPORT_SCRIPT"; then
        chmod +x "$REPORT_SCRIPT" 2>/dev/null
        sleep 2
		return 0
    else
        if [ -f "$0" ]; then
            echo -e "\n${YL}[!] GitHub unreachable. Installing current local copy...${NC}\n"
            cp "$0" "$REPORT_SCRIPT"
            chmod +x "$REPORT_SCRIPT" 2>/dev/null
            return 0
        else
            echo -e "${RD}[!] Download failed. Aborting installation.${NC}"
            return 1
        fi
    fi
}

ScriptUpdateFromAMTM() {
    if [ "$doScriptUpdateFromAMTM" != "true" ]; then
        printf "Automatic updates via AMTM are currently disabled.\n\n"
        return 1
    fi
    if [ "$1" = "check" ]; then return 0; fi
	amtm=1; menu_vars
    if do_update; then
        echo -e "\n\n${BG} wr${NC}${GR} [✓] Wireless Report successfully updated${NC}\n"
		logger -p user.info -t "Wireless_Report" "AMTM Update: (v$REMOTE_VERSION) successfully installed."
		return 0
    else
        return 1
    fi
}

get_usb() {
	if [ -n "$USB_PATH" ]; then return; fi
	read -r uptime_val _ < /proc/uptime
	local BUP="${uptime_val%%.*}"
    local mount
    local FOUND=0
    for mount in /tmp/mnt/*; do
        [ -d "$mount" ] || continue
        if [ -d "$mount/wirelessreport" ]; then
            USB_PATH="$mount/wirelessreport"
            FOUND=1
            break
        fi
    done
    if [ "$FOUND" -eq 0 ] && [ "$BUP" -lt 300 ]; then
        sleep 2
        for mount in /tmp/mnt/*; do
            [ -d "$mount" ] || continue
            if [ -d "$mount/wirelessreport" ]; then
                USB_PATH="$mount/wirelessreport"
                FOUND=1
                break
            fi
        done
    fi
	if [ "$FOUND" -eq 1 ] && [ -d "$INSTALL_DIR/data" ] && [ ! -L "$INSTALL_DIR/data" ]; then
		if [ "$(ls -A "$INSTALL_DIR/data")" ]; then
			cp -a "$INSTALL_DIR/data/." "$USB_PATH/"
			rm -rf "$INSTALL_DIR/data"
		else
			rm -rf "$INSTALL_DIR/data"
		fi
	fi
    if [ "$FOUND" -eq 0 ]; then
        local ROOT_PATH=$(ls -d /tmp/mnt/*/ 2>/dev/null | grep -v "defaults" | head -n 1 | sed 's/\/$//')
        if [ -n "$ROOT_PATH" ]; then
            ROOT_PATH=$(echo "$ROOT_PATH" | sed 's/\/wirelessreport//g')
            USB_PATH="$ROOT_PATH/wirelessreport"
        else
            USB_PATH="$INSTALL_DIR/data"
        fi
    fi
    if [ -n "$USB_PATH" ] && [ ! -d "$USB_PATH" ]; then mkdir -p "$USB_PATH"; fi
    KNOWN_DB="$USB_PATH/known_macs.db"
	HISTORY_DB="$USB_PATH/rssi_history.db"
    ERROR_LOG="$USB_PATH/ssh_error.log"
	export USB_PATH KNOWN_DB HISTORY_DB ERROR_LOG
}

check_storage() {
    get_usb
	echo -e "\n${BL}[*] Checking for Storage...${NC}"
    sleep 3
	if echo "$USB_PATH" | grep -q "/tmp/mnt/"; then
        echo -e "\n${GR}[+] USB Found: Using $USB_PATH for reports and history.${NC}"
    else
        echo -e "\n${YL}[!] No USB detected: Using JFFS at $USB_PATH.${NC}"
    fi
    mkdir -p "$USB_PATH" 2>/dev/null
	if [ -n "$USB_PATH" ]; then
        touch "$USB_PATH/rssi_history.db"
        touch "$USB_PATH/known_macs.db"
    fi
}

check_github() {
	GITHUB="https://raw.githubusercontent.com/JB1366/Wireless_Report/main/wirelessreport.sh"
	LOCAL_VERSION=$(grep "SCRIPT_VERSION=" "$REPORT_SCRIPT" | head -n 1 | cut -d'"' -f2 2>/dev/null)
	LOCAL_HASH=$(sha256sum "$0" | awk '{print $1}')
	REMOTE_TMP="/tmp/wr_remote.tmp"
	if curl -sfL --retry 3 "$GITHUB" -o "$REMOTE_TMP" 2>/dev/null && [ -s "$REMOTE_TMP" ]; then
		REMOTE_VERSION=$(grep "SCRIPT_VERSION=" "$REMOTE_TMP" | head -n 1 | cut -d'"' -f2 | tr -cd '0-9.')
		REMOTE_HASH=$(sha256sum "$REMOTE_TMP" | awk '{print $1}')
	else
		REMOTE_VERSION=""; REMOTE_HASH=""
	fi
	rm -f "$REMOTE_TMP"
	if [ -n "$REMOTE_VERSION" ] && [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then VERHASH="[$REMOTE_VERSION]"
	elif [ -n "$REMOTE_HASH" ] && [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then VERHASH="[Hash]"
	else VERHASH=""; fi
}

ssh_init () {
	NODE_USER=$(nvram get http_username)
	SSH_PORT=$(nvram get sshd_port)
	SSH_PORT=${SSH_PORT:-22}
	if [ -f "/root/.ssh/id_dropbear" ]; then SSH_KEY="/root/.ssh/id_dropbear"
	else SSH_KEY=""; fi
}

check_ssh() {
	if [ "$1" = "pause" ]; then check_installed || return 1; fi
	while true; do
		show_header; get_usb
		echo -e "${BL}==================================================${NC}"
		echo -e "${BL}                 SSH Environment                  ${NC}"
		echo -e "${BL}==================================================${NC}"
		echo -e " SSH-Key: $KEY                          Port: $PORT         "
		echo -e "${BL}==================================================${NC}"
		echo -e "                                                            "
		echo -e "  $N1  Create RSA Keys & Setup AiMesh Nodes                 "
		echo -e "  $N2  Delete RSA Keys                                      "
		echo -e "  $N3  Router-Only Setup                                    "
		echo -e "  $N4  View Authorized Keys                                 "
		echo -e "  $N5  View Known Hosts                                     "
		echo -e "  $N6  View SSH Error Log                                   "
		echo -e "  $N7  Node Authentication                                  "
		echo -e "                                                            "
		echo -e "  $NE  Exit to main menu                                    "
		echo -e "                                                            "
		echo -e "${BL}==================================================${NC}"
		printf "\n ${BL}Selection:${NC} "
		read ssh_choice
		case "$ssh_choice" in
            1)
                ssh_keys
                if [ "$install" = "1" ]; then return 0; fi
                continue
                ;;
            2)
				del_ssh_keys
				continue
				;;
			3)
                echo -e "\n${YL}[i] Setting Up Router-Only...${NC}"
                sed -i '/^SSH_NODES=/d' "$CONFIG"
                echo 'SSH_NODES=" "' >> "$CONFIG"
                sleep 5
				pause
                continue
                ;;
            4)
                echo -e "\n${BL}================ Authorized Keys =================${NC}\n"
                if [ -f "/root/.ssh/authorized_keys" ]; then cat /root/.ssh/authorized_keys
                else echo -e "${YL}[!] File not found.${NC}"; fi
                echo -e "\n\n${BL}==================================================${NC}"
                pause
                continue
                ;;
            5)
                echo -e "\n${BL}================== Known Hosts  ==================${NC}\n"
                if [ -f "/jffs/.ssh/known_hosts" ]; then cat /jffs/.ssh/known_hosts
                else echo -e "${YL}[!] File not found.${NC}"; fi
                echo -e "\n${BL}==================================================${NC}"
                pause
                continue
                ;;
            6)
				echo -e "\n${BL}================= SSH Error Log ==================${NC}\n"
				if [ -f "$ERROR_LOG" ]; then
					cat "$ERROR_LOG"
					echo -e "\n\n${BL}==================================================${NC}"
					printf "\nRemove error log? (y/n): "
					read -r rm_log
					if [ "$rm_log" = "y" ] || [ "$rm_log" = "Y" ]; then
						rm -f "$ERROR_LOG"
						echo -e "\n${GR}[✓] Error log removed.${NC}"
						pause
					fi
				else
					echo -e "${YL}[!] File not found.${NC}"
					echo -e "\n${BL}==================================================${NC}"
					pause
				fi
				continue
				;;
            7)
                if [ "$install" = "1" ]; then
                    echo -e "\n${YL}[i] You must run option #1 first.${NC}"
                    pause
                    continue
                fi
                node_auth
                pause
                ;;
            e|E)
                return
                ;;
            *)
                continue
                ;;
        esac
	done
}

node_auth() {
	check_installed || return 1
	if [ ! -s "$SSH_KEY" ]; then echo -e "\n${YL}[!] Main Router SSH Key not found.${NC}"; sleep 3; return; fi
	sed -i '/^SSH_NODES=/d' "$CONFIG"
	echo -e "\n${GR}[✓] Main Router SSH Key found at: ${WH}$SSH_KEY${NC}\n"
	echo -e "${BL}==================================================${NC}"
    echo -e "${BL}          Verifying Node Authentication           ${NC}"
    echo -e "${BL}==================================================${NC}\n"
	UNSUPPORTED_MODELS="AX4200|AX1800S|XD4"
	AIMESH_NODES=$(nvram get asus_device_list | sed 's/</\n/g' | grep '>2$' | awk -F '>' '{print $2 "|" $3}' | grep -vE "$UNSUPPORTED_MODELS" | sort -t . -k 4,4n)
	if [ -z "$AIMESH_NODES" ]; then
		AIMESH_NODES=$(nvram get cfg_device_list | sed 's/</\n/g' | grep '>0$' | awk -F '>' '{print $1 "|" $2}' | grep -vE "$UNSUPPORTED_MODELS" | sort -t . -k 4,4n)
	fi
	if nvram get asus_device_list | grep -qE "$UNSUPPORTED_MODELS" || nvram get cfg_device_list | grep -qE "$UNSUPPORTED_MODELS"; then
		echo -e " ${YL}[!]${NC} These models not supported: TUF-AX4200, RT-AX1800S, ZENWIFI_XD4_PLUS."
	fi
    if [ -z "$AIMESH_NODES" ]; then
        echo -e "\n${RD}[!] No AiMesh Nodes detected in NVRAM.${NC}"
        TOTAL_NODES=0
        any_success=0
        ACTION_MSG="Force ROUTER-ONLY configuration"
        KEY_LBL="r"
    else
        TOTAL_NODES=$(echo "$AIMESH_NODES" | grep -o "|" | wc -l)
		any_success=0
        VALID_NODES=""
		new_nodes=0
        for line in $AIMESH_NODES; do
			ROUTER=$(echo "$line" | cut -d'|' -f1)
			IP=$(echo "$line" | cut -d'|' -f2)
			if [ -z "$IP" ]; then continue; fi
			if [ -z "$ROUTER" ]; then ROUTER="Node_$IP"; fi
			printf "[*] Testing ${GR}%-14s${NC} (%s) " "$ROUTER" "$IP"
            SSH_ERR=$(/usr/bin/ssh -p "$SSH_PORT" -i "$SSH_KEY" -o StrictHostKeyChecking=no -o BatchMode=yes "${NODE_USER}@${IP}" "exit" 2>&1 >/dev/null)
			SSH_RC=$?
			if [ -n "$SSH_ERR" ]; then
				echo "$SSH_ERR" | while read -r line; do
					ssh_error "$line"
				done
			fi
			if [ "$SSH_RC" -eq 0 ]; then
				echo -e "${GR}[✓] AUTHENTICATED${NC}"
				any_success=$((any_success + 1))
				VALID_NODES="$VALID_NODES $ROUTER|$IP"
				if ! grep -q "$IP" /jffs/.ssh/known_hosts 2>/dev/null; then
					echo -ne "    Capturing fingerprint & updating known_hosts "
					dbclient -y -p "$SSH_PORT" "$IP" "exit" > /dev/null 2>&1
					if grep -q "$IP" /root/.ssh/known_hosts 2>/dev/null; then
						grep "$IP" /root/.ssh/known_hosts >> /jffs/.ssh/known_hosts
						sort -u /jffs/.ssh/known_hosts -o /jffs/.ssh/known_hosts
						echo -e "${GR}[✓] DONE${NC}"
						new_nodes=$((new_nodes + 1))
						TARGET_KEY=$(awk -v ip="$IP" '$1 ~ ip {print $2, $3}' /jffs/.ssh/known_hosts 2>/dev/null)
						if [ -n "$TARGET_KEY" ]; then
							echo -e "    Node Host Key: ${BL}$TARGET_KEY${NC}"
						fi
					else
						echo -e "${RD}[✗] FAILED${NC}"
					fi
				fi
			else
				if echo "$SSH_ERR" | grep -q "No auth methods"; then
					echo -e "${RD}[✗] Failed: Invalid Username or SSH Key.${NC}"
				elif echo "$SSH_ERR" | grep -q "Connection refused"; then
					echo -e "${RD}[✗] Failed: SSH Connection refused.${NC}"
				else
					echo -e "${RD}[✗] Failed: Unknown connection issue.${NC}"
				fi
			fi
		done
    fi
    sed -i '/SSH_NODES=/d' "$CONFIG"
    if [ -z "$VALID_NODES" ]; then
        echo 'SSH_NODES=" "' >> "$CONFIG"
    else
        echo "SSH_NODES=\"$VALID_NODES\"" >> "$CONFIG"
    fi
    if [ "$any_success" -gt 0 ] && [ "$any_success" -eq "$TOTAL_NODES" ]; then
        echo -e "\n${GR}[✓] All nodes ($any_success/$TOTAL_NODES) authenticated successfully!${NC}"
        if [ "$new_nodes" -gt 0 ]; then
            [ "$new_nodes" -eq 1 ] && suffix="" || suffix="s"
            echo -e "\n${YL}[!] $new_nodes new node$suffix successfully authenticated.${NC}"
        fi
        [ "$1" = "pause" ] && pause
		return
    else
        if [ "$any_success" -gt 0 ]; then
            echo -e "\n${YL}[!] Partial Success: Only $any_success of $TOTAL_NODES nodes authenticated.${NC}"
            ACTION_MSG="Continue with current nodes only"
            KEY_LBL="c"
        else
            echo -e "\n${RD}[!] CRITICAL: SSH authentication failed on all nodes.${NC}\n"
            ACTION_MSG="Force ROUTER-ONLY configuration"
            KEY_LBL="r"
        fi
        if [ "$1" = "pause" ]; then
            echo -e "${BL}Choices:${NC}\n"
            echo -e "  ${BL}[Enter]${NC} Retry authentication"
            echo -e "  ${BL}[$KEY_LBL]${NC}     $ACTION_MSG"
            echo -e "  ${BL}[e]${NC}     Exit to main menu\n"
            printf "${BL}Selection: ${NC}"
            read -n 1 input
            case "$input" in
				[rR]|[cC])
					echo -e "\n\n${YL}[!] $ACTION_MSG...${NC}\n"
					if [ "$any_success" -eq 0 ]; then
						sed -i '/SSH_NODES=/d' "$CONFIG"
						echo 'SSH_NODES=" "' >> "$CONFIG"
					fi
					echo -e "${GR}[✓] Environment configuration locked in.${NC}"
					pause
					return
					;;
				[eE])
					read
					return
					;;
				*)
					echo -e "\n\n${BL}[i] Retrying authentication...${NC}"
					sleep 5
					node_auth "pause"
					return
					;;
			esac
        else
            sleep 2
        fi
    fi
}

ssh_keys() {
	if [ -f "$SSH_KEY" ]; then
		echo -e "\n${YL}[!] Main Router SSH Key already exists.${NC}"
		pause
		return 0
	fi
	if [ -f "/jffs/.ssh/id_dropbear" ] && [ ! -f "/root/.ssh/id_dropbear" ]; then
		echo -e "\n${GR}[!] Stored JFFS key detected. Linking and configuring...${NC}\n"
		sleep 3
	fi
	echo -e "${BL}==================================================${NC}"
    echo -e "${BL}                Generating SSH Key                ${NC}"
    echo -e "${BL}==================================================${NC}"
    if [ ! -f "/jffs/.ssh/id_dropbear" ]; then
        echo -e "\n${YL}[i] Creating RSA Key in JFFS...${NC}\n"
        mkdir -p /jffs/.ssh
        dropbearkey -t rsa -f /jffs/.ssh/id_dropbear
    fi
	rm -f /jffs/.ssh/known_hosts /root/.ssh/known_hosts >/dev/null 2>&1
    mkdir -p /root/.ssh
    cp /jffs/.ssh/id_dropbear /root/.ssh/id_dropbear
	SSH_KEY="/root/.ssh/id_dropbear"
    local pub_key=$(dropbearkey -y -f "/root/.ssh/id_dropbear" | grep "^ssh-rsa")
    local current_keys=$(nvram get sshd_authkeys)
	local combined_keys=$(printf "%s\n%s" "$current_keys" "$pub_key" | sed '/^$/d' | sort -u)
	echo -e "\n${YL}[i] Injecting Key into NVRAM...${NC}\n"
	nvram set sshd_authkeys="$combined_keys"
    nvram commit
	nvram get sshd_authkeys > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    if [ ! -f "$SS_FILE" ]; then echo "#!/bin/sh" > "$SS_FILE" && chmod +x "$SS_FILE"; fi
    if ! grep -q "id_dropbear" "$SS_FILE"; then
        echo -e "\n${YL}[i] Adding SSH Key to services-start for persistence on reboots...${NC}"
		echo -e "\n${YL}[i] Adding known_hosts to services-start...${NC}\n"
		echo "cp /jffs/.ssh/id_dropbear /tmp/home/root/.ssh/id_dropbear # sshpairs" >> "$SS_FILE"
        echo "cp /jffs/.ssh/known_hosts /tmp/home/root/.ssh/known_hosts # sshpairs persistence" >> "$SS_FILE"
    fi
	echo -e "${BL}==================================================${NC}"
	echo -e "${YL}               ACTION REQUIRED NOW                ${NC}"
    echo -e "${BL}==================================================${NC}\n"
	echo -e "${BL}[*] STEP 1: Go to Asus WebGUI > AiMesh > Management${NC}"
	echo -e "${BL}[*] STEP 2: Click 'Reboot Node' for each node${NC}\n"
	echo -e "${YL}[!] Do not press [Enter] until Nodes are confirmed to be back online.${NC}\n"
	echo -e "${BL}[*] TIP: If a node is missing after authentication,${NC}"
	echo -e "${BL}[*]      use option #6 to reauthenticate.${NC}"
	echo -ne "\n[*] Press ${BL}[ENTER]${NC} to begin authentication check..."
	read
	node_auth "pause"
}

del_ssh_keys() {
	if [ -f "$SSH_KEY" ]; then
		echo -e "\n${YL}[!] Main Router SSH Key exists.${NC}\n"
		printf "Do you want to delete Key? (y/n): "
		read -r delete
		case "$delete" in [yY]*) ;; *) return ;; esac
	else
		echo -e "\n${YL}[!] No active RSA key found to delete.${NC}"
		pause
		return
	fi
	echo -e "\n${YL}[i] Purging RSA key footprint from environment...${NC}"
	if [ -f "/jffs/.ssh/id_dropbear.pub" ]; then
		PUB_STRING=$(awk '{print $2}' /jffs/.ssh/id_dropbear.pub)
	else
		PUB_STRING=""
	fi
	if [ -n "$PUB_STRING" ] && [ -f "/root/.ssh/authorized_keys" ]; then
		sed -i "\|$PUB_STRING|d" /root/.ssh/authorized_keys
	fi
	NVRAM_KEYS=$(nvram get sshd_authkeys)
	if [ -n "$PUB_STRING" ] && echo "$NVRAM_KEYS" | grep -q "$PUB_STRING"; then
		CLEANED_KEYS=$(echo "$NVRAM_KEYS" | grep -v "$PUB_STRING")
		nvram set sshd_authkeys="$CLEANED_KEYS"
		nvram commit
	fi
	rm -f "/jffs/.ssh/id_dropbear" "/jffs/.ssh/id_dropbear.pub" "/root/.ssh/id_dropbear"
	nvram get sshd_authkeys > /root/.ssh/authorized_keys
	chmod 600 /root/.ssh/authorized_keys
	echo -e "\n${GR}[✓] RSA Keys removed successfully.${NC}"
	ssh_init
	pause
}

inject_menu() {
	. /usr/sbin/helper.sh
	menu_vars; TAB_LABEL="Wireless Report"
	if [ -f "$CONFIG" ]; then sed -i '/^INSTALLED_PAGE=/d' "$CONFIG"
	else touch "$CONFIG"; fi
    if ! nvram get rc_support | grep -q am_addons; then
		logger -p user.info -t "Wireless_Report" "This firmware does not support addons!"
		exit 5
	fi
    if [ ! -f "$WEB_PAGE" ]; then
		echo "<html><body>$TAB_LABEL Loading...</body></html>" > "$WEB_PAGE"
	fi
	am_get_webui_page "$WEB_PAGE"
	if [ "$am_webui_page" = "none" ]; then
		logger -p user.info -t "Wireless_Report" "Unable to install $TAB_LABEL"
		exit 5
	fi
	cp "$WEB_PAGE" "/www/user/$am_webui_page" 2>/dev/null
	echo "INSTALLED_PAGE=$am_webui_page" >> "$CONFIG"
	if [ ! -f "$TEMP_MENU" ]; then
		cp "$SYSTEM_MENU" /tmp/
		mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"
	fi
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
	restart_httpd
	"$REPORT_SCRIPT" &
}

do_uninstall() {
    if [ ! -d "$INSTALL_DIR" ]; then
        echo -e "\n${YL}[!] Wireless Report is not installed.${NC}"
        pause
        return
    fi
    echo -e "\n${RD}[!] WARNING: Removing Wireless Report...${NC}\n"
    printf "Are you sure? (y/n): "
    read -r confirm
    case "$confirm" in [nN]) return ;; esac
	if [ -f "$CONFIG" ]; then . "$CONFIG"; fi
	get_usb
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
		rm -f "/www/user/$INSTALLED_PAGE" >/dev/null 2>&1
	fi
	sed -i "\|$REPORT_SCRIPT|d" "$SS_FILE"
	sed -i "/wireless_report/d" "$SE_FILE"
	restart_httpd
	rm -rf "$INSTALL_DIR" 2>/dev/null
	rm -rf "$WEB_PAGE" 2>/dev/null
	case "$USB_PATH" in *wirelessreport*) rm -rf "$USB_PATH" 2>/dev/null ;; esac
	logger -p user.info -t "Wireless_Report" "(v$LOCAL_VERSION) successfully uninstalled."
	ssh_init; unset RTIME BACKHAUL RS_HIST HOST_COLOR DARKMODE IPPAD PULSE_MINS DISPLAY_UNIT
	echo -e "${GR}[+] System cleaned. SSH Keys and Fingerprints preserved in /jffs/.ssh${NC}\n"
	echo -e "${GR}[+] Success: Wireless Report uninstalled.${NC}"
	pause
}

set_temp_date() {
    check_installed || return 1
    while true; do
        show_header
        echo -e "${BL}==================================================${NC}"
        echo -e "${BL}                  Set Temp/Date                   ${NC}"
        echo -e "${BL}==================================================${NC}"
        echo -e "${BL}  Unit:${NC} $DU              ${BL}Date:${NC} $CT      "
        echo -e "${BL}==================================================${NC}"
        echo -e "                                                            "
        echo -e "  $N1  Fahrenheit (°F) / USA  ($DATE_USA)                   "
        echo -e "  $N2  Celsius    (°C) / INTL ($DATE_INTL)                  "
        echo -e "  $N3  Technical  (°C) / TECH ($DATE_ISO)                   "
        echo -e "                                                            "
        echo -e "  $NE  Exit to main menu                                    "
        echo -e "                                                            "
		echo -e "${BL}==================================================${NC}"
		printf "\n ${BL}Selection:${NC} "
        read -r t_choice
        case "$t_choice" in
            1) NEW_UNIT="F" ;;
            2) NEW_UNIT="C" ;;
            3) NEW_UNIT="ISO" ;;
            e|E) sort -u -o "$CONFIG" "$CONFIG"; return ;;
            *) continue ;;
        esac
        sed -i '/REPORT_UNIT=/d' "$CONFIG"
        echo "REPORT_UNIT=\"$NEW_UNIT\"" >> "$CONFIG"
        REPORT_UNIT="$NEW_UNIT"
        echo -e "\n${GR}[+] Settings updated to $NEW_UNIT${NC}"
        pause
    done
}

set_nicknames() {
    check_installed || return 1
    while true; do
        show_header
        echo -e "${BL}==================================================${NC}"
        echo -e "${BL}              Router/Node Nicknames               ${NC}"
        echo -e "${BL}==================================================${NC}"
        echo -e "    (Press $N0 for Defaults $N1 for Locations)              "
        echo -e "              (Press $NE to Exit)                           "
        echo -e "${BL}==================================================${NC}"
        MAIN_HW_MODEL=$(nvram get productid)
        MAIN_IP=$(nvram get lan_ipaddr)
        echo -e "\n  ${BL}Main${NC} $MAIN_IP -> ${GR}${MAIN_NICK:-$MAIN_HW_MODEL}${NC}"
        if [ -n "$SSH_NODES" ] && [ "$SSH_NODES" != " " ]; then
            VALID_NODES=$(echo "$SSH_NODES" | tr ' ' '\n' | grep '|')
            for node in $VALID_NODES; do
                MODEL=$(echo "$node" | cut -d'|' -f1)
				IP=$(echo "$node" | cut -d'|' -f2)
                CLEAN_IP=$(echo "$IP" | tr '.' '_')
                eval SAVED_NICK=\$NODE_NICK_$CLEAN_IP
                echo -e "  ${BL}Node${NC} $IP -> ${GR}${SAVED_NICK:-$MODEL}${NC}"
            done
        fi
        echo -e "\n${BL}==================================================${NC}"
        printf "\n${BL} [Enter]${NC} Manual Name | ${BL}Selection:${NC} "
        read -r input_main
        case "$input_main" in
            e|E)
                sort -u -o "$CONFIG" "$CONFIG"
				return
                ;;
            0)
                echo -e "\n${BL}[+] Resetting to hardware defaults...${NC}\n"
                OLD_NAME="${MAIN_NICK:-$MAIN_HW_MODEL}"
                sed -i '/^MAIN_NICK=/d' "$CONFIG"
                unset MAIN_NICK
                echo -e "    $OLD_NAME -> ${GR}$MAIN_HW_MODEL${NC}"; sleep 1
                if [ -n "$SSH_NODES" ] && [ "$SSH_NODES" != " " ]; then
                    for node in $VALID_NODES; do
                        MODEL=$(echo "$node" | cut -d'|' -f1)
						IP=$(echo "$node" | cut -d'|' -f2)
                        CLEAN_IP=$(echo "$IP" | tr '.' '_')
                        eval OLD_NICK=\$NODE_NICK_$CLEAN_IP
                        sed -i "/^NODE_NICK_$CLEAN_IP=/d" "$CONFIG"
                        eval "unset NODE_NICK_$CLEAN_IP"
                        echo -e "    ${OLD_NICK:-$MODEL} -> ${GR}$MODEL${NC}"; sleep 1
                    done
                fi
                echo -e "\n${GR}[+] Default hardware models restored.${NC}"
                pause
                ;;
            1)
                echo -e "\n${BL}[*] Updating nicknames with Locations...${NC}\n"
                OLD_NAME="${MAIN_NICK:-$MAIN_HW_MODEL}"
                NEW_LOC=$(nvram get cfg_alias)
                sed -i '/^MAIN_NICK=/d' "$CONFIG"
                if [ -n "$NEW_LOC" ]; then
                    echo "MAIN_NICK=\"$NEW_LOC\"" >> "$CONFIG"
                    echo -e "    $OLD_NAME -> ${GR}$NEW_LOC${NC}"; sleep 1
                else
                    unset MAIN_NICK
                    echo -e "    $OLD_NAME -> ${GR}$MAIN_HW_MODEL (Default)${NC}"; sleep 1
                fi
                for node in $VALID_NODES; do
                    MODEL=$(echo "$node" | cut -d'|' -f1); IP=$(echo "$node" | cut -d'|' -f2)
                    CLEAN_IP=$(echo "$IP" | tr '.' '_')
                    eval OLD_NICK=\$NODE_NICK_$CLEAN_IP
                    NODE_LOC=$(cat /jffs/.sys/cfg_mnt/re.info | sed 's/},/}\n/g' | grep "$IP" | sed -n 's/.*"alias":"\([^"]*\)".*/\1/p')
                    sed -i "/^NODE_NICK_$CLEAN_IP=/d" "$CONFIG"
                    if [ -n "$NODE_LOC" ]; then
                        echo "NODE_NICK_$CLEAN_IP=\"$NODE_LOC\"" >> "$CONFIG"
                        echo -e "    ${OLD_NICK:-$MODEL} -> ${GR}$NODE_LOC${NC}"; sleep 1
                    else
                        eval "unset NODE_NICK_$CLEAN_IP"
                        echo -e "    ${OLD_NICK:-$MODEL} -> ${GR}$MODEL (Default)${NC}"; sleep 1
                    fi
                done
                echo -e "\n${GR}[+] Nicknames updated to Locations...${NC}"
                pause
                ;;
            *)
                echo -e "\n${BL}[*] Manual Entry Mode${NC}\n"
                OLD_MAIN="${MAIN_NICK:-$MAIN_HW_MODEL}"
                printf "  Main $MAIN_IP ${GR}[$OLD_MAIN]:${NC} "
                read -r manual_main
                if [ -n "$manual_main" ]; then
                    sed -i '/^MAIN_NICK=/d' "$CONFIG"
                    echo "MAIN_NICK=\"$manual_main\"" >> "$CONFIG"
                fi
                for node in $VALID_NODES; do
                    MODEL=$(echo "$node" | cut -d'|' -f1)
					IP=$(echo "$node" | cut -d'|' -f2)
                    CLEAN_IP=$(echo "$IP" | tr '.' '_')
                    eval OLD_NICK=\$NODE_NICK_$CLEAN_IP
                    printf "  Node $IP ${GR}[${OLD_NICK:-$MODEL}]:${NC} "
                    read -r input_node
                    if [ -n "$input_node" ]; then
                        sed -i "/^NODE_NICK_$CLEAN_IP=/d" "$CONFIG"
                        echo "NODE_NICK_$CLEAN_IP=\"$input_node\"" >> "$CONFIG"
                    fi
                done
                echo -e "\n${GR}[+] Manual nicknames saved.${NC}"
                pause
                ;;
        esac
    done
}

set_options() {
    check_installed || return 1
    while true; do
        show_header; get_usb
        echo -e "${BL}==================================================${NC}"
        echo -e "${BL}                    Set Options                   ${NC}"
        echo -e "${BL}==================================================${NC}"
        echo -e "                                                            "
        echo -e "  $N1  Show Runtime Tracking: ($RTM)                        "
        echo -e "  $N2  Show Wireless Backhaul: ($WB_STAT)                   "
        echo -e "  $N3  Uptime Alert Pulse: ($UP_STAT)                       "
        echo -e "  $N4  Show RSSI History: ($RH_STAT)                        "
        echo -e "  $N5  Enable Dark Mode: ($DM_STAT)                         "
		echo -e "  $N6  Enable IP Padding: ($PD_STAT)                        "
		echo -e "  $N7  Node Hostname Display: ($HN_STAT)                    "
		echo -e "                                                            "
        echo -e "  $NE  Exit to main menu                                    "
        echo -e "                                                            "
        echo -e "${BL}==================================================${NC}"
        printf "\n ${BL}Selection:${NC} "
        read -r t_choice
        case "$t_choice" in
            1)
                if grep -q "RTIME=" "$CONFIG"; then
                    if [ "$RTIME" = "1" ]; then
						sed -i 's/RTIME=.*/RTIME="0"/' "$CONFIG"
					else
						sed -i 's/RTIME=.*/RTIME="1"/' "$CONFIG"
					fi
                else
                    echo 'RTIME="0"' >> "$CONFIG"
                fi
                if [ -f "$USB_PATH/runtime.db" ]; then rm -f "$USB_PATH/runtime.db"; fi
                ;;
            2)
                if grep -q "BACKHAUL=" "$CONFIG"; then
                    if [ "$BACKHAUL" = "yes" ]; then NEW_BACK="no"; else NEW_BACK="yes"; fi
                    sed -i "s/BACKHAUL=.*/BACKHAUL=\"$NEW_BACK\"/" "$CONFIG"
                else
                    echo 'BACKHAUL="yes"' >> "$CONFIG"
                fi
                ;;
            3)
                echo -e "\n (${GR}0${NC}) disable (${GR}15${NC}) def (${GR}1440${NC}) max "
                printf " ${BL}Enter alert interval in mins:${NC} "
                read -r user_mins
                if [ -z "$user_mins" ]; then user_mins="15"; fi
                if echo "$user_mins" | grep -q '^[0-9]\+$'; then
                    if [ "$user_mins" -le 1440 ]; then
                        NEW_MINS="$user_mins"
                        if grep -q "PULSE_MINS=" "$CONFIG"; then
                            sed -i "s/PULSE_MINS=.*/PULSE_MINS=\"$NEW_MINS\"/" "$CONFIG"
                        else
                            echo "PULSE_MINS=\"$NEW_MINS\"" >> "$CONFIG"
                        fi
                        echo -e "\n ${GR}[+] Uptime Alert Pulse set to ${NEW_MINS} minutes.${NC}"
                    else
                        echo -e "\n ${RD}[!] Invalid entry. Maximum permitted interval is 1440 minutes (24 hours).${NC}"
                    fi
                else
                    echo -e "\n ${RD}[!] Invalid entry. Please enter numbers only.${NC}"
                fi
                pause
                ;;
            4)
                rssi_submenu ;;
            5)
                if grep -q "DARKMODE=" "$CONFIG"; then
                    if [ "$DARKMODE" = "1" ]; then NEW_DM="0"; else NEW_DM="1"; fi
                    sed -i "s/DARKMODE=.*/DARKMODE=\"$NEW_DM\"/" "$CONFIG"
                else
                    echo 'DARKMODE="1"' >> "$CONFIG"
                fi
                ;;
			6)
                if grep -q "IPPAD=" "$CONFIG"; then
                    if [ "$IPPAD" = "1" ]; then
                        NEW_PAD="0"
                        echo -e "\n${RD}[-] Disabled:${NC} 192.168.050.003 --> ${RD}192.168.50.3${NC}"
                        pause
                    elif [ "$IPPAD" = "0" ]; then
                        NEW_PAD="2"
                        echo -e "\n${GR}[+] Mode 2:${NC} 192.168.50.3 --> ${GR}192.168.050.003${NC} (Last 2 Octets)"
                        pause
                    else
                        NEW_PAD="1"
                        echo -e "\n${GR}[+] Mode 1:${NC} 192.168.50.3 --> ${GR}192.168.50.003${NC} (Last Octet Only)"
                        pause
                    fi
                    sed -i "s/IPPAD=.*/IPPAD=\"$NEW_PAD\"/" "$CONFIG"
                else
                    NEW_PAD="0"
                    echo -e "\n${RD}[-] Disabled:${NC} 192.168.050.003 --> ${RD}192.168.50.3${NC}"
                    pause
                    echo 'IPPAD="0"' >> "$CONFIG"
                fi
                ;;
			7)
                if grep -q "HOST_COLOR=" "$CONFIG"; then
                    if [ "$HOST_COLOR" = "1" ]; then NEW_HC="0"; else NEW_HC="1"; fi
                    sed -i "s/HOST_COLOR=.*/HOST_COLOR=\"$NEW_HC\"/" "$CONFIG"
                else
                    echo 'HOST_COLOR="1"' >> "$CONFIG"
                fi
				;;
            u|U)
                echo -e "\n${BL}================= USB Check ======================${NC}"
                check_storage
                echo -e "\n${BL}==================================================${NC}"
                pause
                continue
                ;;
            v|V)
                echo -e "\n${BL}================== CONFIG ======================${NC}\n"
                if [ -f "$CONFIG" ]; then cat "$CONFIG"
                else echo -e "${GR}[!] No CONFIG file found.${NC}"; fi
                echo -e "\n${BL}==================================================${NC}"
                pause
                continue
                ;;
            e|E)
                sort -u -o "$CONFIG" "$CONFIG"
                return
                ;;
            *)
                continue
                ;;
        esac
    done
}

rssi_submenu() {
	while true; do
		show_header
		echo -e "${BL}==============================================${NC}"
		echo -e "${BL}          RSSI History Configuration          ${NC}"
		echo -e "${BL}==============================================${NC}"
		echo -e "                                                        "
		echo -e " $N1 Enable RSSI History: [$CH]                         "
		echo -e " $N2 Set History Depth:   [$CE] entries                 "
		echo -e " $N3 Enable Timestamps:   [$TS]                         "
		echo -e "                                                        "
		echo -e " $NQ Cancel and Discard Changes                         "
		echo -e " $NE Exit and Save Changes                              "
		echo -e "                                                        "
		echo -e "${BL}==============================================${NC}"
		printf "\n ${BL}Selection:${NC} "
		read -r sub_choice
		case "$sub_choice" in
            1)
                if [ "$CUR_RS_HIST" = "1" ]; then CUR_RS_HIST="0"; else CUR_RS_HIST="1"; fi
                ;;
            2)
                echo -ne "\n Enter new depth (${BL}5-20${NC}) [Current: $CE]: "
                read new_days
                if [ "$new_days" -ge 5 ] && [ "$new_days" -le 20 ]; then
                    CUR_ENTRIES="$new_days"
                else
                    echo -e "\n${RD}[!] Invalid: Use 5-20${NC}"
                    sleep 1
                fi
                ;;
            3)
                if [ "$CUR_DATE" = "1" ]; then CUR_DATE="0"; else CUR_DATE="1"; fi
                ;;
            c|C)
                echo -e "\n${RD}[!] Changes discarded.${NC}"
                unset CUR_RS_HIST CUR_ENTRIES CUR_DATE
				pause
                break
                ;;
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
                if [ -f "$HISTORY_DB" ]; then rm -f "$HISTORY_DB"; fi
                echo -e "\n${GR}[+] Configuration saved and DB cleared.${NC}"
                unset CUR_RS_HIST CUR_ENTRIES CUR_DATE
				pause
                break
                ;;
        esac
    done
}

restart_httpd() {
    service restart_httpd >/dev/null 2>&1
    killall -HUP httpd >/dev/null 2>&1

}

pause() {
    printf "\nPress ${BL}[Enter]${NC} to return..."
    read discard

}

do_runtime() {
	RTIME=${RTIME:-1}
	if [ "$RTIME" = "1" ]; then
		read -r END_RUNTIME _ < /proc/uptime
		STATS_FILE="$USB_PATH/runtime.db"
		DIFF=$(awk "BEGIN {printf \"%.2f\", $END_RUNTIME - $START_RUNTIME}")
		RUNTIME="${DIFF}s"
		if [ ! -f "$STATS_FILE" ] || [ "$(wc -w < "$STATS_FILE")" -lt 4 ]; then echo "0 0 999.99 0.00" > "$STATS_FILE"; fi
		read -r TOTAL_TIME COUNT MIN_TIME MAX_TIME < "$STATS_FILE"
		NEW_TOTAL=$(awk "BEGIN {printf \"%.2f\", $TOTAL_TIME + $DIFF}")
		NEW_COUNT=$((COUNT + 1))
		AVERAGE=$(awk "BEGIN {printf \"%.2f\", $NEW_TOTAL / $NEW_COUNT}")
		NEW_MIN=$(awk "BEGIN {printf \"%.2f\", ($DIFF < $MIN_TIME) ? $DIFF : $MIN_TIME}")
		NEW_MAX=$(awk "BEGIN {printf \"%.2f\", ($DIFF > $MAX_TIME) ? $DIFF : $MAX_TIME}")
		echo "$NEW_TOTAL $NEW_COUNT $NEW_MIN $NEW_MAX" > "$STATS_FILE"
		logger -p user.info -t "Wireless_Report" "Report completed in $RUNTIME. AVG: ${AVERAGE}s (L: ${NEW_MIN}s/H: ${NEW_MAX}s) over $NEW_COUNT scans."
		RUNTIME_CSS=".refresh-box:hover select, .refresh-box:hover .btn-manual { color: #0096ff !important; }
			.refresh-box, .refresh-box select, .refresh-box .btn-manual { position: relative; display: inline-block; }
			.refresh-box:before, .refresh-box .btn-manual:before, .refresh-box select:before { position: absolute; height: 28px; line-height: 28px; padding: 0 15px; background: rgba(10,10,10,0.95); color: white; font-size: 12px; font-weight: bold; border: 1.5px solid #0096ff; border-radius: 20px; box-shadow: 0 0 10px rgba(0,150,255,0.3); white-space: nowrap; opacity: 0; visibility: hidden; transition: all 0.3s ease; z-index: 100; pointer-events: none; }
			.refresh-box:after, .refresh-box .btn-manual:after, .refresh-box select:after { content: \"\"; position: absolute; width: 4px; height: 4px; background: #0096ff; border-radius: 50%; opacity: 0; visibility: hidden; transition: all 0.3s ease; z-index: 101; pointer-events: none; }
			.refresh-box:before { content: \"Avg: ${AVERAGE}s over $NEW_COUNT scans\"; left: -110px; bottom: 185%; }
			.refresh-box:after { left: 15px; bottom: 130%; box-shadow: -12px -12px 0 1.5px #0096ff; }
			.refresh-box .btn-manual:before, .refresh-box select:before { content: \"High: ${NEW_MAX}s   Low: ${NEW_MIN}s\"; left: -114px; top: 185%; }
			.refresh-box .btn-manual:after, .refresh-box select:after { left: 11px; top: 130%; box-shadow: -12px 12px 0 1.5px #0096ff; }
			.refresh-box:has(.btn-manual:hover):before { opacity: 1; visibility: visible; bottom: 190%; }
			.refresh-box:has(.btn-manual:hover):after { opacity: 1; visibility: visible; }
			.refresh-box:has(.btn-manual:hover) .btn-manual:before, .refresh-box:has(select:hover) select:before { opacity: 1; visibility: visible; top: 190%; }
			.refresh-box:has(.btn-manual:hover) .btn-manual:after, .refresh-box:has(select:hover) select:after { opacity: 1; visibility: visible; }"
	else
		RUNTIME_CSS=""; RUNTIME=""
		if [ -f "$USB_PATH/runtime.db" ]; then rm -f "$USB_PATH/runtime.db"; fi
	fi
}

ssh_error() {
    if [ -n "$1" ]; then
        case "$1" in
            *Ignoring*|*skipping*) ;;
            *) echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$ERROR_LOG" ;;
        esac
    fi
}

header_box() {
    if [ -n "$REMOTE_VERSION" ] && [ "$REMOTE_VERSION" != "$SCRIPT_VERSION" ]; then
        HOVER_TEXT="Current v$SCRIPT_VERSION <br> New Version v$REMOTE_VERSION available"
        V_WIDTH="190px"
    elif [ -n "$REMOTE_HASH" ] && [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
        HOVER_TEXT="Current v$SCRIPT_VERSION <br> Hash Update available."
        V_WIDTH="190px"
    else
        HOVER_TEXT="Current v$SCRIPT_VERSION"
        V_WIDTH="100px"
    fi
}

do_darkmode() {
	DARKMODE=${DARKMODE:-0}
	if [ "$DARKMODE" = "1" ]; then
		DARK_CSS=".section-header { background: transparent !important; color: #fff; font: bold 12px/16px sans-serif; padding: 12px; text-align: center; border: 0 !important; box-shadow: 0 !important; }
		.header-stats-row { margin-top: 15px !important; }
		.modal-grid .section-header { min-height: 85px !important; }
		.report-column { width: 100%; background: transparent !important; border: 1px solid #475a68; border-radius: 8px; border: 1px solid #475a68; overflow: hidden; display: flex; flex-direction: column; }
		table.report_table td { padding: 6px; border-bottom: 1px solid #3d454b; background: transparent !important; vertical-align: middle; text-align: center; }
		table.report_table tfoot td { border-top: none !important; border-bottom: none !important; box-shadow: none !important; padding: 12px 10px !important; font-weight: bold; background: #171b1f; color: #fff; }"
	else
		DARK_CSS=".section-header { background: linear-gradient(to bottom, #171b1f, #354961); color: #ffffff; font-weight: bold; padding: 12px; text-align: center; border-bottom: 1px solid #475a68; }
		.report-column { width: 100%; background: #1c232b; border-radius: 8px; border: 1px solid #475a68; overflow: hidden; display: flex; flex-direction: column; }
		table.report_table td { padding: 6px; border-bottom: 1px solid #3d454b; background: #1c232b; vertical-align: middle; text-align: center; }
		table.report_table tfoot td { border-top: 1px solid #475a68; padding: 12px 10px !important; font-weight: bold; background: #171b1f; color: #fff; }"
	fi
}

do_numbered_node() {
	if [ "$NUMBERED_NODE" = 1 ]; then NTOTAL=""
	else NTOTAL="<span class='dash-sep'>—›</span> $NODE_TOTALS"; fi
	if [ "$NUMBERED_NODE" -ge 1 ]; then
		TOTAL_DEVICES="Devices: <span class='val-blue'>$GRAND_TOTAL</span> <span class='dash-sep'>—›</span> <span class='val-blue'>$MAIN_DEVICE_TOTAL</span>$DOT$NODE_TOTALS"
	else
		TOTAL_DEVICES="Devices: <span class='val-blue'>$MAIN_DEVICE_TOTAL</span>"
	fi
	if [ "$NUMBERED_NODE" -gt 3 ]; then
		TEMP_STYLE="text-align: center; justify-content: flex-start; font-size: 13px;"
		UPTIME_STYLE="text-align: center; justify-content: flex-start; font-size: 10px;"
	else
		TEMP_STYLE="text-align: center; justify-content: center;"
		UPTIME_STYLE="text-align: center; justify-content: center;"
	fi
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

#====================#
#  Report Functions  #
#====================#
update_time() {
    if [ "$REPORT_UNIT" = "ISO" ]; then
        T_FMT="+%Y-%m-%d %H:%M:%S"
        D_FMT="+%Y-%m-%d %H:%M"
        TEMP_UNIT="C"
    elif [ "$REPORT_UNIT" = "C" ]; then
        T_FMT="+%-d-%b %-H:%M:%S"
        D_FMT="+%-d-%b %-H:%M"
        TEMP_UNIT="C"
    else
        T_FMT="+%b-%-d %-H:%M:%S"
        D_FMT="+%b-%-d %-H:%M"
        TEMP_UNIT="F"
    fi
    CUR_TIME=$(date "$T_FMT")
}

get_temp_unit() {
    local t_unit=$1
    case "$t_unit" in ""|*[!0-9.]*) echo "--"; return ;; esac
    if [ "$TEMP_UNIT" = "C" ]; then
        echo "${t_unit}°C"
    else
        local f_temp=$(( (t_unit * 9 + (t_unit >= 0 ? 2 : -2)) / 5 + 32 ))
        echo "${f_temp}°F"
    fi
}

get_temp_class() {
    local temp=$1
	local val="${temp%%[^0-9]*}"
    case "$val" in ""|*[!0-9]*) echo "stat-cool"; return ;; esac
    if [ "$REPORT_UNIT" = "C" ]; then
        if [ "$val" -ge 90 ]; then echo "stat-hot"
        elif [ "$val" -ge 75 ]; then echo "stat-warm"
        else echo "stat-cool"; fi
    else
        if [ "$val" -ge 194 ]; then echo "stat-hot"
        elif [ "$val" -ge 167 ]; then echo "stat-warm"
        else echo "stat-cool"; fi
    fi
}

get_load_class() {
    local load=$1
    case "$load" in ""|*[!0-9.]*) echo "stat-cool"; return ;; esac
    case "$load" in
        [4-9]*|[0-9][0-9]*) echo "stat-hot" ;;
        1.[5-9]*|[2-3].*)   echo "stat-warm" ;;
        *)                  echo "stat-cool" ;;
    esac
}

get_mac_address() {
	mac_address=$(echo "$mac" | tr '[:lower:]' '[:upper:]')
	mac_prefix="${mac_address#??}"
	mac_prefix="${mac_prefix%???}"
	is_node_pfx=0; bh="no"
	case "$NODE_PFX" in *"$mac_prefix"*) is_node_pfx=1 ;; esac
	if [ "$mac_prefix" = "$MAIN_PFX" ] || [ "$is_node_pfx" -eq 1 ]; then
		    if [ "$BACKHAUL" != "yes" ]; then return 1; fi
			bh="yes"
	fi
	if [ "$bh" = "yes" ]; then
		mac_check="${CLEAN_IP}_${iface}_${mac_address}"
	else
		mac_check="$mac_address"
	fi
	case " $SEEN_MACS_VAR " in
		*" $mac_check "*) return 1 ;;
	esac

	get_name "$mac_address"

	if [ "$bh" = "yes" ]; then
		mac_final="${CLEAN_IP}_${iface}_${mac}"
	else
		mac_final="$mac"
	fi
	case " $SEEN_MACS_VAR " in
		*" $mac_final "*) return 1 ;;
	esac
	SEEN_MACS_VAR="$SEEN_MACS_VAR $mac_final"
	return 0
}

get_name() {
	mac="$mac_address"
	name=""

	# YazDHCP
	if [ -f "$YAZ_CACHE" ]; then
		local entry=$(grep -i "^$mac|" "$YAZ_CACHE")
		name="${entry##*|}"
	fi

	# Custom Client List
	if [ -z "$name" ] || [ "$name" = "*" ]; then
		if [ -f "$CUSTOM_CLIENTS_CACHE" ]; then
			local entry=$(grep -i "^$mac|" "$CUSTOM_CLIENTS_CACHE")
			name="${entry#*|}"
		fi
	fi

	# Networkmap Client / MLO
	if [ -z "$name" ] || [ "$name" = "*" ]; then
		local entry=$(sed 's/},"/ \n"/g' /jffs/nmp_cl_json.js | grep -i "$mac" | head -n 1)
		local raw_parent=$(echo "$entry" | sed -n 's/.*"mlo_all_mac":"<\([^"]*\)".*/\1/p' | tr '[:lower:]' '[:upper:]')
		local parent_mac=$(echo "$raw_parent" | cut -d'<' -f1)
		if [ -n "$parent_mac" ] && [ "$parent_mac" != "$mac" ]; then mac="$parent_mac"; fi
		name=$(echo "$entry" | sed -n 's/.*"name":"\([^"]*\)".*/\1/p')
    fi

	# Wireless Backhaul
	if [ -z "$name" ] || [ "$name" = "*" ] || [ "$name" = "$mac" ]; then
		local temp="${mac#*:}"
		local mid_mac="${temp%:*}"
		if [ -n "$mid_mac" ]; then
			local node_match=""
			if [ -f "$DEVICE_LIST_CACHE" ]; then node_match=$(grep -i "$mid_mac" "$DEVICE_LIST_CACHE"); fi
			if [ -n "$node_match" ]; then
				node_alias=$(echo "$node_match" | cut -d'>' -f2)
				name="${node_alias:-NODE}-BH"
			fi
		fi
	fi

	# Fallback
	if [ -z "$name" ] || [ "$name" = "*" ]; then name="$mac"; fi
}

get_ip() {
	ip=""
	if [ -z "$ip" ]; then line=$(grep -ihm 1 "^$mac|" "$ARP_CACHE"); if [ -n "$line" ]; then ip="${line#*|}"; ip="${ip%%|*}"; fi; fi
    if [ -z "$ip" ]; then line=$(grep -ihm 1 "^$mac|" "$LEASES_CACHE"); if [ -n "$line" ]; then ip="${line#*|}"; ip="${ip%%|*}"; fi; fi
    if [ -z "$ip" ]; then line=$(grep -ihm 1 "^$mac|" "$YAZ_CACHE"); if [ -n "$line" ]; then ip="${line#*|}"; ip="${ip%%|*}"; fi; fi
    if [ -z "$ip" ]; then line=$(grep -ihm 1 "^$mac|" "$DHCPSTATIC_CACHE"); if [ -n "$line" ]; then ip="${line#*|}"; ip="${ip%%|*}"; fi; fi
	case "$name" in *-BH*) ip="" ;; esac
	case "$ip" in ""|*[!0-9.]*) ip=$(printf "900.000.000.00%d" "$NUMBERED_NODE") ;; esac
	if [ "$IPPAD" = "1" ]; then
		ip=$(printf "%s.%03d" "${ip%.*}" "${ip##*.}")
	elif [ "$IPPAD" = "2" ]; then
		ip_base="${ip%.*.*}"
		ip_last_two="${ip#*.*.}"
		ip=$(printf "%s.%03d.%03d" "$ip_base" "${ip_last_two%.*}" "${ip_last_two#*.}")
	fi
	ip_to_num "$ip"
    ip_sort="$IP_NUM"
}

ip_to_num() {
    local ip="$1" o1 o2 o3 o4
    o1="${ip%%.*}"; local rest="${ip#*.}"
    o2="${rest%%.*}"; rest="${rest#*.}"
    o3="${rest%%.*}"; o4="${rest#*.}"
    case "$o1" in *[!0-9]*|"") IP_NUM="000000000000"; return ;; esac
    case "$o2" in *[!0-9]*|"") IP_NUM="000000000000"; return ;; esac
    case "$o3" in *[!0-9]*|"") IP_NUM="000000000000"; return ;; esac
    case "$o4" in *[!0-9]*|"") IP_NUM="000000000000"; return ;; esac
    o1=${o1#${o1%%[!0]*}}; [ -z "$o1" ] && o1=0
    o2=${o2#${o2%%[!0]*}}; [ -z "$o2" ] && o2=0
    o3=${o3#${o3%%[!0]*}}; [ -z "$o3" ] && o3=0
    o4=${o4#${o4%%[!0]*}}; [ -z "$o4" ] && o4=0
    IP_NUM=$(printf "%03d%03d%03d%03d" "$o1" "$o2" "$o3" "$o4")
}

final_chk() {
    if [ -z "$ssid" ]; then ssid="Wireless"; fi
    case "$rssi" in
        *[!0-9-]*|""|"-")
            rssi="N/A"
            ;;
        *)
            if [ "$rssi" -ge 0 ] && [ "$rssi" -le 1 ]; then rssi=-54; fi
            ;;
    esac
}

check_new_mac() {
	local mac="$1"
    if [ ! -f "$KNOWN_DB" ]; then touch "$KNOWN_DB"; fi
    if ! grep -qi "^$mac$" "$KNOWN_CACHE"; then
        echo "$mac" >> "$KNOWN_DB"
        echo "$mac" >> "$KNOWN_CACHE"
        echo "new-device-row"
    fi
}

get_trend() {
    local mac="$1"
    local current_rssi="$2"
    local rssi_name="${3:-""}"
	if [ "$RS_HIST" = "1" ]; then
		local rband=$(get_band "$iface" "$width" "$ROUTER" "band")
		local entry=$(grep -F "$mac|" "$HISTORY_CACHE" 2>/dev/null)
		local history_str="${entry#*|}"
		local prev_entry="${history_str##*,}"
		local prev_rssi="${prev_entry%%|*}"
		local trend_icon=""
		if [ -z "$prev_rssi" ]; then
			trend_icon="<span class='trend-box'>•</span>"
		elif [ "$current_rssi" -gt "$prev_rssi" ]; then
			trend_icon="<span class='trend-box trend-up rssi-exc'>↑</span>"
		elif [ "$current_rssi" -lt "$prev_rssi" ]; then
			trend_icon="<span class='trend-box trend-down rssi-poor'>↓</span>"
		else
			trend_icon="<span class='trend-box'>•</span>"
		fi
		if [ "$RS_HIST_DATE" = "1" ]; then
            local new_entry="$current_rssi|$rssi_name|$rband|$CUR_TIME"
        else
            local new_entry="$current_rssi|$rssi_name|$rband"
        fi
		local new_history="${history_str:+$history_str,}$new_entry"
		local final_history="$new_history"
		local commas_only="${final_history//[^,]/}"
		local count=$(( ${#commas_only} + 1 ))
		while [ "$count" -gt "$RS_HIST_ENTRIES" ]; do
			final_history="${final_history#*,}"
			count=$((count - 1))
		done
		echo "$mac|$final_history" >> "$NEW_HISTORY"
		local rssi_history=""
		local IFS=','
		for entry in $final_history; do
			rssi="${entry%%|*}"
			rest="${entry#*|}"
			name="${rest%%|*}"
			rest="${rest#*|}"
			if [ "$RS_HIST_DATE" = "1" ]; then
                rband_val="${rest%%|*}"
                time="${rest#*|}"
            else
                rband_val="$rest"
                time=""
            fi
			if [ "$time" = "$rest" ]; then time=""; fi
			if [ "$rssi" -ge -50 ]; then style="color: #30d158; font-weight: bold;"
			elif [ "$rssi" -ge -60 ]; then style="color: #64d2ff; font-weight: bold;"
			elif [ "$rssi" -ge -70 ]; then style="color: #ffd60a; font-weight: bold;"
			else style="color: #ff453a; font-weight: bold;"; fi
			rssi_history="${rssi_history}${rssi_history:+<br>}<span style='$style'>$rssi [$name] [$rband_val]${time:+ $time}</span>"
		done
		unset IFS
		echo -n "$trend_icon<span class='rssi-tooltip'>$rssi_history</span>"
	else
		local entry=$(grep -F "$mac|" "$HISTORY_CACHE" 2>/dev/null)
		local old="${entry##*|}"
		echo "$mac|$current_rssi" >> "$NEW_HISTORY"
		if [ -z "$old" ] || [ "$old" -eq 0 ]; then
            echo "<span class='trend-box'>•</span>"
            return
        fi
        if [ "$current_rssi" -gt "$old" ]; then
            echo "<span class='trend-box trend-up rssi-exc'>↑</span>"
        elif [ "$current_rssi" -lt "$old" ]; then
            echo "<span class='trend-box trend-down rssi-poor'>↓</span>"
        else
            echo "<span class='trend-box'>•</span>"
        fi
	fi
}

get_band() {
    local iface=$1; local width=$2; local model=$3
    local w_text=""; local Label="Unknown"
	if [ -n "$width" ]; then w_text=" ($width)"; fi
    local m=$(echo "$model" | tr '[:lower:]' '[:upper:]')
	case "$m" in

		# Quad-Band Mapping (5G,6G-1,6G-2,2.4G)
		# Models: GT-BE98(Pro), BQ16
        *BE98*|*BQ16*)
            case "$iface" in
                wl0*|eth7*)  Label="5G" ;;
                wl1*|eth8*)  Label="6G-1" ;;
                wl2*|eth9*)  Label="6G-2" ;;
                wl3*|eth10*) Label="2.4G" ;;
            esac
            ;;

		# Quad-Band Mapping (5G,5G-2,6G,2.4G)
		# Models: GT-AXE16000, GT-BE25000
        *AXE16000*|*BE25000*)
            case "$iface" in
                wl0*|eth7*)  Label="5G" ;;
                wl1*|eth8*)  Label="5G-2" ;;
                wl2*|eth9*)  Label="6G" ;;
                wl3*|eth10*) Label="2.4G" ;;
            esac
            ;;

		# Tri-Band ZenWiFi-BT10 Specific
        *BT10*)
            case "$iface" in
                wl0*) Label="6G" ;;
                wl1*) Label="5G" ;;
                wl2*) Label="2.4G" ;;
            esac
            ;;

		# Tri-Band Mapping (2.4G,5G,6G)
        # Models: RT-BE96U, RT-BE92U, GT-BE19000, GS-BE18000, GS-BE12000, BT6, ZENWIFI-BT8(MTK),
        #         RT-AXE7800, GT-AXE11000, ET8, ET9, ET12
        *BE96U*|*BE92U*|*BE19000*|*BE18000*|*BE12000*|*BT6*|*BT8*|*AXE7800*|*AXE11000*|*ET8*|*ET9*|*ET12*)
            case "$iface" in
                wl0*|eth1*|eth4*|eth8*|ra[0-9]*)         Label="2.4G" ;;
                wl1*|eth2*|eth5*|eth7*|eth10*|rai[0-9]*) Label="5G" ;;
                wl2*|eth6*|eth9*|rax[0-9]*)              Label="6G" ;;
            esac
            ;;

		# Tri-Band Mapping (2.4G,5G-1,5G-2)
        # Models:  RT-AX92U, GT6, XT8, XT9, ZENWIFI-XT12
        *AX92U*|*GT6*|*XT8*|*XT9*|*XT12*)
            case "$iface" in
                wl0*|eth1*|eth4*|eth8*)        Label="2.4G" ;;
                wl1*|eth2*|eth5*|eth7*|eth10*) Label="5G-1" ;;
                wl2*|eth6*|eth9*)              Label="5G-2" ;;
            esac
            ;;

		# Dual-Band DSL-AX82U Specific
        *DSL-AX82U*)
            case "$iface" in
                wl0*|eth5*) Label="2.4G" ;;
                wl1*|eth6*) Label="5G" ;;
                *)          Label="Unknown" ;;
            esac
            ;;

		# Dual-Band Mapping
		# Models:  RT-AX86U, ZENWIFI-BD4(QCA)
        *)
            case "$iface" in
                wl0*|eth1*|eth4*|eth6*|eth8*|ath0*)  Label="2.4G" ;;
                wl1*|eth2*|eth5*|eth7*|eth10*|ath1*) Label="5G" ;;
                *)                                   Label="Unknown" ;;
            esac
            ;;
    esac

	# Unsupported: TUF-AX4200(MTK), RT-AX1800S(MTK), ZENWIFI_XD4_PLUS(MTK)

	# Wireless Backhaul
    if [ -n "$width" ]; then
        if [ "$width" -eq 320 ] && [ "$Label" = "Unknown" ]; then
            Label="6G"
        elif [ "$width" -ge 80 ] && [ "$width" -le 160 ]; then
            if [ "$Label" = "2.4G" ] || [ "$Label" = "Unknown" ]; then
                Label="5G"
            fi
        elif [ "$Label" = "Unknown" ]; then
            case "$iface" in *0*) Label="2.4G" ;; *) Label="5G" ;; esac
        fi
    fi

    # Band UI Renderer
	local class="" sort="0"
	case "$Label" in
		2.4G*)  class="text-24"; sort="2.4" ;;
		5G*)    class="text-5g"; sort="5"   ;;
		6G*)    class="text-6g"; sort="6"   ;;
	esac
	if [ "$4" = "band" ]; then
        echo "$Label"
    else
		echo "<td data-sort='$sort' style='text-align:center;'><span class='$class'>$Label$w_text</span></td>"
	fi
}

check_qca_up() {
	if [ "$uptime" = "UP_QCA" ]; then case "$iface" in *ath*)
		NOW=$(date +%s)
		CLEAN_MAC="$mac"
		START_TS=$(jq -r ".\"$CLEAN_MAC\".start // 0" "/jffs/wlcnt.json")
		if [ "$START_TS" -gt 0 ]; then
			uptime=$((NOW - START_TS))
			if [ "$uptime" -lt 0 ]; then uptime=$((START_TS - NOW)); fi
		else
			uptime="0"
		fi
		;;
	esac; fi
}

fmt_uptime() {
    local T=$1
    if [ -z "$T" ] || case "$T" in *[!0-9]*) true ;; *) false ;; esac; then
        echo "<span data-sort='0'>---</span>"
        return
    fi
    local check_mins="${PULSE_MINS:-15}"
    local pulse_sec=$((check_mins * 60))
    local pulse=""
    if [ "$check_mins" -ne 0 ] && [ "$T" -lt "$pulse_sec" ]; then pulse="pulse-blue"; fi
    local d=$((T / 86400))
    local rem=$((T % 86400))
    local h=$((rem / 3600))
    local m=$(((rem % 3600) / 60))
    if [ "$d" -gt 0 ]; then
        printf "<span class='%s' data-sort='%s'>%02dd %02dh</span>" "$pulse" "$T" "$d" "$h"
    elif [ "$h" -gt 0 ]; then
        printf "<span class='%s' data-sort='%s'>%02dh %02dm</span>" "$pulse" "$T" "$h" "$m"
    else
        printf "<span class='%s' data-sort='%s'>00h %02dm</span>" "$pulse" "$T" "$m"
    fi
}

get_bars_rssi_style() {
    if [ "$rssi" = "N/A" ]; then
        bars="<span class='bar-box'></span>"
        rssi_style="color: #8e8e93;"
        return
    fi
    if [ "$rssi" -ge -50 ]; then
        bars="<span class='bar-box rssi-exc'>||||</span>"
        rssi_style="color: #30d158; font-weight: bold;"
        T_EXC=$((T_EXC+1))
    elif [ "$rssi" -ge -60 ]; then
        bars="<span class='bar-box rssi-good'>|||</span>"
        rssi_style="color: #64d2ff; font-weight: bold;"
        T_GOOD=$((T_GOOD+1))
    elif [ "$rssi" -ge -70 ]; then
        bars="<span class='bar-box rssi-fair'>||</span>"
        rssi_style="color: #ffd60a; font-weight: bold;"
        T_FAIR=$((T_FAIR+1))
    else
        bars="<span class='bar-box rssi-poor'>|</span>"
        rssi_style="color: #ff453a; font-weight: bold;"
        T_POOR=$((T_POOR+1))
    fi
}

get_max_column() {
	if [ "${#name}" -gt 20 ]; then name="${name:0:20}"; fi
	if [ "${#mac}"  -gt 17 ]; then mac="${mac:0:17}"; fi
	if [ "${#ip}"   -gt 15 ]; then ip="${ip:0:15}"; fi
	if [ "${#ssid}" -gt 15 ]; then ssid="${ssid:0:15}"; fi
}

hostcolor_main_name() {
	if [ "$HOST_COLOR" = "1" ]; then
		IP_COLOR=""; MAC_COLOR="color: #64d2ff;"
		NAME_MAIN="<span style='color:#0096ff;'>$name</span>"
		name="$NAME_MAIN"
	else
		IP_COLOR="color: #64d2ff;"; MAC_COLOR=""
	fi
}

hostcolor_node_name() {
    if [ "$HOST_COLOR" = "1" ]; then
        NAME_NODE="<span style='color:$NODE_COLOR;'>$name</span>"
        NODE_NUM="<span style='position:absolute; width:0; height:0; overflow:hidden; opacity:0; pointer-events:none;'>$SUPNN</span>"
    else
        NAME_NODE="<span style='color:#ffffff;'>$name</span>"
		NODE_NUM="<span style='color:$NODE_COLOR;'>$SUPNN</span>"
    fi
	name="$NAME_NODE$NODE_NUM"
}

get_row() {
	ROW="<tr class='$is_mac_new'>
		<td style='text-align:left;'>$name</td>
		<td>
			<span class='mac-val' data-sort='$mac'>$mac</span>
			<span class='ip-val' data-sort='$ip_sort'>$ip</span>
		</td>
		<td data-sort='$rssi' class='rssi-container'>
			$bars <span style='$rssi_style'>$rssi</span> $trend
		</td>
		<td data-sort='$lrd_val' style='$rssi_style; text-align:center;'>$lrd</td>
		<td>
			<span class='ssid-val' data-sort='$ssid'>$ssid</span>
			<span class='iface-val' data-sort='$iface'>$iface</span>
		</td>
		$band
		<td>$uptime</td>
	</tr>"
	ALL_ROWS="${ALL_ROWS}${ROW}${NL}"
}

parse_main_sta() {
    local raw_info="$1"
    printf "%s\n" "$raw_info" | awk '
        /smoothed rssi:/ { split($0, a, ": "); rssi = a[2] }
        /rate of last rx pkt/ { rx = $6 / 1000 }
        /rate of last tx pkt/ { split($0, a, ": "); split(a[2], b, " "); tx = b[1] / 1000 }
        /Max Rate =/ { max = $4 }
        /in network/ { uptime = $3 }
        /link bandwidth/ { for(i=1; i<=NF; i++) { if($i == "bandwidth") { if ($(i+1) == "=") width = $(i+2); else width = substr($(i+1), 2) } } }
        END { print rssi "|" rx "|" tx "|" max "|" width "|" uptime }'
}

parse_main() {
    IFS='|' read -r rssi rx tx max width uptime <<ROW
$1
ROW
}

parse_node_out() {
    N_TEMP_RAW="" N_LOAD="" N_UPTIME_RAW="" N_UPTIME=""
    while IFS='|' read -r key val; do
        case "$key" in
            "TEMP")       N_TEMP_RAW=$val ;;
            "LOAD")       N_LOAD=$val ;;
            "UPTIME_RAW") N_UPTIME_RAW=$val ;;
            "UPTIME_VAL") N_UPTIME=$val ;;
        esac
    done <<EOF
$1
EOF
}

parse_node() {
    IFS='|' read -r _ mac rssi iface uptime ssid lrd_val lrd width _ <<ROW
$1
ROW
}

check_github; ssh_init
update_time; get_usb

run_report() {
#=================#
#  Node Scan(s)   #
#=================#
read -r START_RUNTIME _ < /proc/uptime
# N_COLORS="lime-green medium-purple yellow skyblue orange red"
N_COLORS="#30d158 #bf40bf #ffd60a #64d2ff #ff9500 #ff453a"
DOT=" <span style='color:white;'>•</span> "
N_NAMES=""; N_TEMPS=""; N_LOADS=""; N_BOOTS=""; N_UPTIMES=""
NODE_TOTALS=""; COLOR_INDEX=0; NUMBERED_NODE=0
IPPAD=${IPPAD:-1}; HOST_COLOR=${HOST_COLOR:-0}
NODE_DATA_DIR="/tmp/node_data"
rm -rf "$NODE_DATA_DIR" 2>/dev/null
mkdir -p "$NODE_DATA_DIR"
for line in $SSH_NODES; do
	ROUTER=$(echo "$line" | cut -d'|' -f1)
	IP=$(echo "$line" | cut -d'|' -f2)
	if [ -z "$IP" ]; then continue; fi
	CLEAN_IP=$(echo "$IP" | tr '.' '_')
	(
		/usr/bin/ssh -p "$SSH_PORT" -i "$SSH_KEY" -o StrictHostKeyChecking=no -o BatchMode=yes "${NODE_USER}@${IP}" "
			UP_SEC=\$(cut -d. -f1 /proc/uptime)
			F_UP=\$(awk -v s=\"\$UP_SEC\" 'BEGIN {d=int(s/86400); h=int((s%86400)/3600); m=int((s%3600)/60); if(d>0) printf \"%dd %dh %dm\", d, h, m; else if(h>0) printf \"%dh %dm\", h, m; else printf \"%dm\", m}')
			NODE_COUNT=0
			if ifconfig -a | grep -q "ath"; then
				HW_ENGINE=\"QCA\"
				ALL_IFACES=\$(ifconfig -a | grep -oE \"(ath|wl)[0-9]*(\.[0-9]+)?\")
			elif [ -f \"/usr/sbin/wl\" ] || [ -f \"/usr/bin/wl\" ]; then
				HW_ENGINE=\"BRCM\"
				ALL_IFACES=\"\"
				FOR_SCAN=\$(ifconfig -a | grep -oE \"(wl|eth6|eth7|eth8|eth9|eth10)[0-9]*(\.[0-9]+)?\")
				for ifc in \$FOR_SCAN; do
					case \"\$ifc\" in wl0.0|wl1.0|wl2.0|wl3.0) continue ;; esac
					if wl -i \"\$ifc\" assoclist 2>/dev/null | grep -qE '^assoclist'; then
						ALL_IFACES=\"\$ALL_IFACES \$ifc\"
					fi
				done
			elif [ -d \"/sys/module/mt_wifi\" ] || [ -d \"/sys/module/mt79xx\" ] || [ -f \"/usr/sbin/cfg_client\" ] || ifconfig -a | grep -qE \"(ra|rai|rax)[0-9]\"; then
				HW_ENGINE=\"MTK\"
				ALL_IFACES=\$(ifconfig -a | grep -oE \"(ra|rai|rax)[0-9]*(\.[0-9]+)?\")
			fi
			for iface in \$ALL_IFACES; do
				case \"\$iface\" in wl0.0|wl1.0|wl2.0|wl3.0) continue ;; esac
				SN=\$(nvram get \"\${iface}_ssid\")
				if [ -z \"\$SN\" ] || echo \"\$SN\" | grep -qE '^[0-9A-Fa-f]{16,}\$'; then
					case \"\$iface\" in
						eth6|eth8)  SN=\$(nvram get wl0_ssid) ;;
						eth7|eth10) SN=\$(nvram get wl1_ssid) ;;
						eth9)       SN=\$(nvram get wl2_ssid) ;;
					esac
				fi
				[ -z \"\$SN\" ] && SN=\$(nvram get \"\${iface%.*}_ssid\")
				[ -z \"\$SN\" ] && SN=\$(nvram get wl0_ssid)
				if [ \"\$HW_ENGINE\" = \"BRCM\" ] && echo \"\$SN\" | grep -qE '^[0-9A-Fa-f]{16,}\$'; then continue; fi
				if echo \"\$SN\" | grep -qE '^[0-9A-Fa-f]{16,}\$'; then SN=\"\"; fi
				case \"\$HW_ENGINE\" in
					BRCM)
						for mac in \$(wl -i \"\$iface\" assoclist 2>/dev/null | awk '{print \$2}'); do
							RAW=\$(wl -i \"\$iface\" sta_info \"\$mac\" 2>/dev/null)
							RSSI=\$(echo \"\$RAW\" | awk -F': ' '/smoothed rssi:/ {print \$2; exit}')
							[ -z \"\$RSSI\" ] && RSSI=\$(wl -i \"\$iface\" rssi \"\$mac\" 2>/dev/null | awk '{print \$1}')
							W=\$(echo \"\$RAW\" | grep -i "bandwidth" | grep -oE '[0-9]+' | head -n 1)
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
							UP=\$(echo \"\$RAW\" | grep \"in network\" | awk '{print \$3}')
							RX=\$(echo \"\$RAW\" | grep \"rate of last rx pkt\" | awk '{print \$6/1000}')
							TX=\$(echo \"\$RAW\" | grep \"rate of last tx pkt\" | awk -F': ' '{print \$2}' | awk '{print \$1/1000}')
							MX=\$(echo \"\$RAW\" | grep \"Max Rate =\" | awk '{print \$4}')
							RXD=\$(echo \"\$RX\" | awk '{if (\$1==0) print \"1\"; else printf \"%.0f\", \$1}')
							TXD=\$(echo \"\$TX\" | awk -v m=\"\$MX\" '{if (\$1==0) print \"1\"; else printf \"%.0f\", \$1}')
							[ \"\$RXD\" = \"1\" ] && [ \"\$TXD\" = \"1\" ] && LRD=\"1 / 72\" || LRD=\"\${RXD} / \${TXD}\"
							V1=\$(echo \"\$RXD\" | tr -dc '0-9'); V2=\$(echo \"\$TXD\" | tr -dc '0-9')
							[ -n \"\$V1\" ] && [ -n \"\$V2\" ] && [ \"\$V1\" -gt \"\$V2\" ] 2>/dev/null && { T=\$RXD; RXD=\$TXD; TXD=\$T; LRD=\"\$RXD / \$TXD\"; }
							TX=\$(printf \"%04d\" \"\${TXD:-0}\")
							echo \"DATA|\$mac|\$RSSI|\$iface|\$UP|\$SN|\$TX|\$LRD|\$W|\"
							NODE_COUNT=\$((NODE_COUNT + 1))
						done
						;;
					MTK)
						IFACE_INFO=\$(iw dev \"\$iface\" info 2>/dev/null)
						LIVE_CHAN=\$(echo \"\$IFACE_INFO\" | grep \"channel\" | grep -oE '[0-9]+' | head -n1)
						BASE_IFACE=\$(echo \"\$iface\" | sed 's/[0-9]\$/0/')
						if [ \"\$BASE_IFACE\" = \"\$(nvram get wl2_ifname)\" ]; then
							PREFIX=\"wl2\"
						elif [ \"\$BASE_IFACE\" = \"\$(nvram get wl1_ifname)\" ]; then
							PREFIX=\"wl1\"
						else
							PREFIX=\"wl0\"
						fi
						DRIVER_SSID=\$(echo \"\$IFACE_INFO\" | grep \"ssid\" | sed 's/^[[:space:]]*ssid //')
						if [ -n \"\$DRIVER_SSID\" ] && ! echo \"\$DRIVER_SSID\" | grep -qE \"^[0-9A-Fa-f]{32}\$\"; then
							DISPLAY_SSID=\"\$DRIVER_SSID\"
						else
							VAP_NUM=\$(echo \"\$iface\" | sed 's/[^0-9]//g')
							if [ -n \"\$VAP_NUM\" ] && [ \"\$VAP_NUM\" -gt 0 ] && [ \"\$iface\" != \"rax0\" ] && [ \"\$iface\" != \"rai0\" ] && [ \"\$iface\" != \"ra0\" ]; then
								DISPLAY_SSID=\$(nvram get \"\${PREFIX}.\${VAP_NUM}_ssid\")
							else
								DISPLAY_SSID=\$(nvram get \"\${PREFIX}_ssid\")
							fi
						fi
						W=\"20\"
						if echo \"\$IFACE_INFO\" | grep -q \"6GHz\" || echo \"\$IFACE_INFO\" | grep -q \"width:\"; then
							echo \"\$IFACE_INFO\" | grep -q \"320 MHz\" && W=\"320\"
							echo \"\$IFACE_INFO\" | grep -q \"160 MHz\" && W=\"160\"
							echo \"\$IFACE_INFO\" | grep -q \"80 MHz\" && W=\"80\"
						elif [ -n \"\$LIVE_CHAN\" ] && [ \"\$(echo \"\$LIVE_CHAN\" | tr -d ',')\" -gt 14 ]; then
							W=\"80\"
							echo \"\$IFACE_INFO\" | grep -q \"160\" && W=\"160\"
						fi
						RAW_STAS=\$(iw dev \"\$iface\" station dump 2>/dev/null)
						if [ -n \"\$RAW_STAS\" ]; then
							echo \"\$RAW_STAS\" | awk -v def_w=\"\$W\" '
								/^Station/ {
									if (mac != \"\") print mac, rssi, tx, rx, uptime, c_width
									mac=\$2; rssi=\"-60\"; tx=\"0\"; rx=\"0\"; uptime=\"0\"; c_width=def_w
								}
								/signal:/ && !/last ack/ {
									gsub(/[^0-9-]/, \"\", \$2);
									rssi=\$2
								}
								/tx bitrate:/ {
									tx=\$3
									if (\$0 ~ /[0-9]+MHz/) {
										match(\$0, /[0-9]+MHz/)
										str = substr(\$0, RSTART, RLENGTH)
										gsub(/[^0-9]/, \"\", str)
										c_width = str
									} else {
										c_width = \"20\"
									}
								}
								/rx bitrate:/ { rx=\$3 }
								/connected time:/ {
									s=\$3;
									gsub(/[^0-9]/, \"\", s);
									uptime=s
								}
								END { if (mac != \"\") print mac, rssi, tx, rx, uptime, c_width }
							' | while read -r c_mac c_rssi c_tx c_rx c_uptime c_width; do
								[ -z \"\$c_mac\" ] && continue
								TX_INT=\$(echo \"\$c_tx\" | cut -d. -f1)
								RX_INT=\$(echo \"\$c_rx\" | cut -d. -f1)
								[ -z \"\$TX_INT\" ] && TX_INT=0
								[ -z \"\$RX_INT\" ] && RX_INT=0
								if [ \"\$RX_INT\" -eq 0 ] && [ \"\$TX_INT\" -eq 0 ]; then
									LRD=\"1\"
								else
									if [ \"\$RX_INT\" -gt \"\$TX_INT\" ]; then
										LRD=\"\$TX_INT / \$RX_INT\"
									else
										LRD=\"\$RX_INT / \$TX_INT\"
									fi
								fi
								TX=\$(printf \"%04d\" \"\${TX_INT:-0}\")
								echo \"DATA|\$c_mac|\$c_rssi|\$iface|\$c_uptime|\$DISPLAY_SSID|\$TX|\$LRD|\$c_width|\"
								NODE_COUNT=\$((NODE_COUNT + 1))
							done
						fi
						;;
					QCA)
						SN=\$(iw dev \"\$iface\" info 2>/dev/null | grep ssid | awk '{print \$2}')
						[ -z \"\$SN\" ] && SN=\$(nvram get \"\${iface}_ssid\")
						MACS=\$(wlanconfig \"\$iface\" list 2>/dev/null | awk 'NR>1 {print \$1}' | grep \":\")
						for mac in \$MACS; do
							ROW=\$(wlanconfig \"\$iface\" list 2>/dev/null | grep -i \"\$mac\")
							RSSI=\$(echo \"\$ROW\" | awk '{print \$7}')
							TX=\$(echo \"\$ROW\" | awk '{print \$5}' | tr -dc '0-9')
							RX=\$(echo \"\$ROW\" | awk '{print \$6}' | tr -dc '0-9')
							W=\"20\"; echo \"\$iface\" | grep -q \"ath1\" && W=\"80\"
							LRD=\"\${RX} / \${TX}\"
							TXV=\$(printf \"%04d\" \"\${TX:-0}\")
							echo \"DATA|\$mac|\$RSSI|\$iface|UP_QCA|\$SN|\$TXV|\$LRD|\$W|\"
							NODE_COUNT=\$((NODE_COUNT + 1))
						done
						;;
				esac
			done
			echo \"TEMP|\$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | cut -c1-2)\"
			echo \"LOAD|\$(cat /proc/loadavg | awk '{print \$1}')\"
			echo \"UPTIME_VAL|\$F_UP\"; echo \"UPTIME_RAW|\$UP_SEC\"; echo \"COUNT|\$NODE_COUNT\"
		" 2>/dev/null > "$NODE_DATA_DIR/${CLEAN_IP}.out"
	) &
done

#=============================#
#  Main Scan/Device Assembly  #
#=============================#
YAZDHCP="/jffs/addons/YazDHCP.d/DHCP_clients"
awk '$0 ~ /0x2/ {print toupper($4)"|"$1}' /proc/net/arp > "$ARP_CACHE"
if [ -f "$KNOWN_DB" ]; then cp "$KNOWN_DB" "$KNOWN_CACHE" 2>/dev/null; else > "$KNOWN_CACHE"; fi
if [ -f "$HISTORY_DB" ]; then cp "$HISTORY_DB" "$HISTORY_CACHE" 2>/dev/null; else > "$HISTORY_CACHE"; fi
if [ -f "$YAZDHCP" ]; then awk -F',' 'NR>1 {print toupper($1) "|" $2 "|" $3}' "$YAZDHCP" > "$YAZ_CACHE"; else > "$YAZ_CACHE"; fi
awk '{print toupper($2)"|"$3}' /var/lib/misc/dnsmasq*.leases > "$LEASES_CACHE" 2>/dev/null || > "$LEASES_CACHE"
nvram get dhcp_staticlist | sed 's/>>/  /g; s/[<>]/ /g' | \
awk '{print toupper($1)"|"$2}' > "$DHCPSTATIC_CACHE" 2>/dev/null || > "$DHCPSTATIC_CACHE"
nvram get asus_device_list | sed 's/</\n/g' > "$DEVICE_LIST_CACHE" 2>/dev/null || > "$DEVICE_LIST_CACHE"
nvram get custom_clientlist | sed 's/</\n/g' | awk -F'>' '{if($2!="") print toupper($2)"|"$1}' > "$CUSTOM_CLIENTS_CACHE" 2>/dev/null || > "$CUSTOM_CLIENTS_CACHE"
M_T=$(($(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0) / 1000))
M_TEMP=$(get_temp_unit "$M_T")
MC_TEMP=$(get_temp_class "$M_TEMP")
read -r M_LOAD _ < /proc/loadavg
MC_LOAD=$(get_load_class "$M_LOAD")
read -r s _ < /proc/uptime; s=${s%.*}; d=$((s / 86400)); h=$((s % 86400 / 3600)); m=$((s % 3600 / 60))
if [ $d -gt 0 ]; then M_UPTIME="${d}d ${h}h ${m}m"
elif [ $h -gt 0 ]; then M_UPTIME="${h}h ${m}m"
else M_UPTIME="${m}m"; fi
read -r s _ < /proc/uptime; s=${s%.*}; boot_epoch=$(( $(date +%s) - s ))
M_BOOT=$(date -d @$boot_epoch "$D_FMT")
MAIN_PFX=$(nvram get lan_hwaddr | cut -c 3-14 | tr '[:lower:]' '[:upper:]')
NODE_PFX=$(nvram get cfg_relist | sed 's/[<>]/ /g' | tr ' ' '\n' | grep ":" | cut -c 3-14 | sort -u | tr '[:lower:]' '[:upper:]')
ROUTER_IP=$(nvram get lan_ipaddr)
ROUTER=$(nvram get cfg_device_list | sed 's/</\n/g' | grep ">$ROUTER_IP>" | awk -F'>' '{print $1}')
MAIN_NAME="${MAIN_NICK:-${ROUTER:-"Main Router"}}"
if [ "${#MAIN_NAME}" -gt 25 ]; then MAIN_NAME="${MAIN_NAME:0:25}"; fi
MAIN_LABEL="<span class='router-branding'>$MAIN_NAME</span>"
> "$SEEN_MACS"; > "$NEW_HISTORY"
SEEN_MACS_VAR=""
NL=$'\n'; MAIN_ROWS=""; NODE_ROWS=""; ALL_ROWS=""
T_EXC=0; T_GOOD=0; T_FAIR=0; T_POOR=0; MAIN_DEVICE_TOTAL=0; NODE_DEVICE_TOTAL=0
WL_BASES=$(nvram get wl_ifnames)
WL0_PHYS=$(echo "$WL_BASES" | awk '{print $1}')
WL1_PHYS=$(echo "$WL_BASES" | awk '{print $2}')
WL2_PHYS=$(echo "$WL_BASES" | awk '{print $3}')
WL3_PHYS=$(echo "$WL_BASES" | awk '{print $4}')
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
		${WL0_PHYS:+"$WL0_PHYS"*}) data_iface="wl0" ;;
		${WL1_PHYS:+"$WL1_PHYS"*}) data_iface="wl1" ;;
		${WL2_PHYS:+"$WL2_PHYS"*}) data_iface="wl2" ;;
		${WL3_PHYS:+"$WL3_PHYS"*}) data_iface="wl3" ;;
		*) data_iface="$iface" ;;
	esac
    ASSOCLIST=$(wl -i "$iface" assoclist 2>/dev/null)
    WL_ALIVE=0
    if [ -n "$ASSOCLIST" ]; then WL_ALIVE=1; fi
    ssid=$(nvram get "${iface}_ssid")
	if [ -z "$ssid" ] || echo "$ssid" | grep -qE '^[0-9A-Fa-f]{16,}$'; then
		idx=${iface#*.}
		if [ "$idx" != "$iface" ]; then ssid=$(nvram get "gnp_name_$idx"); fi
	fi
	if [ -z "$ssid" ] && [ -n "$data_iface" ]; then ssid=$(nvram get "${data_iface}_ssid"); fi
	if [ -z "$ssid" ]; then ssid=$(nvram get "${iface%.*}_ssid"); fi
	if [ -z "$ssid" ] && [ -n "$data_iface" ]; then ssid=$(nvram get "${data_iface%.*}_ssid"); fi
	MAC_LIST=$(echo "$ASSOCLIST" | awk '{print $2}')
	if [ -z "$MAC_LIST" ]; then
		BRIDGE=$(brctl show 2>/dev/null | grep "$iface" | awk '{print $1}')
		if [ -z "$BRIDGE" ]; then BRIDGE=$(brctl show 2>/dev/null | grep -B1 "$iface" | grep -v "\-\-" | head -n1 | awk '{print $1}'); fi
		if [ -n "$BRIDGE" ]; then MAC_LIST=$(brctl showmacs "$BRIDGE" 2>/dev/null | grep -v "yes" | awk '{print $2}'); fi
	fi
	for mac in $MAC_LIST; do
		if [ -z "$mac" ] || [ "$mac" = "mac" ]; then continue; fi
		get_mac_address || continue
		get_ip
		raw_info=$(wl -i "$iface" sta_info "$mac" 2>/dev/null)
		if [ -z "$raw_info" ]; then raw_info=$(wl -i "$data_iface" sta_info "$mac" 2>/dev/null); fi
		sta_parsed=$(parse_main_sta "$raw_info")
		parse_main "$sta_parsed"
		if [ -z "$rssi" ]; then rssi=$(wl -i "$iface" rssi "$mac_address" 2>/dev/null); rssi="${rssi%% *}"; fi
		[ -z "$width" ] && case "0x${raw_info##*0x}" in
		0x10*|0xd0*|*) width="20" ;; 0x11*|0xd1*) width="40" ;; 0xe0*) width="80" ;;
		0xe8*|0xe9*) width="160" ;; 0xf0*) width="320" ;; esac
		if [ -z "$rx" ] || [ "$rx" = "0" ]; then rx_disp="?"; else rx_disp="${rx%.*}"; fi
		if [ -z "$tx" ] || [ "$tx" = "0" ]; then tx_disp="${max:-?}"; else tx_disp="${tx%.*}"; fi
		if [ "$rx_disp" = "?" ]; then rx_disp="1"; fi
		if [ "$tx_disp" = "?" ]; then tx_disp="1"; fi
		if [ "$rx_disp" = "1" ] && [ "$tx_disp" = "1" ]; then lrd="1 / 72"; else lrd="${rx_disp} / ${tx_disp}"; fi
		case "$rx_disp" in *[!0-9]*|"") V1="" ;; *) V1="$rx_disp" ;; esac
		case "$tx_disp" in *[!0-9]*|"") V2="" ;; *) V2="$tx_disp" ;; esac
		if [ -n "$V1" ] && [ -n "$V2" ] && [ "$V1" -gt "$V2" ] 2>/dev/null; then T=$rx_disp; rx_disp=$tx_disp; tx_disp=$T; lrd="$rx_disp / $tx_disp"; fi
		lrd_val=$(printf "%04d" "${tx_disp:-0}")
		final_chk
		is_mac_new=$(check_new_mac "$mac")
		trend=$(get_trend "$mac" "$rssi" "$MAIN_NAME")
		band=$(get_band "$iface" "$width" "$ROUTER")
		uptime=$(fmt_uptime "$uptime")
		get_bars_rssi_style
		get_max_column
		hostcolor_main_name
		get_row
		MAIN_ROWS="${MAIN_ROWS}${ROW}${NL}"
		MAIN_DEVICE_TOTAL=$((MAIN_DEVICE_TOTAL + 1))
	done
done
TOTAL_TEMP="<span class='${MC_TEMP}'>${M_TEMP}</span>"
TOTAL_LOAD="<span class='${MC_LOAD}'>${M_LOAD}</span>"
TOTAL_UPTIME="<span class='val-blue'>${M_UPTIME}</span>"
TOTAL_BOOTTIME="<span class='val-blue'>${M_BOOT}</span>"
wait

#========================#
#  Node Device Assembly  #
#========================#
for line in $SSH_NODES; do
	NODE_OUT=""
	ROUTER=$(echo "$line" | cut -d'|' -f1)
	IP=$(echo "$line" | cut -d'|' -f2)
	if [ -z "$IP" ]; then continue; fi
	CLEAN_IP=$(echo "$IP" | tr '.' '_')
	eval CUSTOM_NICK=\$NODE_NICK_$CLEAN_IP
	NODE_NAME="${CUSTOM_NICK:-${ROUTER:-$IP}}"
	if [ "${#NODE_NAME}" -gt 25 ]; then NODE_NAME="${NODE_NAME:0:25}"; fi
	if [ -f "$NODE_DATA_DIR/${CLEAN_IP}.out" ]; then NODE_OUT=$(cat "$NODE_DATA_DIR/${CLEAN_IP}.out"); fi
	if [ -n "$NODE_OUT" ]; then
        NUMBERED_NODE=$((NUMBERED_NODE + 1))
		COLOR_INDEX=$((COLOR_INDEX + 1))
        NODE_COLOR=$(echo $N_COLORS | cut -d' ' -f$((COLOR_INDEX)))
        SUPNN="<sup>$NUMBERED_NODE</sup>"
        NODE_NUM="<span style='color:$NODE_COLOR;'>$SUPNN</span>"
		if [ "$HOST_COLOR" = "1" ]; then NN=""; else NN="$SUPNN"; fi
        NODE_BRAND="<span class='router-branding' style='color:$NODE_COLOR;'>${NODE_NAME}$NN</span>"
		if [ -z "$N_NAMES" ]; then N_NAMES="$NODE_BRAND"; else N_NAMES="$N_NAMES$DOT$NODE_BRAND"; fi
		parse_node_out "$NODE_OUT"
		if [ "${#N_TEMP_RAW}" -gt 3 ]; then N_TEMP_RAW=$((N_TEMP_RAW / 1000)); fi
		N_TEMP=$(get_temp_unit "$N_TEMP_RAW")
		NC_TEMP=$(get_temp_class "$N_TEMP")
		NC_LOAD=$(get_load_class "$N_LOAD")
		N_BOOT=$(date -d @$(( $(date +%s) - ${N_UPTIME_RAW:-0} )) "$D_FMT")
		TOTAL_TEMP="$TOTAL_TEMP$DOT<span class='${NC_TEMP}'>${N_TEMP}</span>"
        TOTAL_LOAD="$TOTAL_LOAD$DOT<span class='${NC_LOAD}'>${N_LOAD}</span>"
        TOTAL_UPTIME="$TOTAL_UPTIME$DOT<span style='color:$NODE_COLOR;'>${N_UPTIME}</span>"
        TOTAL_BOOTTIME="$TOTAL_BOOTTIME$DOT<span style='color:$NODE_COLOR;'>${N_BOOT}</span>"
		N_TEMPS="${N_TEMPS}${N_TEMPS:+$DOT}<span class='${NC_TEMP}'>$N_TEMP</span>"
		N_LOADS="${N_LOADS}${N_LOADS:+$DOT}<span class='${NC_LOAD}'>$N_LOAD</span>"
        N_UPTIMES="${N_UPTIMES}${N_UPTIMES:+$DOT}<span style='color:$NODE_COLOR;'>$N_UPTIME</span>"
		N_BOOTS="${N_BOOTS}${N_BOOTS:+$DOT}<span style='color:$NODE_COLOR;'>$N_BOOT</span>"
        NODE_DEVICES=0
		while read -r ssh_node_data; do
			if [ -z "$ssh_node_data" ]; then continue; fi
			parse_node "$ssh_node_data"
			get_mac_address || continue
			get_ip
			final_chk
            is_mac_new=$(check_new_mac "$mac")
			trend=$(get_trend "$mac" "$rssi" "$NODE_NAME")
			band=$(get_band "$iface" "$width" "$ROUTER")
			check_qca_up
			uptime=$(fmt_uptime "$uptime")
			get_bars_rssi_style
			get_max_column
			hostcolor_node_name
            get_row
            NODE_ROWS="${NODE_ROWS}${ROW}${NL}"
			NODE_DEVICES=$((NODE_DEVICES + 1))
			NODE_DEVICE_TOTAL=$((NODE_DEVICE_TOTAL + 1))
        done <<EOF
$(echo "$NODE_OUT" | grep "DATA|")
EOF
NODE_TOTALS="${NODE_TOTALS}${NODE_TOTALS:+$DOT}<span style='color:$NODE_COLOR;'>$NODE_DEVICES</span>"
    fi
done
GRAND_TOTAL=$((MAIN_DEVICE_TOTAL + NODE_DEVICE_TOTAL))
BRAND_LINE_ALL="<span class='router-branding'>$MAIN_NAME</span>$DOT$N_NAMES"
do_numbered_node; do_runtime; header_box; do_darkmode
JS_DIFF="${DIFF:-5.00}"
mv "$NEW_HISTORY" "$HISTORY_DB"

#=================#
#  Generate HTML  #
#=================#
/usr/bin/printf '\xEF\xBB\xBF' > "$WEB_PAGE"
cat <<HTML >> "$WEB_PAGE"
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" />
<title>Wireless Report $LOCAL_VERSION $VERHASH</title>
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
	#wifiReportContainer { color: #f2f2f7; font-size: 12px; font-family: Arial, sans-serif; width: 97% !important; margin: 0 !important; padding: 0 !important; position: relative; }
	.report-header-main { text-align: center; color: #0096ff; margin: 0 0 10px 0; font-size: 1.8em; font-weight: bold; width: 100%; position: static; margin-left: 0; }
	.top-controls { display: flex; justify-content: center; gap: 8px; width: 100%; margin: 0 0 12px 0; }
	.total-count { text-align: center; color: #f2f2f7; margin-bottom: 12px; font-size: 11px; font-weight: bold; letter-spacing: 0.5px; }
	.count-highlight { background: #0096ff; color: #000; padding: 1px 6px; border-radius: 3px; margin-left: 4px; font-weight: 900; }
	.header-wrap { text-align: center; width: 100%; margin: 10px 0; }
	.header-box { visibility: hidden; width: var(--v-width, 190px); background: rgba(0,0,0,0.9); color: white; text-align: center; border: 1px solid #475a68; border-radius: 6px; padding: 8px; position: absolute; z-index: 999; bottom: 135%; left: 50%; transform: translateX(-50%); opacity: 0; transition: opacity 0.6s cubic-bezier(0.4, 0, 0.2, 1), bottom 0.6s cubic-bezier(0.4, 0, 0.2, 1); font-size: 0.85rem; font-weight: bold; box-shadow: 0 4px 12px #000; pointer-events: none; line-height: 1.4; }
	.header-tip { position: relative; cursor: pointer; display: inline-block; }
	.header-tip:hover .header-box { visibility: visible; opacity: 1; bottom: 145%; }
	.quality-bar { display: flex; justify-content: center; gap: 12px; align-items: center; width: 100%; margin: -5px auto -5px auto; padding: 0; background: transparent; border: none; height: auto; }
	.quality-box { display: inline-block; height: 28px; line-height: 26px; text-align: center; padding: 0 12px; border-radius: 4px; background: rgba(0,0,0,0.4); border: 1px solid #475a68; font-weight: bold; box-sizing: border-box; transition: all 0.2s ease; }
	.quality-box:hover { border-color: #0096ff; box-shadow: 0 0 10px rgba(0,150,255,0.4); cursor: pointer; }
	.refresh-box { display: inline-block; height: 28px; line-height: 26px; text-align: center; padding: 0 12px; border-radius: 4px; background: rgba(0,0,0,0.4); border: 1px solid #475a68; font-weight: bold; box-sizing: border-box; transition: all 0.2s ease; }
	.refresh-box:hover { border-color: #0096ff; box-shadow: 0 0 10px rgba(0,150,255,0.4); cursor: pointer; }
	${RUNTIME_CSS}
	.btn-black-blue { background: rgba(0,0,0,0.6); border: 1px solid #475a68; color: #0096ff; cursor: pointer; padding: 0 12px; font-size: 12px; border-radius: 4px; font-weight: bold; height: 28px; line-height: 26px; transition: all 0.2s ease; box-sizing: border-box; }
	.btn-black-blue:hover, .btn-black-blue.active { border-color: #0096ff; box-shadow: 0 0 10px rgba(0,150,255,0.4); color: #0096ff; }
	.btn-black-blue.active { background: rgba(0,150,255,0.15); }
	#countdown { margin-left: 6px; font-weight: bold; }
	#refreshRate:focus { outline: none; border: none; background: #000; }
	.grid-container { display: flex; flex-direction: column; gap: 15px; align-items: center; width: 100%; }
	${DARK_CSS}
	.report_table tbody tr:hover td { background-color: rgba(0, 123, 255, 0.15) !important; cursor: pointer; }
	table.report_table { width: 100%; border-collapse: collapse; }
	table.report_table .mac-val { $MAC_COLOR; }
	table.report_table .ip-val { $IP_COLOR; }
	table.report_table.show-ip .mac-val { display: none !important; }
	table.report_table.show-ip .ip-val { display: inline !important; }
	table.report_table.show-mac .mac-val { display: inline !important; }
	table.report_table.show-mac .ip-val { display: none !important; }
	table.report_table.show-iface .ssid-val { display: none !important; }
	table.report_table.show-iface .iface-val { display: inline !important; color: #64d2ff; }
	table.report_table thead th { position: sticky; top: 0; z-index: 10; background: linear-gradient(to bottom, #0096ff, #0056b3); color: #fff; padding: 8px; cursor: pointer; text-align: center; border-right: 1px solid rgba(255,255,255,0.1); }
	table.report_table th:hover { background: #00e5ff; color: #000; text-shadow: 0 0 10px rgba(0,229,255,0.8); }
	table.report_table td:nth-child(1) { max-width: 150px; white-space: nowrap; overflow: hidden; text-overflow: clip; }
	table.report_table td:nth-child(5) { max-width: 100px; white-space: nowrap; overflow: hidden; text-overflow: clip; }
	.mac-val, .ssid-val { display: inline; }
    .ip-val, .iface-val { display: none; }
    .seperator-line { border: 0; border-top: 1px solid #475a68; margin: 8px -12px; width: calc(100% + 24px); display: block; }
	.pulse-blue { color: #00e5ff !important; font-weight: bold; animation: pulse-blue-glow 2s infinite; }
	@keyframes pulse-blue-glow { 0% { opacity: 1; } 50% { opacity: 0.5; } 100% { opacity: 1; } }
	.new-device-row { background-color: rgba(0, 229, 255, 0.1) !important; animation: pulse-blue-glow 2s infinite; }
	.val-blue { color: #0096ff !important; font-weight: bold; }
	.rssi-exc { color: #30d158; } .rssi-good { color: #64d2ff; }
	.rssi-fair { color: #ffd60a; } .rssi-poor { color: #ff453a; }
	.stat-warm { color: #ffa500 !important; font-weight: bold; }
	.stat-hot { color: #ff453a !important; font-weight: bold; }
	.stat-cool { color: #0096ff !important; font-weight: bold; }
	.bar-box { font-family: monospace; font-weight: 900; width: 40px; display: inline-block; text-align: right; margin-right: 5px; }
	.router-branding { color: #0096ff; font-size: 1.4em; font-weight: bold; text-transform: uppercase; display: inline-block; margin-bottom: 4px; }
	.header-stats-row { display: block; font-size: 14px; color: #f2f2f7; margin-top: 5px; font-weight: bold; white-space: nowrap; width: 100%; overflow: visible !important; }
	.text-24 { color: #0096ff !important; font-weight: bold; }
	.text-5g { color: #30d158 !important; font-weight: bold; }
	.text-6g { color: #bf40bf !important; font-weight: bold; }
	.modal-overlay { display: none; position: fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.4); z-index:9999; align-items: center; justify-content: center; backdrop-filter: blur(8px); }
	.modal-content { background: rgba(0, 0, 0, 0.2); width: 95%; max-width: 1450px; margin: auto; padding:15px; border-radius:15px; border:1px solid rgba(0, 150, 255, 0.4); position: relative; max-height: 95vh; overflow-y: auto; box-shadow: 0 0 40px rgba(0,0,0,0.6); backdrop-filter: blur(20px); }
	.modal-close-x { position: absolute; top: 10px; right: 20px; color: #fff; font-size: 30px; cursor: pointer; font-weight: bold; }
	.modal-grid { display: flex; width: 100%; gap: 5px; margin-top: 5px; align-items: flex-start; justify-content: center; }
	.modal-grid .report-column { flex: 1; max-width: 49.5%; }
	#popoutModal th, #popoutModal td { white-space: nowrap; height: 25px !important; line-height: 25px !important; padding: 0 4px !important; }
	.dash-sep { color: rgba(255,255,255,0.4); font-size: 0.9em; margin: 0 4px; animation: sep-glow 3s infinite ease-in-out; }
	@keyframes sep-glow { 0% { color: rgba(255,255,255,0.2); } 50% { color: #0096ff; text-shadow: 0 0 5px #0096ff; } 100% { color: rgba(255,255,255,0.2); } }
	#allCol { display: none; width: 100% ; align-self: flex-start; }
	sup { font-size: 0.6em; margin-left: 2px; }
	.rssi-container { position: relative; cursor: help; vertical-align: middle; }
	.rssi-tooltip { visibility: hidden; position: fixed; z-index: 99999; background: #000; color: #fff; padding: 10px; border-radius: 8px; border: 1px solid #0096ff; opacity: 0; transition: opacity .3s; font: 1.1em monospace; white-space: pre; width: max-content; pointer-events: none; text-align: left !important; }
	.rssi-container:hover .rssi-tooltip { visibility: visible; opacity: 1; }
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
    });
    var scanTime = parseFloat("$JS_DIFF") || 5.0;
    var delay = Math.max(2500, Math.ceil((scanTime * 1000) + 1500));
    setTimeout(function() { window.location.reload(); }, delay);
}
window.addEventListener('load', function() {
    if (document.cookie.indexOf("report_done=true") === -1) {
        setTimeout(function() {
            triggerRefresh();
        }, 250);
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
	var allBar = document.getElementById('allDevicesQualityBar');
    if(view === 'all') {
        if (split) split.style.display = 'none';
        if (all) all.style.display = 'flex';
		if (allBar) allBar.style.display = 'flex';
        if (btnAll) btnAll.classList.add('active');
        if (btnStack) btnStack.classList.remove('active');
    } else {
        if (split) split.style.display = 'flex';
        if (all) all.style.display = 'none';
		if (allBar) allBar.style.display = 'none';
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
            h.innerHTML = "RSSI<span style='font-size:14px; font-weight:bold; margin-left:2px;'>ᵈᴮᵐ</span>";
        } else if (txt.includes("RX/TX")) {
            h.innerHTML = "RX/TX<span style='font-size:14px; font-weight:bold; margin-left:2px;'>ᵐᵇᵖˢ</span>";
        } else if (txt.includes("BAND")) {
            h.innerHTML = "BAND<span style='font-size:14px; font-weight:bold; margin-left:2px;'>ᵐʰᶻ</span>";
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
				var match = cell.innerHTML.match(/<sup>(\d+)<\/sup>/);
				return match ? parseInt(match[1]) : 0;
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
function openPopout() {
    localStorage.setItem('wifiReportPopoutOpen', 'true');
    var body = document.getElementById('popoutBody'); body.innerHTML = "";
    var mCol = document.getElementById('mainCol');
    var nCol = document.getElementById('nodeCol');
    if (!mCol || !nCol) return;
    mCol = mCol.cloneNode(true);
    nCol = nCol.cloneNode(true);
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
    Object.assign(mainWrapper.style, { display: "flex", flexDirection: "column", flex: "1", maxWidth: "49.5%" });
    Object.assign(mCol.style, { maxWidth: "100%", width: "100%" });
    mainWrapper.appendChild(mCol);
    var originalBar = document.querySelector('.quality-bar');
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
                <div id="wifiReportContainer" style="padding:10px;">
                    <div class="header-wrap"><div class="header-tip" style="--v-width: $V_WIDTH;"><h1 id="v-header" class="report-header-main" style="margin:0; display:inline-block;">WIRELESS REPORT</h1><span class="header-box">$HOVER_TEXT</span></div></div>
                    <div class="total-count">Total Wireless Devices: <span class="count-highlight">$GRAND_TOTAL</span></div>
                    <div class="top-controls">
                        <div class="refresh-box" style="padding:0 5px; display:inline-flex; align-items:center;">
                            <button class="btn-manual btn-black-blue" style="border:none; height:100%; line-height:inherit; padding:0 8px;" onclick="triggerRefresh()">
                                Refresh <span style="color: white;">${RUNTIME}</span>
                            </button>
                            <span style="font-size:12px; margin-left:5px; color: #0096ff;">Auto: </span>
                            <select id="refreshRate" onchange="localStorage.setItem('wifiReportAutoRefresh', this.value); initAutoRefresh(parseInt(this.value));" style="background:#000; font-weight:bold; color:white; border:0px solid #444; margin-left:5px; font-size:12px; height:20px;">
                                <option value="0">Off</option>
                                <option value="30">30s</option>
                                <option value="60">1m</option>
                                <option value="120">2m</option>
                                <option value="300">5m</option>
                                <option value="600">10m</option>
                                <option value="1200">20m</option>
                                <option value="1800">30m</option>
                            </select>
                            <span style="color: #0096ff;" id="countdown"></span>
                        </div>
HTML
if [ "$NUMBERED_NODE" -gt 0 ]; then
cat <<BUTTONSHTML >> "$WEB_PAGE"
                        <button id="btnStack" class="btn-black-blue active" onclick="switchTab('split')">Stacked</button>
                        <button id="btnAll" class="btn-black-blue" onclick="switchTab('all')">All Devices</button>
                        <button class="btn-black-blue" onclick="openPopout()">Side by Side ⇗</button>
BUTTONSHTML
fi
cat <<HTML >> "$WEB_PAGE"
                    </div>
                    <div class="grid-container">
                        <div id="splitView" style="display:flex; flex-direction:column; gap:15px; width:100%;">
                            <div id="mainCol" class="report-column">
                                <div class="section-header">
                                    $MAIN_LABEL<br>
                                    <span style="font-size:11px; font-weight:bold;">Updated: $CUR_TIME</span>
                                    <hr class="seperator-line">
                                    <div class="header-stats-row">Temp: <span class="$MC_TEMP">$M_TEMP</span>&ensp;Load: <span class="$MC_LOAD">$M_LOAD</span>&ensp;Devices: <span class="val-blue">$MAIN_DEVICE_TOTAL</span></div>
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
                                    <tbody>$MAIN_ROWS</tbody>
                                    <tfoot><tr><td colspan="7" style="text-align: center !important;">Uptime: <span class="val-blue">$M_UPTIME</span>&ensp;Reboot: <span class="val-blue">$M_BOOT</span></td></tr></tfoot>
                                </table>
                            </div>
                            <div class="quality-bar">
                                <div class="quality-box rssi-exc">Excellent: <span style="background:#30d158; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_EXC</span></div>
                                <div class="quality-box rssi-good">Good: <span style="background:#0096ff; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_GOOD</span></div>
                                <div class="quality-box rssi-fair" style="color:#ffd60a;">Fair: <span style="background:#ffd60a; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_FAIR</span></div>
                                <div class="quality-box rssi-poor" style="color:#ff453a;">Poor: <span style="background:#ff453a; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_POOR</span></div>
                            </div>
HTML
if [ "$NUMBERED_NODE" -gt 0 ]; then
cat <<NODEHTML >> "$WEB_PAGE"
                            <div id="nodeCol" class="report-column">
                                <div class="section-header">
                                    $N_NAMES <span class="router-branding"></span><br>
                                    <span style="font-size:11px; font-weight:bold;">Updated: $CUR_TIME</span>
                                    <hr class="seperator-line">
                                    <div class="header-stats-row">Temp: <span class='${NC_TEMP}'>${N_TEMPS:-0}</span>&ensp;Load: <span class='${NC_LOAD}'>${N_LOADS:-0}</span>&ensp;Devices: <span class="val-blue">$NODE_DEVICE_TOTAL</span> $NTOTAL</div>
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
                                    <tbody>$NODE_ROWS</tbody>
                                    <tfoot><tr><td colspan="7" style="text-align: center !important;">$( [ -n "$N_UPTIMES" ] && echo "Uptime: $N_UPTIMES&ensp; Reboot: $N_BOOTS" || echo "Offline" )</td></tr></tfoot>
                                </table>
                            </div>
                        </div>
NODEHTML
fi
cat <<HTML >> "$WEB_PAGE"
                        <div id="allCol" class="report-column">
                            <div class="section-header">
                                $BRAND_LINE_ALL<br>
                                <span style="font-size:11px; font-weight:bold;">Updated: $CUR_TIME</span>
                                <hr class="seperator-line">
                                <div class="header-stats-row" style="$TEMP_STYLE">Temp: $TOTAL_TEMP&ensp;Load: $TOTAL_LOAD&ensp;$TOTAL_DEVICES</div>
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
                                <tbody>$ALL_ROWS</tbody>
                                <tfoot><tr><td colspan="7" style="$UPTIME_STYLE">Uptime: $TOTAL_UPTIME&ensp;Reboot: $TOTAL_BOOTTIME</td></tr></tfoot>
                            </table>
                        </div>
                        <div id="allDevicesQualityBar" class="quality-bar">
                            <div class="quality-box rssi-exc">Excellent: <span style="background:#30d158; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_EXC</span></div>
                            <div class="quality-box rssi-good">Good: <span style="background:#0096ff; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_GOOD</span></div>
                            <div class="quality-box rssi-fair" style="color:#ffd60a;">Fair: <span style="background:#ffd60a; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_FAIR</span></div>
                            <div class="quality-box rssi-poor" style="color:#ff453a;">Poor: <span style="background:#ff453a; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_POOR</span></div>
                        </div>
                    </div>
                </div>
            </td>
        </tr>
    </table>
    <div id="footer"></div>
    <div id="popoutModal" class="modal-overlay" onclick="closePopout()">
        <div class="modal-content" onclick="event.stopPropagation()">
            <div style="height: 40px; position: relative;">
                <span class="modal-close-x" onclick="closePopout()">&times;</span>
            </div>
            <div id="popoutBody" class="modal-grid"></div>
        </div>
    </div>
</body>
HTML
rm -rf "$SEEN_MACS" "$HISTORY_CACHE" "$KNOWN_CACHE" "$ARP_CACHE" "$LEASES_CACHE" "$YAZ_CACHE" "$CUSTOM_CLIENTS_CACHE" "$DEVICE_LIST_CACHE" "$NODE_DATA_DIR" 2>/dev/null
}

case "$1" in
    install)
        # Install/Uninstall options
        install_menu
        ;;
    inject)
        # Called by services-start to mount tab
		inject_menu
        ;;
    inject2)
        # Called by services-start to mount menu
        INJECT="2"
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
