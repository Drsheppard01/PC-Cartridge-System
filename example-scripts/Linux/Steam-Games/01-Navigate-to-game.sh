#!/bin/bash

# Put this script on your SSD at root level and name it "launch.sh" (without quotes). 

#### This script will automatically detects the game on this storage device and navigate to the game's page on Steam. ####
# Meant for single game cartridges.


set -e
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$ROOT/launch.log"

# Log all stdout and stderr to a log file for debugging purposes
exec > >(tee "$LOG_FILE") 2>&1

# ------------------------------------------
# Find Game ID
# ------------------------------------------

# Find steamapps directory first
STEAMAPPS_DIR=$(find "$ROOT" -type d -name "steamapps" -print -quit)

if [ -z "$STEAMAPPS_DIR" ]; then
    echo "ERROR: No steamapps directory found"
    exit 1
fi

echo "Steamapps directory: $STEAMAPPS_DIR"

# Find appmanifest file
GAME=$(find "$STEAMAPPS_DIR" \
    -maxdepth 1 \
    -type f \
    -name "appmanifest_*.acf")

GAME_COUNT=$(echo "$GAME" | grep -c "appmanifest_")

if [ "$GAME_COUNT" -eq 0 ]; then
    echo "ERROR: No appmanifest files inside steamapps"
    exit 1
fi

if [ "$GAME_COUNT" -gt 1 ]; then
    echo "ERROR: More than one game found inside steamapps. Use other scripts instead."
    exit 1
fi


# Extract Game ID from filename
GAME_ID=$(basename "$GAME" | sed -E 's/appmanifest_([0-9]+)\.acf/\1/')

echo "Found Game ID: $GAME_ID"

# Navigate to game's page
echo "Navigating to game's page on Steam..."
steam steam://nav/games/details/$GAME_ID

# For other Steam URL Protocol commands check the documentation:
# https://developer.valvesoftware.com/wiki/Steam_browser_protocol

