#!/bin/bash

# Initial setup
BACKTITLE="Docker Remote Linux Desktop Container Setup"
architecture=$(uname -m)
DEFAULT_PORT=3389

# Check system architecture
if [ "$architecture" != "x86_64" ]; then
    dialog --title "Architecture Error" --msgbox "This script only runs on AMD or Intel (x86_64) CPUs, not on $architecture." 10 50
    clear
    exit 1
fi
# Check for Docker binary and functional service
if ! command -v docker &> /dev/null || ! docker info &> /dev/null; then
    dialog --title "Docker Installation" --infobox "Docker is not installed or the service is not running. Installing Docker..." 10 50
    sleep 2 # Gives user time to read the message

    arch=$(uname -m)
    if [[ "$arch" == "aarch64" ]]; then
        # aarch64 install
        curl -L https://github.com/profork/profork/raw/master/docker/install-aarch64.sh | bash
    else
        # default (x86_64 etc.)
        curl -L https://github.com/profork/profork/raw/master/docker/install.sh | bash
    fi


# Function to check if a port is in use
is_port_in_use() {
    netstat -tuln | grep ":$1 " > /dev/null
    return $?
}

# Function to find the next available port starting from a given port
find_next_available_port() {
    local port=$1
    while is_port_in_use $port; do
        port=$((port + 1))
    done
    echo $port
}

# Check and set the VM port
VM_PORT=$DEFAULT_PORT
if is_port_in_use $VM_PORT; then
    VM_PORT=$(find_next_available_port $VM_PORT)
fi

# Allow user to change the default port if in use
VM_PORT=$(dialog --stdout --inputbox "Enter the RDP access port [Default: $VM_PORT]:" 8 45 "$VM_PORT") || exit
clear

# Desktop Environment selection
DESKTOP_ENVIRONMENT=$(dialog --stdout --menu "Choose a desktop environment:" 20 60 15 \
"alpine-xfce" "XFCE Alpine" \
"ubuntu-xfce" "XFCE Ubuntu" \
"fedora-xfce" "XFCE Fedora" \
"arch-xfce" "XFCE Arch" \
"alpine-kde" "KDE Alpine" \
"ubuntu-kde" "KDE Ubuntu" \
"fedora-kde" "KDE Fedora" \
"arch-kde" "KDE Arch" \
"alpine-mate" "MATE Alpine" \
"ubuntu-mate" "MATE Ubuntu" \
"fedora-mate" "MATE Fedora" \
"arch-mate" "MATE Arch" \
"alpine-i3" "i3 Alpine" \
"ubuntu-i3" "i3 Ubuntu" \
"fedora-i3" "i3 Fedora" \
"arch-i3" "i3 Arch") || exit
clear
#make data folder
mkdir -p /userdata/system/rdesktop

# Docker run command, adapted for rdesktop with user inputs
docker run -d \
  --name=rdesktop \
  --security-opt seccomp=unconfined `#optional based on app requirements` \
  -e PUID=$(id -u) \
  -e PGID=$(id -g) \
  -e TZ=$(cat /etc/timezone) \
  -p $VM_PORT:3389 \
  -v /userdata/system/rdesktop:/config 
  --device /dev/dri:/dev/dri `#optional based on hardware acceleration requirement` \
  --shm-size="1gb" `#optional` \
  --restart unless-stopped \
  lscr.io/linuxserver/rdesktop:$DESKTOP_ENVIRONMENT

# Final message to the user
MSG="Your Rdesktop docker container has been started with the following configurations:\n
- Desktop Environment: $DESKTOP_ENVIRONMENT\n
- RDP Access Port: $VM_PORT\n
\nRemember, the default USERNAME and PASSWORD is: abc/abc\n
- Access the VM via any RDP client using port $VM_PORT.\n
\nThe Container can be managed via cli or portainer webgui."

# Use dialog to display the message
dialog --title "VM Setup Complete" --msgbox "$MSG" 20 70
clear

