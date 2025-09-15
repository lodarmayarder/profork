#!/bin/bash

# Colors for animation
RED='\e[0;31m'
YELLOW='\e[1;33m'
NC='\e[0m' # No Color

# Function to display animated text faster
animate_text() {
    local text="$1"
    echo -e "$text"
    sleep 0.
}

clear

# Display Warning Message
animate_text "${YELLOW}⚠️  Important Notice ⚠️${NC}"
animate_text "${YELLOW}The apps on this repository are provided AS-IS.${NC}"

animate_text "${RED}DO NOT ask for help in the Batocera Discord.${NC}"
animate_text "${RED}They will NOT help you and will REFUSE support if they are made aware unofficial apps are installed.${NC}"

animate_text "${YELLOW}Use at your own risk.${NC}"

# Reset color
echo -e "${NC}"



sleep 10

# Define the options
OPTIONS=("1" "Install Portmaster"
         "2" "Install Librewolf Web Browser (XWAYLAND)"
         "3" "Install Aethersx2 (For Qualcomm SoCs -- RK3588 like OPI5 should Use Rocknix)"
         "4" "Restore Mame .0139 to v41+"         
         "5" "Youtube TV UI (XWAYLAND)"
         "6" "Youtube Music (XWAYLAND)"
         "7" "X-Minecraft Launcher (XWAYLAND - EXPERIMENTAL)"
         "8" "Chiaki-NG (XWAYLAND)"
         "9" "Amazon-Luna (XWAYLAND)"
         "10" "Xcloud (XWAYLAND)"
         "11" "Greenlight (XWAYLAND)"
         "12" "Chromium Web Browser (XWAYLAND)"
         "13" "Firefox"
         "14" "PKGX cli tools"
         "15" "Soar cli tools and apps"
        "16" "Flatpak Apps (for custom Builds)"
        "17" "Flatpak Games (for custom builds)"
        "18" "Emudeck Store and Reg-Linux Homebrew ROMS"
        "19" "ARCH XFCE DESKTOP MODE - RUNIMAGE (XWAYLAND)"
        "20" "Docker Menu (Jellyfin, Plex server, Emby, Nextcloud, CasaOs Umbrel, etc)"
        "99" "Exit")
         
# Display the dialog and get the user choice
while true; do
CHOICE=$(dialog --clear --backtitle "Profork Main Menu" \
                --title "Main Menu" \
                --menu "Choose an option:" 25 120 3 \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear

# Act based on the user choice
case $CHOICE in
    1)
        echo "Portmaster Installer..."
        curl -Ls https://github.com/profork/profork/raw/master/portmaster/install.sh | bash
        ;;
    2)
        echo "Librewolf Web Browser Installer..."
        curl -Ls https://github.com/profork/profork/raw/master/librewolf/install_arm64.sh | bash
        ;;   
    3)
        echo "AetherSX2 Experimental..."
        curl -Ls https://raw.githubusercontent.com/profork/profork/refs/heads/master/aethersx2/aethersx2.sh | bash
        ;;    
    4)
        echo "Mame 0139 for v41+..."
        curl -Ls https://github.com/profork/profork/raw/master/mame2010_v41%2B/2010_arm64.sh | bash
        ;;                
    5)
        echo "Youtube on TV..."
        curl -Ls  https://github.com/profork/profork/raw/master/youtubetv/yttv-arm64.sh | bash
        ;;   
    6)
        echo "Youtube Music..."
        curl -Ls https://github.com/profork/profork/raw/master/youtube-music/ytm-arm64.sh | bash     
        ;;
    7)
        echo "X-Minecraft-Launcher..."
        curl -Ls  https://github.com/profork/profork/raw/master/xmcl/xmcl-arm64.sh | bash
        ;;   
    8)
        echo "Chiaki-NG..."
        curl -Ls https://github.com/profork/profork/raw/master/chiaki/chiaki-arm64.sh | bash
        ;;

    9) echo "Amazon-Luna..."
       curl -Ls https://github.com/profork/profork/raw/master/amazonluna/amazonluna-arm64.sh | bash
       ;;
   
   10) echo "Xcloud..."
       curl -Ls https://github.com/profork/profork/raw/master/xcloud/xcloud-arm64.sh | bash
       ;;

   11) echo "Greenlight..."
       curl -Ls https://github.com/profork/profork/raw/master/greenlight/greenlight-arm64.sh | bash
       ;;

   12) echo "Chromium..."
        curl -Ls https://github.com/profork/profork/raw/master/chromium/chromium-arm64.sh | bash 
        ;;
   13) echo "Firefox..."
        curl -Ls https://github.com/profork/profork/raw/master/firefox/firefox-aarch64.sh | bash 
        ;;
   14) echo "Pkg-X..."
        curl -Ls https://github.com/profork/profork/raw/master/scripts/pkgx-arm.sh | bash 
        ;;
   15) echo "Soar..."
        curl -Ls https://github.com/profork/profork/raw/master/scripts/soar-arm64.sh | bash 
        ;;   
   16) echo "Flatpak Apps..."
        curl -Ls https://github.com/profork/profork/raw/master/app/fp1a.sh | bash 
        ;;
  
   17) echo "Flatpak Games..."
        curl -Ls https://github.com/profork/profork/raw/master/app/fpg1.sh | bash 
        ;;     
   18)  
       echo "Emudeck/Reg-linux Homebrew Games..."
       curl -Ls https://github.com/profork/profork/raw/master/emudeck/homebrew.sh | bash
       ;;
  19) echo "Arch Desktop XFCE conatiner..."
        curl -Ls  https://github.com/profork/profork/raw/master/runimage/ri-desk-aarch64.sh | bash 
        ;;         
  20) echo "Docker Menu"
      curl -L https://github.com/profork/profork/raw/master/app/docker-aarch64.sh | bash
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
