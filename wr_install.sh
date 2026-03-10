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
CONF_FILE="$INSTALL_DIR/webui.conf"
SSH_KEY="/tmp/home/root/.ssh/id_dropbear"

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
    echo -e "  (3)  Check/Update Script"
    echo -e "  (e)  Exit"
    echo -e ""
    echo -e "${CYAN}==================================================${NC}"
    printf " Selection: "
}

do_install() {
    echo -e "${CYAN}[*] Verifying Environment...${NC}"
    if [ "$(nvram get jffs2_scripts)" != "1" ]; then
        echo -e "${RED}[!] ERROR: JFFS custom scripts are not enabled.${NC}"
        exit 1
    fi

    echo -e "\n${CYAN}[*] Downloading Components...${NC}"
    [ ! -d "$INSTALL_DIR" ] && mkdir -p "$INSTALL_DIR"
    curl -s -L "$GITHUB_ROOT/gen_report.sh" -o "$REPORT_SCRIPT"
    curl -s -L "$GITHUB_ROOT/install_menu.sh" -o "$MENU_SCRIPT"

    if [ -s "$REPORT_SCRIPT" ]; then
        chmod +x "$REPORT_SCRIPT" "$MENU_SCRIPT"

        # --- DYNAMIC CLEANUP ---
        echo -e "${CYAN}[*] Detecting and clearing existing mounts...${NC}"
        # Find any custom .asp files mounted in /www and unmount them
        mount | grep "/www/.*\.asp" | awk '{print $3}' | while read -r mnt; do
            umount "$mnt" 2>/dev/null
        done

        # Get target page name from config or use default
        [ -f "$CONF_FILE" ] && . "$CONF_FILE"
        P_NAME="${INSTALLED_PAGE:-wireless.asp}"

        # Purge physical files that conflict with symlinks
        rm -f "$INSTALL_DIR/$P_NAME"
        rm -f "/www/$P_NAME"

        # Save config and create live link
        echo "INSTALLED_PAGE=\"$P_NAME\"" > "$CONF_FILE"
        ln -sf "/tmp/$P_NAME" "/www/$P_NAME"

        # Persistence
        [ ! -f "/jffs/scripts/services-start" ] && echo "#!/bin/sh" > /jffs/scripts/services-start
        sed -i "\|$MENU_SCRIPT|d" /jffs/scripts/services-start
        echo "sh $MENU_SCRIPT # Wireless Report Menu" >> /jffs/scripts/services-start
        chmod +x /jffs/scripts/services-start

        echo -e "${CYAN}[*] Generating initial report...${NC}"
        sh "$REPORT_SCRIPT"
        echo -e "\n${GREEN}SUCCESS: Wireless Report is clean and live!${NC}"
    else
        echo -e "${RED}[!] ERROR: Download failed.${NC}"
    fi
    pause
}

do_uninstall() {
    [ -f "$CONF_FILE" ] && . "$CONF_FILE"
    P_NAME="${INSTALLED_PAGE:-wireless.asp}"
    
    echo -e "\n${RED}[!] Removing all Wireless Report components...${NC}"
    printf " Are you sure? (y/n): "
    read confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        sed -i "\|$MENU_SCRIPT|d" /jffs/scripts/services-start
        umount "/www/$P_NAME" 2>/dev/null
        rm -f "/www/$P_NAME" "/tmp/$P_NAME"
        rm -rf "$INSTALL_DIR"
        echo -e "${GREEN}[+] Uninstalled successfully.${NC}"
    else
        echo -e "[*] Uninstall cancelled."
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