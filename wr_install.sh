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

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# --- (3) Check/Update Logic ---
check_version() {
    local GITHUB_URL="$GITHUB_ROOT/gen_report.sh"
    if [ -f "$REPORT_SCRIPT" ]; then
        LOCAL_VER=$(grep "SCRIPT_VERSION=" "$REPORT_SCRIPT" | head -n 1 | cut -d'"' -f2)
    else
        LOCAL_VER="NOT INSTALLED"
    fi
    REMOTE_VER=$(curl -s --connect-timeout 2 "$GITHUB_URL" | grep "SCRIPT_VERSION=" | head -n 1 | cut -d'"' -f2)

    echo -e "${CYAN}==================================================${NC}"
    echo -e "${CYAN}                WIRELESS REPORT                   ${NC}"
    if [ -z "$REMOTE_VER" ]; then
        echo -e " STATUS: [Offline] Could not reach GitHub"
    elif [ "$LOCAL_VER" = "NOT INSTALLED" ]; then
        echo -e " STATUS: [Ready] Latest available is v$REMOTE_VER"
    elif [ "$LOCAL_VER" != "$REMOTE_VER" ]; then
        echo -e " STATUS: ${RED}[UPDATE AVAILABLE] v$REMOTE_VER${NC} (Current: v$LOCAL_VER)"
    else
        echo -e " STATUS: [Up to date] v$LOCAL_VER"
    fi
    echo -e "${CYAN}==================================================${NC}"
}

show_menu() {
    clear
    check_version
    echo -e ""
    echo -e "  (1)  Install Wireless Report"
    echo -e "  (2)  Uninstall Wireless Report"
    echo -e "  (3)  Check/Update Latest Script"
    echo -e "  (e)  Exit"
    echo -e ""
    echo -e "${CYAN}==================================================${NC}"
    printf " Selection: "
}

# --- Restored: SSH Environment Check ---
check_ssh_environment() {
    echo -e "${CYAN}[*] Verifying Passwordless SSH Environment...${NC}"
    if [ ! -f "$SSH_KEY" ]; then
        echo -e "${RED}[!] ERROR: Local SSH Key not found at $SSH_KEY${NC}"
        exit 1
    fi
    ROUTER_IP=$(nvram get lan_ipaddr)
    NODE_IPS=$(nvram get cfg_device_list | sed 's/</\n/g' | awk -F '>' '{ if ($2 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ && $4 == 0 && $2 != "'"$ROUTER_IP"'") print $2 }')
    NODE_USER=$(nvram get http_username)
    if [ -z "$NODE_IPS" ]; then
        echo -e "${GREEN}[+] No Mesh Nodes detected. Proceeding...${NC}"
        return 0
    fi
    for IP in $NODE_IPS; do
        echo -ne "[*] Testing Passwordless SSH to Node ($IP)... "
        /usr/bin/ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=3 -o BatchMode=yes "${NODE_USER}@${IP}" "exit" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}AUTHENTICATED${NC}"
        else
            echo -e "${RED}FAILED${NC}"; exit 1
        fi
    done
}

do_install() {
    if [ "$(nvram get jffs2_scripts)" != "1" ]; then
        echo -e "${RED}[!] ERROR: JFFS custom scripts are not enabled.${NC}"
        exit 1
    fi

    # Run your custom SSH check
    check_ssh_environment

    echo -e "${CYAN}[*] Installing Wireless Report v1.0.1...${NC}"
    mkdir -p "$INSTALL_DIR"

    if curl -s --connect-timeout 5 "$GITHUB_ROOT/gen_report.sh" -o "$REPORT_SCRIPT"; then
        chmod +x "$REPORT_SCRIPT"
        
        # --- THE FIX: WEB PAGE MOUNTING ---
        # We must 'touch' the file in /tmp and bind mount it to /www/wireless.asp 
        # This solves the "Read-only file system" error. 
        touch /tmp/wireless.asp
        mount --bind /tmp/wireless.asp /www/wireless.asp 2>/dev/null

        # --- Restored: Robust Menu Injection ---
        if [ ! -f /tmp/menuTree.js ]; then
            cp /www/require/modules/menuTree.js /tmp/menuTree.js
            mount -o bind /tmp/menuTree.js /www/require/modules/menuTree.js
        fi
        sed -i "/wireless.asp/d" /tmp/menuTree.js
        sed -i '/url: "Advanced_System_Info.asp"/a {url: "wireless.asp", tabName: "Wireless Report"},' /tmp/menuTree.js
        
        # Persistence
        [ ! -f "/jffs/scripts/services-start" ] && echo "#!/bin/sh" > /jffs/scripts/services-start
        sed -i "\|$MENU_SCRIPT|d" /jffs/scripts/services-start
        echo "sh $MENU_SCRIPT" >> /jffs/scripts/services-start
        chmod +x /jffs/scripts/services-start

        # Generate data
        sh "$REPORT_SCRIPT"

        echo -e "\n${GREEN}SUCCESS: Wireless Report is installed and integrated!${NC}"
    else
        echo -e "${RED}[!] ERROR: Download failed.${NC}"
    fi
}

do_uninstall() {
    echo -e "\n${RED}[!] WARNING: This will remove all Wireless Report files.${NC}"
    printf " Are you sure? (y/n): "
    read confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        sed -i "\|$MENU_SCRIPT|d" /jffs/scripts/services-start
        
        # Cleanup mounts including your menuTree
        umount /www/wireless.asp 2>/dev/null
        umount /www/require/modules/menuTree.js 2>/dev/null
        rm -f /tmp/menuTree.js

        rm -rf "$INSTALL_DIR"
        rm -f /tmp/wireless.asp
        echo -e "${GREEN}[+] Uninstalled successfully.${NC}"
    fi
    pause
}

pause() { printf "\nPress [Enter] to return to menu..."; read discard; }

while true; do
    show_menu
    read choice
    case "$choice" in
        1|3) do_install ;;
        2) do_uninstall ;;
        e|E) clear; exit 0 ;;
        *) echo -e "${RED}Invalid selection.${NC}"; sleep 1 ;;
    esac
done