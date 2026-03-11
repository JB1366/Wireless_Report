#!/bin/sh
#============================================================================#
#  Wireless Report Installer                                                 #
#  Version: 1.0.2                                                            #
#  Author: JB_1366                                                           #
#============================================================================#

# --- Configuration ---
GITHUB_ROOT="https://raw.githubusercontent.com/JB1366/Wireless_Report/main"
INSTALL_DIR="/jffs/addons/wireless_report"
# Fix: SCRIPT_DIR must be defined for mkdir to work
SCRIPT_DIR="/jffs/addons/wireless_report" 
REPORT_SCRIPT="$INSTALL_DIR/gen_report.sh"
MENU_SCRIPT="$INSTALL_DIR/install_menu.sh"
SSH_KEY="/tmp/home/root/.ssh/id_dropbear"
CONF_FILE="$INSTALL_DIR/webui.conf"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
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
        echo -e "${RED}[!] No AIMesh Nodes detected.${NC}"
        exit 1
    fi
    for IP in $NODE_IPS; do
        echo -ne "[*] Testing SSH to Node ($IP)... "
        /usr/bin/ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=3 -o BatchMode=yes "${NODE_USER}@${IP}" "exit" >/dev/null 2>&1
        [ $? -eq 0 ] && echo -e "${GREEN}OK${NC}" || { echo -e "${RED}FAIL${NC}"; exit 1; }
    done
}

do_uninstall_silent() {
    [ -f "$CONF_FILE" ] && . "$CONF_FILE"
    if mount | grep -q "menuTree.js"; then
        umount -l /www/require/modules/menuTree.js >/dev/null 2>&1
        sed -i '/tabName:[[:space:]]*"Wireless Report"/d' /tmp/menuTree.js
        if grep -q "tabName" /tmp/menuTree.js; then
            mount --bind /tmp/menuTree.js /www/require/modules/menuTree.js
        fi
    fi
    [ -n "$INSTALLED_PAGE" ] && umount -l "/www/user/$INSTALLED_PAGE" >/dev/null 2>&1
    sed -i "\|$REPORT_SCRIPT|d" /jffs/scripts/services-start
    killall gen_report.sh >/dev/null 2>&1
    rm -rf "$INSTALL_DIR" 2>/dev/null
    rm -f /tmp/wireless.asp 2>/dev/null
}

do_install() {
    # 1. THE CHECK: Does the directory exist?
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "\n${YELLOW}[!] Wireless Report is ALREADY installed.${NC}"
        printf " Do you want to reinstall/overwrite? (y/n): "
        read -r confirm
        
        # If user says anything other than y/Y, stop and go back to menu
        if [[ ! "$confirm" =~ ^[yY]$ ]]; then
            echo -e "${CYAN}[*] Returning to menu...${NC}"
            pause
            return
        fi

        # If they say yes, we wipe the old one to ensure a clean slate
        echo -e "${CYAN}[*] Cleaning existing installation...${NC}"
        do_uninstall_silent
    fi

    # 2. PROCEED WITH INSTALL (either fresh or after the wipe above)
    echo -e "\n${CYAN}[*] Downloading latest files from GitHub...${NC}"
    mkdir -p "$INSTALL_DIR"

    # Pull directly from GitHub to the target folder
    curl -sL "$GITHUB_ROOT/gen_report.sh" -o "$INSTALL_DIR/gen_report.sh"
    curl -sL "$GITHUB_ROOT/wireless_report.asp" -o "$INSTALL_DIR/wireless_report.asp"
    
    # Verify the download actually happened
    if [ ! -s "$INSTALL_DIR/gen_report.sh" ]; then
        echo -e "${RED}[!] ERROR: Download failed. Check your internet connection.${NC}"
        rm -rf "$INSTALL_DIR"
        pause
        return
    fi

    chmod +x "$REPORT_SCRIPT"

    # 3. CONFIGURE STARTUP
    if [ -f "/jffs/scripts/services-start" ]; then
        grep -q "$REPORT_SCRIPT" /jffs/scripts/services-start || echo "sh $REPORT_SCRIPT &" >> /jffs/scripts/services-start
    else
        echo -e "#!/bin/sh\nsh $REPORT_SCRIPT &" > /jffs/scripts/services-start
        chmod +x /jffs/scripts/services-start
    fi

    # 4. INJECT MENU TAB
    echo -e "${CYAN}[*] Injecting menu tab...${NC}"
    # Pulling the menu installer directly from GitHub and running it
    curl -sL "$GITHUB_ROOT/install_menu.sh" | sh

    # 5. REFRESH & START
    sh "$REPORT_SCRIPT" &
    service restart_httpd >/dev/null 2>&1 || killall -HUP httpd >/dev/null 2>&1

    echo -e "${GREEN}[+] Installation completed successfully!${NC}"
    pause
}

do_uninstall() {
    if [ ! -d "$INSTALL_DIR" ]; then
        echo -e "\n${RED}[!] Wireless Report is not installed.${NC}"
        pause; return
    fi
    echo -e "\n${RED}[!] WARNING: Removing Wireless Report...${NC}"
    printf " Are you sure? (y/n): "
    read -r confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        do_uninstall_silent
        service restart_httpd >/dev/null 2>&1 || killall -HUP httpd >/dev/null 2>&1
        echo -e "${GREEN}[+] Uninstalled.${NC}"
    fi
    pause
}

do_update() {
    # Check for update and run do_install if confirmed
    LOCAL_VER=$(grep "SCRIPT_VERSION=" "$REPORT_SCRIPT" | head -n 1 | cut -d'"' -f2 2>/dev/null)
    REMOTE_DATA=$(curl -s --connect-timeout 2 "$GITHUB_ROOT/gen_report.sh")
    REMOTE_VER=$(echo "$REMOTE_DATA" | grep "SCRIPT_VERSION=" | head -n 1 | cut -d'"' -f2 2>/dev/null)
    
    if [ "$LOCAL_VER" = "$REMOTE_VER" ]; then
        echo -e "${GREEN}[+] Up to date (v$LOCAL_VER).${NC}"
        printf " Reinstall anyway? (y/n): "
        read -r choice
        [ "$choice" = "y" ] || [ "$choice" = "Y" ] && do_install
    else
        do_install
    fi
}

pause() { printf "\nPress [Enter] to return..."; read -r discard; }
show_menu() {
    echo -e "  (1)  Install Wireless Report\n  (2)  Uninstall Wireless Report\n  (3)  Check/Update Script\n  (e)  Exit"
    echo -e "${CYAN}==================================================${NC}"
    printf " Selection: "
}

while true; do
    clear; check_version; show_menu; read -r choice
    case "$choice" in
        1) do_install ;;
        2) do_uninstall ;;
        3) do_update ;;
        e|E) clear; exit 0 ;;
        *) echo -e "${RED}Invalid selection.${NC}"; sleep 1 ;;
    esac
done