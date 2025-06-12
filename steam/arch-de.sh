#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Define the file path
filePath="$HOME/pro/steam/conty.sh"

# Check if the file exists
if [ -f "$filePath" ]; then
    echo "File exists, continuing the script..."
else
    echo "It appears the container is not installed. Please install the Arch Steam/lutris/heroic container first, then retry."
    sleep 10
    exit 1
fi

# Create necessary directories
mkdir -p /userdata/desktop ~/service ~/services
mkdir -p ~/service/dir_ob

# Download files to dir_ob and make batocera-compositor executable

# Change curl to wget commands
wget -O ~/service/dir_ob/batocera-compositor https://github.com/profork/profork/raw/master/steam/desktop/service/dir_ob/batocera-compositor
wget -O ~/service/dir_ob/full.xml https://github.com/profork/profork/raw/master/steam/desktop/service/dir_ob/full.xml
wget -O ~/service/dir_ob/window.xml https://github.com/profork/profork/raw/master/steam/desktop/service/dir_ob/window.xml


# Convert downloaded XML files to Unix format
dos2unix ~/service/dir_ob/full.xml
dos2unix ~/service/dir_ob/window.xml

# Download windowed file to services and make it executable
echo "Downloading windowed script..."
curl -L -o ~/services/windowed https://github.com/profork/profork/raw/master/steam/desktop/services/windowed
chmod +x ~/services/windowed

# Convert windowed script to Unix format
dos2unix ~/services/windowed

# Download desktop environment scripts to /userdata/desktop and make them executable
echo "Downloading LXDE script..."
curl -L -o /userdata/desktop/LXDE.sh https://github.com/profork/profork/raw/master/steam/desktop/LXDE.sh
echo "Downloading MATE script..."
curl -L -o /userdata/desktop/MATE.sh https://github.com/profork/profork/raw/master/steam/desktop/MATE.sh
echo "Downloading XFCE script..."
curl -L -o /userdata/desktop/XFCE.sh https://github.com/profork/profork/raw/master/steam/desktop/XFCE.sh
chmod +x /userdata/desktop/LXDE.sh
chmod +x /userdata/desktop/MATE.sh
chmod +x /userdata/desktop/XFCE.sh

# Convert downloaded shell scripts to Unix format
dos2unix /userdata/desktop/LXDE.sh
dos2unix /userdata/desktop/MATE.sh
dos2unix /userdata/desktop/XFCE.sh

# Display completion message

dialog --title "Installation Complete" --msgbox "To access desktop mode:

1. In EmulationStation, go to Main Menu → System Settings → Services and toggle ON the Windowed service. Make sure to press Back to save.

2. Press F1 — you should see a windowed PCManFM file manager.

3. In /userdata/desktop, launch one of the desktop environment scripts (this can take a while).

To revert back to fullscreen mode:
- Simply toggle the Windowed service OFF and reboot to apply fullscreen layout.

NOTE:
Some Chromium based apps that require --no-sandbox as root (like Google Chrome) should be launched from Batocera's PCManFM inside /userdata/roms/conty instead of using desktop icons or menus." 25 90



