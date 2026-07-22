#!/bin/bash

# Put this script on your SSD at root level and name it "launch.sh" (without quotes). 

#### This script will automatically detects all the games on this storage device and search through  ####
#### the user's configs to find the Collection ID that has all/most of these games on the cartridge. ####
# Meant for cartridges with multiple games


set -e
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$ROOT/launch.log"

# Log all stdout and stderr to a log file for debugging purposes
exec > >(tee "$LOG_FILE") 2>&1

# ------------------------------------------
# Find Game IDs
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

# Extract Game IDs from the game directories
for GAME_DIR in "${GAME_DIRS[@]}"; do
    GAME_ID=$(basename "$GAME_DIR")
    GAME_IDS+=("$GAME_ID")
    echo "Found game: $GAME_ID"
done

# ------------------------------------------
# Find Steam's root directory
# ------------------------------------------

# Common locations for steam installations on Linux
STEAM_LOCATIONS=(
    "$HOME/.steam/root"
    "$HOME/.local/share/Steam"
    "$HOME/.var/app/com.valvesoftware.Steam/.steam/steam"
)

STEAM_ROOT=""

for path in "${STEAM_LOCATIONS[@]}"; do
    if [ -d "$path/userdata" ]; then
        STEAM_ROOT="$path"
        break
    fi
done

if [ -z "$STEAM_ROOT" ]; then
    echo "Steam installation folder not found"
    exit 1
fi

echo "Steam root found: $STEAM_ROOT"

# -----------------------------------
# Find all Steam user collections
# -----------------------------------

STEAM_USERDATA="$STEAM_ROOT/userdata"

COLLECTION_FILES=$(find "$STEAM_USERDATA" \
    -path "*/config/cloudstorage/*" \
    -type f)

if [ -z "$COLLECTION_FILES" ]; then
    echo "No Steam cloudstorage files found."
    exit 1
fi

echo "Searching Steam collections..."

COLLECTION_IDS=()
COLLECTION_NAMES=()
COLLECTION_GAMES=()

while IFS= read -r FILE; do

    while read -r KEY; do

        COLLECTION_ID="${KEY#user-collections.}"

        DATA=$(grep -ao "\"key\":\"user-collections\.$COLLECTION_ID\"[^}]*}" "$FILE" | head -n1)

        if echo "$DATA" | grep -q '"is_deleted":true'; then
            continue
        fi

        if [ -n "$DATA" ]; then

            NAME=$(echo "$DATA" | sed -n 's/.*\\"name\\":\\"\([^"]*\)\\".*/\1/p')

            GAMES=$(echo "$DATA" | sed -n 's/.*\\"added\\":\[\([^]]*\)\].*/\1/p')

            echo "--------------------------------"
            echo "Collection ID: $COLLECTION_ID"
            echo "Name: $NAME"
            echo "Games: $GAMES"

            COLLECTION_IDS+=("$COLLECTION_ID")
            COLLECTION_NAMES+=("$NAME")
            COLLECTION_GAMES+=("$GAMES")

        fi

    done < <(grep -ao 'user-collections\.uc-[A-Za-z0-9]*' "$FILE" | sort -u)

done <<< "$COLLECTION_FILES"

# ------------------------------------------------------------------------
# Find the best matching collection based on the games on the cartridge
# ------------------------------------------------------------------------


BEST_INDEX=-1
BEST_SCORE=-1

for i in "${!COLLECTION_IDS[@]}"; do

    SCORE=0

    IFS=',' read -ra GAMES <<< "${COLLECTION_GAMES[$i]}"

    for CART_GAME in "${GAME_IDS[@]}"; do
        for COLLECTION_GAME in "${GAMES[@]}"; do
            if [ "$CART_GAME" = "$COLLECTION_GAME" ]; then
                SCORE=$((SCORE + 1))
                break
            fi
        done
    done

    echo
    echo "Collection: ${COLLECTION_NAMES[$i]}"
    echo "Score: $SCORE"

    if [ "$SCORE" -gt "$BEST_SCORE" ]; then
        BEST_SCORE=$SCORE
        BEST_INDEX=$i
    fi

done

if [ "$BEST_INDEX" -ge 0 ]; then
    echo "Most likely Collection: ${COLLECTION_NAMES[$BEST_INDEX]}"
    echo "Collection ID: ${COLLECTION_IDS[$BEST_INDEX]}"
    echo "Matching games: $BEST_SCORE"
else
    echo "No matching collection found."
    exit 1
fi


# Navigate to game's page
echo "Switching to Big Picture mode and navigating to the most likely Steam collection..."
steam steam://open/bigpicture
sleep 5  # Wait for Big Picture mode to load for a bit before sending nav command
steam steam://nav/games/library/collection/${COLLECTION_IDS[$BEST_INDEX]}

# For other Steam URL Protocol commands check the documentation:
# https://developer.valvesoftware.com/wiki/Steam_browser_protocol

