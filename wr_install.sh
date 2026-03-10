#!/bin/sh
#============================================================================#
#  Wireless Report Installer                                                 #
#  Version: 1.0.2                                                            #
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
        echo -e "${CYAN}[*] Clearing existing web mounts...${NC}"
        # Automatically find and unmount any custom .asp files in /www
        mount | grep "/www/.*\.asp" | awk '{print $3}' | while read -r mnt; do
            umount "$mnt" 2>/dev/null
        done

        # Use variables from config or set defaults
        [ -f "$CONF_FILE" ] && . "$CONF_FILE"
        P_NAME="${INSTALLED_PAGE:-wireless.asp}"

        # Remove physical placeholders that block mounting [cite: 1]
        rm -f "$INSTALL_DIR/$P_NAME"
        
        # Save current config
        echo "INSTALLED_PAGE=\"$P_NAME\"" > "$CONF_FILE"

        # --- THE FIX: Bind Mount instead of Symlink ---
        echo -e "${CYAN}[*] Applying WebUI Overlay...${NC}"
        touch "/tmp/$P_NAME"
        # This overlays the /tmp file onto the web server path
        mount --bind "/tmp/$P_NAME" "/www/$P_NAME" 2>/dev/null

        # Persistence setup
        [ ! -f "/jffs/scripts/services-start" ] && echo "#!/bin/sh" > /jffs/scripts/services-start
        sed -i "\|$MENU_SCRIPT|d" /jffs/scripts/services-start
        echo "sh $MENU_SCRIPT # Wireless Report Menu" >> /jffs/scripts/services-start
        chmod +x /jffs/scripts/services-start

        # Generate initial data immediately
        echo -e "${CYAN}[*] Generating initial report...${NC}"
        sh "$REPORT_SCRIPT"

        echo -e "\n${GREEN}SUCCESS: Wireless Report is live at /www/$P_NAME!${NC}"
    else
        echo -e "${RED}[!] ERROR: Download failed.${NC}"
    fi
}

do_uninstall() {
    [ -f "$CONF_FILE" ] && . "$CONF_FILE"
    P_NAME="${INSTALLED_PAGE:-wireless.asp}"

    echo -e "\n${RED}[!] Removing Wireless Report...${NC}"
    sed -i "\|$MENU_SCRIPT|d" /jffs/scripts/services-start
    umount "/www/$P_NAME" 2>/dev/null
    rm -rf "$INSTALL_DIR"
    rm -f "/tmp/$P_NAME"
    echo -e "${GREEN}[+] Uninstalled successfully.${NC}"
}

pause() { printf "\nPress [Enter] to return to menu..."; read discard; }

while true; do
    clear
    echo -e "${CYAN}Wireless Report Management${NC}"
    echo " 1) Install/Update"
    echo " 2) Uninstall"
    echo " e) Exit"
    printf "\n Selection: "
    read choice
    case "$choice" in
        1) do_install ;;
        2) do_uninstall ;;
        e|E) exit 0 ;;
    esac
done