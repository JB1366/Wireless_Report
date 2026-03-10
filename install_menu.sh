#!/bin/sh
#============================================================================#
#  Wireless Report Menu-Tab Insertion                                        #
#  Version: 1.0.1                                                           #
#  Author: JB_1366                                                           #
#============================================================================#

source /usr/sbin/helper.sh

# --- Configuration ---
SYSTEM_MENU="/www/require/modules/menuTree.js"
TEMP_MENU="/tmp/menuTree.js"
TAB_LABEL="Wireless Report"
INSTALL_DIR="/jffs/addons/wireless_report"
CONF_FILE="$INSTALL_DIR/webui.conf"
WEB_PAGE="$INSTALL_DIR/wireless.asp"
RAM_PAGE="/tmp/wireless.asp"

# Load the secret menu choice (1=Addons, 2=Wireless)
if [ -f "$CONF_FILE" ]; then
    . "$CONF_FILE"
else
    MENU_TYPE=1 # Default for normal users
fi

# Ensure placeholder exists
if [ ! -f "$RAM_PAGE" ]; then
    echo "<html><body>Generating Report... Please refresh.</body></html>" > "$RAM_PAGE"
fi

# Obtain available mount point
am_get_webui_page "$INSTALL_DIR/wireless.asp"
if [ "$am_webui_page" = "none" ]; then
    exit 1
fi

# Save the used page for uninstaller use
echo "INSTALLED_PAGE=$am_webui_page" >> "$CONF_FILE"
cp "$INSTALL_DIR/wireless.asp" "/www/user/$am_webui_page"

# Prepare the shared menu buffer
if [ ! -f "$TEMP_MENU" ]; then
    cp "$SYSTEM_MENU" "$TEMP_MENU"
    mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"
fi

# 1. Clean up existing entries to prevent duplicates
sed -i "/url: \"$am_webui_page\"/d" "$TEMP_MENU"
sed -i "/tabName: \"$TAB_LABEL\"/d" "$TEMP_MENU"

# 2. THE CHOICE ENGINE
if [ "$MENU_TYPE" = "2" ]; then
    # --- OPTION 2: SNEAKY WIRELESS MENU ---
    START_LINE=$(grep -ni 'url: "Advanced_Wireless_Content.asp"' "$TEMP_MENU" | head -n 1 | cut -d: -f1)
    if [ -n "$START_LINE" ]; then
        INSERT_LINE=$((START_LINE + 9))
        sed -i "${INSERT_LINE}i \ \ \ \ \ \ \ \ \ \ \ \ {url: \"$am_webui_page\", tabName: \"$TAB_LABEL\"}," "$TEMP_MENU"
    fi
else
    # --- OPTION 1: UNIVERSAL ADDONS MENU ---
    if grep -q "menu_addons" "$TEMP_MENU"; then
        # Join existing Addons (like Unbound)
        sed -i '/index: "menu_addons"/,/tab: \[/ s/tab: \[/tab: \[{url: "'"$am_webui_page"'", tabName: "'"$TAB_LABEL"'"\}, /' "$TEMP_MENU"
    else
        # Create Addons section from scratch
        sed -i '/index: "menu_Wireless"/ { :a; n; /}/! ba; a ,{menuName: "Addons", index: "menu_addons", tab: [{url: "'"$am_webui_page"'", tabName: "'"$TAB_LABEL"'"}]}' "$TEMP_MENU"
    fi
fi

# 3. Finalize Mounts with Lazy flag to prevent "Busy" errors
umount -l "$SYSTEM_MENU" 2>/dev/null
mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"

umount "/www/user/$am_webui_page" 2>/dev/null
mount -o bind "$RAM_PAGE" "/www/user/$am_webui_page"
"$INSTALL_DIR/gen_report.sh" &