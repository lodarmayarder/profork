#!/usr/bin/env bash 
######################################################################
# PROFORK/VACUUMTUBE INSTALLER
######################################################################
# --------------------------------------------------------------------
# --------------------------------------------------------------------
# --------------------------------------------------------------------
APPNAME=VACUUMTUBE # for installer info
appname=vacuumtube # directory name in /userdata/system/pro/...
AppName=$appname # App.AppImage name
APPPATH=/userdata/system/pro/$appname/$appname.AppImage
#APPLINK=http://PROFORK/app/$appname.AppImage


#APPLINK=http://PROFORK/app/$appname.AppImage
ORIGIN="GITHUB.COM/SHY1132/VACUUMTUBE-APPIMAGE" # credit & info

# --- resolve APPLINK with GitHub API (quiet) + fallback (NO DOWNLOAD HERE)
APPLINK=$(curl -fsSL https://api.github.com/repos/shy1132/VacuumTube/releases/latest 2>/dev/null \
  | jq -r '.assets[] | select(.name | endswith(".AppImage") and (.name | test("(?i)(x86_64|amd64)"))) | .browser_download_url' 2>/dev/null \
  | head -n1)
APPLINK=${APPLINK:-https://github.com/shy1132/VacuumTube/releases/latest/download/VacuumTube-x86_64.AppImage}


ORIGIN="GITHUB.COM/SHY1132/VACUUMTUBE-APPIMAGE" # credit & info
# --------------------------------------------------------------------
# --------------------------------------------------------------------
# --------------------------------------------------------------------
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
echo
# --------------------------------------------------------------------
# -- output colors:
###########################
W='\033[0;37m'            # white
#-------------------------#
RED='\033[1;31m'          # red
BLUE='\033[1;34m'         # blue
GREEN='\033[1;32m'        # green
PURPLE='\033[1;35m'       # purple
DARKRED='\033[0;31m'      # darkred
DARKBLUE='\033[0;34m'     # darkblue
DARKGREEN='\033[0;32m'    # darkgreen
DARKPURPLE='\033[0;35m'   # darkpurple
###########################
# console theme
X='\033[0m' # / resetcolor
L=$X
R=$X
# --------------------------------------------------------------------
# prepare paths and files for installation 
# paths:
cd ~/
pro=/userdata/system/pro
mkdir $pro 2>/dev/null
mkdir $pro/extra 2>/dev/null
mkdir $pro/$appname 2>/dev/null
mkdir $pro/$appname/extra 2>/dev/null
# --------------------------------------------------------------------
# -- prepare dependencies for this app and the installer: 
mkdir -p ~/pro/.dep 2>/dev/null && cd ~/pro/.dep && wget --tries=10 --no-check-certificate --no-cache --no-cookies -q -O ~/pro/.dep/dep.zip https://github.com/profork/profork/raw/master/.dep/dep.zip && yes "y" | unzip -oq ~/pro/.dep/dep.zip && cd ~/
wget --tries=10 --no-check-certificate --no-cache --no-cookies -q -O $pro/$appname/extra/icon.png https://github.com/profork/profork/raw/master/youtubetv/extra/icon.png; chmod a+x $dep/* 2>/dev/null; cd ~/
chmod 777 ~/pro/.dep/* && for file in /userdata/system/pro/.dep/lib*; do sudo ln -s "$file" "/usr/lib/$(basename $file)"; done
# --------------------------------------------------------------------
# // end of dependencies 
#
# RUN BEFORE INSTALLER: 
######################################################################
killall wget 2>/dev/null && killall $AppName 2>/dev/null && killall $AppName 2>/dev/null && killall $AppName 2>/dev/null
######################################################################
#
# --------------------------------------------------------------------
# show console/ssh info: 
clear
echo
echo
echo
echo -e "${X}PROFORK/$APPNAME INSTALLER${X}"
echo
echo
echo
echo
# --------------------------------------------------------------------
sleep 0.33
# --------------------------------------------------------------------
clear
echo
echo
echo -e "${X}--------------------------------------------------------"
echo -e "${X}PROFORK/$APPNAME INSTALLER${X}"
echo -e "${X}--------------------------------------------------------"
echo
echo
echo
# --------------------------------------------------------------------
sleep 0.33
# --------------------------------------------------------------------
clear
echo
echo -e "${X}--------------------------------------------------------"
echo -e "${X}--------------------------------------------------------"
echo -e "${X}PROFORK/$APPNAME INSTALLER${X}"
echo -e "${X}--------------------------------------------------------"
echo -e "${X}--------------------------------------------------------"
echo
echo
# --------------------------------------------------------------------
sleep 0.33
# --------------------------------------------------------------------
clear
echo -e "${X}--------------------------------------------------------"
echo -e "${X}--------------------------------------------------------"
echo -e "${X}--------------------------------------------------------"
echo -e "${X}PROFORK/$APPNAME INSTALLER${X}"
echo -e "${X}--------------------------------------------------------"
echo -e "${X}--------------------------------------------------------"
echo -e "${X}--------------------------------------------------------"
echo
# --------------------------------------------------------------------
sleep 0.33
echo -e "${X}THIS WILL INSTALL $APPNAME FOR BATOCERA"
echo -e "${X}USING $ORIGIN"
echo
echo -e "${X}$APPNAME WILL BE AVAILABLE IN F1->APPLICATIONS "
echo -e "${X}AND INSTALLED IN /USERDATA/SYSTEM/PRO/$appname"
echo
echo -e "${X}FOLLOW THE BATOCERA DISPLAY"
echo
echo -e "${X}. . .${X}" 
echo
# // end of console info. 
#
#/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
#
# THIS WILL BE SHOWN ON MAIN BATOCERA DISPLAY:   
function batocera-pro-installer {
APPNAME="$1"
appname="$2"
AppName="$3"
APPPATH="$4"
APPLINK="$5"
ORIGIN="$6"
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
# .
######################################################################
clear
echo
echo
echo
echo -e "${W}PROFORK/${G}$APPNAME${W} INSTALLER ${W}"
echo
echo
echo
echo
# --------------------------------------------------------------------
sleep 0.33
# --------------------------------------------------------------------
clear
echo
echo
echo
echo -e "${W}PROFORK/${W}$APPNAME${W} INSTALLER ${W}"
echo
echo
echo
echo
# --------------------------------------------------------------------
sleep 0.33
# --------------------------------------------------------------------
clear
echo
echo
echo -e "${L}-----------------------------------------------------------------------"
echo -e "${W}PROFORK/${G}$APPNAME${W} INSTALLER ${W}"
echo -e "${L}-----------------------------------------------------------------------"
echo
echo
echo
# --------------------------------------------------------------------
sleep 0.33
# --------------------------------------------------------------------
clear
echo
echo -e "${L}-----------------------------------------------------------------------"
echo -e "${L}-----------------------------------------------------------------------"
echo -e "${W}PROFORK/${W}$APPNAME${W} INSTALLER ${W}"
echo -e "${L}-----------------------------------------------------------------------"
echo -e "${L}-----------------------------------------------------------------------"
echo
echo
# --------------------------------------------------------------------
sleep 0.33
# --------------------------------------------------------------------
clear
echo -e "${L}-----------------------------------------------------------------------"
echo -e "${L}-----------------------------------------------------------------------"
echo -e "${L}-----------------------------------------------------------------------"
echo -e "${W}PROFORK/${G}$APPNAME${W} INSTALLER ${W}"
echo -e "${L}-----------------------------------------------------------------------"
echo -e "${L}-----------------------------------------------------------------------"
echo -e "${L}-----------------------------------------------------------------------"
echo
# --------------------------------------------------------------------
sleep 0.33
echo -e "${W}THIS WILL INSTALL $APPNAME FOR BATOCERA"
echo -e "${W}USING $ORIGIN"
echo
echo -e "${W}$APPNAME WILL BE AVAILABLE IN F1->APPLICATIONS "
echo -e "${W}AND INSTALLED IN /USERDATA/SYSTEM/PRO/$APPNAME"
echo
echo -e "${L}- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
# -- check system before proceeding
if [[ "$(uname -a | grep "x86_64")" != "" ]]; then 
:
else
echo
echo -e "${RED}ERROR: SYSTEM NOT SUPPORTED"
echo -e "${RED}YOU NEED BATOCERA X86_64${X}"
echo
sleep 5
exit 0
# quit
exit 0
fi
#
# -- temp for curl download
temp=/userdata/system/pro/$appname/extra/downloads
rm -rf $temp 2>/dev/null
mkdir $temp 2>/dev/null
#
# --------------------------------------------------------------------
#
echo
echo -e "${G}DOWNLOADING${W} $APPNAME . . ."
sleep 1
echo -e "${T}$APPLINK" | sed 's,https://,> ,g' | sed 's,http://,> ,g' 2>/dev/null

# download
curl -fL --progress-bar -o "$APPPATH" "$APPLINK"
chmod +x "$APPPATH"

# safe size calc
if [ -s "$APPPATH" ]; then
  BYTES=$(wc -c < "$APPPATH")
  SIZE=$(( BYTES / 1048576 ))
else
  echo -e "${RED}Download failed: $APPPATH is missing or empty${X}"
  exit 1
fi

echo -e "${T}$APPPATH ${T}${SIZE}MB ${G}OK${W}"

echo -e "${T}$APPPATH ${T}$SIZE( )MB ${G}OK${W}" | sed 's/( )//g'
echo -e "${G}> ${W}DONE"
echo
echo -e "${L}- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
sleep 1.333
#
# --------------------------------------------------------------------
#
echo
echo -e "${G}INSTALLING ${W}. . ."
# -- prepare launcher to solve dependencies on each run and avoid overlay, 
launcher=/userdata/system/pro/$appname/$appname
rm -rf $launcher
echo '#!/bin/bash ' >> $launcher
echo 'export DISPLAY=:0.0; unclutter-remote -s' >> $launcher
## -- APP SPECIFIC LAUNCHER COMMAND: 
######################################################################
######################################################################
###################################################################### 
######################################################################
######################################################################
#echo 'mkdir /userdata/system/pro/'$appname'/home 2>/dev/null; mkdir /userdata/system/pro/'$appname'/config 2>/dev/null; DISPLAY=:0.0 HOME=/userdata/system/pro/'$appname'/home XDG_CONFIG_HOME=/userdata/system/pro/'$appname'/config /userdata/system/pro/'$appname'/'$AppName'.AppImage --no-sandbox --disable-gpu --test-type "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"' >> $launcher
echo 'LD_LIBRARY_PATH="/userdata/system/pro/.dep:${LD_LIBRARY_PATH}" DISPLAY=:0.0 /userdata/system/pro/'$appname'/'$appname'.AppImage --no-sandbox --test-type "$@"' >> $launcher
######################################################################
######################################################################
######################################################################
######################################################################
######################################################################
dos2unix $launcher
chmod a+x $launcher
cp $launcher /userdata/roms/ports/Youtbube-Leanback-Vacuumtube.sh 2>/dev/null
cp $launcher /userdata/system/pro/$appname/Launcher 2>/dev/null
# //
# -- get icon for shortcut,
icon=/userdata/system/pro/$appname/extra/icon.png
wget -q -O $icon https://github.com/profork/profork/raw/master/youtubetv/extra/icon.png
# //
# -- prepare f1 - applications - app shortcut, 
shortcut=/userdata/system/pro/$appname/extra/$appname.desktop
rm -rf $shortcut 2>/dev/null
echo "[Desktop Entry]" >> $shortcut
echo "Version=1.0" >> $shortcut
echo "Icon=/userdata/system/pro/$appname/extra/icon.png" >> $shortcut
echo "Exec=/userdata/system/pro/$appname/$appname %U" >> $shortcut
echo "Terminal=false" >> $shortcut
echo "Type=Application" >> $shortcut
echo "Categories=Game;batocera.linux;" >> $shortcut
echo "Name=$appname" >> $shortcut
f1shortcut=/usr/share/applications/$appname.desktop
cp $shortcut $f1shortcut 2>/dev/null
# //
#
# -- prepare prelauncher to avoid overlay,
pre=/userdata/system/pro/$appname/extra/startup
rm -rf $pre 2>/dev/null
echo "#!/usr/bin/env bash" >> $pre
echo "cp /userdata/system/pro/$appname/extra/$appname.desktop /usr/share/applications/ 2>/dev/null" >> $pre
dos2unix $pre
chmod a+x $pre
# // 
# 
# -- add prelauncher to custom.sh to run @ reboot
customsh=/userdata/system/custom.sh
if [[ -e $customsh ]] && [[ "$(cat $customsh | grep "/userdata/system/pro/$appname/extra/startup")" = "" ]]; then
echo -e "\n/userdata/system/pro/$appname/extra/startup" >> $customsh
fi
if [[ -e $customsh ]] && [[ "$(cat $customsh | grep "/userdata/system/pro/$appname/extra/startup" | grep "#")" != "" ]]; then
echo -e "\n/userdata/system/pro/$appname/extra/startup" >> $customsh
fi
if [[ -e $customsh ]]; then :; else
echo -e "\n/userdata/system/pro/$appname/extra/startup" >> $customsh
fi
dos2unix $customsh 2>/dev/null
# //
#
# -- done. 
sleep 1
echo -e "${G}> ${W}DONE"
echo
sleep 1
echo -e "${L}-----------------------------------------------------------------------"
echo -e "${W}> $APPNAME INSTALLED ${G}OK"
echo -e "${L}-----------------------------------------------------------------------"
sleep 4
}
export -f batocera-pro-installer 2>/dev/null
# --------------------------------------------------------------------
# RUN ALL:
# |
  batocera-pro-installer "$APPNAME" "$appname" "$AppName" "$APPPATH" "$APPLINK" "$ORIGIN"
# --------------------------------------------------------------------
# PROFORK/CHROME INSTALLER //
#################################
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
