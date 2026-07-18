#!/bin/bash

set -e

TRUST_DIR="$HOME/.config/steam-games-cartridges"
TRUST_FILE="$TRUST_DIR/trusted_scripts.sha256"

echo "Scanning for script on Cartridge..."
echo ""

mkdir -p "$TRUST_DIR"
touch "$TRUST_FILE"


FOUND_SCRIPT=""

while read -r DEVICE MOUNTPOINT; do

    if [ -f "$MOUNTPOINT/launch.sh" ]; then
        FOUND_SCRIPT="$MOUNTPOINT/launch.sh"
        FOUND_DEVICE="$DEVICE"
        FOUND_MOUNT="$MOUNTPOINT"
        break
    fi

done < <(findmnt -rn -o SOURCE,TARGET)


if [ -z "$FOUND_SCRIPT" ]; then
    echo "No cartridge with launch.sh found."
    exit 0
fi


LABEL=$(lsblk -no LABEL "$FOUND_DEVICE" 2>/dev/null || true)
[ -z "$LABEL" ] && LABEL="Unknown"


echo "Found launch.sh"
echo "Drive:  $FOUND_DEVICE"
echo "Mount:  $FOUND_MOUNT"
echo "Path:   $FOUND_SCRIPT"
echo "Label:  $LABEL"
echo ""


read -r -p "Do you want to add this script to trusted scripts? (Y/n): " CONFIRM

CONFIRM=${CONFIRM:-Y}


case "$CONFIRM" in

    y|Y|yes|YES)

        HASH=$(sha256sum "$FOUND_SCRIPT" | awk '{print $1}')

        if grep -qx "$HASH" "$TRUST_FILE"; then
            echo "Already trusted."
        else
            echo "$HASH" >> "$TRUST_FILE"
            echo "Added to trusted scripts."
            echo "If you modify the script later, you will need to run this script again to trust the new version."
            echo "Now the script will be executed automatically when you reconnect the Cartridge."
        fi

        echo ""
        echo "SHA256:"
        echo "$HASH"
        ;;

    *)
        echo "Skipped."
        ;;

esac