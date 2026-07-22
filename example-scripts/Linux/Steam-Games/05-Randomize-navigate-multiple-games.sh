#!/bin/sh

# Put this script on your SSD at root level and name it "launch.sh" (without quotes). 

#### This script will automatically detects all the games on this storage device and randomly navigate to the game's page on Steam. ####
# Meant for cartridges with multiple games


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

# Search for all game folders inside compatdata and randomly pick one
GAME_DIRS=()

while IFS= read -r dir; do
    GAME_DIRS+=("$dir")
done < <(find "$COMPATDATA_DIR" -mindepth 1 -maxdepth 1 -type d)

if [ "${#GAME_DIRS[@]}" -eq 0 ]; then
    echo "ERROR: No game folders inside compatdata"
    exit 1
fi

echo "Found ${#GAME_DIRS[@]} game(s) inside compatdata"

# Randomly pick one of the game folders
INDEX=$((RANDOM % ${#GAME_DIRS[@]}))
GAMEID_DIR="${GAME_DIRS[$INDEX]}"

# Removes the path to the compatdata folder, leaving only the game ID
GAME_ID=$(basename "$GAMEID_DIR")

echo "Selected Game ID: $GAME_ID"

# Navigate to game's page
echo "Navigating to game's page on Steam..."
steam steam://nav/games/details/$GAME_ID

# For other Steam URL Protocol commands check the documentation:
# https://developer.valvesoftware.com/wiki/Steam_browser_protocol

