#!/bin/sh

SCRIPT_DIR="$(dirname "$0")"

# Colors
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RESET="\033[0m"

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


echo "        ╭────────────────────────────────────────╮"
echo "        │      Menu                              │"
echo "        ├────────────────────────────────────────┤"
echo "        │   1) Install                           │"
echo "        │   2) Trust Scripts                     │"
echo "        │   3) Mode                              │"
echo "        │   4) Uninstall                         │"
echo "        │   5) Exit                              │"
echo "        ╰────────────────────────────────────────╯"
echo ""

read -rp "     Select option: " OPTION

case "$OPTION" in

    1)
        clear 2>/dev/null || printf "\033c"
        echo "Starting installation..."
        bash "$SCRIPT_DIR/linux/install.sh"
        ;;

    2)
        clear 2>/dev/null || printf "\033c"
        echo "Starting trust process..."
        bash "$SCRIPT_DIR/linux/trust-script.sh"
        ;;

    3)
        echo "Mode selection coming soon..."
        ;;

    4)
        clear 2>/dev/null || printf "\033c"
        echo "Starting uninstall..."
        bash "$SCRIPT_DIR/linux/uninstall.sh"
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