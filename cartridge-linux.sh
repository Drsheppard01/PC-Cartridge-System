#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"

CONFIG_DIR="$HOME/.config/steam-games-cartridges"
CONFIG_FILE="$CONFIG_DIR/settings.conf"


mkdir -p "$CONFIG_DIR"


if [ ! -f "$CONFIG_FILE" ]; then
    echo "MODE=running" > "$CONFIG_FILE"
fi

get_mode() {

    MODE=$(grep "^MODE=" "$CONFIG_FILE" | cut -d '=' -f2)

    if [ "$MODE" = "stopped" ]; then
        echo "stopped"
    else
        echo "running"
    fi

}


toggle_mode() {

    CURRENT_MODE=$(get_mode)


    if [ "$CURRENT_MODE" = "running" ]; then
        echo "MODE=stopped" > "$CONFIG_FILE"
    else
        echo "MODE=running" > "$CONFIG_FILE"
    fi

}


# Colors
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

MODE=$(get_mode)
if [ "$MODE" = "running" ]; then
    MODE_TEXT="\033[1;32mYes\033[0m"
else
    MODE_TEXT="\033[1;31mNo \033[0m"
fi

clear

echo -e "${CYAN}"
cat <<'EOF'
   ██████╗ █████╗ ██████╗ ████████╗██████╗ ██╗██████╗  ██████╗ ███████╗███████╗
  ██╔════╝██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██║██╔══██╗██╔════╝ ██╔════╝██╔════╝
  ██║     ███████║██████╔╝   ██║   ██████╔╝██║██║  ██║██║  ███╗█████╗  ███████╗
  ██║     ██╔══██║██╔══██╗   ██║   ██╔══██╗██║██║  ██║██║   ██║██╔══╝  ╚════██║
  ╚██████╗██║  ██║██║  ██║   ██║   ██║  ██║██║██████╔╝╚██████╔╝███████╗███████║
   ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═════╝  ╚═════╝ ╚══════╝╚══════╝
EOF
echo -e "${RESET}"


echo "        ╭─────────────────────────────────────────╮"
echo "        │      Menu                               │"
echo "        ├─────────────────────────────────────────┤"
echo "        │   1) Install                            │"
echo "        │   2) Trust Scripts / Check trust state  │"
echo -e "        │   3) Auto-Launch scripts: $MODE_TEXT           │"
echo "        │   4) Uninstall                          │"
echo "        │   5) Exit                               │"
echo "        ╰─────────────────────────────────────────╯"
echo ""

read -rp "     Select option: " OPTION

case "$OPTION" in

    1)
        clear 2>/dev/null || printf "\033c"
        echo "Starting installation..."
        sudo bash "$SCRIPT_DIR/linux/install.sh"
        ;;

    2)
        clear 2>/dev/null || printf "\033c"
        echo "Starting trust process..."
        bash "$SCRIPT_DIR/linux/trust-script.sh"
        ;;

    3)
        toggle_mode

        clear 2>/dev/null || printf "\033c"

        exec "$SCRIPT_DIR/cartridge-linux.sh"
        ;;

    4)
        clear 2>/dev/null || printf "\033c"
        echo "Starting uninstall..."
        sudo bash "$SCRIPT_DIR/linux/uninstall.sh"
        ;;

    5)
        echo "Exiting..."
        sleep 1
        clear 2>/dev/null || printf "\033c"
        exit 0
        ;;

    *)
        echo "Invalid option."
        exit 1
        ;;

esac

