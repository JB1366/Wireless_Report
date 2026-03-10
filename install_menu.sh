#!/bin/sh
#============================================================================#
#  Wireless Report Menu-Tab Installer                                        #
#  Version: 1.0.1                                                            #
#  Author: JB_1366                                                           #
#============================================================================#

source /usr/sbin/helper.sh

# --- Configuration ---
SYSTEM_MENU="/www/require/modules/menuTree.js"
TEMP_MENU="/tmp/menuTree.js"
TAB_LABEL="Wireless Report"
INSTALL_DIR="/jffs/addons/wireless_report"
WEB_PAGE="$INSTALL_DIR/wireless.asp"
RAM_PAGE="/tmp/wireless.asp"

# Check for existing mount
if [ -f "$INSTALL_DIR/webui.conf" ]; then
    . "$INSTALL_DIR/webui.conf"
    if [ -n "$INSTALLED_PAGE" ] && mount | grep -q "/www/user/$INSTALLED_PAGE"; then
        logger "Wireless Report:" "Already mounted as $INSTALLED_PAGE. Refreshing data."
        "$INSTALL_DIR/gen_report.sh" >/dev/null 2>&1 &
        exit 0
    fi
fi

# Firmware check
nvram get rc_support | grep -q am_addons
if [ $? != 0 ]; then
    logger "Wireless Report:" "Firmware does not support addons!"
    exit 5
fi

mkdir -p "$INSTALL_DIR"
[ ! -f "$RAM_PAGE" ] && echo "<html><body>Generating Report...</body></html>" > "$RAM_PAGE"
[ ! -f "$WEB_PAGE" ] && echo "<html><body>Generating Report...</body></html>" > "$WEB_PAGE"

am_get_webui_page "$WEB_PAGE"
if [ "$am_webui_page" = "none" ]; then
    logger "Wireless Report:" "Unable to install"
    exit 5
fi

cp "$WEB_PAGE" "/www/user/$am_webui_page"

# Save dynamic page to config and reload
echo "INSTALLED_PAGE=$am_webui_page" >> "$INSTALL_DIR/webui.conf"
. "$INSTALL_DIR/webui.conf"

# Modify MenuTree
if [ ! -f "$TEMP_MENU" ]; then
    cp "$SYSTEM_MENU" /tmp/
    mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"
fi

if [ "$MENU_TYPE" = "1" ]; then
    # Choice 1: Addons Menu
    sed -i '/menuName: "Addons"/,/tab: \[/ s/tab: \[/tab: \[{url: "'"$am_webui_page"'", tabName: "'"$TAB_LABEL"'"\}, /' "$TEMP_MENU"
    echo "Added to Addons Menu."
else
    # Choice 2: Wireless Menu
    START_LINE=$(grep -ni 'url: "Advanced_Wireless_Content.asp"' "$TEMP_MENU" | head -n 1 | cut -d: -f1)
    if [ -n "$START_LINE" ]; then
        INSERT_LINE=$((START_LINE + 9)) 
        sed -i "${INSERT_LINE}i \ \ \ \ \ \ \ \ \ \ \ \ {url: \"$am_webui_page\", tabName: \"$TAB_LABEL\"}," "$TEMP_MENU"
        echo "Added to Wireless Menu."
    else
        echo "ERROR: Wireless anchor not found."
        exit 1
    fi
fi

# Remount logic
umount "$SYSTEM_MENU" && mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"
umount "/www/user/$am_webui_page" 2>/dev/null
mount -o bind "$RAM_PAGE" "/www/user/$am_webui_page"
"$INSTALL_DIR/gen_report.sh" >/dev/null 2>&1 &