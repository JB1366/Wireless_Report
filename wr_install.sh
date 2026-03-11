#!/bin/sh
#============================================================================#
#  Wireless Report Installer                                                 #
#  Version: 1.2.5 (Silent Execution)                                         #
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
        LOCAL_VER=$(grep "SCRIPT_VERSION=" "$REPORT_SCRIPT" | head -n 1 | cut -d'"' -f2)
    else
        LOCAL_VER="NOT INSTALLED"
    fi
    REMOTE_DATA=$(curl -s --connect-timeout 2 "$GITHUB_URL")
    if [ $? -ne 0 ] || [ -z "$REMOTE_DATA" ]; then
        REMOTE_VER="" 
    else
        REMOTE_VER=$(echo "$REMOTE_DATA" | grep "SCRIPT_VERSION=" | head -n 1 | cut -d'"' -f2)
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
    # Silently check for USB path
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
        exit 1
    fi
    ROUTER_IP=$(nvram get lan_ipaddr)
    NODE_IPS=$(nvram get cfg_device_list | sed 's/</\n/g' | awk -F '>' '{print $2}' | grep -E '^[0-9.]+$' | grep -v "$ROUTER_IP")
    NODE_USER=$(nvram get http_username)
    if [ -z "$NODE_IPS" ]; then
        echo -e "${GREEN}[+] No Mesh Nodes detected. Proceeding...${NC}"
        return 0
    fi
    for IP in $NODE_IPS; do
        echo -ne "[*] Testing Passwordless SSH to Node ($IP)... "
        # Silence SSH test errors
        /usr/bin/ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=3 -o BatchMode=yes "${NODE_USER}@${IP}" "exit" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}AUTHENTICATED${NC}"
        else
            echo -e "${RED}FAILED${NC}"
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

    curl -s --connect-timeout 5 "$GITHUB_ROOT/gen_report.sh" -o "$REPORT_SCRIPT"
    curl -s --connect-timeout 5 "$GITHUB_ROOT/install_menu.sh" -o "$MENU_SCRIPT"
    chmod +x "$REPORT_SCRIPT" "$MENU_SCRIPT"

    if [ -f "$MENU_SCRIPT" ]; then
        # Silence the menu injection script output
        sh "$MENU_SCRIPT" >/dev/null 2>&1
        
        [ ! -f "/jffs/scripts/services-start" ] && echo "#!/bin/sh" > /jffs/scripts/services-start
        sed -i "\|$MENU_SCRIPT|d" /jffs/scripts/services-start
        [ -n "$(tail -c 1 /jffs/scripts/services-start 2>/dev/null)" ] && echo "" >> /jffs/scripts/services-start
        echo "sh $MENU_SCRIPT # Inject Wireless Report" >> /jffs/scripts/services-start
        chmod +x /jffs/scripts/services-start
        
        [ ! -f "/jffs/scripts/service-event" ] && echo "#!/bin/sh" > /jffs/scripts/service-event
        sed -i "/wireless_report/d" /jffs/scripts/service-event
        [ -n "$(tail -c 1 /jffs/scripts/service-event 2>/dev/null)" ] && echo "" >> /jffs/scripts/service-event
        echo "if [ \"\$1\" = \"restart\" ] && [ \"\$2\" = \"wireless_report\" ]; then sh $REPORT_SCRIPT; fi # Wireless Report" >> /jffs/scripts/service-event
        chmod +x /jffs/scripts/service-event
        
        # Cleanup: Delete wireless.asp from the installation directory
        [ -f "$INSTALL_DIR/wireless.asp" ] && rm "$INSTALL_DIR/wireless.asp" 2>/dev/null
        
        # Silence web server restart and background report generation
        service restart_httpd >/dev/null 2>&1 || killall -HUP httpd >/dev/null 2>&1
        sh "$REPORT_SCRIPT" >/dev/null 2>&1 &
        
        echo -e "\n${GREEN}SUCCESS: Installation complete!${NC}"
    else
        echo -e "${RED}[!] ERROR: Download failed.${NC}"
    fi
    pause 
}

do_uninstall() {
    echo -e "\n${RED}[!] WARNING: Removing Wireless Report...${NC}"
    printf " Are you sure? (y/n): "
    read confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        [ -f "$CONF_FILE" ] && . "$CONF_FILE"
        [ -f "/tmp/menuTree.js" ] && cp -f /www/require/modules/menuTree.js /tmp/menuTree.js >/dev/null 2>&1
        
        umount -l /www/require/modules/menuTree.js >/dev/null 2>&1
        [ -n "$INSTALLED_PAGE" ] && umount -l "/www/user/$INSTALLED_PAGE" >/dev/null 2>&1

        service restart_httpd >/dev/null 2>&1 || killall -HUP httpd >/dev/null 2>&1
        sleep 4
        
        sed -i "\|$MENU_SCRIPT|d" /jffs/scripts/services-start
        sed -i "/wireless_report/d" /jffs/scripts/service-event

        killall gen_report.sh >/dev/null 2>&1
        rm -rf "$INSTALL_DIR" 2>/dev/null
        rm -f /tmp/wireless.asp /tmp/menuTree.js 2>/dev/null
        
        echo -e "${GREEN}[+] Uninstalled. Factory menus restored.${NC}"
    fi
    pause
}

pause() { printf "\nPress [Enter] to return..."; read discard; }

while true; do
    clear; check_version; show_menu; read choice
    case "$choice" in
        1|3) do_install ;;   
        2) do_uninstall ;;
        e|E) clear; exit 0 ;;
        *) echo -e "${RED}Invalid selection.${NC}"; sleep 1 ;;
    esac
done