#!/bin/bash

# Check if flatpak exists
if ! command -v flatpak &>/dev/null; then
  dialog --title "Flatpak Not Found" \
    --msgbox "Flatpak for aarch64 is only available for custom builds with Flatpak support installed.\n\nConsider asking the Batocera developers to support Flatpak on regular ARM64/aarch64 builds." 10 60
  clear
  exit 1
fi

# Show ARM64 architecture warning
dialog --title "Architecture Warning" \
  --yesno "Some of the apps in the menu may not have aarch64 (ARM64) builds and may not install if selected.\n\nContinue?" 10 60

# If user selects "Yes"
if [ $? -eq 0 ]; then
  curl -L https://github.com/profork/profork/raw/master/app/fp1.sh | bash
else
  echo "Cancelled by user."
  clear
  exit 1
fi

# Clear the screen after dialog
clear
