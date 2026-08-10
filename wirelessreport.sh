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

SCRIPT_VERSION="2.2.12"
INSTALL_DIR="/jffs/addons/wireless_report"
REPORT_SCRIPT="$INSTALL_DIR/wirelessreport.sh"
SYSTEM_MENU="/www/require/modules/menuTree.js"
CONFIG="$INSTALL_DIR/webui.conf"
WEB_PAGE="/tmp/wireless.asp"
TEMP_MENU="/tmp/menuTree.js"
SS_FILE="/jffs/scripts/services-start"
SE_FILE="/jffs/scripts/service-event"
if [ -f "$CONFIG" ]; then . "$CONFIG"; fi
export PATH="/usr/sbin:/usr/bin:/sbin:/bin:$PATH"; unset LD_LIBRARY_PATH

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
		echo -e "  $N3  Edit Date/Time Format ($DF) ($CT)                "
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
						3) set_date_time; run_report ;;
						4) set_nicknames; run_report ;;
						5) set_colors; run_report ;;
						6) set_options; run_report ;;
					esac
					break ;;
				e|E) clear; hasta; exit 0 ;;
				*) freeze2; continue ;;
			esac
		done
	done
}

version_compare() {
    # Compare dotted numeric versions component-by-component.
    # Prints: -1 when $1 < $2, 0 when equal, 1 when $1 > $2.
    # Missing components are treated as zero (2.3 == 2.3.0).
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

check_version() {
    local mode="$1" version_cmp=""; DEV=""; freeze() { return 0; }
    if [ ! -f "$REPORT_SCRIPT" ]; then
        STATE="NOT_INSTALLED"; freeze() { freeze2; return 1; }
    elif [ -z "$REMOTE_VERSION" ]; then
        STATE="OFFLINE"
    else
        version_cmp=$(version_compare "$SCRIPT_VERSION" "$REMOTE_VERSION")
        case "$version_cmp" in -1|0|1) ;; *) version_cmp=0 ;; esac
        if [ "$version_cmp" -gt 0 ]; then
            STATE="UP_TO_DATE"; DEV="-DEV"
        elif [ "$version_cmp" -lt 0 ]; then
            STATE="OUTDATED"
        elif [ -n "$REMOTE_HASH" ] && [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
            STATE="HASH_DIFF"
        else
            STATE="UP_TO_DATE"
        fi
    fi
    case "$mode" in
        header_box)
            case "$STATE" in
                OUTDATED)      HOVER_TEXT="Current v$SCRIPT_VERSION <br> New Version v$REMOTE_VERSION available"
                               VERSION_HASH=" [$REMOTE_VERSION]"; HEADER_TITLE="header-title2" ;;
                HASH_DIFF)     HOVER_TEXT="Current v$SCRIPT_VERSION <br> Hash Update available"
                               VERSION_HASH=" [Hash]"; HEADER_TITLE="header-title2" ;;
                UP_TO_DATE|*)  HOVER_TEXT="Current v$SCRIPT_VERSION$DEV"
                               VERSION_HASH="$DEV"; HEADER_TITLE="header-title" ;;
            esac ;;
        do_install)
            case "$STATE" in
                OUTDATED)      echo -e "\n${GR}[i] A new version (${NC}v$REMOTE_VERSION${GR}) is available!${NC}\n"
                               UP="update version?" ;;
                HASH_DIFF)     echo -e "\n${GR}[i] There is a Hash Update for (${NC}v$SCRIPT_VERSION${GR}).${NC}\n"
                               UP="update Hash?" ;;
                UP_TO_DATE|*)  echo -e "\n${GR}[i] You are already on the latest version (${NC}v$SCRIPT_VERSION$DEV${GR}).${NC}\n"
                               UP="reinstall/overwrite anyway?";;
            esac ;;
        *)
            case "$STATE" in
                OFFLINE)       echo -e "$STATUS ${RD}[Offline]${NC} Could not reach GitHub" ;;
                NOT_INSTALLED) echo -e "$STATUS ${RD}[Not Installed]${NC} Latest Available: ${GR}v$REMOTE_VERSION${NC}"; N1="${BL}(1)" ;;
                OUTDATED)      echo -e "$STATUS [v$REMOTE_VERSION Available] $CURRENT" ;;
                HASH_DIFF)     echo -e "$STATUS [Hash Update Available] $CURRENT" ;;
                UP_TO_DATE|*)  echo -e "$STATUS [Up to date] $CURRENT$DEV" ;;
            esac ;;
    esac
}

menu_vars() {
    if [ -f "$CONFIG" ]; then . "$CONFIG"; fi
    freeze2() { printf "\033[2A\033[J"; }; freeze3() { printf "\033[3A\033[J"; }
	UL='\033[4m'; WH='\e[1;37m'; YL='\033[0;33m'; NC='\033[0m'
    BL='\033[38;5;39m'; GR='\033[0;32m'; RD='\033[0;31m'
    JB1366="${GR}${UL}https://github.com/JB1366/Wireless_Report${NC}"
	N0="${BL}(0)${NC}"; N1="${BL}(1)${NC}"; N2="${BL}(2)${NC}"; N3="${BL}(3)${NC}"; N4="${BL}(4)${NC}"
	N5="${BL}(5)${NC}"; N6="${BL}(6)${NC}"; N7="${BL}(7)${NC}"; N8="${BL}(8)${NC}"; echo -e "${BL}"
	NE="${BL}(e)${NC}"; NQ="${BL}(c)${NC}"; ON="${GR}ON${NC}"; OFF="${RD}OFF${NC}"
	STATUS=" ${BL}STATUS:${NC}"; CURRENT="${GR}Current: v$SCRIPT_VERSION${NC}"
    SS_FILE="/jffs/scripts/services-start"; SE_FILE="/jffs/scripts/service-event"
	DATE_FORMAT=${DATE_FORMAT:-USA}
	case "$DATE_FORMAT" in USA|INTL|ISO) ;; *) DATE_FORMAT="USA" ;; esac
	update_time
	DF="${GR}$DATE_FORMAT${NC}"; CT="${GR}$CUR_TIME${NC}"
	DATE_USA=$(date +"%m/%d/%Y %I:%M %p")
	DATE_INTL=$(date +"%d/%m/%Y %H:%M")
	DATE_ISO=$(date +"%Y-%m-%d %H:%M:%S")
	RTIME=${RTIME:-1}; if [ "$RTIME" = "0" ]; then RT_STAT="$OFF"; else RT_STAT="$ON"; fi
    BACKHAUL=${BACKHAUL:-no}; if [ "$BACKHAUL" = "no" ]; then WB_STAT="$OFF"; else WB_STAT="$ON"; fi
    PULSE_MINS=${PULSE_MINS:-15}; if [ "$PULSE_MINS" = "0" ]; then UP_STAT="$OFF"; else UP_STAT="${GR}${PULSE_MINS} Mins${NC}"; fi
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
	local is_update=0 apply_only=0
	[ "$1" = "--apply" ] && apply_only=1
	if [ -f "$REPORT_SCRIPT" ]; then is_update=1; fi

	# When updating/reinstalling, restart into the newly installed script once,
	# then continue directly into the WebUI mounting phase.  Previously this
	# exec'd back into `install`, which reopened the menu and skipped inject_menu().
	if [ "$is_update" = "1" ] && [ "$apply_only" != "1" ]; then
        while true; do
            check_version do_install
            printf "Do you want to $UP (y/n): "; read -r update
            case "$update" in [yY]) break ;; [nN]) return ;; *) printf "\033[4A\033[J" ;; esac; done
        do_update || return 1
        echo -e "\n${GR}[+] Preparing Wireless Report (${NC}v$REMOTE_VERSION${GR})${NC}"
		echo -e "\n${BL}[✓] Wireless Report files updated.${NC}"
		printf "\nPress ${BL}[Enter]${NC} to apply changes & mount the WebUI..."; read -r discard
		logger -p user.info -t "Wireless_Report" "(v$REMOTE_VERSION) files updated; applying WebUI mount."
		exec "$REPORT_SCRIPT" install-apply
		echo -e "${RD}Error: Failed to restart script for WebUI apply!${NC}" >&2
		exit 1
	fi

	# A fresh install still needs to place/update the script before mounting.
	if [ "$apply_only" != "1" ]; then
        do_update || return 1
        echo -e "\n${GR}[+] Preparing Wireless Report (${NC}v$REMOTE_VERSION${GR})${NC}"
	fi
    if [ "$(nvram get jffs2_scripts)" != "1" ]; then
        echo -e "${RD}[!] ERROR: JFFS custom scripts not enabled.${NC}"
        pause; return 1
    fi
	# v2.2+ is controller-only. Remove legacy add-on persistence hooks,
	# but never delete the user's SSH keys or authorized_keys.
	if [ -f "$SS_FILE" ]; then sed -i '/# sshpairs/d' "$SS_FILE" 2>/dev/null; fi
	sed -i '/^SSH_NODES=/d; /^MESH_NODES=/d' "$CONFIG" 2>/dev/null
    echo -e "\n${GR}[+] Processing Wireless Report Files...${NC}\n"
    inject_menu
    echo -e "${GR}[+] Mounting Menu [Wireless] Tab [Wireless Report]${NC}\n"
    if ! mkdir -p /jffs/scripts 2>/dev/null; then
        echo -e "${RD}[!] ERROR: Unable to access /jffs/scripts.${NC}"
        return 1
    fi
    if [ ! -f "$SS_FILE" ]; then
        if ! printf '#!/bin/sh\n' > "$SS_FILE"; then
            echo -e "${RD}[!] ERROR: Unable to create $SS_FILE.${NC}"
            return 1
        fi
    fi
    sed -i "\|$REPORT_SCRIPT|d" "$SS_FILE" 2>/dev/null
    if ! echo "$REPORT_SCRIPT inject & # Inject Wireless Report" >> "$SS_FILE"; then
        echo -e "${RD}[!] ERROR: Unable to update $SS_FILE.${NC}"
        return 1
    fi
    if ! chmod +x "$SS_FILE"; then
        echo -e "${RD}[!] ERROR: Unable to make $SS_FILE executable.${NC}"
        return 1
    fi
    # Dynamic refreshes are handled in the browser; no service-event scan hook is required.
    if [ -f "$SE_FILE" ]; then sed -i "/wireless_report/d" "$SE_FILE" 2>/dev/null; fi
    install=""; SCRIPT_VERSION="$REMOTE_VERSION"
    logger -p user.info -t "Wireless_Report" "(v$REMOTE_VERSION) successfully installed."
    echo -e "${GR}[✓] SUCCESS: Installation complete!${NC}\n"
    echo -e "${YL}[i] To access Report, navigate to Advanced Settings > Wireless "
    echo -e "${YL}    in the ASUS WebGUI and select the Wireless Report tab on the far right.${NC}\n"
    echo -e "${BL}[i] AiMesh nodes are discovered automatically from the primary router."
    echo -e "${BL}    No node SSH keys, passwords, cookies, or direct node login are required.${NC}"
	pause
}

do_update() {
    TEMP_SCRIPT="/tmp/wirelessreport.sh"
    local CURRENT_PATH TARGET_PATH version_cmp
    version_cmp=0
    if [ -n "$REMOTE_VERSION" ]; then
        version_cmp=$(version_compare "$SCRIPT_VERSION" "$REMOTE_VERSION")
        case "$version_cmp" in -1|0|1) ;; *) version_cmp=0 ;; esac
    fi

    # Never let a local/dev build be silently replaced by an older public build.
    # Use the same component-aware comparison as check_version so versions such
    # as 2.2.10 and 2.3.0 are ordered correctly.
    if [ -n "$REMOTE_VERSION" ] && [ "$version_cmp" -gt 0 ]; then
        CURRENT_PATH=$(readlink -f "$0" 2>/dev/null); [ -z "$CURRENT_PATH" ] && CURRENT_PATH="$0"
        TARGET_PATH=$(readlink -f "$REPORT_SCRIPT" 2>/dev/null); [ -z "$TARGET_PATH" ] && TARGET_PATH="$REPORT_SCRIPT"
        if [ "$CURRENT_PATH" != "$TARGET_PATH" ]; then
            cp "$0" "$REPORT_SCRIPT" || return 1
            chmod +x "$REPORT_SCRIPT" 2>/dev/null
        fi
        REMOTE_VERSION="$SCRIPT_VERSION"
        echo -e "\n${YL}[i] Using local v$SCRIPT_VERSION build; upstream is older.${NC}"
        return 0
    fi

    if curl -sfL --retry 3 "$GITHUB" -o "$TEMP_SCRIPT" && [ -s "$TEMP_SCRIPT" ]; then
        mv "$TEMP_SCRIPT" "$REPORT_SCRIPT"
        chmod +x "$REPORT_SCRIPT" 2>/dev/null
        return 0
    else
        rm -f "$TEMP_SCRIPT"
        if [ ! -f "$0" ]; then
            echo -e "${RD}[!] Download failed. Aborting installation.${NC}"
            return 1
        fi
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
        echo -e "\n  [+] Downloading latest version (v$REMOTE_VERSION)\n"
        echo -e "\n  [✓] Wireless Report successfully updated.\n"
		logger -p user.info -t "Wireless_Report" "AMTM Update: (v$REMOTE_VERSION) successfully installed."
		return 0
    else
        return 1
    fi
}

check_github() {
	GITHUB="https://raw.githubusercontent.com/JB1366/Wireless_Report/main/wirelessreport.sh"
	LOCAL_HASH=$(sha256sum "$REPORT_SCRIPT" 2>/dev/null | awk '{print $1}')
	REMOTE_TMP="/tmp/wr_remote.tmp"
	if curl -sfL --retry 3 "$GITHUB" -o "$REMOTE_TMP" 2>/dev/null && [ -s "$REMOTE_TMP" ]; then
		REMOTE_VERSION=$(grep "SCRIPT_VERSION=" "$REMOTE_TMP" | head -n 1 | cut -d'"' -f2 | tr -cd '0-9.')
		REMOTE_HASH=$(sha256sum "$REMOTE_TMP" | awk '{print $1}')
	else
		REMOTE_VERSION=""; REMOTE_HASH=""
	fi
	rm -f "$REMOTE_TMP"
}

mesh_init() {
	VALID_NODES=""
	# Terminal-only settings (nicknames/colors) need a lightweight node list.
	# This reads the primary router's local AiMesh inventory only; it never
	# contacts a node and never performs authentication.
	MESH_NODES=$(nvram get asus_device_list | sed 's/</\n/g' | grep '>2$' | \
		awk -F '>' '{print $2 "|" $3}' | sort -t . -k 4,4n)
	if [ -z "$MESH_NODES" ]; then
		MESH_NODES=$(nvram get cfg_device_list | sed 's/</\n/g' | grep '>0$' | \
			awk -F '>' '{print $1 "|" $2}' | sort -t . -k 4,4n)
	fi
}

inject_menu() {
	source /usr/sbin/helper.sh
	TAB_LABEL="Wireless Report"
	if [ -f "$CONFIG" ]; then sed -i '/^INSTALLED_PAGE=/d' "$CONFIG"; else touch "$CONFIG"; fi
    if ! nvram get rc_support | grep -q am_addons; then echo -e "\n${RD}[!] ERROR: This firmware does not support addons!${NC}"; exit 5; fi
    if [ ! -f "$WEB_PAGE" ]; then echo "<html><body>$TAB_LABEL Loading...</body></html>" > "$WEB_PAGE"; fi
	LOCKFILE=/tmp/addonwebui.lock; FD=386; eval exec "$FD>$LOCKFILE"; flock -x "$FD"
    am_get_webui_page "$WEB_PAGE"
	if [ -z "$am_webui_page" ] || [ "$am_webui_page" = "none" ]; then
		echo -e "\n${RD}[!] ERROR: Unable to allocate a WebUI page for $TAB_LABEL.${NC}"
		flock -u "$FD"
		exit 5
	fi
	if ! cp "$WEB_PAGE" "/www/user/$am_webui_page" 2>/dev/null; then
		echo -e "\n${RD}[!] ERROR: Unable to create /www/user/$am_webui_page.${NC}"
		flock -u "$FD"
		exit 5
	fi
	echo "INSTALLED_PAGE=$am_webui_page" >> "$CONFIG"
	echo -e "${BL}[i] WebUI page allocated as ${NC}$am_webui_page"
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
	sed -i "\|$REPORT_SCRIPT|d" "$SS_FILE"; sed -i "/# sshpairs/d" "$SS_FILE" 2>/dev/null; sed -i "/wireless_report/d" "$SE_FILE"
	restart_httpd; mesh_init
	rm -rf "$INSTALL_DIR" "$WEB_PAGE" 2>/dev/null
	logger -p user.info -t "Wireless_Report" "(v$SCRIPT_VERSION) successfully uninstalled."
    unset RTIME BACKHAUL CUR_DATE RS_HIST_DATE RS_HIST CUR_RS_HIST CUR_ENTRIES
    unset THEME IPPAD PULSE_MINS DATE_FORMAT REPORT_UNIT HOST_COLOR MAIN_COLOR NODE_COLORS
	echo -e "${GR}[+] System cleaned. Existing SSH keys were left untouched.${NC}\n"
	echo -e "${GR}[+] Success: Wireless Report uninstalled.${NC}"
	pause
}

set_date_time() {
    while true; do
        show_header
        echo -e "${BL}=================================================="
        echo -e "${NC}                Set Date/Time Format               "
        echo -e "${BL}=================================================="
        echo -e "${BL}  Current:${NC} $DF          ${BL}Now:${NC} $CT "
        echo -e "${BL}=================================================="
        echo -e "                                                       "
        echo -e "  $N1  USA           ($DATE_USA)                       "
        echo -e "  $N2  International ($DATE_INTL)                      "
        echo -e "  $N3  ISO           ($DATE_ISO)                       "
        echo -e "                                                       "
        echo -e "  $NE  Back to main menu                               "
        echo -e "                                                       "
		echo -e "${BL}=================================================="
        while true; do
            printf "\n ${NC}Selection: ${BL}"; read -r t_choice
            case "$t_choice" in
                1) NEW_FORMAT="USA" ;;
                2) NEW_FORMAT="INTL" ;;
                3) NEW_FORMAT="ISO" ;;
                e|E) sort -u -o "$CONFIG" "$CONFIG"; return ;;
                *) freeze2; continue ;;
            esac
            sed -i '/^DATE_FORMAT=/d; /^REPORT_UNIT=/d' "$CONFIG"
            echo "DATE_FORMAT=\"$NEW_FORMAT\"" >> "$CONFIG"
            DATE_FORMAT="$NEW_FORMAT"
            update_time
            echo -e "\n${GR}[+] Date/time format updated to $NEW_FORMAT${NC}"
            pause; break
        done
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
		echo -e "  $NE Back to main menu                                "
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
                            sed -i "/^NODE_NICK_$CLEAN_IP=/d" "$CONFIG"
                            echo "NODE_NICK_$CLEAN_IP=\"$input_node\"" >> "$CONFIG"
                        fi
                        node_idx=$((node_idx + 1))
                    done
                    echo -e "\n${GR}[+] Manual nicknames saved.${NC}"
                    pause; break ;;
                e|E)
                    sort -u -o "$CONFIG" "$CONFIG"; return ;;
                *)
                    freeze2; continue ;;
            esac
        done
    done
}

hex_to_ansi() {
    : "${MAIN_COLOR:=#0096ff}"
    : "${NODE_COLORS:=#30d158 #bf40bf #ffd60a #64d2ff #ff9500 #ff453a #ffffff #ff70a6 #64ffda}"
    NB='\033[38;5;39m'; LG='\033[38;5;82m'; MP='\033[38;5;133m'; RD='\033[38;5;196m'; PK='\033[38;5;211m'
    YL='\033[38;5;220m'; SB='\033[38;5;75m'; OR='\033[38;5;208m'; WT='\033[38;5;231m'; MT='\033[38;5;86m'
    case "$1" in
        "#0096ff") echo -e "$NB" ;;
        "#30d158") echo -e "$LG" ;;
        "#bf40bf") echo -e "$MP" ;;
        "#ffd60a") echo -e "$YL" ;;
        "#64d2ff") echo -e "$SB" ;;
        "#ff9500") echo -e "$OR" ;;
        "#ff453a") echo -e "$RD" ;;
        "#ffffff") echo -e "$WT" ;;
        "#ff70a6") echo -e "$PK" ;;
        "#64ffda") echo -e "$MT" ;;
        *)         echo -e "$NC" ;;
    esac
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
        echo -e "${NC}\n${BL} Current Device Configuration:\n"
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
            local ip_underscores="${node_ip//./_}"
            local nick_var_name="NODE_NICK_${ip_underscores}"
            local node_display_name=$(eval echo \"\${$nick_var_name}\")
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
                local target_node=$(echo "$MESH_NODES" | awk -v n="$node_choice" '{print $n}')
                local target_ip=$(echo "$target_node" | cut -d'|' -f2)
                local target_ip_underscores=$(echo "$target_ip" | tr '.' '_')
                local target_nick_var="NODE_NICK_${target_ip_underscores}"
                target_name=$(eval echo \"\${$target_nick_var}\")
                target_name="${target_name:-$(echo "$target_node" | cut -d'|' -f1)}"
                target_hex=$(echo "$working_colors" | awk -v col="$node_choice" '{print $col}')
            fi
            hex_to_ansi; local target_prompt_color=$(hex_to_ansi "$target_hex")
            echo -e "\nSelect a new color for ${target_prompt_color}[${target_name}]${NC}:\n"
            echo -e "${NB}   (1) Neon-Blue (#0096ff)"
            echo -e "${LG}   (2) Lime-Green (#30d158)"
            echo -e "${MP}   (3) Medium-Purple (#bf40bf)"
            echo -e "${YL}   (4) Yellow (#ffd60a)"
            echo -e "${SB}   (5) SkyBlue (#64d2ff)"
            echo -e "${OR}   (6) Orange (#ff9500)"
            echo -e "${RD}   (7) Red (#ff453a)"
            echo -e "${WT}   (8) White (#ffffff)"
            echo -e "${PK}   (9) Light-Pink (#ff70a6)"
            echo -e "${MT}  (10) Mint-Green (#64ffda)"
            echo -e "${NC}"
            local selected_hex=""
            while true; do
                printf "${NC}Choose option ${BL}(1-10): "; read -r color_choice
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
        echo -e "  $N1  Toggle Browser Refresh Runtime: ($RT_STAT)      "
        echo -e "  $N2  Configure Connection Alert Pulse: ($UP_STAT)    "
        echo -e "  $N3  Configure RSSI History: ($RH_STAT)              "
        echo -e "  $N4  Set Theme: ($TM_STAT)                           "
        echo -e "  $N5  Toggle IP Padding: ($PD_STAT)                   "
        echo -e "  $N6  Toggle Node Hostname Display: ($HN_STAT)        "
        echo -e "                                                       "
        echo -e "  $NE  Back to main menu                               "
        echo -e "                                                       "
        echo -e "${BL}=================================================="
        while true; do
            printf "\n ${NC}Selection: ${BL}"; read -r t_choice
            case "$t_choice" in
                1)
                    if grep -q "RTIME=" "$CONFIG"; then
                        if [ "$RTIME" = "1" ]; then sed -i 's/RTIME=.*/RTIME="0"/' "$CONFIG"
                        else sed -i 's/RTIME=.*/RTIME="1"/' "$CONFIG"; fi
                    else
                        echo 'RTIME="0"' >> "$CONFIG"
                    fi
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
                        echo -e "\n${RD}[-] Disabled:${NC} IP padding"
                        echo 'IPPAD="0"' >> "$CONFIG"
                        pause
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
                    sort -u -o "$CONFIG" "$CONFIG"; return 0 ;;
                *)
                    freeze2; continue ;;
            esac
        done
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
                            CE="${GR}$CUR_ENTRIES${NC}"
                            break 2
                        fi
                        freeze2
                    done ;;
                3)
                    if [ "$CUR_DATE" = "1" ]; then CUR_DATE="0"; else CUR_DATE="1"; fi
                    break ;;
                c|C)
                    unset CUR_RS_HIST CUR_ENTRIES CUR_DATE
                    return 0 ;;
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
                    echo -e "${BL}[i] History is stored only in browser localStorage."
                    echo -e "    If these settings changed, browser history resets on the next report reload.${NC}"
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
        echo -e "${NC} Set Theme                    Current: $TM_STAT   "
        echo -e "${BL}=================================================="
        echo -e "                                                       "
        echo -e "  $N1 Original Theme                                   "
        echo -e "  $N2 Darkmode Theme                                   "
        echo -e "  $N3 Asus WebUI Theme                                 "
        echo -e "                                                       "
        echo -e "  $NE Exit                                             "
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
                    return 0 ;;
                *)
                    freeze2; continue ;;
            esac
        done
    done
}

restart_httpd() { service restart_httpd >/dev/null 2>&1; killall -HUP httpd >/dev/null 2>&1; }

pause() { printf "\nPress ${BL}[Enter]${NC} to return..."; read -r discard; }

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

#====================#
#  Report Functions  #
#====================#
normalize_date_format() {
    # v2.1.x/v2.2.0-v2.2.9 tied date style to REPORT_UNIT.  Temperature is no
    # longer displayed, so migrate that legacy preference once to DATE_FORMAT.
    case "${DATE_FORMAT:-}" in
        USA|INTL|ISO) ;;
        *)
            case "${REPORT_UNIT:-}" in
                C)   DATE_FORMAT="INTL" ;;
                ISO) DATE_FORMAT="ISO" ;;
                *)   DATE_FORMAT="USA" ;;
            esac
            ;;
    esac

    if [ -f "$CONFIG" ]; then
        if grep -q '^REPORT_UNIT=' "$CONFIG" 2>/dev/null || ! grep -q '^DATE_FORMAT=' "$CONFIG" 2>/dev/null; then
            sed -i '/^DATE_FORMAT=/d; /^REPORT_UNIT=/d' "$CONFIG" 2>/dev/null
            echo "DATE_FORMAT=\"$DATE_FORMAT\"" >> "$CONFIG"
        fi
    fi
}

update_time() {
    case "${DATE_FORMAT:-USA}" in
        INTL) T_FMT="+%d/%m/%Y %H:%M:%S" ;;
        ISO)  T_FMT="+%Y-%m-%d %H:%M:%S" ;;
        *)    DATE_FORMAT="USA"; T_FMT="+%m/%d/%Y %I:%M:%S %p" ;;
    esac
    CUR_TIME=$(date "$T_FMT")
}

startup() { mesh_init; check_github; normalize_date_format; update_time; }

run_report() {
#======================================#
#  Browser/API Report Page Preparation #
#======================================#
# v2.2+ deliberately does not scan AiMesh nodes from the shell. The generated
# page uses the browser's already-authenticated primary-router WebUI session:
#   /appGet.cgi
#   /get_diag_latest_content_data.cgi
# All client/node refreshes happen in-page with same-origin fetch() calls.

IPPAD=${IPPAD:-1}; HOST_COLOR=${HOST_COLOR:-0}
PULSE_MINS=${PULSE_MINS:-15}
: "${MAIN_COLOR:=#0096ff}"
: "${NODE_COLORS:=#30d158 #bf40bf #ffd60a #64d2ff #ff9500 #ff453a #ffffff #ff70a6 #64ffda}"
ROUTER=$(nvram get productid)
MAIN_NAME="${MAIN_NICK:-${ROUTER:-Main Router}}"
[ "${#MAIN_NAME}" -gt 25 ] && MAIN_NAME="${MAIN_NAME:0:25}"

# Preserve custom node nicknames configured by the add-on without exposing any
# credentials to the page. Values are emitted as JavaScript string literals.
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

set_theme
check_version header_box
RUNTIME_CSS=""
RUNTIME=""
ROUTER_ONLY=""
TEMP_STYLE="text-align: center; justify-content: center;"
UPTIME_STYLE="text-align: center; justify-content: center;"
MAC_COLOR=""
IP_COLOR="color: #64d2ff;"

MAIN_NAME="<span id='wr-main-name' class='router-style'>${MAIN_NAME}</span>"
UPDATED_TIME="<span class='wr-updated-time total-count'>Loading controller data...</span>"
GRAND_TOTAL_DEVICES="<span id='wr-grand-total' class='count-highlight'>0</span>"
MAIN_TEMP="<span id='wr-main-cpu' class='stat-cool'>--</span>"
MAIN_LOAD="<span id='wr-main-memory' class='stat-cool'>--</span>"
MAIN_DEVICE_TOTAL="<span id='wr-main-count' class='main-color'>0</span>"
MAIN_UPTIME="<span id='wr-main-uptime' class='main-color'>--</span>"
MAIN_BOOTTIME="<span id='wr-main-reboot' class='main-color'>--</span>"

NODE_NAMES="<span id='wr-node-names' class='router-style'>AiMesh nodes</span>"
NODE_TEMPS="<span id='wr-node-cpu' class='stat-cool'>--</span>"
NODE_LOADS="<span id='wr-node-memory' class='stat-cool'>--</span>"
NODE_DEVICE_TOTAL="<span id='wr-node-count' class='stat-cool'>0</span>"
NODE_UPTIMES="<span id='wr-node-diag'>Controller telemetry pending...</span>"
NODE_BOOTTIMES=""

ALL_NAMES="<span id='wr-all-names' class='router-style'>Loading...</span>"
ALL_TEMP="<span id='wr-all-main-cpu'>--</span>"
ALL_LOAD="<span id='wr-all-main-memory'>--</span>"
ALL_DEVICES="Devices: <span id='wr-all-count' class='stat-cool'>0</span>"
ALL_UPTIME="<span id='wr-all-api-note'>Primary-router WebUI APIs • no direct node authentication</span>"
ALL_BOOTTIME=""
NTOTAL=""
MAIN_ROWS=""
NODE_ROWS=""
ALL_ROWS=""

RSSI_BOXES="<div class='rssi-quality-box rssi-excl'>Excellent: <span style='background:#30d158;' class='rssi-font wr-rssi-excellent'>0</span></div>
    <div class='rssi-quality-box rssi-good'>Good: <span style='background:#64d2ff;' class='rssi-font wr-rssi-good'>0</span></div>
    <div class='rssi-quality-box rssi-fair'>Fair: <span style='background:#ffd60a;' class='rssi-font wr-rssi-fair'>0</span></div>
    <div class='rssi-quality-box rssi-poor'>Poor: <span style='background:#ff453a;' class='rssi-font wr-rssi-poor'>0</span></div>"

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
    ${RUNTIME_CSS}
    .button-auto-refresh { display: inline-flex; align-items: center; padding: 0 5px; height: 28px; border: 0; margin-left: -4px; border-top-left-radius: 0 !important; border-bottom-left-radius: 0 !important; border-top-right-radius: 4px; border-bottom-right-radius: 4px; color: #0096ff; font-size: 12px; font-weight: bold; cursor: pointer !important; }
    .button-auto-refresh > span { color: #0096ff; font-weight: bold; pointer-events: none; user-select: none; }
    .button-auto-refresh:hover, .button-auto-refresh.active { border-color: #0096ff; box-shadow: 0 0 25px rgba(0,150,255,0.6); color: #0096ff; position: relative; z-index: 5 }
    .button-auto-refresh.active { background: rgba(0,150,255,0.15); }
    .button-tables.button-trigger { color: #0096ff; border: none; border-top-right-radius: 0; border-bottom-right-radius: 0; height: 100%; line-height: inherit; padding: 0 5px; }
    .button-tables.button-trigger span { color: white; }
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
	table.report_table .mac-val { $MAC_COLOR; }
	table.report_table .ip-val { $IP_COLOR; }
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
    .temp_load_row { display: block; font-size: 14px; color: #f2f2f7; margin-top: 11px; font-weight: bold; white-space: nowrap; width: 100%; overflow: visible !important; }
    .temp_load_row > span:not(:last-child) { margin-right: 1px; }
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
    body.wr-wide-mode table.report_table th:nth-child(1), #popoutModal table.report_table th:nth-child(1) { min-width: 110px; }
    body.wr-wide-mode table.report_table th:nth-child(2), #popoutModal table.report_table th:nth-child(2) { min-width: 125px; }
    body.wr-wide-mode table.report_table th:nth-child(3), #popoutModal table.report_table th:nth-child(3) { min-width: 75px; }
    body.wr-wide-mode table.report_table th:nth-child(4), #popoutModal table.report_table th:nth-child(4) { min-width: 130px; }
    body.wr-wide-mode table.report_table th:nth-child(5), #popoutModal table.report_table th:nth-child(5) { min-width: 185px; }
    body.wr-wide-mode table.report_table th:nth-child(6), #popoutModal table.report_table th:nth-child(6) { min-width: 115px; }
    body.wr-wide-mode table.report_table th:nth-child(7), #popoutModal table.report_table th:nth-child(7) { min-width: 90px; }

    .popout-overlay { display: none; position: fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.4); z-index:9999; align-items: center; justify-content: center; backdrop-filter: blur(8px); }
    .popout-content { background: rgba(0, 0, 0, 0.2); width: calc(100vw - 24px); max-width: none; height: calc(100vh - 24px); max-height: none; margin: 12px; padding:12px; box-sizing: border-box; border-radius:15px; border:1px solid rgba(0, 150, 255, 0.4); position: relative; overflow-y: auto; box-shadow: 0 0 40px rgba(0,0,0,0.6); backdrop-filter: blur(20px); overflow-x: hidden !important; }
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
    #popoutModal .report-column .section-header .temp_load_row { margin-top: -2px !important; margin-bottom: -2px !important; display: block !important; }
    #popoutModal .report-column .section-header .temp_load_row span { font-size: 14px !important; font-weight: bold !important; }
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

var WR_CONFIG = {
    mainColor: "$MAIN_COLOR",
    nodeColors: String("$NODE_COLORS").trim().split(/\s+/).filter(Boolean),
    hostColor: Number("$HOST_COLOR") || 0,
    pulseMins: Number("$PULSE_MINS"),
    dateFormat: String("${DATE_FORMAT:-USA}"),
    runtimeTracking: Number("${RTIME:-1}") || 0,
    ipPad: Number("${IPPAD:-1}") || 0,
    rssiHistory: Number("${RS_HIST:-0}") || 0,
    rssiHistoryEntries: Number("${RS_HIST_ENTRIES:-5}") || 5,
    rssiHistoryDate: Number("${RS_HIST_DATE:-0}") || 0
};

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

function wrNodeColor(index) {
    if (!WR_CONFIG.nodeColors.length) return '#30d158';
    return WR_CONFIG.nodeColors[index % WR_CONFIG.nodeColors.length] || '#30d158';
}

function wrIpSort(ip) {
    var parts = String(ip || '').split('.');
    if (parts.length !== 4) return '999.999.999.999';
    return parts.map(function(p) {
        var n = parseInt(p, 10);
        return Number.isFinite(n) ? String(n).padStart(3, '0') : '999';
    }).join('.');
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

function wrFormatDateTime(value) {
    var d = value instanceof Date ? value : new Date(value);
    if (!d || Number.isNaN(d.getTime())) return '--';

    var y = d.getFullYear();
    var month = wrPad2(d.getMonth() + 1);
    var day = wrPad2(d.getDate());
    var hh24 = d.getHours();
    var minute = wrPad2(d.getMinutes());
    var second = wrPad2(d.getSeconds());

    switch (WR_CONFIG.dateFormat) {
        case 'INTL':
            return day + '/' + month + '/' + y + ' ' + wrPad2(hh24) + ':' + minute + ':' + second;
        case 'ISO':
            return y + '-' + month + '-' + day + ' ' + wrPad2(hh24) + ':' + minute + ':' + second;
        case 'USA':
        default:
            var suffix = hh24 >= 12 ? 'PM' : 'AM';
            var hh12 = hh24 % 12 || 12;
            return month + '/' + day + '/' + y + ' ' + wrPad2(hh12) + ':' + minute + ':' + second + ' ' + suffix;
    }
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
        '2G': '2.4 GHz',
        '5G': '5 GHz',
        '5G1': '5 GHz-2',
        '6G': '6 GHz',
        '6G1': '6 GHz-2'
    };
    return map[String(band || '')] || String(band || '');
}

function wrWidth(code) {
    var map = { 0: '', 1: '20 MHz', 2: '40 MHz', 3: '80 MHz', 4: '160 MHz', 5: '320 MHz' };
    var n = Number(code);
    return Object.prototype.hasOwnProperty.call(map, n) ? map[n] : '';
}

function wrBandHtml(sta, client) {
    var band = sta ? wrBandName(sta.sta_band) : String(wrFirst(client, ['band', 'wlBand']) || '');
    var width = sta ? wrWidth(sta.bw) : '';
    var label = band + (width ? ' (' + width + ')' : '');
    var cls = '';
    var sort = '0';
    if (/2\.4|2G/i.test(band)) { cls = 'band-24g'; sort = '2.4'; }
    else if (/5/.test(band)) { cls = 'band-5g'; sort = '5'; }
    else if (/6/.test(band)) { cls = 'band-6g'; sort = '6'; }
    return "<td data-sort='" + sort + "' style='text-align:center;'><span class='" + cls + "'>" + wrEscape(label || '--') + "</span></td>";
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

    // v2.2.0-v2.2.11 stored just one numeric RSSI value per MAC. Preserve that
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

    // On the first v2.2.12 load, keep/migrate the single-sample v2.2 history.
    // After that, mirror v2.1.0 behavior: changing history settings starts clean.
    if (previous !== null && previous !== current) {
        localStorage.removeItem('wirelessReportRssiHistory');
    }
    localStorage.setItem(sigKey, current);
}

function wrRssiHistoryBand(item) {
    if (item && item.sta && item.sta.sta_band !== undefined) {
        return wrBandName(item.sta.sta_band);
    }
    return wrBandName(wrFirst(item && item.client, ['band', 'wlBand']) || '');
}

function wrRssiHistoryLocation(item) {
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
            text += ' ' + wrEscape(wrFormatDateTime(new Date(Number(entry.time))));
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

async function wrDiag(db, content, filter) {
    var r = await fetch('/get_diag_latest_content_data.cgi', {
        method: 'POST',
        credentials: 'same-origin',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ db: db, content: content, filter: filter || '' })
    });
    if (!r.ok) throw new Error('diagnostic API HTTP ' + r.status);
    return r.json();
}

async function wrGetNodeDiag(mac) {
    var cols = ['data_time', 'node_type', 'node_ip', 'node_mac', 'cpu_usage', 'mem_usage', 'cpu_temp'];
    var data = await wrDiag('sys_detect', cols.join(';'), 'node_mac>txt>' + wrNormMac(mac) + '>0;');
    var row = data && data.contents && data.contents[0];
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

function wrMainHealthSampleUsable(sample) {
    sample = sample || {};
    var cpu = sample.cpu || {};
    var memory = sample.memory || {};
    var hasCpu = Object.keys(cpu).some(function(key) {
        var core = cpu[key] || {};
        return /^cpu[0-9]+$/.test(key) &&
            wrNumber(core.total) !== null && wrNumber(core.usage) !== null;
    });
    return hasCpu && wrNumber(memory.total) !== null &&
        (wrNumber(memory.simple_used) !== null || wrNumber(memory.used) !== null);
}

async function wrGetMainHealthSample() {
    // Tested GT-BE98 Pro behavior:
    //   cpu_usage(appobj) / memory_usage(appobj) => malformed {{...}} wrappers
    //   cpu_usage() / memory_usage()             => clean JSON
    // Request the clean hooks independently and consume their actual nested schema.
    var responses = await Promise.all([
        wrAppGet('cpu_usage();'),
        wrAppGet('memory_usage();')
    ]);

    var sample = {
        cpu: (responses[0] && responses[0].cpu_usage) || {},
        memory: (responses[1] && responses[1].memory_usage) || {}
    };

    if (!wrMainHealthSampleUsable(sample)) {
        throw new Error('primary CPU/memory response did not contain usable counters');
    }
    return sample;
}

async function wrGetMainHealth(first) {
    first = first || { cpu: {}, memory: {} };
    var second = await wrGetMainHealthSample();
    var cpu = wrCpuUsageBetween(first.cpu, second.cpu);

    // CPU usage is counter based. If the first pair is unusable, take another
    // sample after a short interval rather than fabricating a utilization value.
    if (cpu === null) {
        await new Promise(function(resolve) { setTimeout(resolve, 250); });
        var third = await wrGetMainHealthSample();
        cpu = wrCpuUsageBetween(second.cpu, third.cpu);
        second = third;
    }

    var memory = wrMemoryUsage(second.memory);
    if (memory === null) memory = wrMemoryUsage(first.memory);
    return { cpuUsage: cpu, memoryUsage: memory };
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

async function wrGetStaRows(nodeMac) {
    try {
        var filter = 'node_mac>txt>' + wrNormMac(nodeMac) + '>0;sta_active>txt>1>0;';
        var data = await wrDiag('stainfo', WR_STA_COLUMNS.join(';'), filter);
        var rows = data && Array.isArray(data.contents) ? data.contents : [];
        return rows.map(function(row) {
            var obj = {};
            WR_STA_COLUMNS.forEach(function(name, i) { obj[name] = row[i]; });
            return obj;
        });
    } catch (e) {
        console.warn('STAINFO batch query failed for ' + nodeMac, e);
        return [];
    }
}

async function wrGetSta(nodeMac, staMac) {
    try {
        var filter =
            'node_mac>txt>' + wrNormMac(nodeMac) + '>0;' +
            'sta_mac>txt>' + wrNormMac(staMac) + '>0;' +
            'sta_active>txt>1>0;';
        var data = await wrDiag('stainfo', WR_STA_COLUMNS.join(';'), filter);
        var row = data && data.contents && data.contents[0];
        if (!row) return null;
        var obj = {};
        WR_STA_COLUMNS.forEach(function(name, i) { obj[name] = row[i]; });
        return obj;
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
    return custom || wrFirst(node, ['alias', 'model_name', 'product_id']) || ip || wrNormMac(wrFirst(node, ['mac', 'mac_addr']));
}

function wrRenderRow(item, history, known, firstHistoryLoad) {
    var c = item.client;
    var saved = item.saved;
    var sta = item.sta;
    var mac = item.mac;
    var ip = wrFirst(c, ['ip']) || '';
    var name = wrClientName(mac, c, saved);
    var ssid = wrFirst(c, ['ssid']) || '';
    var iface = sta ? (sta.conn_if || '') : wrFirst(c, ['ifname', 'interface']);
    var rssi = sta && sta.sta_rssi !== undefined ? wrNumber(sta.sta_rssi) : wrNumber(c.rssi);
    var rx = sta && sta.sta_rx !== undefined ? wrNumber(sta.sta_rx) : wrNumber(c.curRx);
    var tx = sta && sta.sta_tx !== undefined ? wrNumber(sta.sta_tx) : wrNumber(c.curTx);
    var connected = sta && sta.conn_time !== undefined ? sta.conn_time : c.wlConnectTime;
    var quality = wrQuality(rssi);
    var trend = wrGetTrend(item, rssi, history);
    var isNew = !firstHistoryLoad && !known[mac] ? 'new-device-row' : '';
    var nodeMarker = '';

    if (item.node) {
        var markerColor = wrNodeColor(item.nodeIndex);
        nodeMarker = "<sup style='color:" + markerColor + ";'>" + (item.nodeIndex + 1) + "</sup>";
        if (WR_CONFIG.hostColor) {
            name = "<span style='color:" + markerColor + ";'>" + wrEscape(name) + "</span><span class='hidden-node-number'>" + nodeMarker + "</span>";
        } else {
            name = "<span style='color:#ffffff;'>" + wrEscape(name) + "</span>" + nodeMarker;
        }
    } else if (WR_CONFIG.hostColor) {
        name = "<span style='color:" + WR_CONFIG.mainColor + ";'>" + wrEscape(name) + "</span>";
    } else {
        name = wrEscape(name);
    }

    var rxText = Number.isFinite(rx) && rx >= 0 ? rx : '--';
    var txText = Number.isFinite(tx) && tx >= 0 ? tx : '--';
    var rateText = rxText + ' / ' + txText;
    var rateSort = Number.isFinite(tx) && tx >= 0 ? tx : 0;
    var rssiText = Number.isFinite(rssi) && rssi < 0 && rssi >= -120 ? rssi : '--';
    var bars = quality.bars ? "<span class='rssi_bars " + quality.cls + "'>" + quality.bars + "</span>" : '';

    return "<tr class='" + isNew + "'>" +
        "<td style='text-align:left;'>" + name + "</td>" +
        "<td><span class='mac-val' data-sort='" + wrEscape(mac) + "'>" + wrEscape(mac) + "</span>" +
        "<span class='ip-val' data-sort='" + wrIpSort(ip) + "'>" + wrEscape(wrDisplayIp(ip) || '--') + "</span></td>" +
        "<td data-sort='" + (Number.isFinite(rssi) ? rssi : -999) + "' class='rssi-container'>" +
            bars + " <span style='" + quality.style + "'>" + rssiText + "</span> " + trend + "</td>" +
        "<td data-sort='" + rateSort + "' style='" + quality.style + "text-align:center;'>" + wrEscape(rateText) + "</td>" +
        "<td><span class='ssid-val' data-sort='" + wrEscape(ssid) + "'>" + wrEscape(ssid || '--') + "</span>" +
        "<span class='iface-val' data-sort='" + wrEscape(iface) + "'>" + wrEscape(iface || '--') + "</span></td>" +
        wrBandHtml(sta, c) +
        "<td>" + wrFormatConnection(connected) + "</td>" +
        "</tr>";
}

function wrApplyRssiCounts(items) {
    var counts = { excellent: 0, good: 0, fair: 0, poor: 0 };
    items.forEach(function(item) {
        var sta = item.sta;
        var rssi = sta && sta.sta_rssi !== undefined ? wrNumber(sta.sta_rssi) : wrNumber(item.client.rssi);
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
    var best = null;

    if (map) {
        candidates.forEach(function(candidate) {
            var found = map.get(candidate);
            if (found && (!best || Number(found.data_time) > Number(best.data_time))) best = found;
        });
    }
    if (best) return best;

    // ASUS get_diag_latest_content_data.cgi returns only one/latest matching
    // stainfo row for a broad node_mac query on the tested GT-BE98 Pro.
    // Therefore the batch map is only a fast-path hint, not a complete station
    // inventory. Fall back to the proven per-client node_mac + sta_mac query
    // for BOTH primary-router and AiMesh-node clients when the batch map misses.
    for (var i = 0; i < candidates.length; i++) {
        var found = await wrGetSta(nodeMac, candidates[i]);
        if (found && (!best || Number(found.data_time) > Number(best.data_time))) best = found;
    }
    return best;
}

async function loadWirelessReport() {
    // Primary CPU usage is derived from two clean cpu_usage() counter samples.
    // Start the first sample alongside the larger client-inventory request so
    // the normal page load provides a useful interval without slowing refreshes.
    var mainHealthFirstPromise = wrGetMainHealthSample().catch(function(e) {
        console.warn('Primary CPU/memory first sample failed', e);
        return { cpu: {}, memory: {} };
    });

    var base = await wrAppGet(
        'get_cfg_clientlist();' +
        'get_clientlist();' +
        'get_clientlist_from_json_database();' +
        'nvram_get(productid);' +
        'nvram_get(lan_hwaddr);' +
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
        var savedClient = wrSavedClient(saved, macRaw, mac);
        items.push({
            mac: mac,
            client: c,
            saved: savedClient,
            node: nodeInfo ? nodeInfo.node : null,
            nodeIndex: nodeInfo ? nodeInfo.index : -1,
            nodeMac: nodeInfo ? parent : mainMac
        });
    });

    // Keep per-client stainfo fallback sequential. The diagnostic endpoint may
    // return only one/latest row for a broad node query, so every client missing
    // from the batch fast-path is resolved individually without flooding the CGI.
    for (var itemIndex = 0; itemIndex < items.length; itemIndex++) {
        items[itemIndex].sta = await wrResolveSta(items[itemIndex], staMaps);
    }

    // Match v2.1.0's report-wide sample time so the Main, Node and All views show
    // the same timestamp for a given refresh and the persisted sample matches it.
    var historySampleTime = Date.now();
    items.forEach(function(item) { item.historyTime = historySampleTime; });

    var mainItems = items.filter(function(item) { return !item.node; });
    var nodeItems = items.filter(function(item) { return !!item.node; });

    var diagPairs = await Promise.all(nodes.map(async function(node) {
        var mac = wrNormMac(node.mac || node.mac_addr);
        try { return [mac, await wrGetNodeDiag(mac)]; }
        catch (e) { console.warn('Node diagnostic query failed for ' + mac, e); return [mac, null]; }
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
        var rssi = item.sta && item.sta.sta_rssi !== undefined ? wrNumber(item.sta.sta_rssi) : wrNumber(item.client.rssi);
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

    var mainHealthFirst = await mainHealthFirstPromise;
    var mainHealth;
    try {
        mainHealth = await wrGetMainHealth(mainHealthFirst);
    } catch (e) {
        console.warn('Primary CPU/memory query failed', e);
        mainHealth = { cpuUsage: null, memoryUsage: wrMemoryUsage(mainHealthFirst.memory) };
    }
    wrSetMetric('wr-main-cpu', mainHealth.cpuUsage, '%');
    wrSetMetric('wr-all-main-cpu', mainHealth.cpuUsage, '%');
    wrSetMetric('wr-main-memory', mainHealth.memoryUsage, '%');
    wrSetMetric('wr-all-main-memory', mainHealth.memoryUsage, '%');

    var uptimeSecs = wrParseUptime(base.uptime);
    wrSetText('wr-main-uptime', wrFormatRouterUptime(uptimeSecs));
    wrSetText('wr-main-reboot', Number.isFinite(uptimeSecs) ? wrFormatDateTime(new Date(Date.now() - uptimeSecs * 1000)) : '--');

    var mainNameEl = document.getElementById('wr-main-name');
    if (mainNameEl && !mainNameEl.textContent.trim()) mainNameEl.textContent = base.productid || 'Main Router';

    var nodeNamesHtml = [];
    var cpuHtml = [];
    var memHtml = [];
    var nodeCountParts = [];
    var nodeDiagParts = [];

    nodes.forEach(function(node, index) {
        var mac = wrNormMac(node.mac || node.mac_addr);
        var ip = String(wrFirst(node, ['ip', 'ip_addr', 'ipAddr']) || '');
        var name = wrNodeDisplayName(node);
        var color = wrNodeColor(index);
        var marker = nodes.length > 1 ? '<sup>' + (index + 1) + '</sup>' : '';
        var diag = diagByMac.get(mac);
        var nodeClientCount = nodeItems.filter(function(item) { return item.nodeIndex === index; }).length;

        nodeNamesHtml.push("<span style='color:" + color + ";'>" + wrEscape(name) + marker + "</span>");
        nodeCountParts.push("<span style='color:" + color + ";'>" + nodeClientCount + marker + "</span>");

        if (diag && diag.cpuUsage !== null) {
            cpuHtml.push("<span class='" + wrMetricClass(diag.cpuUsage) + "'>" + diag.cpuUsage + "%" + marker + "</span>");
        } else {
            cpuHtml.push("<span style='color:" + color + ";'>--" + marker + "</span>");
        }
        if (diag && diag.memoryUsage !== null) {
            memHtml.push("<span class='" + wrMetricClass(diag.memoryUsage) + "'>" + diag.memoryUsage + "%" + marker + "</span>");
        } else {
            memHtml.push("<span style='color:" + color + ";'>--" + marker + "</span>");
        }

        var model = wrFirst(node, ['model_name', 'product_id']) || '';
        var firmware = wrFirst(node, ['firmware', 'fwver', 'fw_version', 'version']);
        var details = "<span style='color:" + color + ";'>" + wrEscape(name) + "</span>";
        if (model) details += ' ' + wrEscape(model);
        if (ip) details += ' • ' + wrEscape(ip);
        if (firmware) details += ' • FW ' + wrEscape(firmware);
        if (diag && Number.isFinite(diag.timestamp)) details += ' • Telemetry ' + wrFormatDateTime(new Date(diag.timestamp * 1000));
        nodeDiagParts.push(details);
    });

    var bullet = " <span style='color:white;'>•</span> ";
    wrSetHtml('wr-node-names', nodeNamesHtml.length ? nodeNamesHtml.join(bullet) : 'No AiMesh nodes detected');
    wrSetHtml('wr-node-cpu', cpuHtml.length ? cpuHtml.join(bullet) : '--');
    wrSetHtml('wr-node-memory', memHtml.length ? memHtml.join(bullet) : '--');
    wrSetHtml('wr-node-count', nodes.length > 1 && nodeCountParts.length ? nodeItems.length + " <span class='right-arrow'>—›</span> " + nodeCountParts.join(bullet) : nodeItems.length);
    wrSetHtml('wr-node-diag', nodeDiagParts.length ? nodeDiagParts.join('<br>') : 'No node diagnostic telemetry available.');

    var allNames = ["<span style='color:" + WR_CONFIG.mainColor + ";'>" + wrEscape(document.getElementById('wr-main-name').textContent) + "</span>"];
    allNames = allNames.concat(nodeNamesHtml);
    wrSetHtml('wr-all-names', allNames.join(bullet));

    var nodeCol = document.getElementById('nodeCol');
    if (nodeCol) nodeCol.style.display = nodes.length ? 'flex' : 'none';

    document.querySelectorAll('.wr-updated-time').forEach(function(el) { el.textContent = 'Updated: ' + wrFormatDateTime(new Date()); });
    wrRestoreTableState();

    if (localStorage.getItem('wifiReportPopoutOpen') === 'true') {
        openPopout();
        wrRestoreTableState();
    }
}

async function initial() {
    show_menu();
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
    } catch (e) {
        console.error('Wireless Report refresh failed', e);
        document.querySelectorAll('.wr-updated-time').forEach(function(el) { el.textContent = 'Unable to read controller APIs. Verify the primary WebUI session and reload.'; });
    } finally {
        var ended = (window.performance && performance.now) ? performance.now() : Date.now();
        var seconds = Math.max(0, (ended - started) / 1000);
        if (btn) {
            btn.classList.remove('refresh-pulse');
            if (WR_CONFIG.runtimeTracking) {
                var stats = wrLoadJson('wirelessReportRuntimeStats', { total: 0, count: 0, min: null, max: 0 });
                stats.total += seconds;
                stats.count += 1;
                stats.min = stats.min === null ? seconds : Math.min(stats.min, seconds);
                stats.max = Math.max(stats.max, seconds);
                localStorage.setItem('wirelessReportRuntimeStats', JSON.stringify(stats));
                var avg = stats.total / stats.count;
                btn.innerHTML = 'Refresh <span>' + seconds.toFixed(2) + 's</span>';
                btn.title = 'Browser API refresh • Avg ' + avg.toFixed(2) + 's • Low ' + stats.min.toFixed(2) + 's • High ' + stats.max.toFixed(2) + 's';
            } else {
                btn.innerText = 'Refresh';
                btn.removeAttribute('title');
            }
        }
        isRefreshing = false;
    }
}

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

    /* Starting Wide View at the top makes the transition predictable.  Leaving
       it restores the ordinary ASUS page without navigating or reloading. */
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
        let h = c.querySelector('.temp_load_row'), s = c.querySelector('.section-header'), r = c.querySelector('.separator-line');
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
    Object.assign(mCol.style, { maxWidth: "100%", width: "100%" });
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
                                Refresh <span>${RUNTIME}</span>
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
                            <button id="btnMain" class="button-tables active" onclick="switchTab('split')" style="$ROUTER_ONLY">Main</button>
                            <button id="btnAll" class="button-tables" onclick="switchTab('all')" style="$ROUTER_ONLY">All Devices</button>
                            <button class="button-tables" onclick="openPopout()" style="$ROUTER_ONLY">Side by Side ⇗</button>
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
                                    <div class="temp_load_row">
                                        <span>CPU: $MAIN_TEMP</span>
                                        <span>Memory: $MAIN_LOAD</span>
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
                                        <th onclick="sortTable(6, 'mainTable')">CONNECTED</th>
                                    </tr></thead>
                                    <tbody>$MAIN_ROWS</tbody>
                                    <tfoot>
                                        <tr>
                                            <td colspan="7">
                                                <span>Uptime: $MAIN_UPTIME</span>
                                                <span>Reboot: $MAIN_BOOTTIME</span>
                                            </td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                            <div class="rssi-quality-bar">
                                $RSSI_BOXES
                            </div>
                            <div id="nodeCol" class="report-column" style="$ROUTER_ONLY">
                                <div class="section-header">
                                    $NODE_NAMES<br>
                                    $UPDATED_TIME
                                    <hr class="separator-line">
                                    <div class="temp_load_row">
                                        <span>CPU: $NODE_TEMPS</span>
                                        <span>Memory: $NODE_LOADS</span>
                                        <span>Devices: $NODE_DEVICE_TOTAL $NTOTAL</span>
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
                                        <th onclick="sortTable(6, 'nodeTable')">CONNECTED</th>
                                    </tr></thead>
                                    <tbody>$NODE_ROWS</tbody>
                                    <tfoot>
                                        <tr>
                                            <td colspan="7">
                                                $NODE_UPTIMES
                                            </td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                        </div>
                        <div id="allCol" class="report-column" style="$ROUTER_ONLY">
                            <div class="section-header">
                                $ALL_NAMES<br>
                                $UPDATED_TIME
                                <hr class="separator-line">
                                <div class="temp_load_row" style="$TEMP_STYLE">
                                    <span>Main CPU: $ALL_TEMP</span>
                                    <span>Main Memory: $ALL_LOAD</span>
                                    <span>$ALL_DEVICES</span>
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
                                    <th onclick="sortTable(6, 'allTable')">CONNECTED</th>
                                </tr></thead>
                                <tbody>$ALL_ROWS</tbody>
                                <tfoot>
                                    <tr>
                                        <td colspan="7" style="$UPTIME_STYLE">
                                            $ALL_UPTIME
                                        </td>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>
                        <div id="allDevicesQualityBar" class="rssi-quality-bar" style="$ROUTER_ONLY">
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
}
case "$1" in
    install)
        # Install/Uninstall options
        startup
        install_menu
        ;;
    install-apply)
        # Internal second stage used after an update/reinstall.  Do not reopen
        # the menu; finish persistence and WebUI injection immediately.
        startup
        # install-apply bypasses show_header(), so initialize the menu/install
        # variables explicitly (including services-start/service-event paths).
        menu_vars
        REMOTE_VERSION="$SCRIPT_VERSION"
        do_install --apply
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
		startup
		run_report
        ;;
esac