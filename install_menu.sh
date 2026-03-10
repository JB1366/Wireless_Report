#!/bin/sh

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

# --- SMART SLOT DETECTION ---
# Check if we already have a page assigned in our config file
if [ -f "$CONF_FILE" ]; then
    source "$CONF_FILE"
fi

# Use existing assignment or find a new one
if [ -z "$INSTALLED_PAGE" ]; then
    am_get_webui_page "$WEB_PAGE"
    INSTALLED_PAGE="$am_webui_page"
    echo "INSTALLED_PAGE=\"$INSTALLED_PAGE\"" > "$CONF_FILE"
fi

logger "Wireless Report:" "Mounting Wireless\Wireless Report as $INSTALLED_PAGE"

# THE COMMAND THAT MUST STAY: Copy the file to the user directory
cp "$WEB_PAGE" "/www/user/$INSTALLED_PAGE"

# Copy menuTree (if no other script has done it yet) so we can modify it
if [ ! -f "$TEMP_MENU" ]; then
    cp "$SYSTEM_MENU" /tmp/
    mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"
fi

# ### Default Addons Menu-Tab Insertion ###
# Insert Wireless Report at the end of the Tools menu.  Match partial string, since tabname can change between builds (if using an AS tag)
# sed -i "/url: \"Tools_OtherSettings.asp\", tabName:/a {url: \"$INSTALLED_PAGE\", tabName: \"$TAB_LABEL\"}," "$TEMP_MENU"

# ### Wireless Menu-Tab Insertion ###
# 1. Check if the Tab Label already exists in the menu
if grep -q "tabName: \"$TAB_LABEL\"" "$TEMP_MENU"; then
    # UPDATE MODE: Change the URL for the existing Tab Label
    # Dynamically targets any userX.asp assigned to this specific Label
    sed -i "s|url: \"user[0-9].asp\", tabName: \"$TAB_LABEL\"|url: \"$INSTALLED_PAGE\", tabName: \"$TAB_LABEL\"|g" "$TEMP_MENU"
    echo "Wireless Report tab URL updated to $INSTALLED_PAGE."
else
    # INSERT MODE: Only runs if the tab is missing
    # Inject Wireless Report at the end of Advanced_Wireless_Content menu at Perfect End Offset
    START_LINE=$(grep -ni 'url: "Advanced_Wireless_Content.asp"' "$TEMP_MENU" | head -n 1 | cut -d: -f1)
    
    if [ -n "$START_LINE" ]; then
        INSERT_LINE=$((START_LINE + 9))
        sed -i "${INSERT_LINE}i \ \ \ \ \ \ \ \ \ \ \ \ {url: \"$INSTALLED_PAGE\", tabName: \"$TAB_LABEL\"}," "$TEMP_MENU"
        echo "Wireless Report tab successfully injected."
    else
        echo "ERROR: Wireless anchor not found."
        exit 1
    fi
fi

# Remount modified menu
umount "$SYSTEM_MENU" 2>/dev/null
mount -o bind "$TEMP_MENU" "$SYSTEM_MENU"

# Finalize the mount to the RAM page for live updates
umount "/www/user/$INSTALLED_PAGE" 2>/dev/null
mount -o bind "$RAM_PAGE" "/www/user/$INSTALLED_PAGE"

# Refresh data
"$INSTALL_DIR/gen_report.sh" &