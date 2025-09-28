#!/usr/bin/env bash
# profork INSTALLER

#---------------------------------------------------------------------
#       DEFINE APP INFO >>
APPNAME=java
APPLINK=$(curl -s https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases | grep AppImage | grep "browser_download_url" | head -n 1 | sed 's,^.*https://,https://,g' | cut -d \" -f1) 2>/dev/null
APPHOME=azul.com
#---------------------------------------------------------------------
#       DEFINE LAUNCHER COMMAND >>
COMMAND='mkdir -p /userdata/system/pro/'$APPNAME'/home /userdata/system/pro/'$APPNAME'/config /userdata/system/pro/'$APPNAME'/roms 2>/dev/null; HOME=/userdata/system/pro/'$APPNAME'/home XDG_CONFIG_HOME=/userdata/system/pro/'$APPNAME'/config QT_SCALE_FACTOR="1" GDK_SCALE="1" XDG_DATA_HOME=/userdata/system/pro/'$APPNAME'/home DISPLAY=:0.0 /userdata/system/pro/'$APPNAME'/'$APPNAME'.AppImage --no-sandbox'
#---------------------------------------------------------------------

# --------------------------------------------------------------------
APPNAME="${APPNAME^^}"; ORIGIN="${APPHOME^^}"; appname=$(echo "$APPNAME" | awk '{print tolower($0)}'); AppName=$appname; APPPATH=/userdata/system/pro/$appname/$AppName.AppImage
# --------------------------------------------------------------------

# -- output colors (placeholders kept) :
X='\033[0m'; W='\033[0m'
RED='\033[0m'; BLUE='\033[0m'; GREEN='\033[0m'; PURPLE='\033[0m'
DARKRED='\033[0m'; DARKBLUE='\033[0m'; DARKGREEN='\033[0m'; DARKPURPLE='\033[0m'
L=$X; R=$X

# --------------------------------------------------------------------
# -- prepare paths and files for installation: 
cd ~/
pro=/userdata/system/pro
mkdir -p "$pro" "$pro/extra" 2>/dev/null
rm -rf "$pro/$appname" 2>/dev/null
mkdir -p "$pro/$appname" "$pro/$appname/extra" 2>/dev/null

# --------------------------------------------------------------------
# -- pass launcher command as cookie for main function: 
command="$pro/$appname/extra/command"; rm -f "$command" 2>/dev/null
echo "$COMMAND" >> "$command" 2>/dev/null

# --------------------------------------------------------------------
# -- prepare dependencies for this app and the installer: 
mkdir -p ~/pro/.dep 2>/dev/null
cd ~/pro/.dep
wget --tries=10 --no-check-certificate --no-cache --no-cookies -q -O dep.zip "https://github.com/profork/profork/raw/master/.dep/dep.zip"
yes "y" | unzip -oq dep.zip
cd ~/

# make a copy into /userdata so later references work consistently
mkdir -p "$pro/.dep" 2>/dev/null
cp -af ~/pro/.dep/* "$pro/.dep/" 2>/dev/null
dep="$pro/.dep"

# icon
wget --tries=10 --no-check-certificate --no-cache --no-cookies -q -O "$pro/$appname/extra/icon.png" "https://github.com/profork/profork/raw/master/$appname/extra/icon.png"

# ensure deps executable and link common libs
chmod 755 "$dep"/* 2>/dev/null
for file in "$dep"/lib*; do ln -sf "$file" "/usr/lib/$(basename "$file")" 2>/dev/null; done

# --------------------------------------------------------------------
# -- show console/ssh info: 
# try native tput first (fallback to 120 cols)
cols=$(tput cols 2>/dev/null || echo 120)
rm -f "$pro/$appname/extra/cols" 2>/dev/null
echo "$cols" >> "$pro/$appname/extra/cols" 2>/dev/null

line(){ echo 1>/dev/null; }  # placeholder to keep original flow

clear
echo -e "${X}profork/$APPNAME INSTALLER${X}"
sleep 0.33
clear
line "$cols" '-'; echo
echo -e "${X}profork/$APPNAME INSTALLER${X}"
line "$cols" '-'; echo
sleep 0.33
clear
line "$cols" '\'; echo
line "$cols" '/'; echo
echo -e "${X}THIS WILL INSTALL JAVA RUNTIMES FOR BATOCERA"
echo -e "${X}USING $ORIGIN JAVA JRE PACKAGES"
echo -e "${X}VERSIONS: 21, 19, 17, 15, 13, 11, 8"
echo
echo -e "${X}$APPNAME RUNTIMES WILL BE INSTALLED IN:"
echo -e "${X}/USERDATA/SYSTEM/PRO/$APPNAME"
echo

# --------------------------------------------------------------------
# -- THIS WILL BE SHOWN ON master BATOCERA DISPLAY:   
PROFORK_installer() {
  APPNAME=$1
  appname=$2
  AppName=$3
  APPPATH=$4
  APPLINK=$5
  ORIGIN=$6

  # colors
  X='\033[0m'; W='\033[0m'; RED='\033[0m'; BLUE='\033[0m'; GREEN='\033[0m'; PURPLE='\033[0m'
  L=$W; T=$W; R=$RED; B=$BLUE; G=$GREEN; P=$PURPLE

  # cols from dep
  if [[ -f /userdata/system/pro/.dep/display.cfg ]]; then
    cols=$(tail -n 1 /userdata/system/pro/.dep/display.cfg 2>/dev/null)
    cols=$(bc <<<"scale=0;$cols/1.3" 2>/dev/null)
  else
    cols=$(tput cols 2>/dev/null || echo 120)
  fi
  line(){ echo 1>/dev/null; }

  clear
  echo -e "${W}profork/${G}$APPNAME${W} INSTALLER ${W}"
  sleep 0.33
  clear
  line "$cols" '-'; echo
  echo -e "${W}profork/${G}$APPNAME${W} INSTALLER ${W}"
  line "$cols" '-'; echo
  sleep 0.33
  clear
  line "$cols" '='; echo
  echo -e "${W}profork/${G}$APPNAME${W} INSTALLER ${W}"
  line "$cols" '='; echo
  sleep 0.33
  echo -e "${W}THIS WILL INSTALL JAVA RUNTIMES FOR BATOCERA" 
  echo -e "${W}USING $ORIGIN JAVA JRE PACKAGES" 
  echo -e "${W}VERSIONS: ${G}21, 19, 17, 15, 13, 11, 8${W}"  
  echo
  echo -e "${W}$APPNAME RUNTIMES WILL BE INSTALLED IN:"
  echo -e "${W}/USERDATA/SYSTEM/PRO/$APPNAME"
  echo

  # --------------------------------------------------------------------
  # -- check system before proceeding
  if ! uname -a | grep -q "x86_64"; then
    echo -e "${RED}ERROR: SYSTEM NOT SUPPORTED"
    echo -e "${RED}YOU NEED BATOCERA X86_64${X}"
    sleep 5
    exit 0
  fi

  # --------------------------------------------------------------------
  # -- temp for curl download
  pro=/userdata/system/pro
  dep="$pro/.dep"
  temp="$pro/$appname/extra/downloads"
  rm -rf "$temp" 2>/dev/null 
  mkdir -p "$temp" 2>/dev/null

  echo
  echo -e "${G}DOWNLOADING${W} [7] JAVA RUNTIME PACKAGES . . ."
  url=https://github.com/profork/profork/raw/master/
  cd "$temp"

  # Java 21 (save with a stable name so later steps are consistent)
  curl --progress-bar --location \
    -o "$temp/java21.tar.gz" \
    "https://download.oracle.com/java/21/archive/jdk-21.0.7_linux-x64_bin.tar.gz"

  curl --progress-bar --remote-name --location "$url/$appname/extra/java19.tar.gz"
  curl --progress-bar --remote-name --location "$url/$appname/extra/java17.tar.gz"
  curl --progress-bar --remote-name --location "$url/$appname/extra/java15.tar.gz"
  curl --progress-bar --remote-name --location "$url/$appname/extra/java13.tar.gz"
  curl --progress-bar --remote-name --location "$url/$appname/extra/java11.tar.gz"
  curl --progress-bar --remote-name --location "$url/$appname/extra/java8.tar.gz"

  SIZE=$(du -sh "$temp" | awk '{print $1}') 2>/dev/null
  echo -e "${T}$temp  ${T}$SIZE  ${G}OK${W}"

  sleep 1.0
  echo -e "${G}INSTALLING${W} . . ." 

  # get tar helper
  wget -q -O "$pro/.dep/tar" "$url/.dep/tar" 2>/dev/null
  chmod a+x "$pro/.dep/tar"

  # --------------------------------------------------------------------
  # java21
  "$pro/.dep/tar" -xf "$temp/java21.tar.gz" -C "$temp" 2>/dev/null
  j21_top=$("$pro/.dep/tar" -tf "$temp/java21.tar.gz" | head -1 | cut -d/ -f1)
  [ -z "$j21_top" ] && j21_top="$(ls -1 "$temp" | grep -E '^jdk-21' | head -1)"
  rm -rf "$pro/$appname/java21" 2>/dev/null
  mv "$temp/$j21_top" "$pro/$appname/java21" 2>/dev/null

  # --------------------------------------------------------------------
  # java19
  "$pro/.dep/tar" -xf "$temp/java19.tar.gz" -C "$temp" 2>/dev/null
  rm -rf "$pro/$appname/java19" 2>/dev/null
  mv "$temp/java19" "$pro/$appname/" 2>/dev/null

  # --------------------------------------------------------------------
  # java17 (also set as default into /userdata/system/pro/java)
  "$pro/.dep/tar" -xf "$temp/java17.tar.gz" -C "$temp" 2>/dev/null
  # make this version the default system java version in /userdata/system/pro/java
  cp -r "$temp/java17/"* "$pro/$appname/" 2>/dev/null
  rm -rf "$pro/$appname/java17" 2>/dev/null
  mv "$temp/java17" "$pro/$appname/" 2>/dev/null

  # --------------------------------------------------------------------
  # java15
  "$pro/.dep/tar" -xf "$temp/java15.tar.gz" -C "$temp" 2>/dev/null
  rm -rf "$pro/$appname/java15" 2>/dev/null
  mv "$temp/java15" "$pro/$appname/" 2>/dev/null

  # --------------------------------------------------------------------
  # java13
  "$pro/.dep/tar" -xf "$temp/java13.tar.gz" -C "$temp" 2>/dev/null
  rm -rf "$pro/$appname/java13" 2>/dev/null
  mv "$temp/java13" "$pro/$appname/" 2>/dev/null

  # --------------------------------------------------------------------
  # java11
  "$pro/.dep/tar" -xf "$temp/java11.tar.gz" -C "$temp" 2>/dev/null
  rm -rf "$pro/$appname/java11" 2>/dev/null
  mv "$temp/java11" "$pro/$appname/" 2>/dev/null

  # --------------------------------------------------------------------
  # java8
  "$pro/.dep/tar" -xf "$temp/java8.tar.gz" -C "$temp" 2>/dev/null
  rm -rf "$pro/$appname/java8" 2>/dev/null
  mv "$temp/java8" "$pro/$appname/" 2>/dev/null

  # --------------------------------------------------------------------
  # chmod binaries
  chmod a+x "$pro/$appname/bin/"* 2>/dev/null              # default (from java17 copy)
  chmod a+x "$pro/$appname/java21/bin/"* 2>/dev/null
  chmod a+x "$pro/$appname/java19/bin/"* 2>/dev/null
  chmod a+x "$pro/$appname/java17/bin/"* 2>/dev/null
  chmod a+x "$pro/$appname/java15/bin/"* 2>/dev/null
  chmod a+x "$pro/$appname/java13/bin/"* 2>/dev/null
  chmod a+x "$pro/$appname/java11/bin/"* 2>/dev/null
  chmod a+x "$pro/$appname/java8/bin/"* 2>/dev/null

  cd ~/
  SIZE=$(du -sh "$pro/$appname" | awk '{print $1}') 2>/dev/null
  echo -e "${T}$pro/$appname  ${T}$SIZE  ${G}OK${W}"

  # --------------------------------------------------------------------
  # attach java runtime to ~/.profile
  find="system/pro/java"
  file=/userdata/system/.profile
  if [[ -e "$file" ]]; then
    tempf=/userdata/system/.profile.tmp
    rm -f "$tempf" 2>/dev/null
    nl=$(wc -l < "$file")
    l=1
    while [[ $l -le $nl ]]; do
      ln=$(sed -n ""$l"p" "$file")
      if echo "$ln" | grep -q "$find"; then :; else echo "$ln" >> "$tempf"; fi
      ((l++))
    done
    echo -e '\nexport PATH=/userdata/system/pro/java/bin:$PATH && export JAVA_HOME=/userdata/system/pro/java' >> "$tempf"
    cp "$tempf" "$file" 2>/dev/null; rm -f "$tempf" 2>/dev/null
  else
    echo -e '\nexport PATH=/userdata/system/pro/java/bin:$PATH && export JAVA_HOME=/userdata/system/pro/java' >> "$file"
  fi
  dos2unix /userdata/system/.profile 2>/dev/null
  export PATH="/userdata/system/pro/java/bin:${PATH}" && export JAVA_HOME=/userdata/system/pro/java

  # --------------------------------------------------------------------
  # attach java runtime to ~/.bashrc
  file=/userdata/system/.bashrc
  if [[ -e "$file" ]]; then
    tempf=/userdata/system/.bashrc.tmp
    rm -f "$tempf" 2>/dev/null
    nl=$(wc -l < "$file")
    l=1
    while [[ $l -le $nl ]]; do
      ln=$(sed -n ""$l"p" "$file")
      if echo "$ln" | grep -q "$find"; then :; else echo "$ln" >> "$tempf"; fi
      ((l++))
    done
    echo -e '\nexport PATH=/userdata/system/pro/java/bin:$PATH && export JAVA_HOME=/userdata/system/pro/java' >> "$tempf"
    cp "$tempf" "$file" 2>/dev/null; rm -f "$tempf" 2>/dev/null
  else
    echo -e '\nexport PATH=/userdata/system/pro/java/bin:$PATH && export JAVA_HOME=/userdata/system/pro/java' >> "$file"
  fi
  dos2unix /userdata/system/.bashrc 2>/dev/null

  # --------------------------------------------------------------------
  # Launcher that shows current versions
  launcher="/userdata/system/pro/$appname/Launcher"
  rm -f "$launcher"
  {
    echo '#!/bin/bash'
    echo 'export PATH=/userdata/system/pro/java/bin:$PATH && export JAVA_HOME=/userdata/system/pro/java'
    echo 'function get-java-version {'
    echo 'W="\033[0;37m"; G="\033[1;32m"'
    echo 'java=/userdata/system/pro/java/bin/java'
    echo 'if [[ -e "$java" ]]; then echo -e "${G}> DEFAULT JAVA RUNTIME${W}"; $java --version | grep openjdk; echo; else echo -e "${W}DEFAULT JAVA RUNTIME NOT FOUND"; echo; fi'
    echo 'java21=/userdata/system/pro/java/java21/bin/java'
    echo 'if [[ -e "$java21" ]]; then echo -e "${G}~/pro/java/java21${W}"; $java21 --version | grep openjdk; echo; else echo -e "${W}JAVA 21 NOT FOUND"; echo; fi'
    echo 'java19=/userdata/system/pro/java/java19/bin/java'
    echo 'if [[ -e "$java19" ]]; then echo -e "${G}~/pro/java/java19${W}"; $java19 --version | grep openjdk; echo; else echo -e "${W}JAVA 19 NOT FOUND"; echo; fi'
    echo 'java17=/userdata/system/pro/java/java17/bin/java'
    echo 'if [[ -e "$java17" ]]; then echo -e "${G}~/pro/java/java17${W}"; $java17 --version | grep openjdk; echo; else echo -e "${W}JAVA 17 NOT FOUND"; echo; fi'
    echo 'java15=/userdata/system/pro/java/java15/bin/java'
    echo 'if [[ -e "$java15" ]]; then echo -e "${G}~/pro/java/java15${W}"; $java15 --version | grep openjdk; echo; else echo -e "${W}JAVA 15 NOT FOUND"; echo; fi'
    echo 'java13=/userdata/system/pro/java/java13/bin/java'
    echo 'if [[ -e "$java13" ]]; then echo -e "${G}~/pro/java/java13${W}"; $java13 --version | grep openjdk; echo; else echo -e "${W}JAVA 13 NOT FOUND"; echo; fi'
    echo 'java11=/userdata/system/pro/java/java11/bin/java'
    echo 'if [[ -e "$java11" ]]; then echo -e "${G}~/pro/java/java11${W}"; $java11 --version | grep openjdk; echo; else echo -e "${W}JAVA 11 NOT FOUND"; echo; fi'
    echo 'java8=/userdata/system/pro/java/java8/bin/java'
    echo 'if [[ -e "$java8" ]]; then echo -e "${G}~/pro/java/java8${W}"; $java8 --version | grep openjdk; echo; else echo -e "${W}JAVA 8 NOT FOUND"; echo; fi'
    echo 'echo "will close after 10 seconds"'
    echo 'sleep 10'
    echo '}'
    echo 'export -f get-java-version 2>/dev/null'
    echo 'function get-xterm-fontsize {'
    echo 'tput=/userdata/system/pro/.dep/tput; chmod a+x "$tput"'
    echo 'ln -sf /userdata/system/pro/.dep/libtinfo.so.6 /usr/lib/libtinfo.so.6 2>/dev/null'
    echo 'cfg=/userdata/system/pro/.dep/display.cfg; rm -f "$cfg" 2>/dev/null'
    echo 'DISPLAY=:0.0 xterm -fullscreen -bg "black" -fa "Monospace" -e bash -c "\"$tput\" cols >> \"$cfg\"" 2>/dev/null'
    echo 'cols=$(tail -n 1 "$cfg" 2>/dev/null)'
    echo 'TEXT_SIZE=$(bc <<<"scale=0;$cols/16" 2>/dev/null)'
    echo '}'
    echo 'export -f get-xterm-fontsize 2>/dev/null'
    echo 'get-xterm-fontsize 2>/dev/null'
    echo 'cfg=/userdata/system/pro/.dep/display.cfg'
    echo 'cols=$(tail -n 1 "$cfg" 2>/dev/null)'
    echo 'until [[ "$cols" != "80" && -n "$cols" ]]; do'
    echo '  get-xterm-fontsize 2>/dev/null'
    echo '  cols=$(tail -n 1 "$cfg" 2>/dev/null)'
    echo 'done'
    echo 'TEXT_SIZE=$(bc <<<"scale=0;$cols/16" 2>/dev/null)'
    echo "DISPLAY=:0.0 xterm -fullscreen -bg black -fa 'Monospace' -fs \"\$TEXT_SIZE\" -e bash -c \"get-java-version\" 2>/dev/null"
  } >> "$launcher"
  dos2unix "$launcher" 2>/dev/null
  chmod a+x "$launcher" 2>/dev/null
  rm -f "/userdata/system/pro/$appname/extra/command" 2>/dev/null

  # --------------------------------------------------------------------
  # F1 applications shortcut
  shortcut="/userdata/system/pro/$appname/extra/$appname.desktop"
  rm -f "$shortcut" 2>/dev/null
  {
    echo "[Desktop Entry]"
    echo "Version=1.0"
    echo "Icon=/userdata/system/pro/$appname/extra/icon.png"
    echo "Exec=/userdata/system/pro/$appname/Launcher"
    echo "Terminal=false"
    echo "Type=Application"
    echo "Categories=Game;batocera.linux;"
    echo "Name=$appname"
  } >> "$shortcut"
  f1shortcut="/usr/share/applications/$appname.desktop"
  dos2unix "$shortcut" 2>/dev/null
  chmod a+x "$shortcut" 2>/dev/null
  cp "$shortcut" "$f1shortcut" 2>/dev/null

  # --------------------------------------------------------------------
  # prelauncher to avoid overlay,
  pre="/userdata/system/pro/$appname/extra/startup"
  rm -f "$pre" 2>/dev/null
  {
    echo "#!/usr/bin/env bash"
    echo "cp /userdata/system/pro/$appname/extra/$appname.desktop /usr/share/applications/ 2>/dev/null"
    echo "ln -sf /userdata/system/pro/$appname/bin/java /usr/bin/java 2>/dev/null"
    echo "ln -sf /userdata/system/pro/.dep/libselinux.so.1 /usr/lib/libselinux.so.1 2>/dev/null"
    echo "ln -sf /userdata/system/pro/.dep/tar /bin/tar 2>/dev/null"
  } >> "$pre"
  dos2unix "$pre" 2>/dev/null
  chmod a+x "$pre" 2>/dev/null

  # add prelauncher to custom.sh to run @ reboot
  csh=/userdata/system/custom.sh
  if [[ -e $csh ]]; then
    if ! grep -q "/userdata/system/pro/$appname/extra/startup" "$csh"; then
      echo -e "\n/userdata/system/pro/$appname/extra/startup" >> "$csh"
    fi
    if grep -q "^#.*\/userdata\/system\/pro\/$appname\/extra\/startup" "$csh"; then
      echo -e "\n/userdata/system/pro/$appname/extra/startup" >> "$csh"
    fi
  else
    echo -e "\n/userdata/system/pro/$appname/extra/startup" >> "$csh"
  fi
  dos2unix "$csh" 2>/dev/null
  chmod a+x "$csh" 2>/dev/null

  sleep 1
  echo -e "${G}> ${W}DONE${W}"
  sleep 1
  echo -e "${G}> $APPNAME INSTALLED ${G}OK${W}"
  echo -e "${W}TO CHANGE THE DEFAULT JAVA VERSION: COPY CONTENTS OF"
  echo -e "${W}~/pro/java/java[VER] TO THE MAIN ~/pro/java FOLDER"
  line "$cols" '='; echo
  sleep 2
}

export -f PROFORK_installer 2>/dev/null

# --------------------------------------------------------------------
# RUN:
PROFORK_installer "$APPNAME" "$appname" "$AppName" "$APPPATH" "$APPLINK" "$ORIGIN"

# --------------------------------------------------------------------
# Final existence check (corrected paths)
if  [[ -e "/userdata/system/pro/java/java21/bin/java" ]] \
 && [[ -e "/userdata/system/pro/java/java19/bin/java" ]] \
 && [[ -e "/userdata/system/pro/java/java17/bin/java" ]] \
 && [[ -e "/userdata/system/pro/java/java15/bin/java" ]] \
 && [[ -e "/userdata/system/pro/java/java13/bin/java" ]] \
 && [[ -e "/userdata/system/pro/java/java11/bin/java" ]] \
 && [[ -e "/userdata/system/pro/java/java8/bin/java" ]]; then
  echo
  echo -e "${W}> $APPNAME INSTALLED ${G}OK${W}"
  echo 
  echo -e "${W}TO CHANGE THE DEFAULT JAVA VERSION: COPY CONTENTS OF"
  echo -e "${W}~/pro/java/java[VER] TO THE MAIN ~/pro/java FOLDER"
  echo
fi
