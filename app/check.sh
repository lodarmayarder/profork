#!/bin/bash

PORTS_LAUNCHER="/userdata/roms/ports/Profork.sh"
SPLASH_MP4="/userdata/system/pro/pf.mp4"
INSTALL_URL="https://github.com/profork/profork/raw/master/app/install.sh"

# Convert June 12, 2025 to Unix timestamp
CUTOFF_TIMESTAMP=$(date -d "2025-06-12" +%s)

# Get the actual file's modification time (if it exists)
if [ -f "$PORTS_LAUNCHER" ]; then
    FILE_TIMESTAMP=$(date -r "$PORTS_LAUNCHER" +%s)
else
    FILE_TIMESTAMP=0
fi

# Check if missing or outdated
if [ ! -f "$PORTS_LAUNCHER" ] || [ ! -f "$SPLASH_MP4" ] || [ "$FILE_TIMESTAMP" -lt "$CUTOFF_TIMESTAMP" ]; then
    echo "Profork not installed, incomplete, or outdated. Running installer..."
    curl -Ls "$INSTALL_URL" | bash

    # Re-check and confirm
    if [ -f "$PORTS_LAUNCHER" ] && [ -f "$SPLASH_MP4" ]; then
        echo "✅ Installed or updated Profork launcher and splash video."
    else
        echo "❌ Installation failed or incomplete. Check your network or GitHub link."
    fi
else
    echo "✅ Profork is already fully installed and up to date."
fi
