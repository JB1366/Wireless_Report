#!/bin/sh
#============================================================================#
#  Wireless Report                                                           #
#  Version: 1.0.1                                                            #
#  Author: JB_1366                                                           #
#============================================================================#

# --- Configuration (Update these for your Repo) ---
GITHUB_ROOT="https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/YOUR_REPO/main"
INSTALL_DIR="/jffs/addons/wireless_report"
REPORT_SCRIPT="$INSTALL_DIR/gen_report.sh"
MENU_SCRIPT="$INSTALL_DIR/install_menu.sh"

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

do_install() {
    echo -e "\n${CYAN}[*] Initializing Installation...${NC}"
    
    # 1. Prepare Directory
    if [ ! -d "$INSTALL_DIR" ]; then
        mkdir -p "$INSTALL_DIR"
        echo -e "[+] Created directory: $INSTALL_DIR"
    fi

    # 2. Download Files from GitHub
    echo -e "[*] Downloading components from GitHub..."
    
    curl -s -L "$GITHUB_ROOT/gen_report.sh" -o "$REPORT_SCRIPT"
    curl -s -L "$GITHUB_ROOT/install_menu.sh" -o "$MENU_SCRIPT"

    if [ -s "$REPORT_SCRIPT" ] && [ -s "$MENU_SCRIPT" ]; then
        chmod +x "$REPORT_SCRIPT" "$MENU_SCRIPT"
        echo -e "${GREEN}[+] Components downloaded successfully.${NC}"

        # 3. Setup services-start (Reboot Persistence)
        echo -e "[*] Applying Boot Hook (services-start)..."
        [ ! -f "/jffs/scripts/services-start" ] && echo "#!/bin/sh" > /jffs/scripts/services-start
        
        # Remove old entries if they exist to prevent duplicates
        sed -i "\|$MENU_SCRIPT|d" /jffs/scripts/services-start
        
        # Add the hook
        echo "sh $MENU_SCRIPT # Inject Wireless Report" >> /jffs/scripts/services-start
        chmod +x /jffs/scripts/services-start

        # 4. Setup service-event (Web UI Refresh Hook)
        echo -e "[*] Applying Refresh Hook (service-event)..."
        [ ! -f "/jffs/scripts/service-event" ] && echo "#!/bin/sh" > /jffs/scripts/service-event
        
        # Remove old entries if they exist
        sed -i "/wireless_report/d" /jffs/scripts/service-event
        
        # Add the hook
        echo 'if [ "$1" = "restart" ] && [ "$2" = "wireless_report" ]; then sh '$REPORT_SCRIPT'; fi # Wireless Report' >> /jffs/scripts/service-event
        chmod +x /jffs/scripts/service-event

        # 5. Finalize setup
        echo -e "[*] Mounting UI and generating initial data..."
        sh "$MENU_SCRIPT"
        sh "$REPORT_SCRIPT"

        echo -e "\n${GREEN}SUCCESS: Wireless Report v1.0.1 is installed!${NC}"
        echo -e "You can find it under: Advanced Settings -> Wireless -> Wireless Report"
    else
        echo -e "${RED}[!] ERROR: Download failed. Check your GitHub URL and connection.${NC}"
    fi
    pause
}

do_uninstall() {
    echo -e "\n${RED}[!] WARNING: This will remove all Wireless Report files and hooks.${NC}"
    printf " Are you sure you want to uninstall? (y/n): "
    read confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        echo -e "[*] Removing hooks..."
        [ -f "/jffs/scripts/services-start" ] && sed -i "\|$MENU_SCRIPT|d" /jffs/scripts/services-start
        [ -f "/jffs/scripts/service-event" ] && sed -i "/wireless_report/d" /jffs/scripts/service-event
        
        echo -e "[*] Deleting files..."
        rm -rf "$INSTALL_DIR"
        rm -f /tmp/wireless.asp
        
        echo -e "${GREEN}[+] Wireless Report has been uninstalled.${NC}"
        echo -e "[*] Note: The menu tab will disappear completely after your next reboot."
    else
        echo -e "[*] Uninstall cancelled."
    fi
    pause
}

pause() {
    printf "\nPress [Enter] to return to the menu..."
    read discard
}

# --- Main Execution Loop ---
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