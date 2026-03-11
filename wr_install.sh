#!/bin/sh
#============================================================================#
#  Wireless Report Installer - Version 1.0.3                                 #
#  Author: JB_1366                                                           #
#============================================================================#

# --- Configuration ---
GITHUB_ROOT="https://raw.githubusercontent.com/JB1366/Wireless_Report/main"
INSTALL_DIR="/jffs/addons/wireless_report"
REPORT_SCRIPT="$INSTALL_DIR/gen_report.sh"
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

check_ssh_environment() {
    echo -e "${CYAN}[*] Verifying Passwordless SSH Environment...${NC}"
    if [ ! -f "$SSH_KEY" ]; then
        echo -e "${RED}[!] ERROR: Local SSH Key not found at $SSH_KEY${NC}"
        pause && return 1
    fi
    ROUTER_IP=$(nvram get lan_ipaddr)
    NODE_IPS=$(nvram get cfg_device_list | sed 's/</\n/g' | awk -F '>' '{print $2}' | grep -E '^[0-9.]+$' | grep -v "$ROUTER_IP")
    NODE_USER=$(nvram get http_username)
    
    if [ -z "$NODE_IPS" ]; then
        echo -e "${GREEN}[+] No AIMesh Nodes detected. Single Router Mode.${NC}"
        return 0
    fi

    for IP in $NODE_IPS; do
        echo -ne "[*] Testing SSH to Node ($IP)... "
        /usr/bin/ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no -o ConnectTimeout=3 -o BatchMode=yes "${NODE_USER}@${IP}" "exit" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}OK${NC}"
        else
            echo -e "${RED}FAIL${NC}"
            echo -e "${YELLOW}[!] Ensure SSH is enabled and keys are exchanged with Node $IP${NC}"
            pause && return 1
        fi
    done
}

check_storage() {
    echo -e "${CYAN}[*] Checking for USB Storage...${NC}"
    USB_PATH=$(mount | grep -E "ext2|ext3|ext4|tfat|ntfs|vfat" | grep -v "/jffs" | awk '{print $3}' | head -n 1)
    if [ -n "$USB_PATH" ]; then
        DATA_DIR="$USB_PATH/gen_report"
        echo -e "${GREEN}[+] USB Found: Using $DATA_DIR for history.${NC}"
    else
        DATA_DIR="$INSTALL_DIR/data"
        echo -e "${YELLOW}[!] No USB detected: Using JFFS storage.${NC}"
    fi
    mkdir -p "$DATA_DIR" 2>/dev/null
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
}

do_install() {
    # 1. Environment Gatekeepers
    check_ssh_environment || return
    check_storage

    # 2. Overwrite Check
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "\n${YELLOW}[!] Wireless Report is ALREADY installed.${NC}"
        printf " Do you want to reinstall/overwrite? (y/n): "
        read -r confirm
        if [[ ! "$confirm" =~ ^[yY]$ ]]; then
            return
        fi
        do_uninstall_silent
    fi

    echo -e "\n${CYAN}[*] Downloading Latest Files from GitHub...${NC}"
    mkdir -p "$INSTALL_DIR"
    curl -sL "$GITHUB_ROOT/gen_report.sh" -o "$INSTALL_DIR/gen_report.sh"
    curl -sL "$GITHUB_ROOT/wireless_report.asp" -o "$INSTALL_DIR/wireless_report.asp"
    
    if [ ! -s "$INSTALL_DIR/gen_report.sh" ]; then
        echo -e "${RED}[!] ERROR: Download failed. Check internet.${NC}"
        rm -rf "$INSTALL_DIR"
        pause && return
    fi
    chmod +x "$REPORT_SCRIPT"

    # 3. Startup Configuration
    if [ -f "/jffs/scripts/services-start" ]; then
        grep -q "$REPORT_SCRIPT" /jffs/scripts/services-start || echo "sh $REPORT_SCRIPT &" >> /jffs/scripts/services-start
    else
        echo -e "#!/bin/sh\nsh $REPORT_SCRIPT &" > /jffs/scripts/services-start
        chmod +x /jffs/scripts/services-start
    fi

    # 4. Web UI Injection
    echo -e "${CYAN}[*] Injecting Wireless Report into Web UI...${NC}"
    curl -sL "$GITHUB_ROOT/install_menu.sh" | sh

    # 5. Start Service
    sh "$REPORT_SCRIPT" &
    service restart_httpd >/dev/null 2>&1 || killall -HUP httpd >/dev/null 2>&1

    echo -e "${GREEN}[+] Installation completed successfully!${NC}"
    pause
}

do_uninstall() {
    if [ ! -d "$INSTALL_DIR" ]; then
        echo -e "\n${RED}[!] Wireless Report is not installed.${NC}"
        pause && return
    fi
    echo -e "\n${RED}[!] WARNING: Removing Wireless Report...${NC}"
    printf " Are you sure? (y/n): "
    read -r confirm
    if [[ "$confirm" =~ ^[yY]$ ]]; then
        do_uninstall_silent
        service restart_httpd >/dev/null 2>&1
        echo -e "${GREEN}[+] Uninstalled successfully.${NC}"
    fi
    pause
}

pause() { printf "\nPress [Enter] to return..."; read -r discard; }

while true; do
    clear; check_version
    echo -e "  (1)  Install Wireless Report\n  (2)  Uninstall Wireless Report\n  (3)  Check/Update Script\n  (e)  Exit"
    echo -e "${CYAN}==================================================${NC}"
    printf " Selection: "
    read -r choice
    case "$choice" in
        1) do_install ;;
        2) do_uninstall ;;
        3) do_install ;; # Update is effectively a clean re-install
        e|E) clear; exit 0 ;;
        *) echo -e "${RED}Invalid selection.${NC}"; sleep 1 ;;
    esac
done