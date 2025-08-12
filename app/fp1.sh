#!/bin/bash

set -euo pipefail

echo "Ensuring Flathub remote is added..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

ARCH="$(uname -m)"

# Declare all apps, descriptions, and whether they need --no-sandbox
declare -A apps
apps["Chromium"]="org.chromium.Chromium"
apps["Ungoogled-Chromium"]="com.github.Eloston.UngoogledChromium"
apps["Google-Chrome"]="com.google.Chrome"
apps["Brave-Browser"]="com.brave.Browser"
apps["Vivaldi"]="com.vivaldi.Vivaldi"
apps["Microsoft-Edge"]="com.microsoft.Edge"
apps["Discord"]="com.discordapp.Discord"
apps["Greenlight-(xCloud)"]="io.github.unknownskl.greenlight"
apps["GeForce-NOW-Electron"]="io.github.hmlendea.geforcenow-electron"
apps["Heroic-Game-Launcher"]="com.heroicgameslauncher.hgl"
apps["VacuumTube"]="rocks.shy.VacuumTube"
apps["Parsec"]="com.parsecgaming.parsec"
apps["Xcloud"]="io.github.mandruis7.xbox-cloud-gaming-electron"
apps["XStreamingDesktop"]="io.github.Geocld.XStreamingDesktop"
apps["Jellyfin-Media-Player"]="com.github.iwalton3.jellyfin-media-player"
apps["Plex-Desktop"]="tv.plex.PlexDesktop"
apps["Firefox"]="org.mozilla.firefox"
apps["LibreWolf"]="io.gitlab.librewolf-community"
apps["SteamLink"]="com.valvesoftware.SteamLink"
apps["LibreOffice"]="org.libreoffice.LibreOffice"
apps["PeaZip"]="io.github.peazip.PeaZip"
apps["Remmina"]="org.remmina.Remmina"
apps["Lutris"]="net.lutris.Lutris"
apps["Jdownloader2"]="org.jdownloader.JDownloader"
apps["Steam"]="com.valvesoftware.Steam"
apps["Bottles"]="com.usebottles.bottles"
apps["Moonlight-Qt"]="com.moonlight_stream.Moonlight"

# Descriptions
declare -A desc
desc["Chromium"]="Vanilla Chromium browser"
desc["Ungoogled-Chromium"]="Privacy-focused Chromium fork"
desc["Google-Chrome"]="Official Google Chrome browser"
desc["Brave-Browser"]="Ad-blocking privacy browser"
desc["Vivaldi"]="Power-user browser with tabs & tools"
desc["Microsoft-Edge"]="Microsoft's Chromium-based browser"
desc["Discord"]="Voice/text chat app (Electron)"
desc["Greenlight-(xCloud)"]="Xbox Remote Gaming and Xcloud Gaming client"
desc["GeForce-NOW-Electron"]="NVIDIA game streaming"
desc["Heroic-Game-Launcher"]="Epic/GOG game launcher"
desc["VacuumTube"]="YouTube Leanback wrapper (TV UI)"
desc["Parsec"]="Low-latency remote desktop/game streaming client"
desc["Xcloud"]="Xbox Xcloud electron client"
desc["XStreamingDesktop"]="Greenlight fork with Gamepad menu navigation"
desc["Jellyfin-Media-Player"]="Client for self-hosted Jellyfin media server"
desc["Plex-Desktop"]="Desktop client for Plex streaming media"
desc["Firefox"]="Native privacy-respecting browser"
desc["LibreWolf"]="Hardened privacy fork of Firefox"
desc["SteamLink"]="Game streaming from Steam PC"
desc["LibreOffice"]="Full office suite"
desc["PeaZip"]="Compression Utility"
desc["Remmina"]="RDP Client"
desc["Lutris"]="Game launcher for Wine, emulators, etc."
desc["Jdownloader2"]="Downloader and Management tool"
desc["Steam"]="Valve's Gaming Platform"
desc["Bottles"]="Wine Installer and Manager"
desc["Moonlight-Qt"]="Streaming Client for Geforce Now and Sunshine"

# Apps requiring --no-sandbox
declare -A needs_sandbox
needs_sandbox["Chromium"]=1
needs_sandbox["Ungoogled-Chromium"]=1
needs_sandbox["Google-Chrome"]=1
needs_sandbox["Brave-Browser"]=1
needs_sandbox["Vivaldi"]=1
needs_sandbox["Microsoft-Edge"]=1
needs_sandbox["Discord"]=1
needs_sandbox["Greenlight-(xCloud)"]=1
needs_sandbox["GeForce-NOW-Electron"]=1
needs_sandbox["Heroic-Game-Launcher"]=1
needs_sandbox["VacuumTube"]=1
needs_sandbox["Parsec"]=1
needs_sandbox["Xcloud"]=1
needs_sandbox["XStreamingDesktop"]=1
needs_sandbox["Jellyfin-Media-Player"]=1
needs_sandbox["Plex-Desktop"]=1
needs_sandbox["Firefox"]=0
needs_sandbox["LibreWolf"]=0
needs_sandbox["SteamLink"]=0
needs_sandbox["LibreOffice"]=0
needs_sandbox["PeaZip"]=0
needs_sandbox["Remmina"]=0
needs_sandbox["Lutris"]=0
needs_sandbox["Jdownloader2"]=0
needs_sandbox["Steam"]=0
needs_sandbox["Chiaki"]=1
needs_sandbox["Bottles"]=0
needs_sandbox["Moonlight-Qt"]=0

# Build dialog UI
dialog_items=()
for app in $(printf "%s\n" "${!apps[@]}" | sort); do
  dialog_items+=( "$app" "${desc[$app]}" off )
done

tempfile=$(mktemp)
trap 'rm -f "$tempfile"' EXIT

dialog --clear --title "Flatpak App Installer" \
  --checklist "Select apps to install:" 20 100 15 \
  "${dialog_items[@]}" 2> "$tempfile"

selected=$(<"$tempfile")
clear

created_launchers=0

# Only run installs if something was selected
if [ -n "$selected" ]; then
  # Properly parse quoted selection
  read -r -a selected_apps <<< "$selected"
  for app in "${selected_apps[@]}"; do
    app_name="${app//\"/}"  # Strip quotes
    app_id="${apps[$app_name]}"
    sandbox="${needs_sandbox[$app_name]:-0}"

    echo "Installing $app_name ($app_id)..."
    flatpak install --system -y flathub "$app_id"

    # Special patch for Lutris: bypass root check
    if [ "$app_id" == "net.lutris.Lutris" ]; then
      echo "Patching Lutris to allow running as root..."
      bootstrap_dir=$(find /userdata/saves/flatpak/binaries/app/net.lutris.Lutris*/ -type d -name "files" | head -n 1 || true)
      if [ -n "${bootstrap_dir:-}" ]; then
        app_py="${bootstrap_dir}/lib/python3.11/site-packages/lutris/gui/application.py"
        if [ -f "$app_py" ]; then
          sed -i 's,os.geteuid() == 0,os.geteuid() == 888,g' "$app_py" 2>/dev/null || true
          echo "✅ Lutris patched successfully."
          sleep 1
        else
          echo "⚠️ Lutris application.py not found; patch skipped."
        fi
      else
        echo "⚠️ Lutris install path not found; patch skipped."
      fi
    fi

    echo "Applying Flatpak overrides..."
    flatpak override "$app_id" --filesystem=/userdata
    flatpak override "$app_id" --filesystem=/media

    # Launcher logic
    if [ "$sandbox" -eq 1 ]; then
      launcher="/userdata/roms/ports/${app_name// /_}.sh"
      {
        echo '#!/bin/bash'
        # Special Jellyfin launcher for aarch64 with Wayland/X11 detection + no-sandbox flags
        if [ "$app_id" = "com.github.iwalton3.jellyfin-media-player" ] && [ "$ARCH" = "aarch64" ]; then
          cat <<'EOF'
set -euo pipefail
APP_ID="com.github.iwalton3.jellyfin-media-player"
FLATPAK_EXPORT="/userdata/saves/flatpak/data/.local/share/flatpak/exports/share"
export XDG_DATA_DIRS="${FLATPAK_EXPORT}:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/0}"
mkdir -p "$XDG_RUNTIME_DIR"; chmod 700 "$XDG_RUNTIME_DIR" || true
CHROMIUM_FLAGS="--no-sandbox --disable-gpu-sandbox"

if [ -n "${WAYLAND_DISPLAY:-}" ] || [ -e "${XDG_RUNTIME_DIR}/wayland-0" ]; then
  echo "[JMP] Wayland detected. Using Qt Wayland."
  exec flatpak run \
    --env=QT_QPA_PLATFORM=wayland \
    --env=QTWEBENGINE_CHROMIUM_FLAGS="$CHROMIUM_FLAGS" \
    "$APP_ID"
fi

if [ -n "${DISPLAY:-}" ]; then
  echo "[JMP] DISPLAY=${DISPLAY} found. Using XCB (X11)."
  exec flatpak run \
    --env=QT_QPA_PLATFORM=xcb \
    --env=QTWEBENGINE_CHROMIUM_FLAGS="$CHROMIUM_FLAGS" \
    "$APP_ID"
fi

if [ -e /tmp/.X11-unix/X0 ]; then
  export DISPLAY=":0"
  echo "[JMP] Using DISPLAY=:0 with XCB."
  exec flatpak run \
    --env=QT_QPA_PLATFORM=xcb \
    --env=QTWEBENGINE_CHROMIUM_FLAGS="$CHROMIUM_FLAGS" \
    "$APP_ID"
fi

echo "[JMP] No Wayland or X11 display available."
exit 1
EOF
        else
          # default root-friendly launcher for other sandboxed apps (x11)
          echo 'export DISPLAY=:0.0'
          echo "exec flatpak run $app_id --no-sandbox"
        fi
      } > "$launcher"
      chmod +x "$launcher"
      echo "✅ Custom launcher created: ${launcher##*/}"
      created_launchers=1
    else
      echo "ℹ️  Skipped launcher for $app_name — sandbox not required."
    fi
  done
else
  echo "No apps selected. Skipping installs."
fi

# If any launchers were created, show that dialog once
if [ "$created_launchers" -eq 1 ]; then
  dialog --title "Custom Launchers Created" \
    --msgbox "One or more apps require the --no-sandbox flag. A custom launcher was created in /userdata/roms/ports.\n\nYou may see duplicate entries in EmulationStation. Consider hiding the auto-generated versions." 10 70
fi

# ALWAYS ask about updates, even if nothing was installed
dialog --title "Update Flatpaks" --defaultno \
  --yesno "Do you want to update your Flatpak apps now?" 8 50
update_choice=$?

if [ "$update_choice" -eq 0 ]; then
  flatpak update --system -y
fi

echo "Done! Refresh EmulationStation to see any new entries."
