#!/bin/bash

# Directory where Switch ROMs are stored
roms_dir="/userdata/roms/switch"

# Enable safe filename handling
shopt -s nullglob nocaseglob

# Default pad2key content (Alt+F4 hotkey)
keys_content='{
  "actions_player1": [
    {
      "trigger": ["hotkey", "start"],
      "type": "key",
      "target": ["KEY_LEFTALT", "KEY_F4"],
      "description": "Press Alt+F4"
    }
  ]
}'

# Supported Switch extensions
extensions=(".nsp" ".xci" ".ncz" ".nsz")

# Loop through matching ROM files
find "$roms_dir" -type f \( -iname "*.nsp" -o -iname "*.xci" -o -iname "*.ncz" -o -iname "*.nsz" \) | while read -r file_path; do
  file_name=$(basename "$file_path")
  base_name="${file_name%.*}"
  sanitized_name=$(echo "$base_name" | tr ' ' '_' | tr -cd '[:alnum:]_-')

  script_path="$roms_dir/${sanitized_name}.sh"
  keys_path="$roms_dir/${sanitized_name}.sh.keys"

  # Create the launcher script
  cat << EOF > "$script_path"
#!/bin/bash
batocera-mouse show
DISPLAY=:0.0 /userdata/system/pro/citron/citron.AppImage --appimage-extract-and-run -f -g "$file_path"
batocera-mouse hide
EOF

  chmod +x "$script_path"
  echo "$keys_content" > "$keys_path"

  echo "Shortcut created: $script_path"
  echo "Keys file created: $keys_path"
done

# Restart EmulationStation to refresh menu
killall -9 emulationstation
