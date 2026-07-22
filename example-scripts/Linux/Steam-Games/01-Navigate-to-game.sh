#!/bin/sh

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

# Find compatdata directory first
COMPATDATA_DIR=$(find "$ROOT" -type d -name "compatdata" -print -quit)

if [ -z "$COMPATDATA_DIR" ]; then
    echo "ERROR: No compatdata directory found"
    exit 1
fi

echo "Comapatdata directory: $COMPATDATA_DIR"

# Take the folder name of the first folder inside compatdata as the game ID
GAMEID_DIR=$(find "$COMPATDATA_DIR" \
    -mindepth 1 \
    -maxdepth 1 \
    -type d \
    -print -quit)

if [ -z "$GAMEID_DIR" ]; then
    echo "ERROR: No game folder inside compatdata"
    exit 1
fi

echo "Game folder: $GAMEID_DIR"

# Removes the path to the compatdata folder, leaving only the game ID
GAME_ID=$(basename "$GAMEID_DIR")
echo "Found Game ID: $GAME_ID"

# Navigate to game's page
echo "Navigating to game's page on Steam..."
steam steam://nav/games/details/$GAME_ID

# For other Steam URL Protocol commands check the documentation:
# https://developer.valvesoftware.com/wiki/Steam_browser_protocol

