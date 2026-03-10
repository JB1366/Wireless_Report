#!/bin/sh
#============================================================================#
#  Wireless Report Menu-Tab Installer                                        #
#  Version: 1.0.0                                                            #
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

# Check if already mounted to avoid redundant installs
if [ -f "$INSTALL_DIR/webui.conf" ]; then
    . "$INSTALL_DIR/webui.conf"
    if [ -n "$INSTALLED_PAGE" ] && mount | grep -q "/www/user/$INSTALLED_PAGE"; then
        logger "Wireless Report:" "Already mounted as $INSTALLED_PAGE. Refreshing data and exiting."
        "$INSTALL_DIR/gen_report.sh" >/dev/null 2>&1 &
        exit 0
    fi
fi

# Does the firmware support addons?
nvram get rc_support | grep -q am_addons
if [ $? != 0 ]; then
    logger "Wireless Report:" "This firmware does not support addons!"
    exit 5
fi

mkdir -p "$INSTALL_DIR"

if [ ! -f "$RAM_PAGE" ]; then
    echo "<html><body>Generating Report... Please refresh.</body></html>" > "$RAM_PAGE"
fi

if [ ! -f "$WEB_PAGE" ]; then
    echo "Initial Install: Creating placeholder."
    echo "<html><body>Generating Report... Please refresh.</body></html>" > "$WEB_PAGE"
fi

am_get_webui_page "$WEB_PAGE"

if [ "$am_webui_page" = "none" ]; then
    logger "Wireless Report:" "Unable to install Wireless Report"
    exit 5
fi
logger "Wireless Report:" "Mounting Wireless\Wireless Report as $am_webui_page"

cp "$WEB_PAGE" "/www/user/$am_webui_page"

# Save dynamic page name to config (Append to existing MENU_TYPE)
echo "INSTALLED_PAGE=$am_webui_page" >> "$INSTALL_DIR/webui.conf"

# Refresh local variables from config
. "$INSTALL_DIR/webui.conf"

# Copy menuTree (if no other script has done it yet) so we can modify it
if [ ! -f "$TEMP_MENU" ]; then
    cp "$SYSTEM_MENU" /tmp/
    mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"
fi

if [ "$MENU_TYPE" = "1" ]; then
    # Option:1 Addons Menu-Tab Insertion 
    sed -i '/menuName: "Addons"/,/tab: \[/ s/tab: \[/tab: \[{url: "'"$am_webui_page"'", tabName: "'"$TAB_LABEL"'"\}, /' "$TEMP_MENU"
    echo "Wireless Report tab successfully added to Addons Menu."
else
    # Option:2  Wireless Menu-Tab Insertion 
    START_LINE=$(grep -ni 'url: "Advanced_Wireless_Content.asp"' "$TEMP_MENU" | head -n 1 | cut -d: -f1)

    if [ -n "$START_LINE" ]; then
        INSERT_LINE=$((START_LINE + 9))  
        sed -i "${INSERT_LINE}i \ \ \ \ \ \ \ \ \ \ \ \ {url: \"$am_webui_page\", tabName: \"$TAB_LABEL\"}," "$TEMP_MENU"
        echo "Wireless Report tab successfully added to Wireless Menu."
    else
        echo "ERROR: Wireless anchor not found."
        exit 1
    fi
fi

# Remount modified menu
umount "$SYSTEM_MENU" && mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"
umount "/www/user/$am_webui_page" 2>/dev/null
mount -o bind "$RAM_PAGE" "/www/user/$am_webui_page"
"$INSTALL_DIR/gen_report.sh" >/dev/null 2>&1 &