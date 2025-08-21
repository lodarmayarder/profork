#!/bin/bash

# === BUA Detection ===
if [ -d "/userdata/system/add-ons" ]; then
    rm -f /userdata/roms/ports/Profork.sh
    rm -r /userdata/roms/ports/Profork.sh.keys
    clear
    echo "BUA detected."
    echo "Dual installs not supported"
    echo "Goodbye."
    echo
exit 0
fi

   
# Detect system architecture
ARCH=$(uname -m)

if [ "$ARCH" = "aarch64" ]; then
    echo "ARM64 (aarch64) detected. Loading ARM Menu..."
    sleep 2
    curl -Ls https://github.com/profork/profork/raw/master/app/arm_menu.sh | bash
    exit 0
fi



# Ensure /userdata/system/pro exists
mkdir -p /userdata/system/pro

# Set and export DIALOGRC if missing
DIALOGRC_FILE="/userdata/system/pro/.dialogrc"
if [ ! -f "$DIALOGRC_FILE" ]; then
    echo "Downloading .dialogrc for custom dialog colors..."
    curl -Ls https://github.com/profork/profork/raw/master/.dep/.dialogrc -o "$DIALOGRC_FILE"
fi

export DIALOGRC="$DIALOGRC_FILE"



if [ "$ARCH" != "x86_64" ]; then
    echo "This script only runs on x86_64 (AMD/Intel) or aarch64 (ARM64)."
    exit 1
fi

echo "x86_64 (AMD/INTEL) detected. Loading Main Menu....."
sleep 2

# Colors for animation
RED='\e[0;31m'
YELLOW='\e[1;33m'
NC='\e[0m' # No Color

animate_text() {
    local text="$1"
    echo -e "$text"
    sleep 0.
}

clear
curl -Ls https://github.com/profork/profork/raw/master/app/check.sh | bash

animate_text "${YELLOW}⚠️  Important Notice ⚠️${NC}"
animate_text "${YELLOW}The apps on this repository are provided AS-IS.${NC}"
animate_text "${RED}DO NOT ask for help in the Batocera Discord.${NC}"
animate_text "${RED}They will NOT help you and will REFUSE support if they are made aware unofficial apps are installed.${NC}"
animate_text "${YELLOW}Support is not available. Use at your own risk.${NC}"


echo -e "${NC}"
sleep 4

# Define the options
OPTIONS=("1" "Multi-App Arch Container"
         "2" "Standalone Apps (mostly appimages)"
         "3" "Docker & Containers"
         "4" "Tools"
         "5" "Wine tools and Wine Custom Downloader for v40+"
         "6" "Flatpak Apps"
         "7" "Flatpak Linux Games"
         "8" "Other Linux & Windows/Wine Freeware games"
         "9" "Install Portmaster"             
         "99" "Exit")
while true; do
CHOICE=$(dialog --clear --backtitle "Profork Main Menu" \
                --title "Main Menu" \
                --menu "Choose an option:" 20 80 3 \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear

case $CHOICE in
    1)
        echo "Arch Container..."
        curl -Ls https://github.com/profork/profork/raw/master/steam/steam.sh | bash
        ;;
    2)
        echo "Apps Menu"
        rm /tmp/runner 2>/dev/null
        wget -q --tries=30 --no-check-certificate --no-cache --no-cookies -O /tmp/runner https://github.com/profork/profork/raw/master/app/appmenu.sh
        dos2unix /tmp/runner 2>/dev/null 
        chmod 777 /tmp/runner 2>/dev/null
        bash /tmp/runner
        ;;
    3)
        echo "Docker Menu..."
        rm /tmp/runner 2>/dev/null
        wget -q --tries=30 --no-check-certificate --no-cache --no-cookies -O /tmp/runner https://github.com/profork/profork/raw/master/app/dockermenu.sh
        dos2unix /tmp/runner 2>/dev/null 
        chmod 777 /tmp/runner 2>/dev/null
        bash /tmp/runner
        ;;
    4)
        echo "Tools Menu..."
        rm /tmp/runner 2>/dev/null
        wget -q --tries=30 --no-check-certificate --no-cache --no-cookies -O /tmp/runner https://github.com/profork/profork/raw/master/app/tools.sh
        chmod 777 /tmp/runner 2>/dev/null
        bash /tmp/runner
        ;;
    5)
        echo "Wine Custom...."
        curl -Ls https://github.com/profork/profork/raw/master/wine-custom/wine.sh | bash
        ;;              
    6)
        echo "Flatpak Apps..."
        curl -Ls https://raw.githubusercontent.com/profork/profork/master/app/fp1.sh | bash
        ;;         
    7)
        echo "Flatpak Linux Games..."
        curl -Ls https://raw.githubusercontent.com/profork/profork/master/app/fpg.sh | bash
        ;;            
    8)
        echo "Other Linux & Windows/Wine Freeware..."
        curl -Ls https://github.com/profork/profork/raw/master/app/wquashfs.sh | bash
        ;;             
    9)
        echo "Portmaster Installer..."
        curl -Ls https://github.com/profork/profork/raw/master/portmaster/portmaster_x64.sh | bash
       ;;
   
    99)
        echo "Exiting..."
        exit
        ;;
    *)
        echo "No valid option selected or cancelled. Exiting."
        ;;
    esac
done
