#!/usr/bin/env bash 
# Check if Xwayland is running
if ! pgrep -x "Xwayland" > /dev/null; then
    echo "❌ Xwayland is not running. Exiting."
    exit 1
fi
# PROFORK INSTALLER
######################################################################
#--------------------------------------------------------------------- 
#       DEFINE APP INFO >> 
APPNAME=youtube-music 
APPHOME="github.com# === Pick ONE AppImage URL for arm64 (aarch64) without regex ===
API="https://api.github.com/repos/ytmd-devs/ytmd/releases/latest"

# 1) Prefer explicit arm64 AppImage
APPLINK=$(curl -fsSL "$API" \
  | jq -r '.assets[] | select(.name | endswith("arm64.AppImage")) | .browser_download_url' \
  | head -n1)

# 2) Fallback: generic AppImage (no arch suffix at all)
if [ -z "$APPLINK" ] || [ "$APPLINK" = "null" ]; then
  APPLINK=$(curl -fsSL "$API" \
    | jq -r '.assets[] | select(.name | (endswith(".AppImage")
        and (contains("x86_64")|not)
        and (contains("armv7l")|not)
        and (contains("ia32")|not))) | .browser_download_url' \
    | head -n1)
fi

# 3) Fallback: any AppImage (last resort)
if [ -z "$APPLINK" ] || [ "$APPLINK" = "null" ]; then
  APPLINK=$(curl -fsSL "$API" \
    | jq -r '.assets[] | select(.name | endswith(".AppImage")) | .browser_download_url' \
    | head -n1)
fi

# Sanity check
if [ -z "$APPLINK" ] || [ "$APPLINK" = "null" ]; then
  echo "Failed to find a suitable AppImage in latest release."
  exit 1
fi
"
#---------------------------------------------------------------------

#Download URL from GitHub

# === Pick ONE AppImage URL for arm64 (aarch64) without regex ===
API="https://api.github.com/repos/# === Pick ONE AppImage URL for arm64 (aarch64) without regex ===
API="https://api.github.com/repos/ytmd-devs/ytmd/releases/latest"

# 1) Prefer explicit arm64 AppImage
APPLINK=$(curl -fsSL "$API" \
  | jq -r '.assets[] | select(.name | endswith("arm64.AppImage")) | .browser_download_url' \
  | head -n1)

# 2) Fallback: generic AppImage (no arch suffix at all)
if [ -z "$APPLINK" ] || [ "$APPLINK" = "null" ]; then
  APPLINK=$(curl -fsSL "$API" \
    | jq -r '.assets[] | select(.name | (endswith(".AppImage")
        and (contains("x86_64")|not)
        and (contains("armv7l")|not)
        and (contains("ia32")|not))) | .browser_download_url' \
    | head -n1)
fi

# 3) Fallback: any AppImage (last resort)
if [ -z "$APPLINK" ] || [ "$APPLINK" = "null" ]; then
  APPLINK=$(curl -fsSL "$API" \
    | jq -r '.assets[] | select(.name | endswith(".AppImage")) | .browser_download_url' \
    | head -n1)
fi

# Sanity check
if [ -z "$APPLINK" ] || [ "$APPLINK" = "null" ]; then
  echo "Failed to find a suitable AppImage in latest release."
  exit 1
fi
/releases/latest"

# 1) Prefer explicit arm64 AppImage
APPLINK=$(curl -fsSL "$API" \
  | jq -r '.assets[] | select(.name | endswith("arm64.AppImage")) | .browser_download_url' \
  | head -n1)

# 2) Fallback: generic AppImage (no arch suffix at all)
if [ -z "$APPLINK" ] || [ "$APPLINK" = "null" ]; then
  APPLINK=$(curl -fsSL "$API" \
    | jq -r '.assets[] | select(.name | (endswith(".AppImage")
        and (contains("x86_64")|not)
        and (contains("armv7l")|not)
        and (contains("ia32")|not))) | .browser_download_url' \
    | head -n1)
fi

# 3) Fallback: any AppImage (last resort)
if [ -z "$APPLINK" ] || [ "$APPLINK" = "null" ]; then
  APPLINK=$(curl -fsSL "$API" \
    | jq -r '.assets[] | select(.name | endswith(".AppImage")) | .browser_download_url' \
    | head -n1)
fi

# Sanity check
if [ -z "$APPLINK" ] || [ "$APPLINK" = "null" ]; then
  echo "Failed to find a suitable AppImage in latest release."
  exit 1
fi

echo "Downloading from: $APPLINK"
curl -L -o /userdata/system/pro/youtube-music/YouTube-Music-arm64.AppImage "$APPLINK"
echo "Download complete!"



# Validate if APPLINK was found
if [ -z "$APPLINK" ]; then
  echo "Failed to retrieve the latest release URL. Exiting..."
  exit 1
fi

#---------------------------------------------------------------------
#       DEFINE LAUNCHER COMMAND >>
COMMAND='mkdir /userdata/system/pro/'$APPNAME'/home 2>/dev/null; mkdir /userdata/system/pro/'$APPNAME'/config 2>/dev/null; mkdir /userdata/system/pro/'$APPNAME'/roms 2>/dev/null; LD_LIBRARY_PATH="/userdata/system/pro/.dep:${LD_LIBRARY_PATH}" HOME=/userdata/system/pro/'$APPNAME'/home XDG_CONFIG_HOME=/userdata/system/pro/'$APPNAME'/config QT_SCALE_FACTOR="1" GDK_SCALE="1" XDG_DATA_HOME=/userdata/system/pro/'$APPNAME'/home DISPLAY=:0.0 /userdata/system/pro/'$APPNAME'/'$APPNAME'.AppImage --appimage-extract-and-run --no-sandbox --disable-gpu "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"'
#--------------------------------------------------------------------- 
######################################################################
APPNAME="${APPNAME^^}"; ORIGIN="${APPHOME^^}"; appname=$(echo "$APPNAME" | awk '{print tolower($0)}'); AppName=$appname; APPPATH=/userdata/system/pro/$appname/$AppName.AppImage
# --------------------------------------------------------------------
# show console/ssh info: 
clear 
echo 
echo 
echo 
echo -e "${X}PREPARING $APPNAME INSTALLER, PLEASE WAIT . . . ${X}"
echo 
echo 
echo 
# --------------------------------------------------------------------
# -- output colors:
###########################
X='\033[0m'               # 
W='\033[0m'               # 
#-------------------------#
RED='\033[0m'             # 
BLUE='\033[0m'            # 
GREEN='\033[0m'           # 
PURPLE='\033[0m'          # 
DARKRED='\033[0m'         # 
DARKBLUE='\033[0m'        # 
DARKGREEN='\033[0m'       # 
DARKPURPLE='\033[0m'      # 
###########################
# --------------------------------------------------------------------
# -- prepare paths and files for installation: 
cd ~/
pro=/userdata/system/pro
mkdir $pro 2>/dev/null
mkdir $pro/extra 2>/dev/null
rm -rf $pro/$appname 2>/dev/null
mkdir $pro/$appname 2>/dev/null
mkdir $pro/$appname/extra 2>/dev/null
# --------------------------------------------------------------------
# -- pass launcher command as cookie for master function: 
command=$pro/$appname/extra/command; rm $command 2>/dev/null;
echo "$COMMAND" >> $command 2>/dev/null 
# --------------------------------------------------------------------
# -- prepare dependencies for this app and the installer: 
mkdir -p ~/pro/.dep 2>/dev/null && cd ~/pro/.dep && wget --tries=10 --no-check-certificate --no-cache --no-cookies -q -O ~/pro/.dep/dep.zip https://github.com/profork/profork/raw/master/.dep/dep_arm64.zip && yes "y" | unzip -oq ~/pro/.dep/dep.zip && cd ~/
wget --tries=10 --no-check-certificate --no-cache --no-cookies -q -O $pro/$appname/extra/icon.png https://github.com/profork/profork/raw/master/$appname/extra/icon.png; chmod a+x $dep/* 2>/dev/null; cd ~/
chmod 777 ~/pro/.dep/* && for file in /userdata/system/pro/.dep/lib*; do sudo ln -s "$file" "/usr/lib/$(basename $file)"; done
# --------------------------------------------------------------------
# // end of dependencies 
#
# --------------------------------------------------------------------
# -- run before installer:  
#killall wget 2>/dev/null && killall $AppName 2>/dev/null && killall $AppName 2>/dev/null && killall $AppName 2>/dev/null
# --------------------------------------------------------------------
cols=$($dep/tput cols); rm -rf /userdata/system/pro/$appname/extra/cols
echo $cols >> /userdata/system/pro/$appname/extra/cols
line(){
echo 1>/dev/null
}
# -- show console/ssh info: 
clear
echo
echo
echo
echo -e "${X}PROFORK/$APPNAME INSTALLER${X}"
echo
echo
echo
echo
sleep 0.33
clear
echo
echo
echo -e "${W}- - -"
echo -e "${X}PROFORK/$APPNAME INSTALLER${X}"
echo -e "${W}- - -"
echo
echo
echo
sleep 0.33
clear
echo
echo -e "${W}- - -"
line $cols ' '; echo
echo -e "${X}PROFORK/$APPNAME INSTALLER${X}"
line $cols ' '; echo
echo -e "${W}- - -"
echo
echo
sleep 0.33
clear
line $cols '\'; echo
line $cols '/'; echo
line $cols ' '; echo
echo -e "${X}PROFORK/$APPNAME INSTALLER${X}"
line $cols ' '; echo
line $cols '/'; echo
line $cols '\'; echo
echo
sleep 0.33
echo -e "${X}THIS WILL INSTALL $APPNAME FOR BATOCERA"
echo -e "${X}USING $ORIGIN"
echo
echo -e "${X}$APPNAME WILL BE AVAILABLE IN PORTS"
echo -e "${X}AND ALSO IN THE F1->APPLICATIONS MENU"
echo -e "${X}AND INSTALLED IN /USERDATA/SYSTEM/PRO/$APPNAME"
echo
echo -e "${X}FOLLOW THE BATOCERA DISPLAY"
echo
echo -e "${X}. . .${X}" 
echo
# --------------------------------------------------------------------
#\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
# -- THIS WILL BE SHOWN ON MAIN BATOCERA DISPLAY:   
function batocera-pro-installer {
APPNAME="$1"
appname="$2"
AppName="$3"
APPPATH="$4"
APPLINK="$5"
ORIGIN="$6"
# --------------------------------------------------------------------
# -- colors: 
###########################
X='\033[0m'               # 
W='\033[0m'               # 
#-------------------------#
RED='\033[0m'             # 
BLUE='\033[0m'            # 
GREEN='\033[0m'           # 
PURPLE='\033[0m'          # 
DARKRED='\033[0m'         # 
DARKBLUE='\033[0m'        # 
DARKGREEN='\033[0m'       # 
DARKPURPLE='\033[0m'      # 
###########################
# -- display theme:
L=$W
T=$W
R=$RED
B=$BLUE
G=$GREEN
P=$PURPLE
# --------------------------------------------------------------------
cols=$(cat /userdata/system/pro/.dep/display.cfg | tail -n 1)
cols=$(bc <<<"scale=0;$cols/1.3") 2>/dev/null
line(){
echo 1>/dev/null
}
clear
echo
echo
echo
echo -e "${W}PROFORK/${G}$APPNAME${W} INSTALLER ${W}"
echo
echo
echo
echo
sleep 0.33
clear
echo
echo
echo
echo -e "${W}PROFORK/${W}$APPNAME${W} INSTALLER ${W}"
echo
echo
echo
echo
sleep 0.33
clear
echo
echo
echo -e "${W}- - -"
echo -e "${W}PROFORK/${G}$APPNAME${W} INSTALLER ${W}"
echo -e "${W}- - -"
echo
echo
echo
sleep 0.33
clear
echo
echo -e "${W}- - -"
echo; 
echo -e "${W}PROFORK/${W}$APPNAME${W} INSTALLER ${W}"
echo; 
echo -e "${W}- - -"
echo
echo
sleep 0.33
clear
echo -e "${W}- - -"
echo; 
echo; 
echo -e "${W}PROFORK/${G}$APPNAME${W} INSTALLER ${W}"
echo; 
echo; 
echo -e "${W}- - -"
echo
sleep 0.33
echo -e "${W}THIS WILL INSTALL $APPNAME FOR BATOCERA"
echo -e "${W}USING $ORIGIN"
echo
echo -e "${W}$APPNAME WILL BE AVAILABLE IN PORTS"
echo -e "${W}AND ALSO IN THE F1->APPLICATIONS MENU"
echo -e "${W}AND INSTALLED IN /USERDATA/SYSTEM/PRO/$APPNAME"
echo 
# --------------------------------------------------------------------
# -- check system before proceeding
if [[ "$(uname -a | grep "aarch64")" != "" ]]; then 
:
else
echo
echo -e "${RED}ERROR: SYSTEM NOT SUPPORTED"
echo -e "${RED}YOU NEED BATOCERA ARM64${X}"
echo
sleep 5
exit 0
fi
# --------------------------------------------------------------------
# -- temp for curl download
pro=/userdata/system/pro
temp=$pro/$appname/extra/downloads
rm -rf $temp 2>/dev/null 
mkdir -p $temp 2>/dev/null
# --------------------------------------------------------------------
#
echo
echo -e "${G}DOWNLOADING${W} $APPNAME . . ."
sleep 1
echo -e "${T}$APPLINK" | sed 's,https://,> ,g' | sed 's,http://,> ,g' 2>/dev/null
cd $temp
curl --progress-bar --remote-name --location "$APPLINK"
cd ~/
mv $temp/* $APPPATH 2>/dev/null
chmod a+x $APPPATH 2>/dev/null
rm -rf $temp/*.AppImage
SIZE=$(($(wc -c $APPPATH | awk '{print $1}')/1048576)) 2>/dev/null
echo -e "${T}$APPPATH ${T}$SIZE( )MB ${G}OK${W}" | sed 's/( )//g'
echo -e "${G}> ${W}DONE" 
echo
sleep 1.333 
# 
# -------------------------------------------------------------------- 
echo -e "${G}INSTALLING${W}" 
# -- prepare launcher to solve dependencies on each run and avoid overlay, 
launcher=/userdata/system/pro/$appname/Launcher
rm -rf $launcher
echo '#!/bin/bash ' >> $launcher
echo 'unclutter-remote -s' >> $launcher 
## -- GET APP SPECIFIC LAUNCHER COMMAND: 
######################################################################
echo "$(cat /userdata/system/pro/$appname/extra/command)" >> $launcher
######################################################################
dos2unix $launcher
chmod a+x $launcher
rm /userdata/system/pro/$appname/extra/command 2>/dev/null
# --------------------------------------------------------------------
# -- prepare f1 - applications - app shortcut, 
shortcut=/userdata/system/pro/$appname/extra/$appname.desktop
rm -rf $shortcut 2>/dev/null
echo "[Desktop Entry]" >> $shortcut
echo "Version=1.0" >> $shortcut
echo "Icon=/userdata/system/pro/$appname/extra/icon.png" >> $shortcut
echo "Exec=/userdata/system/pro/$appname/Launcher" >> $shortcut
echo "Terminal=false" >> $shortcut
echo "Type=Application" >> $shortcut
echo "Categories=Game;batocera.linux;" >> $shortcut
echo "Name=$appname" >> $shortcut
f1shortcut=/usr/share/applications/$appname.desktop
dos2unix $shortcut 
chmod a+x $shortcut 
cp $shortcut $f1shortcut 2>/dev/null
# --------------------------------------------------------------------
# -- prepare Ports file, 
port=/userdata/system/pro/$appname/youtube-music.sh 
cp /userdata/system/pro/$appname/Launcher $port 
dos2unix $port 
chmod a+x $port 
cp $port "/userdata/roms/ports/$appname.sh" 
# --------------------------------------------------------------------
# --------------------------------------------------------------------
# -- prepare prelauncher to avoid overlay,
pre=/userdata/system/pro/$appname/extra/startup
rm -rf $pre 2>/dev/null
echo "#!/usr/bin/env bash" >> $pre
echo "cp /userdata/system/pro/$appname/extra/$appname.desktop /usr/share/applications/ 2>/dev/null" >> $pre
dos2unix $pre
chmod a+x $pre
# -- add prelauncher to custom.sh to run @ reboot
csh=/userdata/system/custom.sh
if [[ -e $csh ]] && [[ "$(cat $csh | grep "/userdata/system/pro/$appname/extra/startup")" = "" ]]; then
echo -e "\n/userdata/system/pro/$appname/extra/startup" >> $csh
fi
if [[ -e $csh ]] && [[ "$(cat $csh | grep "/userdata/system/pro/$appname/extra/startup" | grep "#")" != "" ]]; then
echo -e "\n/userdata/system/pro/$appname/extra/startup" >> $csh
fi
if [[ -e $csh ]]; then :; else
echo -e "\n/userdata/system/pro/$appname/extra/startup" >> $csh
fi
dos2unix $csh
sleep 1
echo -e "${G}> ${W}DONE${W}"
echo
sleep 1
echo; 
echo -e "${W}> $APPNAME INSTALLED ${G}OK${W}"
sleep 3
}
export -f batocera-pro-installer 2>/dev/null
# --------------------------------------------------------------------
# RUN:
# |
  batocera-pro-installer "$APPNAME" "$appname" "$AppName" "$APPPATH" "$APPLINK" "$ORIGIN"
# --------------------------------------------------------------------
# PROFORK INSTALLER //
##########################
function autostart() {
  csh="/userdata/system/custom.sh"
  pcsh="/userdata/system/pro-custom.sh"
  pro="/userdata/system/pro"
  rm -f $pcsh
  temp_file=$(mktemp)
  find $pro -type f \( -path "*/extra/startup" -o -path "*/extras/startup.sh" \) > $temp_file
  echo "#!/bin/bash" > $pcsh
  sort $temp_file >> $pcsh
  rm $temp_file
  chmod a+x $pcsh
  temp_csh=$(mktemp)
  grep -vxFf $pcsh $csh > $temp_csh
  mapfile -t lines < $temp_csh
  if [[ "${lines[0]}" != "#!/bin/bash" ]]; then
    lines=( "#!/bin/bash" "${lines[@]}" )
  fi
  if ! grep -Fxq "$pcsh &" $temp_csh; then
    lines=( "${lines[0]}" "$pcsh &" "${lines[@]:1}" )
  fi
  printf "%s\n" "${lines[@]}" > $csh
  chmod a+x $csh
  rm $temp_csh
}
export -f autostart
autostart
exit 0
