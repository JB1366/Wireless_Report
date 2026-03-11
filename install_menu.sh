#!/bin/sh
#============================================================================#
#  Wireless Report Menu-Tab Insertion                                        #
#  Version: 1.0.1                                                           #
#  Author: JB_1366                                                           #
#============================================================================#

source /usr/sbin/helper.sh

SYSTEM_MENU="/www/require/modules/menuTree.js"
TEMP_MENU="/tmp/menuTree.js"
TAB_LABEL="Wireless Report"
INSTALL_DIR="/jffs/addons/wireless_report"
CONF_FILE="$INSTALL_DIR/webui.conf"
WEB_PAGE="$INSTALL_DIR/wireless.asp"
RAM_PAGE="/tmp/wireless.asp"

# 1. Load Choice
[ -f "$CONF_FILE" ] && . "$CONF_FILE" || MENU_TYPE=1

# 2. Safety Placeholders
[ ! -f "$WEB_PAGE" ] && echo "<html><body>Loading...</body></html>" > "$WEB_PAGE"
[ ! -f "$RAM_PAGE" ] && cp "$WEB_PAGE" "$RAM_PAGE"

# 3. Get Mount Point
am_get_webui_page "$WEB_PAGE"
[ "$am_webui_page" = "none" ] && exit 1

# 4. RESTORED CP COMMAND - This puts the file in the web path
cp -f "$WEB_PAGE" "/www/user/$am_webui_page"
echo "INSTALLED_PAGE=$am_webui_page" >> "$CONF_FILE"

# 5. Prepare Buffer
if [ ! -f "$TEMP_MENU" ]; then
    cp "$SYSTEM_MENU" "$TEMP_MENU"
    mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"
fi

# 6. Clean Duplicates
sed -i "/url: \"$am_webui_page\"/d" "$TEMP_MENU"
sed -i "/tabName: \"$TAB_LABEL\"/d" "$TEMP_MENU"

# 7. LOGIC ENGINE

if [ "$MENU_TYPE" = "2" ]; then
    # SNEAKY WIRELESS
    START_LINE=$(grep -ni 'url: "Advanced_Wireless_Content.asp"' "$TEMP_MENU" | head -n 1 | cut -d: -f1)
    if [ -n "$START_LINE" ]; then
        INSERT_LINE=$((START_LINE + 9))
        sed -i "${INSERT_LINE}i \ \ \ \ \ \ \ \ \ \ \ \ {url: \"$am_webui_page\", tabName: \"$TAB_LABEL\"}," "$TEMP_MENU"
    fi
else
    # STANDARD ADDONS
    if grep -q "menu_addons" "$TEMP_MENU"; then
        # Join existing (e.g., Unbound is there)
        sed -i "/index: \"menu_addons\"/,/tab: \[/ s/tab: \[/tab: \[{url: \"$am_webui_page\", tabName: \"$TAB_LABEL\"}, /" "$TEMP_MENU"
    else
        # Create from scratch if Unbound is NOT there
        # Adds new menu object safely after the Wireless block
        sed -i '/index: "menu_Wireless"/!b;n;n;n;n;n;n;n;n;n;a ,{menuName: "Addons", index: "menu_addons", tab: [{url: "'"$am_webui_page"'", tabName: "'"$TAB_LABEL"'"}]}' "$TEMP_MENU"
    fi
fi

# 8. Apply Mounts
umount -l "$SYSTEM_MENU" 2>/dev/null
mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"
umount -l "/www/user/$am_webui_page" 2>/dev/null
mount -o bind "$RAM_PAGE" "/www/user/$am_webui_page"