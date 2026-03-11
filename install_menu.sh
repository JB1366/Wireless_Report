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

# 1. Load Choice
if [ -f "$CONF_FILE" ]; then
    . "$CONF_FILE"
else
    MENU_TYPE=1
fi

# 2. Safety: Create placeholders to avoid "No such file" mount errors
if [ ! -f "$WEB_PAGE" ]; then
    echo "<html><body>Generating Report... Please refresh.</body></html>" > "$WEB_PAGE"
fi
if [ ! -f "$RAM_PAGE" ]; then
    cp "$WEB_PAGE" "$RAM_PAGE"
fi

# 3. Find mount point
am_get_webui_page "$WEB_PAGE"
if [ "$am_webui_page" = "none" ]; then
    exit 1
fi

# 4. Save assigned page for uninstaller
echo "INSTALLED_PAGE=$am_webui_page" >> "$CONF_FILE"
cp "$WEB_PAGE" "/www/user/$am_webui_page"

# 5. Prepare shared menu buffer
if [ ! -f "$TEMP_MENU" ]; then
    cp "$SYSTEM_MENU" "$TEMP_MENU"
    mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"
fi

# 6. Clean existing entries to prevent duplicates
sed -i "/url: \"$am_webui_page\"/d" "$TEMP_MENU"
sed -i "/tabName: \"$TAB_LABEL\"/d" "$TEMP_MENU"

# 7. THE LOGIC ENGINE
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
        # Join existing Addons array (like Unbound)
        sed -i "/index: \"menu_addons\"/,/tab: \[/ s/tab: \[/tab: \[{url: \"$am_webui_page\", tabName: \"$TAB_LABEL\"}, /" "$TEMP_MENU"
    else
        # Create Addons section from scratch after Wireless block
        sed -i '/index: "menu_Wireless"/!b;n;n;n;n;n;n;n;n;n;a ,{menuName: "Addons", index: "menu_addons", tab: [{url: "'"$am_webui_page"'", tabName: "'"$TAB_LABEL"'"}]}' "$TEMP_MENU"
    fi
fi

# 8. Finalize Mounts with Lazy unmount to prevent 'Busy' errors
umount -l "$SYSTEM_MENU" 2>/dev/null
mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"

umount "/www/user/$am_webui_page" 2>/dev/null
mount -o bind "$RAM_PAGE" "/www/user/$am_webui_page"