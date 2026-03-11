#!/bin/sh
#============================================================================#
#  Wireless Report Menu-TAB Insertion                                        #
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

# Does the firmware support addons?
nvram get rc_support | grep -q am_addons
if [ $? != 0 ]; then
    logger "Wireless Report:" "This firmware does not support addons!"
    exit 5
fi

# Create the directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Ensure the RAM target exists so the mount doesn't fail later
if [ ! -f "$RAM_PAGE" ]; then
    echo "<html><body>Generating Report... Please refresh.</body></html>" > "$RAM_PAGE"
fi

# If this is a first-time install, create a placeholder so the API sees a file
if [ ! -f "$WEB_PAGE" ]; then
    echo "Initial Install: Creating placeholder."
    echo "<html><body>Generating Report... Please refresh.</body></html>" > "$WEB_PAGE"
fi

# Obtain the first available mount point in $am_webui_page
am_get_webui_page "$WEB_PAGE"

if [ "$am_webui_page" = "none" ]; then
    logger "Wireless Report:" "Unable to install Wireless Report"
    exit 5
fi
logger "Wireless Report:" "Mounting Wireless\Wireless Report as $am_webui_page"

cp "$WEB_PAGE" "/www/user/$am_webui_page"

# Copy mounted user page to installed directory config
echo "INSTALLED_PAGE=$am_webui_page" > "$INSTALL_DIR/webui.conf"

# Copy menuTree (if no other script has done it yet) so we can modify it
if [ ! -f "$TEMP_MENU" ]; then
    cp "$SYSTEM_MENU" /tmp/
    mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"
fi

# Addons Menu-Tab Insertion
# Insert Wireless Report before HELP menu
# sed -i "/url: \"javascript:var helpwindow=window.open('\/ext\/shared-jy\/redirect.htm'/i {url: \"$am_webui_page\", tabName: \"$TAB_LABEL\"}," "$TEMP_MENU"

# Wireless Menu-Tab Insertion
# Inject Wireless Report at the end of Advanced_Wireless_Content menu at Perfect End Offset
START_LINE=$(grep -ni 'url: "Advanced_Wireless_Content.asp"' "$TEMP_MENU" | head -n 1 | cut -d: -f1)
if [ -n "$START_LINE" ]; then
    INSERT_LINE=$((START_LINE + 9))
    sed -i "${INSERT_LINE}i \ \ \ \ \ \ \ \ \ \ \ \ {url: \"$am_webui_page\", tabName: \"$TAB_LABEL\"}," "$TEMP_MENU"
    echo "Wireless Report tab successfully restored."
else
    echo "ERROR: Wireless anchor not found."
    exit 1
fi

# Remount modified menu
umount "$SYSTEM_MENU" && mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"
umount "/www/user/$am_webui_page" 2>/dev/null
mount -o bind "$RAM_PAGE" "/www/user/$am_webui_page"
"$INSTALL_DIR/gen_report.sh" &