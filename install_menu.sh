#!/bin/sh
#============================================================================#
#  Wireless Report Menu-TAB Insertion                                        #
#  Version: 1.1.0                                                            #
#  Author: JB_1366                                                           #
#  Revised: adjust tab insertion                                             #
#============================================================================#

source /usr/sbin/helper.sh

# --- Configuration ---
SYSTEM_MENU="/www/require/modules/menuTree.js"
TEMP_MENU="/tmp/menuTree.js"
TAB_LABEL="Wireless Report"
INSTALL_DIR="/jffs/addons/wireless_report"
WEB_PAGE="$INSTALL_DIR/wireless.asp"
RAM_PAGE="/tmp/wireless.asp"
CONF_FILE="$INSTALL_DIR/webui.conf"

# Does the firmware support addons?
nvram get rc_support | grep -q am_addons
if [ $? != 0 ]; then
    logger -t "Wireless Report" "This firmware does not support addons!"
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
    logger -t "Wireless Report" "Unable to install Wireless Report"
    exit 5
fi

cp "$WEB_PAGE" "/www/user/$am_webui_page"

# Copy mounted user page to installed directory config
if [ -f "$CONF_FILE" ]; then
    if grep -q "INSTALLED_PAGE=" "$CONF_FILE"; then
        # Replace the value in-place so REPORT_UNIT stays safe
        sed -i "s/^INSTALLED_PAGE=.*/INSTALLED_PAGE=$am_webui_page/" "$CONF_FILE"
    else
        # Line doesn't exist, append it
        echo "INSTALLED_PAGE=$am_webui_page" >> "$CONF_FILE"
    fi
else
    # File missing, create it
    echo "INSTALLED_PAGE=$am_webui_page" > "$CONF_FILE"
fi

# Copy menuTree (if no other script has done it yet) so we can modify it
if [ ! -f "$TEMP_MENU" ]; then
    cp "$SYSTEM_MENU" /tmp/
    mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"
fi

# Addons Menu-Tab Insertion
# Insert Wireless Report before HELP menu
# sed -i "/url: \"javascript:var helpwindow=window.open('\/ext\/shared-jy\/redirect.htm'/i {url: \"$am_webui_page\", tabName: \"$TAB_LABEL\"}," "$TEMP_MENU"
# logger "Wireless Report:" "Mounting Addons\Wireless Report as $am_webui_page"

# Wireless Menu-Tab Insertion
# Inject Wireless Report tab just before the Wireless menu's __INHERIT__ sentinel
sed -i "/index: \"menu_Wireless\"/,/{url: \"NULL\", tabName: \"__INHERIT__\"}/ {/{url: \"NULL\", tabName: \"__INHERIT__\"}/i \\
{url: \"$am_webui_page\", tabName: \"$TAB_LABEL\"},
}" "$TEMP_MENU"
logger -t "Wireless Report" "Mounting Wireless\Wireless Report as $am_webui_page"

# Remount modified menu
umount "$SYSTEM_MENU" && mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"
umount "/www/user/$am_webui_page" 2>/dev/null
mount -o bind "$RAM_PAGE" "/www/user/$am_webui_page"
"$INSTALL_DIR/gen_report.sh" &