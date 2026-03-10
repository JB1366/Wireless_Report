#!/bin/sh
#============================================================================#
#  Wireless Report                                                           #
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

show_menu() {
    clear
    echo -e "${CYAN}==================================================${NC}"
    echo -e "${CYAN}         WIRELESS REPORT v1.0.1                   ${NC}"
    echo -e "${CYAN}==================================================${NC}"
    echo -e ""
    echo -e "  (1)  Install Wireless Report"
    echo -e "  (2)  Uninstall Wireless Report"
    echo -e "  (e)  Exit Installer"
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
            echo -e "${RED}FAILED${NC}"
            echo -e "${RED}[!] ERROR: Passwordless SSH failed for Node $IP.${NC}"
            exit 1
        fi
    done
}

do_install() {
    check_ssh_environment
    echo -e "\n${CYAN}[*] Initializing Installation...${NC}"
    [ ! -d "$INSTALL_DIR" ] && mkdir -p "$INSTALL_DIR"

    curl -s -L "$GITHUB_ROOT/gen_report.sh" -o "$REPORT_SCRIPT"
    curl -s -L "$GITHUB_ROOT/install_menu.sh" -o "$MENU_SCRIPT"

    if [ -s "$REPORT_SCRIPT" ] && [ -s "$MENU_SCRIPT" ]; then
        chmod +x "$REPORT_SCRIPT" "$MENU_SCRIPT"

        [ ! -f "/jffs/scripts/services-start" ] && echo "#!/bin/sh" > /jffs/scripts/services-start
        sed -i "\|$MENU_SCRIPT|d" /jffs/scripts/services-start
        echo "sh $MENU_SCRIPT # Inject Wireless Report" >> /jffs/scripts/services-start
        chmod +x /jffs/scripts/services-start

        [ ! -f "/jffs/scripts/service-event" ] && echo "#!/bin/sh" > /jffs/scripts/service-event
        sed -i "/wireless_report/d" /jffs/scripts/service-event
        echo 'if [ "$1" = "restart" ] && [ "$2" = "wireless_report" ]; then sh '$REPORT_SCRIPT'; fi # Wireless Report' >> /jffs/scripts/service-event
        chmod +x /jffs/scripts/service-event

        sh "$MENU_SCRIPT"
        sh "$REPORT_SCRIPT"
        echo -e "\n${GREEN}SUCCESS: Wireless Report v1.0.1 is installed!${NC}"
    else
        echo -e "${RED}[!] ERROR: Download failed.${NC}"
    fi
    pause
}

do_uninstall() {
    echo -e "\n${RED}[!] WARNING: This will remove all Wireless Report files.${NC}"
    printf " Are you sure? (y/n): "
    read confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        sed -i "\|$MENU_SCRIPT|d" /jffs/scripts/services-start
        sed -i "/wireless_report/d" /jffs/scripts/service-event
        rm -rf "$INSTALL_DIR"
        rm -f /tmp/wireless.asp
        echo -e "${GREEN}[+] Uninstalled successfully.${NC}"
    else
        echo -e "[*] Uninstall cancelled."
    fi
    pause # Moved outside the if-block
}

pause() { printf "\nPress [Enter] to return to menu..."; read discard; }

while true; do
    show_menu
    read choice
    case "$choice" in
        1) do_install ;;
        2) do_uninstall ;;
        e|E) clear; exit 0 ;;
        *) echo -e "${RED}Invalid selection.${NC}"; sleep 1 ;;
    esac
done