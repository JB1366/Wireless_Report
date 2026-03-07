#!/bin/sh

# --- Configuration ---
SYSTEM_MENU="/www/require/modules/menuTree.js"
TEMP_MENU="/tmp/menuTree.js"
TAB_LABEL="WIRELESS REPORT"

# --- 1. Reset ---
umount "$SYSTEM_MENU" 2>/dev/null
rm "$TEMP_MENU" 2>/dev/null
cp "$SYSTEM_MENU" "$TEMP_MENU"

# --- 2. Inject at the Perfect End Offset ---
START_LINE=$(grep -ni 'url: "Advanced_Wireless_Content.asp"' "$TEMP_MENU" | head -n 1 | cut -d: -f1)

if [ -n "$START_LINE" ]; then
    # Offset +9 is the 'sweet spot' for 3006 firmware
    INSERT_LINE=$((START_LINE + 9))
    
    # Injected with plain text TAB_LABEL
    sed -i "${INSERT_LINE}i \ \ \ \ \ \ \ \ \ \ \ \ {url: \"user5.asp\", tabName: \"$TAB_LABEL\"}," "$TEMP_MENU"
    echo "Wireless Report tab successfully restored with plain text."
else
    echo "ERROR: Wireless anchor not found."
    exit 1
fi

# --- 3. Apply and Finalize ---
mount --bind "$TEMP_MENU" "$SYSTEM_MENU"

# --- Wireless Report Setup ---
touch /jffs/www/user5.asp

# 1. Create the sub-folder the router's shortcut expects
mkdir -p /www/user

# 2. Create the real placeholder inside that folder
touch /www/user/user5.asp

# 3. Bind your file to that real placeholder
mount --bind /jffs/www/user5.asp /www/user/user5.asp
/jffs/addons/wireless_report/gen_report.sh &