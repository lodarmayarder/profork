#!/usr/bin/env bash 

# -- Check if Xwayland is running
if ! pgrep -x "Xwayland" > /dev/null; then
    echo "❌ Xwayland is not running. Exiting."
    exit 1
fi

echo "✅ Xwayland detected. Continuing..."
sleep 2

######################################################################
# PROFORK/CITRON INSTALLER
######################################################################
dialog --title "Citron Notice" --yesno "Citron is experimental and tested on highend ARM64 builds like Odin 2. Continue installing?" 12 50
if [ $? -ne 0 ]; then
    echo "Installation canceled by user."
    exit 1
fi

clear

APPNAME=CITRON
appname=citron
AppName=$appname
APPPATH=/userdata/system/pro/$appname/$appname.AppImage
APPLINK="https://github.com/pkgforge-dev/Citron-AppImage/releases/download/v0.6.1%402025-07-02_1751414657/Citron-v0.6.1-anylinux-aarch64.AppImage"
ORIGIN="github.com/profork/profork"

# Prepare directories
cd ~/
pro=/userdata/system/pro
mkdir -p $pro/$appname/extra/downloads
mkdir -p /userdata/roms/switch

# Dependency setup (optional for Flatpak integration)
mkdir -p ~/pro/.dep && cd ~/pro/.dep
wget -q -O dep.zip https://github.com/profork/profork/raw/master/.dep/dep_arm64.zip
unzip -oq dep.zip && chmod 777 *
for file in ~/pro/.dep/lib*; do ln -sf "$file" "/usr/lib/$(basename $file)"; done

# Kill existing processes
killall -9 $AppName wget curl 2>/dev/null

# Download AppImage
cd /userdata/system/pro/$appname/extra/downloads
curl --progress-bar -L -o citron.AppImage "$APPLINK"
mv citron.AppImage "$APPPATH"
chmod +x "$APPPATH"

# EmulationStation Configs
ES_CONFIG_DIR="/userdata/system/configs/emulationstation"
mkdir -p "$ES_CONFIG_DIR"
curl -s -o "$ES_CONFIG_DIR/es_features_citron.cfg" https://raw.githubusercontent.com/profork/profork/master/app/citron/es_features_citron.cfg
curl -s -o "$ES_CONFIG_DIR/es_systems_citron.cfg" https://raw.githubusercontent.com/profork/profork/master/app/citron/es_system_citron.cfg

# Download parser script for Switch shortcuts
dlpath="/userdata/roms/switch"
curl -s -o "$dlpath/+UPDATE-SWITCH-SHORTCUTS.sh" https://raw.githubusercontent.com/profork/profork/master/app/citron/%2BUPDATE-SWITCH-SHORTCUTS.sh
dos2unix "$dlpath/+UPDATE-SWITCH-SHORTCUTS.sh" 2>/dev/null
chmod +x "$dlpath/+UPDATE-SWITCH-SHORTCUTS.sh"

# Launcher script
launcher=/userdata/system/pro/$appname/$appname
cat << EOF > "$launcher"
#!/bin/bash
export DISPLAY=:0.0
batocera-mouse show
/userdata/system/pro/$appname/$appname.AppImage --appimage-extract-and-run
batocera-mouse hide
EOF
chmod +x "$launcher"

# Port shortcut
cp "$launcher" /userdata/roms/ports/Citron.sh

# F1 desktop shortcut
icon=/userdata/system/pro/$appname/extra/icon.png
curl -# -o "$icon" "https://github.com/foclabroc/batocera-switch/raw/main/system/switch/extra/citron.png"

shortcut=/userdata/system/pro/$appname/extra/$appname.desktop
cat << EOF > "$shortcut"
[Desktop Entry]
Version=1.0
Icon=$icon
Exec=$launcher %U
Terminal=false
Type=Application
Categories=Game;batocera.linux;
Name=Citron
EOF
cp "$shortcut" /usr/share/applications/$appname.desktop

# Prelauncher for persistence
prelauncher=/userdata/system/pro/$appname/extra/startup
cat << EOF > "$prelauncher"
#!/bin/bash
cp $shortcut /usr/share/applications/ 2>/dev/null
EOF
chmod +x "$prelauncher"

# Add to custom.sh
customsh=/userdata/system/custom.sh
grep -q "$prelauncher" "$customsh" || echo "$prelauncher" >> "$customsh"
chmod +x "$customsh"

# Autostart logic to ensure future startup integration
function autostart() {
  pcsh="/userdata/system/pro-custom.sh"
  tmp=$(mktemp)
  find /userdata/system/pro -type f -name startup >> "$tmp"
  echo "#!/bin/bash" > "$pcsh"
  sort "$tmp" >> "$pcsh"
  chmod +x "$pcsh"
  grep -q "$pcsh &" "$customsh" || echo "$pcsh &" >> "$customsh"
  rm "$tmp"
}
autostart

dialog --msgbox "✅ Citron installed.
dialog --msgbox "✅ Citron installed.

🕹️ Run the +UPDATE-SWITCH-SHORTCUTS parser from the Switch menu to generate per-game launchers.

🔑 Place your keys in:
/userdata/system/.local/share/citron/keys

📁 Place firmware files in:
/userdata/system/.local/share/citron/nand/system/Contents/registered

🎮 Place your ROMs in:
/userdata/roms/switch

⚙️ You will need to configure your gamepad and other settings from the Citron GUI.

🚀 You can launch Citron GUI from the Ports menu or manually via F1 > pcmanfm." 20 65



exit 0
