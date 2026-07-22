#!/bin/sh

# Put this script on your SSD at root level and name it "launch.sh" (without quotes).

#### This script will launch the game from the specified entry point (e.g. start.sh). ####
# Meant for single game cartridges.

set -e
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$ROOT/launch.log"

# Log all stdout and stderr to a log file for debugging purposes
exec > >(tee "$LOG_FILE") 2>&1

# ------------------------------------------
# Define game's entry point
# ------------------------------------------

GAME_ENTRYPOINT="$ROOT/path/to/your/game/start.sh"  # Replace this with the actual path to your game's entry point script

# ------------------------------------------
# Restore graphical session environment
# ------------------------------------------

export XDG_RUNTIME_DIR="/run/user/$(id -u)"

if [ -z "$DISPLAY" ]; then
    export DISPLAY=:0
fi

if [ -z "$WAYLAND_DISPLAY" ]; then
    export WAYLAND_DISPLAY=wayland-0
fi


# ------------------------------------------
# Start the game
# ------------------------------------------

if [ ! -f "$GAME_ENTRYPOINT" ]; then
    echo "ERROR: Game entrypoint not found: $GAME_ENTRYPOINT"
    exit 1
fi

echo "Launching game..."
chmod +x "$GAME_ENTRYPOINT"
"$GAME_ENTRYPOINT"



