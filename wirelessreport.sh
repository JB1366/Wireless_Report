#!/bin/sh
#===============================================================================#
#                                                                               #
#       __      __ __                __                                         #
#      /  \    /  \__|______  ____  |  |   ____   ______ ______                 #
#      \   \/\/   /  \_  __ \/ __ \ |  | _/ __ \ /  ___//  ___/                 #
#       \        /|  ||  | \/\  __/ |  |_\  ___/ \___ \ \___ \                  #
#        \__/\  / |__||__|    \___  >____/\___  >____  >____  >                 #
#             \/                  \/          \/     \/     \/                  #
#                __________                            __                       #
#                \______   \ ____ ______   ____  ____ /  |__                    #
#                 |       _// __ \\  __ \ /  _ \/  __ \   __\                   #
#                 |    |   \  ___/|  |_> >  <_> )  | \/|  |                     #
#                 |____|_  /\___  >   __/ \____/|__|   |__|                     #
#                        \/     \/|__|                                          #
#                             _____   __                       __               #
#                            /  _  \ |__|__   _    ____  _____|  |__            #
#                           /  /_\  \|  /  \_/ \__/ __ \/  ___/  |  \           #
#                          /    |    \  |  Y Y  \  ___/ \___ \|   Y  \          #
#                          \____|__  /__|__|_|  /\___  >____  >___|  /          #
#                                  \/         \/     \/     \/     \/           #
#                                                                               #
#                                                                               #
#===============================================================================#
#                                                                               #
#              Copyright (c) 2026 JB_1366 - All Rights Reserved                 #
#                  https://github.com/JB1366/Wireless_Report                    #
#                                                                               #
#===============================================================================#
# shellcheck shell=sh disable=SC2086,SC2155,SC3043                              #                  
#===============================================================================#

SCRIPT_VERSION="1.8.4"
INSTALL_DIR="/jffs/addons/wireless_report"
REPORT_SCRIPT="$INSTALL_DIR/wirelessreport.sh"
CONFIG="$INSTALL_DIR/webui.conf"
WEB_PAGE="/tmp/wireless.asp"
SYSTEM_MENU="/www/require/modules/menuTree.js"
TEMP_MENU="/tmp/menuTree.js"
SS_FILE="/jffs/scripts/services-start"
SE_FILE="/jffs/scripts/service-event"
NEW_HISTORY="/tmp/rssi_new.db"
SEEN_MACS="/tmp/seen_macs.txt"
YAZ_CACHE="/tmp/yaz_cache.tmp"
ARP_CACHE="/tmp/arp_cache.tmp"
KNOWN_CACHE="/tmp/known_macs.cache"
HISTORY_CACHE="/tmp/rssi_history.cache"
LEASES_CACHE="/tmp/dnsmasq_leases.cache"
DEVICE_LIST_CACHE="/tmp/asus_device_list.cache"
CUSTOM_CLIENTS_CACHE="/tmp/custom_clients.cache"
GITHUB="https://raw.githubusercontent.com/JB1366/Wireless_Report/main/wirelessreport.sh"
REMOTE_VER=$(curl -sfL --retry 3 "$GITHUB" | grep "SCRIPT_VERSION=" | head -n 1 | cut -d'"' -f2 | tr -cd '0-9.')
[ -f "/root/.ssh/id_dropbear" ] && SSH_KEY="/root/.ssh/id_dropbear" || SSH_KEY=""
BL='\033[38;5;39m'; GR='\033[0;32m'; NC='\033[0m'; RD='\033[0;31m'
UL='\033[4m'; WH='\e[1;37m'; YL='\033[0;33m'
NODE_USER=$(nvram get http_username)
SSH_PORT=$(nvram get sshd_port)
[ -z "$SSH_PORT" ] && SSH_PORT=22
[ -f "$CONFIG" ] && . "$CONFIG"
doScriptUpdateFromAMTM=true
unset LD_LIBRARY_PATH
export PATH="/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

#==================#
#  Script Install  #
#==================#
install_menu() {
	while true; do
		clear; menu_vars 
		echo -e "${BL}" #=====================================================
		echo -e "  __      __ __               __                            "
		echo -e " /  \    /  \__|______  ____ |  |   ____  ____________      "
		echo -e " \   \/\/   /  \_  __ \/ __ \|  | _/ __ \/  ___/  ___/      "
		echo -e "  \        /|  ||  | \/\  __/|  |_\  ___/\___ \___  \       "
		echo -e "   \__/\  / |__||__|    \___ >____/\___ >____  >___  >      "
		echo -e "        \/                  \/         \/    \/    \/       "
		echo -e "      __________                           __               "
		echo -e "      \______   \ ____  ____   ____  _____/  |__            "
		echo -e "       |       _// __ \/ __ \ /  _ \/  __ \   __\           "
		echo -e "       |    |   \  ___/| |_> X  (_) )  | \/|  |             "
		echo -e "       |____|_  /\___  >   _/ \____/|__|   |__|             "
		echo -e "              \/     \/|__|                                 "
		echo -e "    _____   __                      __                      "
		echo -e "   /  _  \ |__|__   _   ____  _____/  |__                   "
		echo -e "  /  /_\  \|  /  \_/ \_/ __ \/ ___/\  |  \                  "
		echo -e " /    |    \  |  Y Y  \  ___/\___ \/   Y  \                 "
		echo -e " \____|__  /__|__|_|  /\___ >____  >___|  /                 "
		echo -e "         \/         \/     \/    \/     \/                  "
		echo -e "                                                            "
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
		echo -e "  $N5  Set Toggles  RT:($R_STAT) BH:($B_STAT) UP:($P_STAT)  "
		echo -e "  $N6  Node Authentication                                  "
		echo -e "  $N7  Setup SSH Enviroment ($KEY)                          "
		echo -e "  $NE  Exit                                                 "
		echo -e "                                                            "
		echo -e "${BL}==================================================${NC}"
		printf "\n ${BL}Selection:${NC} "
		read choice
        case "$choice" in
            1) do_install ;;
            2) do_uninstall ;;
            3) set_temp_date ;;
            4) set_nicknames ;;
            5) set_toggle ;;
            6) node_auth "pause" ;;
            7) check_ssh "pause" ;;
            e|E) clear; hasta; exit 0 ;;
            *) ;;
        esac
	done
}

check_version() { 
	if [ -f "$REPORT_SCRIPT" ]; then
        LOCAL_VER=$(grep "SCRIPT_VERSION=" "$REPORT_SCRIPT" | head -n 1 | cut -d'"' -f2 2>/dev/null)
    else
        LOCAL_VER="Not Installed"
    fi
	if [ -z "$REMOTE_VER" ]; then
        echo -e " ${BL}STATUS:${NC} ${RD}[Offline]${NC} Could not reach GitHub"
    elif [ "$LOCAL_VER" = "Not Installed" ]; then
        echo -e " ${BL}STATUS:${NC} ${RD}[Not Installed]${NC} Latest Available: ${GR}v$REMOTE_VER${NC}"
    elif [ "$LOCAL_VER" != "$REMOTE_VER" ]; then
        echo -e " ${BL}STATUS:${NC} ${RD}[Update Available] v$REMOTE_VER${NC} ${GR}(Current: v$LOCAL_VER)${NC}"
    else
        echo -e " ${BL}STATUS:${NC} [Up to date] ${GR}v$LOCAL_VER${NC}"
    fi
}

menu_vars() {
    JB1366="${GR}${UL}\e]8;;https://github.com/JB1366/Wireless_Report\e\\\\https://github.com/JB1366/Wireless_Report\e]8;;\e\\\\${NC}"
	[ -f "$CONFIG" ] && . "$CONFIG"; update_time
	if [ "$REPORT_UNIT" = "ISO" ]; then
        DISPLAY_UNIT="C"
    else
        DISPLAY_UNIT="${REPORT_UNIT:-F}"
    fi
    [ -z "$RTIME" ] && RTIME="1"
    if [ "$RTIME" = "0" ]; then
        R_STAT="${RD}OFF${NC}"
    else
        R_STAT="${GR}ON${NC}"
    fi
    [ -z "$BACKHAUL" ] && BACKHAUL="no"
    if [ "$BACKHAUL" = "no" ]; then
        B_STAT="${RD}OFF${NC}"
    else
        B_STAT="${GR}ON${NC}"
    fi
    [ -z "$PULSE_MINS" ] && PULSE_MINS="15"
    if [ "$PULSE_MINS" = "0" ]; then
        P_STAT="${RD}OFF${NC}"
    else
        P_STAT="${GR}${PULSE_MINS} Mins${NC}"
    fi
	if [ ! -f "$SSH_KEY" ]; then
		KEY="${RD}NO KEY FOUND${NC}"
	else
		KEY="${GR}SSH KEY FOUND${NC}"
	fi
	N1="${BL}(1)${NC}"; N2="${BL}(2)${NC}"; N3="${BL}(3)${NC}"
	N4="${BL}(4)${NC}"; N5="${BL}(5)${NC}"; N6="${BL}(6)${NC}"
	N7="${BL}(7)${NC}"; N8="${BL}(8)${NC}"; N9="${BL}(9)${NC}"
	N0="${BL}(0)${NC}"; NV="${BL}(v)${NC}"; NE="${BL}(e)${NC}"; NU="${BL}(u)${NC}"
	CT="${GR}$CUR_TIME${NC}"; DU="${GR}°$DISPLAY_UNIT${NC}"
	DATE_USA=$(date +"%b-%d"); DATE_INTL=$(date +"%d-%b"); DATE_ISO=$(date +"%Y-%m-%d")
}
			
check_installed() {
	if [ ! -f "$REPORT_SCRIPT" ]; then
        echo -e "\n${RD}[!] ERROR: Wireless Report AiMesh not Installed.${NC}\n"
        echo -e "${YL}[i] You must successfully run 'Install/Update' before changing settings.${NC}"
        pause
        return 1
    fi
    [ ! -f "$CONFIG" ] && touch "$CONFIG"
    return 0
}

do_install() {
	mkdir -p "$INSTALL_DIR" 2>/dev/null
    if [ -f "$REPORT_SCRIPT" ]; then
        if [ "$LOCAL_VER" = "$REMOTE_VER" ] && [ -n "$REMOTE_VER" ]; then
            echo -e "\n${YL}[i] You are already on the latest version (v$LOCAL_VER).${NC}\n"
            printf "Do you want to reinstall/overwrite anyway? (y/n): "
            read -r reinstall
            if [ "$reinstall" != "y" ] && [ "$reinstall" != "Y" ]; then
				return
            fi
        fi
		if do_update; then
            echo -e "\n${GR}[✓] Wireless Report successfully installed.${NC}"
			restart_httpd
            pause
            return 0
        fi
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
    echo -e "${GR}[+] Processing Wireless Report Files...${NC}\n"
    grep -q "REPORT_UNIT=" "$CONFIG" 2>/dev/null || echo "REPORT_UNIT=F" >> "$CONFIG"
	grep -q "BACKHAUL=" "$CONFIG" 2>/dev/null || echo 'BACKHAUL="no"' >> "$CONFIG"
	grep -q "PULSE_MINS=" "$CONFIG" 2>/dev/null || echo 'PULSE_MINS="15"' >> "$CONFIG"
    [ -f "$TEMP_MENU" ] && sed -i '/Wireless Report/d' "$TEMP_MENU" 2>/dev/null
    if [ -f "$CONFIG" ]; then
        OLD_PAGE=$(grep "INSTALLED_PAGE=" "$CONFIG" | cut -d'=' -f2)
        if [ -n "$OLD_PAGE" ]; then
            umount -l "/www/user/$OLD_PAGE" 2>/dev/null
            rm -f "/www/user/$OLD_PAGE"
        fi
    fi
    curl -sfL --retry 3 "$GITHUB" -o "$REPORT_SCRIPT"
	if [ ! -s "$REPORT_SCRIPT" ]; then
        echo -e "\n${YL}[!] GitHub unreachable. Installing current local copy...${NC}\n"
        cp "$0" "$REPORT_SCRIPT"
    fi
    chmod +x "$REPORT_SCRIPT" 2>/dev/null
    if [ -f "$REPORT_SCRIPT" ]; then
        inject_menu
		echo -e "${GR}[+] Mounting Menu[Wireless] Tab[Wireless Report]${NC}"
        [ ! -f "$SS_FILE" ] && echo "#!/bin/sh" > "$SS_FILE"
        sed -i "\|$REPORT_SCRIPT|d" "$SS_FILE"
        echo "sh $REPORT_SCRIPT inject # Inject Wireless Report" >> "$SS_FILE"
        chmod +x "$SS_FILE"
        [ ! -f "$SE_FILE" ] && echo "#!/bin/sh" > "$SE_FILE"
        sed -i "/wireless_report/d" "$SE_FILE"
        echo 'if [ "$1" = "restart" ] && [ "$2" = "wireless_report" ]; then sh '$REPORT_SCRIPT'; fi # Wireless Report' >> "$SE_FILE"
        chmod +x "$SE_FILE"
        restart_httpd
		install=""
        echo -e "\n${GR}[✓] SUCCESS: Installation complete!${NC}"
		echo -e "\n${YL}[i] To access Report, navigate to Advanced Settings > Wireless ${NC}"
		echo -e "${YL}    in the ASUS WebGUI and select the Wireless Report tab on the far right.${NC}"
		echo -e "\n${BL}[i] Tip: On router only install, you can add node(s) later.${NC}"
        echo -e "${BL}[i]      Use option #6 in main menu to authenticate new node(s).${NC}"
		echo -e "\n${YL}[i] Use Option 4 if you wish to set custom nicknames.${NC}"
	else
        echo -e "${RD}[!] ERROR: Download failed.${NC}"
    fi
    pause
}

do_update() {
    echo -e "\n${GR}[+] Downloading latest version (v$REMOTE_VER)${NC}"
    if curl -sfL --retry 3 "$GITHUB" -o "$REPORT_SCRIPT"; then
        chmod +x "$REPORT_SCRIPT" 2>/dev/null
        return 0
    else
        echo -e "${RD}[!] Download failed. Sticking with current version.${NC}"
        return 1
    fi
}

get_usb() {
    local BUP=$(cut -d. -f1 /proc/uptime)
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
    [ -n "$USB_PATH" ] && [ ! -d "$USB_PATH" ] && mkdir -p "$USB_PATH"
    KNOWN_DB="$USB_PATH/known_macs.db"
	HISTORY_DB="$USB_PATH/rssi_history.db" 
    ERROR_LOG="$USB_PATH/ssh_error.log"
	export USB_PATH KNOWN_DB HISTORY_DB ERROR_LOG
}

check_storage() {
    get_usb
	echo -e "\n${BL}[*] Checking for Storage...${NC}"
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

check_ssh() {
	if [ "$1" = "pause" ]; then
        check_installed || return 1
    fi
	while true; do
		clear; menu_vars; get_usb
		echo -e "${BL}==================================================${NC}"
		echo -e "${BL}                 SSH Environment                  ${NC}"
		echo -e "${BL}==================================================${NC}"
		echo -e " Status: $KEY                Port: ${GR}$SSH_PORT      ${NC}"
		echo -e "${BL}==================================================${NC}"
		echo -e "                                                            "
		echo -e "  $N1  Create RSA Keys & Setup AiMesh Nodes                 "
		echo -e "  $N2  Router-Only Setup                                    "
		echo -e "  $N3  View Authorized Keys                                 "
		echo -e "  $N4  View Known Hosts                                     "
		echo -e "  $N5  View SSH Error Log                                   "
		echo -e "  $N6  Node Authentication                                  "
		echo -e "                                                            "
		echo -e "  $NE  Exit to main menu                                    "
		echo -e "                                                            "
		echo -e "${BL}==================================================${NC}"
		printf "\n ${BL}Selection:${NC} "
		read ssh_choice
		case "$ssh_choice" in
            1)
                ssh_keys
                if [ "$install" = "1" ]; then
                    return 0
                fi
                continue
                ;;
            2)
                echo -e "\n${YL}[i] Setting Up Router-Only...${NC}"
                sed -i '/^SSH_NODES=/d' "$CONFIG"
                echo 'SSH_NODES=" "' >> "$CONFIG"
                sleep 5
				pause
                continue
                ;;
            3)
                echo -e "\n${BL}================ Authorized Keys =================${NC}\n"
                if [ -f "/root/.ssh/authorized_keys" ]; then
                    cat /root/.ssh/authorized_keys
                else
                    echo -e "${YL}[!] File not found.${NC}"
                fi
                echo -e "\n\n${BL}==================================================${NC}"
                pause
                continue
                ;;
            4)
                echo -e "\n${BL}================== Known Hosts  ==================${NC}\n"
                if [ -f "/jffs/.ssh/known_hosts" ]; then
                    cat /jffs/.ssh/known_hosts
                else
                    echo -e "${YL}[!] File not found.${NC}"
                fi
                echo -e "\n${BL}==================================================${NC}"
                pause
                continue
                ;;
            5) 
                echo -e "\n${BL}================= SSH Error Log ==================${NC}\n"
                if [ -f "$ERROR_LOG" ]; then
                    cat "$ERROR_LOG"
                else
                    echo -e "${YL}[!] File not found.${NC}"
                fi
                echo -e "\n${BL}==================================================${NC}"
                pause
                continue
                ;;
            6) 
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
	[ ! -f "$CONFIG" ] && touch "$CONFIG"
	if [ ! -s "$SSH_KEY" ]; then
		echo -e "\n${YL}[!] Main Router SSH Key not found.${NC}"
		sleep 3
		return
	fi
	sed -i '/^SSH_NODES=/d' "$CONFIG"
	echo -e "\n${GR}[✓] Main Router SSH Key found at: ${WH}$SSH_KEY${NC}\n"
	echo -e "${BL}==================================================${NC}"
    echo -e "${BL}          Verifying Node Authentication           ${NC}"
    echo -e "${BL}==================================================${NC}\n"
    NODE_IPS=$(nvram get asus_device_list | sed 's/</\n/g' | grep '>2$' | awk -F '>' '{print $2 "|" $3}' | sort -t . -k 4,4n)
    if [ -z "$NODE_IPS" ]; then
        NODE_IPS=$(nvram get dhcp_staticlist | sed 's/</\n/g' | awk -F'>' '{print $3 "|" $2}' | grep -v "|^$")
    fi
    if [ -z "$NODE_IPS" ]; then
        echo -e "\n${RD}[!] No AiMesh Nodes detected in NVRAM.${NC}"
        TOTAL_NODES=0
        any_success=0
        ACTION_MSG="Force ROUTER-ONLY configuration"
        KEY_LBL="r"
    else
        TOTAL_NODES=$(echo "$NODE_IPS" | wc -l)
		any_success=0
        VALID_NODES=""
		new_nodes=0
        for line in $NODE_IPS; do
			get_usb
			ALIAS=$(echo "$line" | cut -d'|' -f1)
			IP=$(echo "$line" | cut -d'|' -f2)
			[ -z "$IP" ] && continue
			[ -z "$ALIAS" ] && ALIAS="Node_$IP"
			printf "[*] Testing ${GR}%-14s${NC} (%s) " "$ALIAS" "$IP"
			#SSH_ERR #true #false #[ "$IP" != "192.168.50.2" -a "$IP" != "192.168.50.4" ]
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
				VALID_NODES="$VALID_NODES $ALIAS|$IP"
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
				if grep -q "No auth methods" "$ERROR_LOG"; then
					echo -e "${RD}[✗] Failed: Invalid Username or SSH Key.${NC}"
				elif grep -q "Connection refused" "$ERROR_LOG"; then
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
            echo -e "${YL}[!] $new_nodes new node$suffix successfully authenticated.${NC}"
        fi
        if [ "$1" = "pause" ]; then
            pause
            return
        else
            return
        fi
    else
        if [ "$any_success" -gt 0 ]; then
            echo -e "\n${YL}[!] Partial Success: Only $any_success of $TOTAL_NODES nodes authenticated.${NC}"
            ACTION_MSG="Continue with current nodes only"
            KEY_LBL="c"
        else
            echo -e "\n${RD}[!] CRITICAL: SSH authentication failed on all nodes.${NC}"
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
					echo -e "\n\n${BL}[i] Retrying authentication (wait for NVRAM sync)...${NC}"
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
		echo -e "\n${YL}[!] Main Router SSH Key already exsists.${NC}"
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
    if [ ! -f "$SS_FILE" ]; then
        echo "#!/bin/sh" > "$SS_FILE"
        chmod +x "$SS_FILE"
    fi
    if ! grep -q "id_dropbear" "$SS_FILE"; then
        echo -e "\n${YL}[i] Adding SSH Key to services-start for persistence on reboots...${NC}\n"
		echo -e "${YL}[i] Adding known_hosts to services-start...${NC}\n"
		echo "cp /jffs/.ssh/id_dropbear /tmp/home/root/.ssh/id_dropbear # sshpairs" >> "$SS_FILE"
        echo "cp /jffs/.ssh/known_hosts /tmp/home/root/.ssh/known_hosts # sshpairs persistance" >> "$SS_FILE"
    fi
	echo -e "${BL}==================================================${NC}"
	echo -e "${YL}               ACTION REQUIRED NOW                ${NC}"
    echo -e "${BL}==================================================${NC}"
	echo -e "\n${BL}[*] STEP 1: Go to Asus WebGUI > AiMesh > Management${NC}" 
	echo -e "${BL}[*] STEP 2: Click 'Reboot Node' for each node${NC}\n"
	echo -e "${YL}[!] Do not press [Enter] until Nodes are confirmed to be back online.${NC}\n"
	echo -e "${BL}[*] TIP: If a node is missing after authentication,${NC}"
	echo -e "${BL}[*]      use option #6 to reauthenticate.${NC}"
	echo -ne "\n[*] Press ${BL}[ENTER]${NC} to begin authentication check..." 
	read
	node_auth "pause"
}

inject_menu() {
	source /usr/sbin/helper.sh
	TAB_LABEL="Wireless Report"
	[ -f "$CONFIG" ] && sed -i '/^INSTALLED_PAGE=/d' "$CONFIG"
    nvram get rc_support | grep -q am_addons || { logger -p user.info -t "Wireless_Report" "No addon support!"; exit 5; }
    [ ! -f "$WEB_PAGE" ] && echo "<html><body>Wireless Report Loading...</body></html>" > "$WEB_PAGE"
	am_get_webui_page "$WEB_PAGE"
	[ "$am_webui_page" = "none" ] && { logger -p user.info -t "Wireless_Report" "Registration failed"; exit 5; }
	cp "$WEB_PAGE" "/www/user/$am_webui_page" 2>/dev/null
	if [ -f "$CONFIG" ]; then
		echo "INSTALLED_PAGE=$am_webui_page" >> "$CONFIG"
	else
		echo "INSTALLED_PAGE=$am_webui_page" > "$CONFIG"
	fi
	if [ ! -f "$TEMP_MENU" ]; then
		cp "$SYSTEM_MENU" /tmp/
		mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"
	fi
	sed -i 'N; /menuName: "Wireless Report"/ { N; N; N; N; N; N; d; }; P; D' "$TEMP_MENU" 2>/dev/null
	sed -i '/tabName:[[:space:]]*"Wireless Report"/d' "$TEMP_MENU" 2>/dev/null
	if [ "$INJECT" = "2" ]; then
		NL=$'\n'
		INSERT_DATA="{\\${NL}menuName: \"$TAB_LABEL\",\\${NL}index: \"menu_Wireless\",\\${NL}tab: [\\${NL}{url: \"$am_webui_page\", tabName: \"$TAB_LABEL\" },\\${NL}{url: \"NULL\", tabName: \"__INHERIT__\" }\\${NL}]\\${NL}},"
		sed -i "/^.*{[[:space:]]*$/ { N; /menuName: \"<#1558#>\",/ i $INSERT_DATA
		}" "$TEMP_MENU"
		logger -p user.info -t "Wireless_Report" "Mounting Menu[Wireless Report] as $am_webui_page"
	else
		sed -i "/index: \"menu_Wireless\"/,/{url: \"NULL\", tabName: \"__INHERIT__\"}/ s|{url: \"NULL\", tabName: \"__INHERIT__\"}|{url: \"$am_webui_page\", tabName: \"$TAB_LABEL\"},\n&|" "$TEMP_MENU"
		logger -p user.info -t "Wireless_Report" "Mounting Menu[Wireless] TAB[Wireless Report] as $am_webui_page"
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
    echo -e "\n${RD}[!] WARNING: Removing Wireless Report AiMesh...${NC}\n"
    printf "Are you sure? (y/n): "
    read confirm
    if [ "$confirm" = "n" ] || [ "$confirm" = "N" ]; then
		return
	fi
	[ -f "$CONFIG" ] && . "$CONFIG"
	get_usb
	if mount | grep -q "menuTree.js"; then
		umount -l "$SYSTEM_MENU" >/dev/null 2>&1
		sed -i 'N; /menuName: "Wireless Report"/ { N; N; N; N; N; N; d; }; P; D' "$TEMP_MENU" 2>/dev/null
		sed -i '/tabName:[[:space:]]*"Wireless Report"/d' "$TEMP_MENU" 2>/dev/null
		if grep -q "tabName" "$TEMP_MENU"; then
			mount --bind "$TEMP_MENU" "$SYSTEM_MENU"
		else
			echo -e "${BL}[*] Wireless Menu restored to default.${NC}"
		fi
	fi
	if [ -n "$INSTALLED_PAGE" ]; then
		logger -p user.info -t "Wireless_Report" "Unmounting Wireless Report Tab."
		umount -l "/www/user/$INSTALLED_PAGE" >/dev/null 2>&1
		rm -f "/www/user/$INSTALLED_PAGE" >/dev/null 2>&1
		echo -e "${BL}[*] Removing Wireless Report Tab...${NC}"
	fi
	sed -i "\|$REPORT_SCRIPT|d" "$SS_FILE"
	sed -i "/wireless_report/d" "$SE_FILE"
	restart_httpd
	rm -rf "$INSTALL_DIR" 2>/dev/null
	rm -rf "$WEB_PAGE" 2>/dev/null
	case "$USB_PATH" in *wirelessreport*) rm -rf "$USB_PATH" 2>/dev/null ;; esac
	echo -e "${GR}[+] System cleaned. SSH Keys and Fingerprints preserved in /jffs/.ssh${NC}\n"
	echo -e "${GR}[+] Success: Wireless Report uninstalled.${NC}"
	pause
}

set_temp_date() {
    check_installed || return 1
    while true; do
        clear; menu_vars
        echo -e "${BL}==================================================${NC}"
        echo -e "${BL}                  Set Temp/Date                   ${NC}"
        echo -e "${BL}==================================================${NC}"
        echo -e "  ${BL}Unit:${NC} $DU              ${BL}Date:${NC} $CT      "
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
        read t_choice
        case "$t_choice" in
            1) NEW_UNIT="F" ;;
            2) NEW_UNIT="C" ;;
            3) NEW_UNIT="ISO" ;;
            e|E) return ;;
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
        clear; menu_vars
        echo -e "${BL}==================================================${NC}"
        echo -e "${BL}              Router/Node Nicknames               ${NC}"
        echo -e "${BL}==================================================${NC}"
        echo -e "    (Press $N0 for Defaults $N1 for Locations)              "
        echo -e "              (Press $NE to Exit)                           "
        echo -e "${BL}==================================================${NC}"
        MAIN_HW_MODEL=$(nvram get modelid)
        [ -z "$MAIN_HW_MODEL" ] && MAIN_HW_MODEL=$(nvram get productid)
        MAIN_IP=$(nvram get lan_ipaddr)
        echo -e "\n  ${BL}Main${NC} $MAIN_IP -> ${GR}${MAIN_NICK:-$MAIN_HW_MODEL}${NC}"
        if [ -n "$SSH_NODES" ] && [ "$SSH_NODES" != " " ]; then
            VALID_NODES=$(echo "$SSH_NODES" | tr ' ' '\n' | grep '|')
            for node in $VALID_NODES; do
                MODEL=$(echo "$node" | cut -d'|' -f1); IP=$(echo "$node" | cut -d'|' -f2)
                CLEAN_IP=$(echo "$IP" | tr '.' '_')
                eval SAVED_NICK=\$NODE_NICK_$CLEAN_IP
                echo -e "  ${BL}Node${NC} $IP -> ${GR}${SAVED_NICK:-$MODEL}${NC}"
            done
        fi
        echo -e "\n${BL}==================================================${NC}"
        printf "\n${BL} [Enter]${NC} Manual Name | ${BL}Selection:${NC} "
        read input_main
        case "$input_main" in
            e|E)
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
                        MODEL=$(echo "$node" | cut -d'|' -f1); IP=$(echo "$node" | cut -d'|' -f2)
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
                read manual_main
                if [ -n "$manual_main" ]; then
                    sed -i '/^MAIN_NICK=/d' "$CONFIG"
                    echo "MAIN_NICK=\"$manual_main\"" >> "$CONFIG"
                fi
                for node in $VALID_NODES; do
                    MODEL=$(echo "$node" | cut -d'|' -f1); IP=$(echo "$node" | cut -d'|' -f2)
                    CLEAN_IP=$(echo "$IP" | tr '.' '_')
                    eval OLD_NICK=\$NODE_NICK_$CLEAN_IP
                    printf "  Node $IP ${GR}[${OLD_NICK:-$MODEL}]:${NC} "
                    read input_node
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

set_toggle() {
    check_installed || return 1
    while true; do
        clear; menu_vars; get_usb
        echo -e "${BL}==================================================${NC}"
        echo -e "${BL}                    Set Toggles                   ${NC}"
        echo -e "${BL}==================================================${NC}"
        echo -e "                                                            "
        echo -e "  $N1  Show Runtime Tracking: ($R_STAT)                     "
        echo -e "  $N2  Show Wireless Backhaul: ($B_STAT)                    "
        echo -e "  $N3  Uptime Alert Pulse: ($P_STAT)                        "
		echo -e "                                                            "
		echo -e "                                                            "
		echo -e "  $NU  USB Check                                            "
        echo -e "  $NV  View CONFIG                                          "
		echo -e "  $NE  Exit to main menu                                    "
        echo -e "                                                            "
		echo -e "${BL}==================================================${NC}"
		printf "\n ${BL}Selection:${NC} "
        read t_choice
		case "$t_choice" in
            1) 
                if grep -q "RTIME=" "$CONFIG"; then
                    [ "$RTIME" = "1" ] && sed -i 's/RTIME=.*/RTIME="0"/' "$CONFIG" || sed -i 's/RTIME=.*/RTIME="1"/' "$CONFIG"
                else
                    echo 'RTIME="0"' >> "$CONFIG"
                fi
                if [ -f "$USB_PATH/runtime.db" ]; then
                    rm -f "$USB_PATH/runtime.db"
                fi 
                ;;
            2) 
                if grep -q "BACKHAUL=" "$CONFIG"; then
                    [ "$BACKHAUL" = "yes" ] && NEW_BACK="no" || NEW_BACK="yes"
                    sed -i "s/BACKHAUL=.*/BACKHAUL=\"$NEW_BACK\"/" "$CONFIG"
                else
                    echo 'BACKHAUL="yes"' >> "$CONFIG"
                fi 
                ;;
            3) 
                echo -e "\n (${GR}0${NC}) disable (${GR}15${NC}) def (${GR}1440${NC}) max "
                printf " ${BL}Enter alert interval in mins:${NC} "
                read user_mins
                sed -i '/^D_MINS=/d' "$CONFIG" # delete later
                [ -z "$user_mins" ] && user_mins="15"
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
            
			u|U) 
                echo -e "\n${BL}================= USB Check ======================${NC}"
                check_storage
                echo -e "\n${BL}==================================================${NC}"
                pause
                continue
                ;;
				
			v|V) 
                echo -e "\n${BL}================== CONFIG ======================${NC}\n"
                if [ -f "$CONFIG" ]; then
                    cat "$CONFIG"
                else
                    echo -e "${GR}[!] No CONFIG file found.${NC}"
                fi
                echo -e "\n${BL}==================================================${NC}"
                pause
                continue
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
	echo -e "\n${GR}[✓] Wireless Report successfully updated${NC}"
    return "$?"
}

restart_httpd() {
    service restart_httpd >/dev/null 2>&1 || killall -HUP httpd >/dev/null 2>&1
}

pause() {
    printf "\nPress ${BL}[Enter]${NC} to return..."
    read discard
}

do_runtime() {
	[ -z "$RTIME" ] && RTIME="1"
	if [ "$RTIME" = "1" ]; then
		END_RUNTIME=$(awk '{print $1}' /proc/uptime)
		STATS_FILE="$USB_PATH/runtime.db"
		DIFF=$(awk "BEGIN {printf \"%.2f\", $END_RUNTIME - $START_RUNTIME}")
		RUNTIME="${DIFF}s"
		if [ ! -f "$STATS_FILE" ] || [ "$(wc -w < "$STATS_FILE")" -lt 4 ]; then
			echo "0 0 999.99 0.00" > "$STATS_FILE"
		fi
		read -r TOTAL_TIME COUNT MIN_TIME MAX_TIME < "$STATS_FILE"
		NEW_TOTAL=$(awk "BEGIN {printf \"%.2f\", $TOTAL_TIME + $DIFF}")
		NEW_COUNT=$((COUNT + 1))
		AVERAGE=$(awk "BEGIN {printf \"%.2f\", $NEW_TOTAL / $NEW_COUNT}")
		NEW_MIN=$(awk "BEGIN {printf \"%.2f\", ($DIFF < $MIN_TIME) ? $DIFF : $MIN_TIME}")
		NEW_MAX=$(awk "BEGIN {printf \"%.2f\", ($DIFF > $MAX_TIME) ? $DIFF : $MAX_TIME}")
		echo "$NEW_TOTAL $NEW_COUNT $NEW_MIN $NEW_MAX" > "$STATS_FILE"
		logger -p user.info -t "Wireless_Report" "Report completed in $RUNTIME. AVG: ${AVERAGE}s (L: ${NEW_MIN}s/H: ${NEW_MAX}s) over $NEW_COUNT runs."
		RUNTIME_CSS=".refresh-box:hover select, .refresh-box:hover .btn-manual { color: #0096ff !important; }
			.refresh-box, .refresh-box select, .refresh-box .btn-manual { position: relative; display: inline-block; }
			.refresh-box:before, .refresh-box .btn-manual:before, .refresh-box select:before { position: absolute; height: 28px; line-height: 28px; padding: 0 15px; background: rgba(10,10,10,0.95); color: white; font-size: 12px; font-weight: bold; border: 1.5px solid #0096ff; border-radius: 20px; box-shadow: 0 0 10px rgba(0,150,255,0.3); white-space: nowrap; opacity: 0; visibility: hidden; transition: all 0.3s ease; z-index: 100; pointer-events: none; }
			.refresh-box:after, .refresh-box .btn-manual:after, .refresh-box select:after { content: \"\"; position: absolute; width: 4px; height: 4px; background: #0096ff; border-radius: 50%; opacity: 0; visibility: hidden; transition: all 0.3s ease; z-index: 101; pointer-events: none; }
			.refresh-box:before { content: \"Avg: ${AVERAGE}s over $NEW_COUNT runs\"; left: -110px; bottom: 185%; }
			.refresh-box:after { left: 15px; bottom: 130%; box-shadow: -12px -12px 0 1.5px #0096ff; }
			.refresh-box .btn-manual:before, .refresh-box select:before { content: \"High: ${NEW_MAX}s   Low: ${NEW_MIN}s\"; left: -114px; top: 185%; }
			.refresh-box .btn-manual:after, .refresh-box select:after { left: 11px; top: 130%; box-shadow: -12px 12px 0 1.5px #0096ff; }
			.refresh-box:has(.btn-manual:hover):before { opacity: 1; visibility: visible; bottom: 190%; }
			.refresh-box:has(.btn-manual:hover):after { opacity: 1; visibility: visible; }
			.refresh-box:has(.btn-manual:hover) .btn-manual:before, .refresh-box:has(select:hover) select:before { opacity: 1; visibility: visible; top: 190%; }
			.refresh-box:has(.btn-manual:hover) .btn-manual:after, .refresh-box:has(select:hover) select:after { opacity: 1; visibility: visible; }"
	else 
		RUNTIME_CSS=""; RUNTIME=""
		if [ -f "$USB_PATH/runtime.db" ]; then
			rm -f "$USB_PATH/runtime.db"
		fi
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

header_box () {
	if [ -n "$REMOTE_VER" ] && [ "$REMOTE_VER" != "$SCRIPT_VERSION" ]; then
		HOVER_TEXT="Current Script v$SCRIPT_VERSION <br> New Version v$REMOTE_VER available"; V_WIDTH="190px"
	else
		HOVER_TEXT="SCRIPT v$SCRIPT_VERSION"; V_WIDTH="100px"
	fi
}

hasta() {
echo -e "\n\n\n${BL}" #=================================================================================
echo -e "                                                                                              "
echo -e "  |   H  H   AAA   SSS  TTTTT  AAA         L      AAA         V   V  IIIII  SSS  TTTTT  AAA   "
echo -e "      H  H  A   A S       T   A   A        L     A   A        V   V    I   S       T   A   A  "
echo -e "  |   HHHH  AAAAA  SSS    T   AAAAA        L     AAAAA        V   V    I    SSS    T   AAAAA  "
echo -e "  |   H  H  A   A     S   T   A   A        L     A   A         V V     I       S   T   A   A  "
echo -e "  |   H  H  A   A  SSS    T   A   A        LLLLL A   A          V    IIIII  SSS    T   A   A  "
echo -e "  |                                                                                           "
echo -e "                                                                                              "
echo -e "${NC}\n\n\n" #=================================================================================
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
    local mac="$1" local current=$2
    local entry=$(grep -F "$mac|" "$HISTORY_CACHE" 2>/dev/null)
    local old="${entry##*|}"
    echo "$mac|$current" >> "$NEW_HISTORY"
    if [ -z "$old" ] || [ "$old" -eq 0 ]; then echo "<span class='trend-box'>•</span>"; return; fi
    if [ "$current" -gt "$old" ]; then echo "<span class='trend-box trend-up sig-exc'>↑</span>"
    elif [ "$current" -lt "$old" ]; then echo "<span class='trend-box trend-down sig-poor'>↓</span>"
    else echo "<span class='trend-box'>•</span>"; fi
}

get_name() {
	local mac="$1"
	local name=""
	
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
	
	# Networkmap / MLO
	if [ -z "$name" ] || [ "$name" = "*" ]; then
        if [ -f "/jffs/nmp_cl_json.js" ]; then
			local entry=$(sed 's/},"/ \n"/g' /jffs/nmp_cl_json.js | grep -i "$mac" | head -n 1)
			local raw_parent=$(echo "$entry" | sed -n 's/.*"mlo_all_mac":"<\([^"]*\)".*/\1/p' | tr '[:lower:]' '[:upper:]')
			local parent_mac=$(echo "$raw_parent" | cut -d'<' -f1)
			if [ -n "$parent_mac" ] && [ "$parent_mac" != "$mac" ]; then
				echo "mlo_swap|$parent_mac"
				return
			fi
			name=$(echo "$entry" | sed -n 's/.*"name":"\([^"]*\)".*/\1/p')
		fi
    fi
	
	# Wireless Backhaul
	if [ -z "$name" ] || [ "$name" = "*" ] || [ "$name" = "$mac" ]; then
		local temp="${mac#*:}"
		local mid_mac="${temp%:*}"
		if [ -n "$mid_mac" ]; then
			local node_match=""
			[ -f "$DEVICE_LIST_CACHE" ] && node_match=$(grep -i "$mid_mac" "$DEVICE_LIST_CACHE")
			if [ -n "$node_match" ]; then
				local node_alias="${node_match%%>*}"
				name="${node_alias:-NODE}-BH"
			fi
		fi
	fi
	
	# Not Found
	if [ -z "$name" ] || [ "$name" = "*" ]; then
		name="$mac"
	fi
	echo "$name"
}

check_new_mac() {
	local mac="$1"
    [ ! -f "$KNOWN_DB" ] && touch "$KNOWN_DB"
    if ! grep -qi "^$mac$" "$KNOWN_CACHE"; then
        echo "$mac" >> "$KNOWN_DB"
        echo "$mac" >> "$KNOWN_CACHE"
        echo "new-device-row"
    fi
}

ip_to_num() {
    local ip="$1" o1 o2 o3 o4
    o1="${ip%%.*}"; local rest="${ip#*.}"
    o2="${rest%%.*}"; rest="${rest#*.}"
    o3="${rest%%.*}"; o4="${rest#*.}"
    case "$o1" in *[!0-9]*|"") printf "000000000000"; return ;; esac
    case "$o2" in *[!0-9]*|"") printf "000000000000"; return ;; esac
    case "$o3" in *[!0-9]*|"") printf "000000000000"; return ;; esac
    case "$o4" in *[!0-9]*|"") printf "000000000000"; return ;; esac
    o1=${o1#${o1%%[!0]*}}; [ -z "$o1" ] && o1=0
    o2=${o2#${o2%%[!0]*}}; [ -z "$o2" ] && o2=0
    o3=${o3#${o3%%[!0]*}}; [ -z "$o3" ] && o3=0
    o4=${o4#${o4%%[!0]*}}; [ -z "$o4" ] && o4=0
    printf "%03d%03d%03d%03d" "$o1" "$o2" "$o3" "$o4"
}

get_band() {
    local iface=$1; local width=$2; local model=$3
    local w_text=""; [ -n "$width" ] && w_text=" ($width)"
    local Label="Unknown"
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
        # Models: RT-BE96U, RT-BE92U, GT-BE19000, GS-BE18000, GS-BE12000, BT6, ZENWIFI-BT8(MEDIATEK), 
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
		# Models:  RT-AX86U, ZENWIFI-BD4(QUALCOMM)
        *)
            case "$iface" in
                wl0*|eth1*|eth4*|eth6*|eth8*|ath0*)  Label="2.4G" ;;
                wl1*|eth2*|eth5*|eth7*|eth10*|ath1*) Label="5G" ;; 
                *)                                   Label="Unknown" ;;
            esac
            ;;
    esac
    
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
    echo "<td data-sort='$sort' style='text-align:center;'><span class='$class'>$Label$w_text</span></td>"
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
    if [ "$check_mins" -ne 0 ] && [ "$T" -lt "$pulse_sec" ]; then
        pulse="pulse-blue"
    fi
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

get_temp_unit() {
    local raw_c=$1
    if [ -z "$raw_c" ] || case "$raw_c" in -[0-9]*|[0-9]*) false ;; *) true ;; esac; then
        echo "--"
        return
    fi
    if [ "$TEMP_UNIT" = "C" ]; then
        echo "${raw_c}°C"
    else
        echo "$raw_c" | awk '{printf "%.0f°F", ($1 * 1.8) + 32}'
    fi
}

get_temp_class() {
    local temp_str=$1
    [ "$temp_str" = "--" ] && echo "stat-cool" && return
    local val=$(echo "$temp_str" | sed 's/[^0-9.]//g')
    if [ "$REPORT_UNIT" = "C" ]; then
        awk -v t="$val" 'BEGIN { if(t>75) print "stat-hot"; else if(t>68) print "stat-warm"; else print "stat-cool"; }'
    else
        awk -v t="$val" 'BEGIN { if(t>167) print "stat-hot"; else if(t>155) print "stat-warm"; else print "stat-cool"; }'
    fi
}
 
get_load_class() {
    local l=$1; [ "$l" = "--" ] && { echo "stat-cool"; return; }
    awk -v l="$l" 'BEGIN { print (l>2.0 ? "stat-hot" : (l>1.0 ? "stat-warm" : "stat-cool")) }'
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

run_report() {
#=================#
#  Node Scan(s)   #
#=================#
START_RUNTIME=$(awk '{print $1}' /proc/uptime)
if [ -n "$SSH_NODES" ]; then
    TARGET_LIST="$SSH_NODES"
else
    TARGET_LIST=$(nvram get asus_device_list | \
        sed 's/</\n/g' | \
        grep '>2$' | \
        awk -F '>' '{print $2"|"$3}' | \
        sort)
fi
NODE_DATA="$TARGET_LIST"
NODE_COUNT_TOTAL=$(echo "$NODE_DATA" | grep -v "^$" | wc -l)
NODE_COLORS="#64d2ff #30d158 #ffd60a #bf40bf #ff9500 #ff453a"
PIPE=" <span style='color:white;'>|</span> "
N_NAMES=""; N_TEMPS=""; N_LOADS=""; N_BOOTS=""; N_UPTIMES=""
N_SPLIT_COUNTS=""; COLOR_IDX=0; ACTIVE_NODES=0
TELEMETRY_DIR="/tmp/wr_telemetry"
rm -rf "$TELEMETRY_DIR" 2>/dev/null
mkdir -p "$TELEMETRY_DIR"
for line in $TARGET_LIST; do
	IP=$(echo "$line" | cut -d'|' -f2)
	ALIAS=$(echo "$line" | cut -d'|' -f1)
	[ -z "$IP" ] && continue
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
						HB=\$(wl -i \"\$iface\" band | awk '{print \$1}')
						for mac in \$(wl -i \"\$iface\" assoclist 2>/dev/null | awk '{print \$2}'); do
							RAW=\$(wl -i \"\$iface\" sta_info \"\$mac\" 2>/dev/null)
							RSSI=\$(echo \"\$RAW\" | awk -F': ' '/smoothed rssi:/ {print \$2; exit}')
							[ -z \"\$RSSI\" ] && RSSI=\$(wl -i \"\$iface\" rssi \"\$mac\" 2>/dev/null | awk '{print \$1}')
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
							RXD=\$(echo \"\$RX\" | awk '{if (\$1==0) print \"1\"; else printf \"%.0f\", \$1}')
							TXD=\$(echo \"\$TX\" | awk -v m=\"\$MX\" '{if (\$1==0) print \"1\"; else printf \"%.0f\", \$1}')
							[ \"\$RXD\" = \"1\" ] && [ \"\$TXD\" = \"1\" ] && LRD=\"1 / 72\" || LRD=\"\${RXD} / \${TXD}\"
							V1=\$(echo \"\$RXD\" | tr -dc '0-9'); V2=\$(echo \"\$TXD\" | tr -dc '0-9')
							[ -n \"\$V1\" ] && [ -n \"\$V2\" ] && [ \"\$V1\" -gt \"\$V2\" ] 2>/dev/null && { T=\$RXD; RXD=\$TXD; TXD=\$T; LRD=\"\$RXD / \$TXD\"; }
							echo \"DATA|\$mac|\$RSSI|\$iface|\$(echo \"\$RAW\" | grep \"in network\" | awk '{print \$3}')|\$SN|\$TX|\$LRD|\$W|\$HB\"
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
						HB=\"2.4GHz\"; W=\"20\"
						if echo \"\$IFACE_INFO\" | grep -q \"6GHz\" || echo \"\$IFACE_INFO\" | grep -q \"width:\"; then
							echo \"\$IFACE_INFO\" | grep -q \"320 MHz\" && W=\"320\" && HB=\"6GHz\"
							echo \"\$IFACE_INFO\" | grep -q \"160 MHz\" && W=\"160\" && HB=\"6GHz\"
							echo \"\$IFACE_INFO\" | grep -q \"80 MHz\" && W=\"80\" && HB=\"6GHz\"
							if [ \"\$HB\" = \"2.4GHz\" ] && [ -n \"\$LIVE_CHAN\" ] && [ \"\$(echo \"\$LIVE_CHAN\" | tr -d ',')\" -gt 14 ]; then
								HB=\"5GHz\"
							fi
						elif [ -n \"\$LIVE_CHAN\" ] && [ \"\$(echo \"\$LIVE_CHAN\" | tr -d ',')\" -gt 14 ]; then
							HB=\"5GHz\"; W=\"80\"
							echo \"\$IFACE_INFO\" | grep -q \"160\" && W=\"160\"
						fi
						RAW_STAS=\$(iw dev \"\$iface\" station dump 2>/dev/null)
						if [ -n \"\$RAW_STAS\" ]; then
							echo \"\$RAW_STAS\" | awk -v def_w=\"\$DEFAULT_W\" '
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
								echo \"DATA|\$c_mac|\$c_rssi|\$iface|\$c_uptime|\$DISPLAY_SSID|\$TX_INT|\$LRD|\$c_width|\$HB\"
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
							HB=\"2.4GHz\"; echo \"\$iface\" | grep -q \"ath1\" && HB=\"5GHz\"
							W=\"20\"; echo \"\$iface\" | grep -q \"ath1\" && W=\"80\"
							LRD=\"\${RX} / \${TX}\"
							echo \"DATA|\$mac|\$RSSI|\$iface|UP_QCA|\$SN|\$TX|\$LRD|\$W|\$HB\"
							NODE_COUNT=\$((NODE_COUNT + 1))
						done
						;;
				esac
			done
			echo \"TEMP|\$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | cut -c1-2)\"
			echo \"LOAD|\$(cat /proc/loadavg | awk '{print \$1}')\"
			echo \"UPTIME_VAL|\$F_UP\"; echo \"UPTIME_RAW|\$UP_SEC\"; echo \"COUNT|\$NODE_COUNT\"
		" 2>/dev/null > "$TELEMETRY_DIR/${CLEAN_IP}.out"
	) &
done

#=============================#
#  Main Scan/Device Assembly  #
#=============================#
update_time; get_usb
YAZ_CLIENTS="/jffs/addons/YazDHCP.d/DHCP_clients"
awk '$0 ~ /0x2/ {print toupper($4)"|"$1}' /proc/net/arp > "$ARP_CACHE"
[ -f "$KNOWN_DB" ] && cp "$KNOWN_DB" "$KNOWN_CACHE" 2>/dev/null || > "$KNOWN_CACHE"
[ -f "$HISTORY_DB" ] && cp "$HISTORY_DB" "$HISTORY_CACHE" 2>/dev/null || > "$HISTORY_CACHE"
awk '{print toupper($2)"|"$3}' /var/lib/misc/dnsmasq*.leases > "$LEASES_CACHE" 2>/dev/null || > "$LEASES_CACHE"
[ -f "$YAZ_CLIENTS" ] && awk -F',' 'NR>1 {print toupper($1) "|" $2 "|" $3}' "$YAZ_CLIENTS" > "$YAZ_CACHE" || > "$YAZ_CACHE"
nvram get custom_clientlist | sed 's/</\n/g' | awk -F'>' '{if($2!="") print toupper($2)"|"$1}' > "$CUSTOM_CLIENTS_CACHE" 2>/dev/null || > "$CUSTOM_CLIENTS_CACHE"
nvram get asus_device_list | sed 's/</\n/g' > "$DEVICE_LIST_CACHE" 2>/dev/null || > "$DEVICE_LIST_CACHE"
M_T=$(($(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0) / 1000))
M_TEMP=$(get_temp_unit "$M_T")
M_LOAD=$(cat /proc/loadavg | awk '{print $1}')
MC_TEMP=$(get_temp_class "$M_TEMP")
MC_LOAD=$(get_load_class "$M_LOAD")
M_UPTIME=$(awk -v s=$(cat /proc/uptime | cut -d. -f1) 'BEGIN {d=int(s/86400); h=int((s%86400)/3600); m=int((s%3600)/60); if(d>0) printf "%dd %dh %dm", d, h, m; else if(h>0) printf "%dh %dm", h, m; else printf "%dm", m}')
M_BOOT=$(date -d @$(( $(date +%s) - $(cut -d. -f1 /proc/uptime) )) "$D_FMT")
MAIN_PFX=$(nvram get lan_hwaddr | cut -c 3-14 | tr '[:lower:]' '[:upper:]')
NODE_PFX=$(nvram get cfg_relist | sed 's/[<>]/ /g' | tr ' ' '\n' | grep ":" | cut -c 3-14 | sort -u | tr '[:lower:]' '[:upper:]')
ROUTER_IP=$(nvram get lan_ipaddr)
DEVICE_LIST=$(nvram get cfg_device_list)
M_ALIAS=$(echo "$DEVICE_LIST" | sed 's/</\n/g' | grep ">$ROUTER_IP>" | awk -F'>' '{print $1}')
M_NAME="${MAIN_NICK:-${M_ALIAS:-"Main Router"}}"
[ ${#M_NAME} -gt 25 ] && M_NAME="${M_NAME:0:25}"
MAIN_LABEL="<span class='router-branding'>$M_NAME</span>"
> "$SEEN_MACS"; > "$NEW_HISTORY"
NL=$'\n'; MAIN_ROWS=""; NODE_ROWS=""; ALL_ROWS=""
T_EXC=0; T_GOOD=0; T_FAIR=0; T_POOR=0; MD_TOTAL=0; ND_TOTAL=0; BH_COUNTER=250
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
		"$WL0_PHYS"*) data_iface="wl0" ;;
		"$WL1_PHYS"*) data_iface="wl1" ;;
		"$WL2_PHYS"*) data_iface="wl2" ;;
		"$WL3_PHYS"*) data_iface="wl3" ;;
		*) data_iface="$iface" ;;
	esac
    ASSOC_OUT=$(wl -i "$iface" assoclist 2>/dev/null)
    WL_ALIVE=0
    [ -n "$ASSOC_OUT" ] && WL_ALIVE=1
    SNAME=$(nvram get "${iface}_ssid")
	if [ -z "$SNAME" ] || echo "$SNAME" | grep -qE '^[0-9A-Fa-f]{16,}$'; then
		idx=${iface#*.}
		[ "$idx" != "$iface" ] && SNAME=$(nvram get "gnp_name_$idx")
	fi
	[ -z "$SNAME" ] && [ -n "$data_iface" ] && SNAME=$(nvram get "${data_iface}_ssid")
	[ -z "$SNAME" ] && SNAME=$(nvram get "${iface%.*}_ssid")
	[ -z "$SNAME" ] && [ -n "$data_iface" ] && SNAME=$(nvram get "${data_iface%.*}_ssid")
	[ -z "$SNAME" ] && SNAME="Wireless"
	MAC_LIST=$(echo "$ASSOC_OUT" | awk '{print $2}')
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
		m_prefix=$(echo "$m_live" | cut -c 3-14 | tr '[:lower:]' '[:upper:]')
		if [ "$BACKHAUL" != "yes" ]; then
			if [ "$m_prefix" = "$MAIN_PFX" ] || echo "$NODE_PFX" | grep -q "$m_prefix"; then
				continue
			fi
		fi
		if grep -qi "$m_live" "$SEEN_MACS"; then
			continue
		fi
		link_ip=$(grep -ih "^$mac|" "$ARP_CACHE" "$LEASES_CACHE" | cut -d'|' -f2 | head -n 1)
        [ -z "$link_ip" ] && link_ip=$(arp -an | grep -i "$mac" | awk '{print $2}' | tr -d '()' | head -n 1)
		lookup=$(get_name "$mac")
        if echo "$lookup" | grep -q "mlo_swap|"; then
            m_up=$(echo "$lookup" | cut -d'|' -f2)
            name=$(get_name "$m_up")
        else
            m_up="$mac"
            name="$lookup"
        fi
        if [ -n "$link_ip" ] && [ "$link_ip" != "---" ]; then
            ip="$link_ip"
        else
            ip=$(grep -ih "^$m_up|" "$ARP_CACHE" "$YAZ_CACHE" "$LEASES_CACHE" | cut -d'|' -f2 | head -n 1)
        fi
        case "$name" in *-BH*) ip="" ;; esac
		if [ -z "$ip" ]; then
            lan_base=$(nvram get lan_ipaddr)
            ip="${lan_base%.*}.$BH_COUNTER"
            BH_COUNTER=$((BH_COUNTER + 1)) 
        fi
		ip=$(echo "$ip" | tr ' \t' '\n' | grep -v '^$' | head -n 1)
		ip=$(printf "%s.%03d" "${ip%.*}" "${ip##*.}")
		{ [ -z "$name" ] || [ "$name" = "*" ]; } && name="$m_up"
		raw_info=$(wl -i "$iface" sta_info "$mac" 2>/dev/null)
		[ -z "$raw_info" ] && raw_info=$(wl -i "$data_iface" sta_info "$mac" 2>/dev/null)
		rssi=$(echo "$raw_info" | awk -F': ' '/smoothed rssi:/ {print $2; exit}')
		[ -z "$rssi" ] && rssi=$(wl -i "$iface" rssi "$mac" 2>/dev/null | awk '{print $1}')
		if [ -z "$rssi" ] || case "$rssi" in -[0-9]*) false ;; *) true ;; esac; then
			rssi=$(wl -i "$data_iface" rssi "$mac" 2>/dev/null | awk '{print $1}')
		fi
		if case "$rssi" in -[0-9]*) false ;; *) true ;; esac; then
			[ "$WL_ALIVE" -eq 1 ] && continue
			rssi="-99"
		fi
		[ "$rssi" -ge -20 ] || [ "$rssi" -le -100 ] || grep -qi "$m_up" "$SEEN_MACS" && continue
		case "$m_up" in ??:??:??:??:??:??) echo "$m_up" >> "$SEEN_MACS" ;; esac
		rx_raw=$(echo "$raw_info" | grep "rate of last rx pkt" | awk '{print $6/1000}')
		tx_raw=$(echo "$raw_info" | grep "rate of last tx pkt" | awk -F': ' '{print $2}' | awk '{print $1/1000}')
		max_raw=$(echo "$raw_info" | grep "Max Rate =" | awk '{print $4}')
		mhz_width=$(get_mhz_width "$raw_info")
		[ -z "$rx_raw" ] || [ "$rx_raw" = "0" ] && rx_disp="?" || rx_disp="${rx_raw%.*}"
		[ -z "$tx_raw" ] || [ "$tx_raw" = "0" ] && tx_disp="${max_raw:-?}" || tx_disp="${tx_raw%.*}"
		[ "$rx_disp" = "?" ] && rx_disp="1"
		[ "$tx_disp" = "?" ] && tx_disp="1"
		[ "$rx_disp" = "1" ] && [ "$tx_disp" = "1" ] && l_rate_disp="1 / 72" || l_rate_disp="${rx_disp} / ${tx_disp}"
		V1=$(echo "$rx_disp" | tr -dc '0-9')
		V2=$(echo "$tx_disp" | tr -dc '0-9')
		[ -n "$V1" ] && [ -n "$V2" ] && [ "$V1" -gt "$V2" ] 2>/dev/null && { T=$rx_disp; rx_disp=$tx_disp; tx_disp=$T; l_rate_disp="$rx_disp / $tx_disp"; }
		[ "$rx_disp" = "---" ] && [ "$tx_disp" = "---" ] && l_rate_disp="---"
		l_rate_val=${tx_disp:-0}
		is_new=$(check_new_mac "$m_up")
		trend=$(get_trend "$m_up" "$rssi")
		bars=$(get_bars "$rssi")
		rssi_style=$(get_rssi_style "$rssi")
		uptime=$(echo "$raw_info" | grep 'in network' | awk '{print $3}')
		[ ${#name} -gt 20 ] && name="${name:0:20}"
		display_ssid="$SNAME"
		[ ${#display_ssid} -gt 15 ] && display_ssid="${display_ssid:0:15}"
		ip_s=$(ip_to_num "$ip"); ip="${ip%% *}"; ip="${ip%%<*}"
		band_td=$(get_band "$iface" "$mhz_width" "$M_ALIAS")
		if [ "$rssi" -ge -50 ]; then T_EXC=$((T_EXC+1))
		elif [ "$rssi" -ge -60 ]; then T_GOOD=$((T_GOOD+1))
		elif [ "$rssi" -ge -70 ]; then T_FAIR=$((T_FAIR+1))
		else T_POOR=$((T_POOR+1)); fi
		ROW_STR="<tr class='$is_new'>
			<td style='text-align:left;'>$name</td>
			<td class='toggle-cell'>
				<span class='m-val' data-sort='$m_up'>$m_up</span>
				<span class='i-val' data-sort='$ip_s'>$ip</span>
			</td>
			<td data-sort='$rssi'>
				$bars <span style='$rssi_style'>$rssi</span> $trend
			</td>
			<td data-sort='$l_rate_val' style='$rssi_style; text-align:center;'>$l_rate_disp</td>
			<td class='toggle-ssid'>
				<span class='s-val' data-sort='$SNAME'>$display_ssid</span>
				<span class='if-val' data-sort='$iface'>$iface</span>
			</td>
			$band_td
			<td>$(fmt_uptime "$uptime")</td>
		</tr>"
		MAIN_ROWS="${MAIN_ROWS}${ROW_STR}${NL}"
		ALL_ROWS="${ALL_ROWS}${ROW_STR}${NL}"
		MD_TOTAL=$((MD_TOTAL + 1))
	done
done
CONSOLIDATED_T="<span class='${MC_TEMP}'>${M_TEMP}</span>"
CONSOLIDATED_L="<span class='${MC_LOAD}'>${M_LOAD}</span>"
CONSOLIDATED_U="<span class='val-blue'>${M_UPTIME}</span>"
CONSOLIDATED_B="<span class='val-blue'>${M_BOOT}</span>"
wait

#========================#
#  Node Device Assembly  #
#========================#
for line in $TARGET_LIST; do
	NODE_OUT=""
	IP=$(echo "$line" | cut -d'|' -f2)
	ALIAS=$(echo "$line" | cut -d'|' -f1)
	[ -z "$IP" ] && continue
	CLEAN_IP=$(echo "$IP" | tr '.' '_')
	eval CUSTOM_NICK=\$NODE_NICK_$CLEAN_IP
	NODE_DISPLAY_NAME="${CUSTOM_NICK:-${ALIAS:-$IP}}"
	[ ${#NODE_DISPLAY_NAME} -gt 25 ] && NODE_DISPLAY_NAME="${NODE_DISPLAY_NAME:0:25}"
	[ -f "$TELEMETRY_DIR/${CLEAN_IP}.out" ] && NODE_OUT=$(cat "$TELEMETRY_DIR/${CLEAN_IP}.out")
	if [ -n "$NODE_OUT" ]; then
        ACTIVE_NODES=$((ACTIVE_NODES + 1))
		COLOR_IDX=$((COLOR_IDX + 1))
        CUR_COLOR=$(echo $NODE_COLORS | cut -d' ' -f$((COLOR_IDX)))
		[ -z "$CUR_COLOR" ] && CUR_COLOR="#ffffff"
        STAR_HTML="<span style='color:$CUR_COLOR;'><sup>$ACTIVE_NODES</sup></span>"
        NODE_BRAND="<span class='router-branding' style='color:$CUR_COLOR;'>${NODE_DISPLAY_NAME}<sup>$ACTIVE_NODES</sup></span>"
        [ -z "$N_NAMES" ] && N_NAMES="$NODE_BRAND" || N_NAMES="$N_NAMES$PIPE$NODE_BRAND"
		N_TEMP_RAW=$(echo "$NODE_OUT" | grep "TEMP|" | cut -d'|' -f2)
        [ ${#N_TEMP_RAW} -gt 3 ] && N_TEMP_RAW=$((N_TEMP_RAW / 1000))
        N_TEMP=$(get_temp_unit "$N_TEMP_RAW")
		N_LOAD=$(echo "$NODE_OUT" | grep "LOAD|" | cut -d'|' -f2)
		NC_TEMP=$(get_temp_class "$N_TEMP")
		NC_LOAD=$(get_load_class "$N_LOAD")
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
        NODE_DISPLAY_COUNT=0
		UPTIME_QCA="/jffs/wlcnt.json"
		while read -r dline; do
			[ -z "$dline" ] && continue
			IFS='|' read -r _ m_live r_raw i_raw u_raw s_name l_rate_val l_rate_disp_n w_raw hb_raw _ <<ROW
$dline
ROW
			m_live=$(echo "$m_live" | tr '[:lower:]' '[:upper:]')
			m_prefix=$(echo "$m_live" | cut -c 3-14 | tr '[:lower:]' '[:upper:]')
			if [ "$BACKHAUL" != "yes" ]; then
				if [ "$m_prefix" = "$MAIN_PFX" ] || echo "$NODE_PFX" | grep -q "$m_prefix"; then
					continue
				fi
			fi
			if grep -qi "$m_live" "$SEEN_MACS"; then
				continue
			fi
			n_ip=$(grep -ih "^$m_live|" "$ARP_CACHE" "$LEASES_CACHE" | cut -d'|' -f2 | head -n 1)
			[ -z "$n_ip" ] && n_ip=$(arp -an | grep -i "$m_live" | awk '{print $2}' | tr -d '()' | head -n 1)
			lookup=$(get_name "$m_live")
			if echo "$lookup" | grep -q "mlo_swap|"; then
				m_target=$(echo "$lookup" | cut -d'|' -f2)
				n_name=$(get_name "$m_target")
			else
				m_target="$m_live"
				n_name="$lookup"
			fi
			if [ -z "$n_ip" ] || [ "$n_ip" = "---" ]; then
				yaz_entry=$(grep -i "^$m_target|" "$YAZ_CACHE" | head -n 1)
				if [ -n "$yaz_entry" ]; then
					m_up=$(echo "$yaz_entry" | cut -d'|' -f1 | tr '[:lower:]' '[:upper:]')
					n_ip=$(echo "$yaz_entry" | cut -d'|' -f2)
					[ "$n_name" = "$m_target" ] && n_name=$(echo "$yaz_entry" | cut -d'|' -f3)
				else
					m_up="$m_target"
					n_ip=$(grep -ih "^$m_up|" "$ARP_CACHE" "$YAZ_CACHE" "$LEASES_CACHE" | cut -d'|' -f2 | head -n 1)
				fi
			else
				m_up="$m_target"
			fi
			case "$n_name" in *-BH*) n_ip="" ;; esac
			if [ -z "$n_ip" ] || [ "$n_ip" = "---" ]; then
				lan_base=$(nvram get lan_ipaddr)
				n_ip="${lan_base%.*}.$BH_COUNTER"
				BH_COUNTER=$((BH_COUNTER + 1))
			fi
			n_ip=$(echo "$n_ip" | tr ' \t' '\n' | grep -v '^$' | head -n 1)
			n_ip=$(printf "%s.%03d" "${n_ip%.*}" "${n_ip##*.}")
			{ [ -z "$n_name" ] || [ "$n_name" = "*" ]; } && n_name="$m_up"
			case "$m_live" in ??:??:??:??:??:??) echo "$m_live" >> "$SEEN_MACS" ;; esac
			ND_TOTAL=$((ND_TOTAL + 1))
			NODE_DISPLAY_COUNT=$((NODE_DISPLAY_COUNT + 1))
			if [ "$r_raw" -ge -50 ]; then T_EXC=$((T_EXC+1))
            elif [ "$r_raw" -ge -60 ]; then T_GOOD=$((T_GOOD+1))
            elif [ "$r_raw" -ge -70 ]; then T_FAIR=$((T_FAIR+1))
            else T_POOR=$((T_POOR+1)); fi
			if [ "$u_raw" = "UP_QCA" ] && echo "$i_raw" | grep -q "ath"; then
				NOW=$(date +%s)
				CLEAN_MAC=$(echo "$dline" | cut -d'|' -f2 | tr -d '<> ' | awk '{print toupper($0)}')
				START_TS=$(jq -r ".\"$CLEAN_MAC\".start // 0" "$UPTIME_QCA")
				if [ "$START_TS" -gt 0 ]; then
					u_raw=$((NOW - START_TS))
					[ "$u_raw" -lt 0 ] && u_raw=$((START_TS - NOW))
				else
					u_raw="0"
				fi
			fi
			display_s_name="$s_name"
            [ ${#display_s_name} -gt 15 ] && display_s_name="${display_s_name:0:15}"
            is_new=$(check_new_mac "$m_up")
			trend=$(get_trend "$m_up" "$r_raw")
			bars_n=$(get_bars "$r_raw")
			rssi_style_n=$(get_rssi_style "$r_raw")
            [ ${#n_name} -gt 25 ] && n_name="${n_name:0:25}"
			ip_ns=$(ip_to_num "$n_ip")
			band_td_n=$(get_band "$i_raw" "$w_raw" "$ALIAS")
            N_ROW="<tr class='$is_new'>
				<td style='text-align:left;'>$n_name$STAR_HTML</td>
				<td class='toggle-cell'>
					<span class='m-val' data-sort='$m_up'>$m_up</span>
					<span class='i-val' data-sort='$ip_ns'>$n_ip</span>
				</td>
				<td data-sort='$r_raw'>
					$bars_n <span style='$rssi_style_n'>$r_raw</span> $trend
				</td>
				<td data-sort='$l_rate_val' style='$rssi_style_n; text-align:center;'>$l_rate_disp_n</td>
				<td class='toggle-ssid'>
					<span class='s-val' data-sort='$s_name'>$display_s_name</span>
					<span class='if-val' data-sort='$i_raw'>$i_raw</span>
				</td>
				$band_td_n
				<td>$(fmt_uptime "$u_raw")</td>
			</tr>"
            NODE_ROWS="${NODE_ROWS}${N_ROW}${NL}"
            ALL_ROWS="${ALL_ROWS}${N_ROW}${NL}"
        done <<EOF
$(echo "$NODE_OUT" | grep "DATA|")
EOF
N_SPLIT_COUNTS="${N_SPLIT_COUNTS}${N_SPLIT_COUNTS:+$PIPE}<span style='color:$CUR_COLOR;'>$NODE_DISPLAY_COUNT</span>"
    fi
done
GRAND_TOTAL=$((MD_TOTAL + ND_TOTAL))
BRAND_LINE_ALL="<span class='router-branding'>$M_NAME</span> | $N_NAMES"
[ "$ACTIVE_NODES" -gt 0 ] && R_TITLE="Wireless Report AiMesh" || R_TITLE="Wireless Report"
if [ "$ACTIVE_NODES" -ge 1 ]; then
    FULL_DEVICE_BREAKDOWN="Devices: <span class='val-blue'>$GRAND_TOTAL</span> <span class='dash-sep'>—›</span> <span class='val-blue'>$MD_TOTAL</span> | $N_SPLIT_COUNTS"
else
    FULL_DEVICE_BREAKDOWN="Devices: <span class='val-blue'>$MD_TOTAL</span>"
fi
RSSI_UNIT="<span style='font-size:14px; font-weight:bold; margin-left:2px;'>ᵈᴮᵐ</span>"
MBPS_UNIT="<span style='font-size:14px; font-weight:bold; margin-left:2px;'>ᵐᵇᵖˢ</span>"
MHZ_UNIT="<span style='font-size:14px; font-weight:bold; margin-left:2px;'>ᵐʰᶻ</span>"
mv "$NEW_HISTORY" "$HISTORY_DB"
do_runtime

#=================#
#  Generate HTML  #
#=================#
header_box; JS_DIFF="${DIFF:-5.00}"
/usr/bin/printf '\xEF\xBB\xBF' > "$WEB_PAGE"
cat <<HTML >> "$WEB_PAGE"
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
	.quality-box#:hover { border-color: #0096ff; box-shadow: 0 0 10px rgba(0,150,255,0.4); cursor: pointer; }
	.refresh-box { display: inline-block; height: 28px; line-height: 26px; text-align: center; padding: 0 12px; border-radius: 4px; background: rgba(0,0,0,0.4); border: 1px solid #475a68; font-weight: bold; box-sizing: border-box; transition: all 0.2s ease; }
	.refresh-box:hover { border-color: #0096ff; box-shadow: 0 0 10px rgba(0,150,255,0.4); cursor: pointer; }
	${RUNTIME_CSS}
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
	.val-blue { color: #0096ff; !important; font-weight: bold; }
	.sig-exc { color: #30d158; } .sig-good { color: #64d2ff; } 
	.sig-fair { color: #ffd60a; } .sig-poor { color: #ff453a; }
	.stat-warm { color: #ffa500 !important; font-weight: bold; }
	.stat-hot { color: #ff453a !important; font-weight: bold; }
	.stat-cool { color: #0096ff; !important; font-weight: bold; }
	.bar-box { font-family: monospace; font-weight: 900; width: 40px; display: inline-block; text-align: right; margin-right: 5px; }
	.section-header { background: linear-gradient(to bottom, #171b1f, #354961); color: #ffffff; font-weight: bold; padding: 12px; text-align: center; border-bottom: 1px solid #475a68; }
	.router-branding { color: #0096ff; font-size: 1.4em; font-weight: bold; text-transform: uppercase; display: inline-block; margin-bottom: 4px; }
	.header-stats-row { display: block; font-size: 14px; color: #f2f2f7; margin-top: 5px; font-weight: bold; white-space: nowrap; width: 100%; overflow: visible !important; }
	.sep-line { border: 0; border-top: 1px solid #475a68; margin: 8px -12px; width: calc(100% + 24px); display: block; }
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
    });
    var scanTime = parseFloat("$JS_DIFF") || 5.0;
    var delay = Math.max(2500, Math.ceil((scanTime * 1000) + 1500));
    setTimeout(function() { window.location.reload(); }, delay); 
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
      <div class="header-wrap"><div class="header-tip" style="--v-width: $V_WIDTH;"><h1 id="v-header" class="report-header-main" style="margin:0; display:inline-block;">$R_TITLE</h1><span class="header-box">$HOVER_TEXT</span></div></div>
        <div class="total-count">Total Wireless Devices: <span class="count-highlight">$GRAND_TOTAL</span></div>
		<div class="top-controls">
			<div class="refresh-box" style="padding:0 5px; display:inline-flex; align-items:center;">
			<button class="btn-manual btn-black-blue" style="border:none; height:100%; line-height:inherit; padding:0 8px;" 
			onclick="triggerRefresh()">Refresh <span style="color: white;">${RUNTIME}</span></button>
				<span style="font-size:12px; margin-left:5px; color: #0096ff;">Auto: </span>
				<select id="refreshRate" onchange="localStorage.setItem('wifiReportAutoRefresh', this.value); initAutoRefresh(parseInt(this.value));" style="background:#000; font-weight:bold; color:white; border:0px solid #444; margin-left:5px; font-size:12px; height:20px;">
					<option value="0">Off</option><option value="30">30s</option><option value="60">1m</option><option value="120">2m</option><option value="300">5m</option><option value="600">10m</option><option value="1200">20m</option><option value="1800">30m</option>
				</select><span style="color: #0096ff;" id="countdown"></span>
			</div>
HTML
if [ "$ACTIVE_NODES" -gt 0 ]; then
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
                  <hr class="sep-line">
                  <div class="header-stats-row">Temp: <span class="$MC_TEMP">$M_TEMP</span> • Load: <span class="$MC_LOAD">$M_LOAD</span> • Devices: <span class="val-blue">$MD_TOTAL</span></div>
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
                  <tfoot><tr><td colspan="7" style="text-align: center !important;">Uptime: <span class="f-res">$M_UPTIME</span> • Reboot: <span class="f-res">$M_BOOT</span></td></tr></tfoot>
                </table>
              </div>
			  <div class="quality-bar">
				  <div class="quality-box sig-exc">Excellent: <span style="background:#30d158; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_EXC</span></div>
				  <div class="quality-box sig-good">Good: <span style="background:#0096ff; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_GOOD</span></div>
				  <div class="quality-box sig-fair" style="color:#ffd60a;">Fair: <span style="background:#ffd60a; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_FAIR</span></div>
				  <div class="quality-box sig-poor" style="color:#ff453a;">Poor: <span style="background:#ff453a; color:#000; padding:1px 5px; border-radius:3px; margin-left:4px;">$T_POOR</span></div>
			  </div>
HTML
if [ "$ACTIVE_NODES" -gt 0 ]; then
cat <<NODEHTML >> "$WEB_PAGE"
			  <div id="nodeCol" class="report-column">
                <div class="section-header">
                  $N_NAMES <span class="router-branding"></span><br>
                  <span style="font-size:11px; font-weight:bold;">Updated: $CUR_TIME</span>
                  <hr class="sep-line">
                  <div class="header-stats-row">Temp: <span class='${NC_TEMP}'>${N_TEMPS:-0}</span> • Load: <span class='${NC_LOAD}'>${N_LOADS:-0}</span> • Devices: <span class="val-blue">$ND_TOTAL</span> <span class="dash-sep">—›</span> $N_SPLIT_COUNTS</div>
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
                  <tfoot><tr><td colspan="7" style="text-align: center !important;">$( [ -n "$N_UPTIMES" ] && echo "Uptime: $N_UPTIMES • Reboot: $N_BOOTS" || echo "Offline" )</td></tr></tfoot>
                </table>
              </div>
NODEHTML
fi
cat <<HTML >> "$WEB_PAGE"
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
              <tbody>$ALL_ROWS</tbody>
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
rm -rf "$SEEN_MACS" "$HISTORY_CACHE" "$KNOWN_CACHE" "$ARP_CACHE" "$LEASES_CACHE" "$YAZ_CACHE" "$CUSTOM_CLIENTS_CACHE" "$DEVICE_LIST_CACHE" "$TELEMETRY_DIR" 2>/dev/null
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
