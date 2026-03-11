#!/bin/sh
#============================================================================#
#  Wireless Report Installer                                                 #
#  Version: 1.0.1                                                            #
#  Author: JB_1366                                                           #
#============================================================================#

# --- Configuration ---
GITHUB_ROOT="https://raw.githubusercontent.com/JB1366/Wireless_Report/main"
INSTALL_DIR="/jffs/addons/wireless_report"
REPORT_SCRIPT="$INSTALL_DIR/gen_report.sh"
MENU_SCRIPT="$INSTALL_DIR/install_menu.sh"
SSH_KEY="/tmp/home/root/.ssh/id_dropbear"
CONF_FILE="$INSTALL_DIR/webui.conf"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

check_version() {
    local GITHUB_URL="$GITHUB_ROOT/gen_report.sh"
    if [ -f "$REPORT_SCRIPT" ]; then
        LOCAL_VER=$(grep "SCRIPT_VERSION=" "$REPORT_SCRIPT" | head -n 1 | cut -d'"' -f2 2>/dev/null)
    else
        LOCAL_VER="NOT INSTALLED"
    fi
    REMOTE_DATA=$(curl -s --connect-timeout 2 "$GITHUB_URL")
    if [ $? -ne 0 ] || [ -z "$REMOTE_DATA" ]; then
        REMOTE_VER=""
    else
        REMOTE_VER=$(echo "$REMOTE_DATA" | grep "SCRIPT_VERSION=" | head -n 1 | cut -d'"' -f2 2>/dev/null)
    fi
    echo -e "${CYAN}==================================================${NC}"
    echo -e "${CYAN}                WIRELESS REPORT                   ${NC}"
    echo -e "${CYAN}==================================================${NC}"
    if [ -z "$REMOTE_VER" ]; then
        echo -e " STATUS: ${RED}[Offline]${NC} Could not reach GitHub"
    elif [ "$LOCAL_VER" = "NOT INSTALLED" ]; then
        echo -e " STATUS: [Ready] Latest available is v$REMOTE_VER"
    elif [ "$LOCAL_VER" != "$REMOTE_VER" ]; then
        echo -e " STATUS: ${RED}[UPDATE AVAILABLE] v$REMOTE_VER${NC} (Current: v$LOCAL_VER)"
    else
        echo -e " STATUS: [Up to date] v$LOCAL_VER"
    fi
    echo -e "${CYAN}==================================================${NC}"
}

check_storage() {
    echo -e "${CYAN}[*] Checking for USB Storage...${NC}"
    USB_PATH=$(mount | grep -E "ext2|ext3|ext4|tfat|ntfs|vfat" | grep -v "/jffs" | awk '{print $3}' | head -n 1)
    if [ -n "$USB_PATH" ]; then
        DATA_DIR="$USB_PATH/gen_report"
        echo -e "${GREEN}[+] USB Found: Using $DATA_DIR for history.${NC}"
    else
        DATA_DIR="$INSTALL_DIR/data"
        echo -e "${RED}[!] No USB detected: Using JFFS at $DATA_DIR.${NC}"
    fi
    mkdir -p "$DATA_DIR" 2>/dev/null
}

show_menu() {
    echo -e ""
    echo -e "  (1)  Install Wireless Report"
    echo -e "  (2)  Uninstall Wireless Report"
    echo -e "  (3)  Check/Update Latest Script"
    echo -e "  (e)  Exit"
    echo -e ""
    echo -e "${CYAN}==================================================${NC}"
    printf " Selection: "
}

check_ssh_environment() {
    echo -e "${CYAN}[*] Verifying Passwordless SSH Environment...${NC}"
    
    if [ ! -f "$SSH_KEY" ]; then
        echo -e "${RED}[!] ERROR: Local SSH Key not found at $SSH_KEY${NC}"
        echo -e "${RED}[!] Please setup passwordless SSH Keys on your nodes and try again.${NC}"
        exit 1
    fi

    ROUTER_IP=$(nvram get lan_ipaddr)
    NODE_IPS=$(nvram get cfg_device_list | sed 's/</\n/g' | awk -F '>' '{print $2}' | grep -E '^[0-9.]+$' | grep -v "$ROUTER_IP")
    NODE_USER=$(nvram get http_username)
    
    if [ -z "$NODE_IPS" ]; then
        echo -e "${RED}[!] No AIMesh Nodes detected. This script requires a AIMesh environment.${NC}"
        echo -e "${RED}[!] Installation aborted.${NC}"
        exit 1
    fi

    for IP in $NODE_IPS; do
        echo -ne "[*] Testing Passwordless SSH to Node ($IP)... "
        /usr/bin/ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=3 -o BatchMode=yes "${NODE_USER}@${IP}" "exit" >/dev/null 2>&1
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}AUTHENTICATED${NC}"
        else
            echo -e "${RED}FAILED${NC}"
            echo -e "${RED}[!] Please setup passwordless SSH Keys on your nodes and try again.${NC}"
            exit 1
        fi
    done
}

do_install() {
    if [ "$(nvram get jffs2_scripts)" != "1" ]; then
        echo -e "${RED}[!] ERROR: JFFS custom scripts are not enabled.${NC}"
        exit 1
    fi

    check_storage
    check_ssh_environment
    echo -e "${CYAN}[*] Processing Wireless Report Files...${NC}"
    mkdir -p "$INSTALL_DIR" 2>/dev/null

    # Pre-cleanup to prevent double tabs
    [ -f "/tmp/menuTree.js" ] && sed -i '/Wireless Report/d' /tmp/menuTree.js 2>/dev/null

    curl -s --connect-timeout 5 "$GITHUB_ROOT/gen_report.sh" -o "$REPORT_SCRIPT"
    curl -s --connect-timeout 5 "$GITHUB_ROOT/install_menu.sh" -o "$MENU_SCRIPT"
    chmod +x "$REPORT_SCRIPT" "$MENU_SCRIPT" 2>/dev/null

    if [ -f "$MENU_SCRIPT" ]; then
        echo -e "${CYAN}[*] Mounting Wireless Report TAB to Wireless menu...${NC}"
        sh "$MENU_SCRIPT" >/dev/null 2>&1
        
        [ ! -f "/jffs/scripts/services-start" ] && echo "#!/bin/sh" > /jffs/scripts/services-start
        sed -i "\|$MENU_SCRIPT|d" /jffs/scripts/services-start
        [ -n "$(tail -c 1 /jffs/scripts/services-start 2>/dev/null)" ] && echo "" >> /jffs/scripts/services-start
        echo "sh $MENU_SCRIPT # Inject Wireless Report" >> /jffs/scripts/services-start
        chmod +x /jffs/scripts/services-start 2>/dev/null
        
        [ ! -f "/jffs/scripts/service-event" ] && echo "#!/bin/sh" > /jffs/scripts/service-event
        sed -i "/wireless_report/d" /jffs/scripts/service-event
        [ -n "$(tail -c 1 /jffs/scripts/service-event 2>/dev/null)" ] && echo "" >> /jffs/scripts/service-event
        echo "if [ \"\$1\" = \"restart\" ] && [ \"\$2\" = \"wireless_report\" ]; then sh $REPORT_SCRIPT; fi # Wireless Report" >> /jffs/scripts/service-event
        chmod +x /jffs/scripts/service-event
        
        [ -f "$INSTALL_DIR/wireless.asp" ] && rm -f "$INSTALL_DIR/wireless.asp" 2>/dev/null
        
        service restart_httpd >/dev/null 2>&1 || killall -HUP httpd >/dev/null 2>&1
        sh "$REPORT_SCRIPT" >/dev/null 2>&1 &
        
        echo -e "\n${GREEN}SUCCESS: Installation complete!${NC}"
    else
        echo -e "${RED}[!] ERROR: Download failed.${NC}"
    fi
    pause
}

do_update() {
    if [ ! -f "$REPORT_SCRIPT" ]; then
        echo -e "${RED}[!] Wireless Report is not installed.${NC}"
        printf " Would you like to install it now? (y/n): "
        read choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            do_install
        fi
    else
        # Compare versions
        LOCAL_VER=$(grep "SCRIPT_VERSION=" "$REPORT_SCRIPT" | head -n 1 | cut -d'"' -f2 2>/dev/null)
        REMOTE_DATA=$(curl -s --connect-timeout 2 "$GITHUB_ROOT/gen_report.sh")
        REMOTE_VER=$(echo "$REMOTE_DATA" | grep "SCRIPT_VERSION=" | head -n 1 | cut -d'"' -f2 2>/dev/null)
        
        if [ "$LOCAL_VER" = "$REMOTE_VER" ]; then
            echo -e "${GREEN}[+] You are already on the latest version (v$LOCAL_VER).${NC}"
            printf " Force a re-install anyway? (y/n): "
            read choice
            if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
                do_install
            fi
        else
            echo -e "${CYAN}[*] Update found: v$LOCAL_VER -> v$REMOTE_VER${NC}"
            do_install
        fi
    fi
}

do_uninstall() {
    echo -e "\n${RED}[!] WARNING: Removing Wireless Report...${NC}"
    printf " Are you sure? (y/n): "
    read confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        [ -f "$CONF_FILE" ] && . "$CONF_FILE"

        # 1. Surgical Strike: Remove only our tab from the temp menu
        if [ -f "/tmp/menuTree.js" ]; then
            echo -e "${CYAN}[*] Removing tab from menu system...${NC}"
            sed -i '/tabName: "Wireless Report"/d' /tmp/menuTree.js
        fi

        # 2. Unmount only the specific ASP page, NOT the whole menu
        [ -n "$INSTALLED_PAGE" ] && umount -l "/www/user/$INSTALLED_PAGE" >/dev/null 2>&1

        # 3. Standard Cleanup
        service restart_httpd >/dev/null 2>&1 || killall -HUP httpd >/dev/null 2>&1
        
        sed -i "\|$MENU_SCRIPT|d" /jffs/scripts/services-start
        sed -i "/wireless_report/d" /jffs/scripts/service-event

        killall gen_report.sh >/dev/null 2>&1
        rm -rf "$INSTALL_DIR" 2>/dev/null
        rm -f /tmp/wireless.asp 2>/dev/null
        # Note: We leave /tmp/menuTree.js mounted so other addons stay visible
        
        echo -e "${GREEN}[+] Uninstalled. Wireless Report removed, other addons preserved.${NC}"
    fi
    pause
}

pause() { printf "\nPress [Enter] to return..."; read discard; }

while true; do
    clear; check_version; show_menu; read choice
    case "$choice" in
        1) do_install ;;
        2) do_uninstall ;;
        3) do_update ;;
        e|E) clear; exit 0 ;;
        *) echo -e "${RED}Invalid selection.${NC}"; sleep 1 ;;
    esac
done