#!/bin/bash

set -e

TRUST_DIR="$HOME/.config/steam-games-cartridges"
TRUST_FILE="$TRUST_DIR/trusted_scripts.sha256"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

mkdir -p "$TRUST_DIR"
touch "$TRUST_FILE"


while true; do

    FOUND_SCRIPT=""
    FOUND_DEVICE=""
    FOUND_MOUNT=""

    while read -r DEVICE MOUNTPOINT; do

        if [ -f "$MOUNTPOINT/launch.sh" ]; then
            FOUND_SCRIPT="$MOUNTPOINT/launch.sh"
            FOUND_DEVICE="$DEVICE"
            FOUND_MOUNT="$MOUNTPOINT"
            break
        fi

    done < <(findmnt -rn -o SOURCE,TARGET)


    if [ -z "$FOUND_SCRIPT" ]; then

        clear 2>/dev/null || printf "\033c"
        echo ""
        echo " Insert cartridge to check the trust state..."
        echo " (Press E to exit.)"

        for i in {1..30}; do

            read -rsn1 -t 0.1 KEY || true

            if [[ "$KEY" == "e" || "$KEY" == "E" ]]; then
                echo ""
                echo " Exiting..."
                sleep 1
                clear 2>/dev/null || printf "\033c"
                exec bash "$ROOT_DIR/cartridge-linux.sh"
            fi

        done

        continue

    fi



    LABEL=$(lsblk -no LABEL "$FOUND_DEVICE" 2>/dev/null || true)
    [ -z "$LABEL" ] && LABEL="Unknown"


    HASH=$(sha256sum "$FOUND_SCRIPT" | awk '{print $1}')


    clear 2>/dev/null || printf "\033c"

    echo ""
    echo " Cartridge found!"
    echo ""
    echo " Drive:  $FOUND_DEVICE"
    echo " Mount:  $FOUND_MOUNT"
    echo " Label:  $LABEL"
    echo " Script: $FOUND_SCRIPT"
    echo ""
    echo " SHA256:"
    echo " $HASH"
    echo ""


    if grep -qx "$HASH" "$TRUST_FILE"; then

        echo -e " State: ${GREEN}trusted${RESET}"
        echo ""

        read -r -p " Stop trusting this script? (y/N): " CONFIRM

        CONFIRM=${CONFIRM:-N}


        case "$CONFIRM" in

            y|Y|yes|YES)

                grep -vx "$HASH" "$TRUST_FILE" > "$TRUST_FILE.tmp"
                mv "$TRUST_FILE.tmp" "$TRUST_FILE"

                echo ""
                echo -e " ${RED}Trust removed.${RESET}"

                ;;

            *)

                echo ""
                echo " Skipped."

                ;;

        esac


    else

        echo -e " State: ${RED}not trusted${RESET}"
        echo ""

        read -r -p " Trust this script? (Y/n): " CONFIRM

        CONFIRM=${CONFIRM:-Y}


        case "$CONFIRM" in

            y|Y|yes|YES)

                echo "$HASH" >> "$TRUST_FILE"

                echo ""
                echo -e " ${GREEN}Script trusted.${RESET}"

                ;;

            *)

                echo ""
                echo " Skipped."

                ;;

        esac

    fi


    echo ""
    echo " Remove the cartridge now..."

    sleep 2


    # Wait for cartridge removal before scanning again
    while [ -f "$FOUND_SCRIPT" ]; do
        sleep 2
    done


    clear 2>/dev/null || printf "\033c"

done