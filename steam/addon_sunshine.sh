#!/bin/bash

# Define the file path
filePath="$HOME/pro/steam/conty.sh"

# Check if the file exists
if [ -f "$filePath" ]; then
    echo "conty.sh exists, continuing the script..."
   
else
    echo "It appears the container is not installed. Please install the multi-app Arch container first, then retry."
    sleep 10
    exit 1
fi

#--------------------------------------------------------
# Create required directories
mkdir -p /userdata/system/pro/sunshine
mkdir -p /userdata/system/logs
mkdir -p /userdata/system/services
mkdir -p /userdata/roms/conty
mkdir -p /userdata/system/.config/sunshine
#--------------------------------------------------------

#--------------------------------------------------------
# Create sunshine.sh (Conty-based Sunshine launcher)
echo "Creating Conty-based Sunshine launcher..."
cat << 'EOF' > /userdata/system/pro/sunshine/sunshine.sh
#!/bin/bash
#------------------------------------------------
conty=/userdata/system/pro/steam/conty.sh
#------------------------------------------------
batocera-mouse show
#------------------------------------------------
  "$conty" \
          --bind /userdata/system/containers/storage /var/lib/containers/storage \
          --bind /userdata/system/flatpak /var/lib/flatpak \
          --bind /userdata/system/etc/passwd /etc/passwd \
          --bind /userdata/system/etc/group /etc/group \
          --bind /userdata/system /home/batocera \
          --bind /var/run/nvidia /run/nvidia \
          --bind /sys/fs/cgroup /sys/fs/cgroup \
          --bind /userdata/system /home/root \
          --bind /etc/fonts /etc/fonts \
          --bind /userdata/system/.config/sunshine /home/.config/sunshine \
          --bind /userdata /userdata \
          --bind /newroot /newroot \
          --bind / /batocera \
  bash -c '/userdata/system/pro/steam/prepare.sh && source /userdata/system/pro/steam/env.sh && exec dbus-run-session /usr/bin/sunshine "$@"'
#------------------------------------------------
# batocera-mouse hide
#------------------------------------------------
EOF

chmod +x /userdata/system/pro/sunshine/sunshine.sh
#--------------------------------------------------------

#--------------------------------------------------------
# Create arch-sunshine service script (no pulse nonsense)
echo "Creating arch_sunshine service script..."
cat << 'EOF' > /userdata/system/services/arch_sunshine
#!/bin/bash

# Batocera service script for Conty-based Sunshine
case "$1" in
    start)
        /userdata/system/pro/sunshine/sunshine.sh > /userdata/system/logs/sunshine.log 2>&1 &
        ;;
    stop)
        killall -9 sunshine
        ;;
    restart)
        $0 stop
        $0 start
        ;;
esac
EOF

chmod +x /userdata/system/services/arch_sunshine
#--------------------------------------------------------

#--------------------------------------------------------
# Enable service in batocera.conf
echo "Enabling arch-sunshine service in batocera.conf..."
if ! grep -q "system.arch_sunshine.enabled" /userdata/system/batocera.conf; then
    echo "system.arch_sunshine.enabled=1" >> /userdata/system/batocera.conf
else
    sed -i 's/system\.arch_sunshine\.enabled=.*/system.arch_sunshine.enabled=1/' /userdata/system/batocera.conf
fi
#--------------------------------------------------------

#--------------------------------------------------------
# Create Sunshine-Config Chrome launcher
echo "Creating Sunshine-Config Chrome launcher..."
cat << 'EOF' > /userdata/roms/conty/Sunshine-Config.sh
#!/bin/bash
#------------------------------------------------
conty=/userdata/system/pro/steam/conty.sh
#------------------------------------------------
batocera-mouse show
#------------------------------------------------
  "$conty" \
          --bind /userdata/system/containers/storage /var/lib/containers/storage \
          --bind /userdata/system/flatpak /var/lib/flatpak \
          --bind /userdata/system/etc/passwd /etc/passwd \
          --bind /userdata/system/etc/group /etc/group \
          --bind /userdata/system /home/batocera \
          --bind /sys/fs/cgroup /sys/fs/cgroup \
          --bind /userdata/system /home/root \
          --bind /var/run/nvidia /run/nvidia \
          --bind /etc/fonts /etc/fonts \
          --bind /userdata /userdata \
          --bind /newroot /newroot \
          --bind / /batocera \
  bash -c 'prepare && source /opt/env && dbus-run-session google-chrome-stable --no-sandbox --test-type https://localhost:47990'
#------------------------------------------------
# batocera-mouse hide
#------------------------------------------------
EOF

chmod +x /userdata/roms/conty/Sunshine-Config.sh
#--------------------------------------------------------

#--------------------------------------------------------
# Done!
dialog --msgbox "Conty-based Sunshine installed and registered as 'arch_sunshine'.\n\nEnable it via Services menu.\n\nWeb UI: https://localhost:47990\nConfig shortcut: Sunshine-Config added to ES Arch Menu" 13 60
#--------------------------------------------------------

