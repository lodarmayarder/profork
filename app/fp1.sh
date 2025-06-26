#!/bin/bash
# === BUA Detection ===
if [ -d "/userdata/system/add-ons" ]; then
    rm -f /userdata/roms/ports/ChromiumApps.sh
    clear
    echo "BUA detected. Dual installs not supported. Goodbye."
    exit 0
fi

echo "Ensuring Flathub remote is added..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

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

declare -A desc
desc["Chromium"]="Vanilla Chromium browser"
desc["Ungoogled-Chromium"]="Privacy-focused Chromium fork"
desc["Google-Chrome"]="Official Google Chrome browser"
desc["Brave-Browser"]="Ad-blocking privacy browser"
desc["Vivaldi"]="Power-user browser with tabs & tools"
desc["Microsoft-Edge"]="Microsoft's Chromium-based browser"
desc["Discord"]="Voice/text chat app (Electron)"
desc["Greenlight (xCloud)"]="Xbox Cloud Gaming wrapper"
desc["GeForce-NOW-Electron"]="NVIDIA game streaming"
desc["Heroic-Game-Launcher"]="Epic/GOG game launcher"
desc["VacuumTube"]="YouTube Leanback wrapper (TV UI)"
desc["Parsec"]="Low-latency remote desktop/game streaming client"
desc["Xcloud"]="Xbox Xcloud electron client"
desc["XStreamingDesktop"]="Greenlight fork with Gamepad menu navigation"
desc["Jellyfin-Media-Player"]="Client for self-hosted Jellyfin media server"
desc["Plex-Desktop"]="Desktop client for Plex streaming media"


# Build dialog UI
dialog_items=()
for app in $(printf "%s\n" "${!apps[@]}" | sort); do
    dialog_items+=( "$app" "${desc[$app]}" off )
done

tempfile=$(mktemp)
dialog --clear --title "Chromium-Based Flatpak Apps" \
--checklist "Select apps to install with --no-sandbox and extra filesystem access:" 20 100 12 \
"${dialog_items[@]}" 2> "$tempfile"

selected=$(<"$tempfile")
rm -f "$tempfile"
clear

[ -z "$selected" ] && { echo "No apps selected. Exiting."; exit 0; }

for app in $selected; do
    app_name="${app//\"/}"
    app_id="${apps[$app_name]}"
    echo "Installing $app_name ($app_id)..."
    flatpak install --system -y flathub "$app_id"

    # Flatpak overrides for /userdata and /media access
    echo "Applying Flatpak overrides..."
    flatpak override  "$app_id" --filesystem=/userdata
    flatpak override  "$app_id" --filesystem=/media

# Create launcher
launcher="/userdata/roms/ports/${app_name// /_}.sh"
cat > "$launcher" <<EOF
#!/bin/bash
export DISPLAY=:0.0
flatpak run $app_id --no-sandbox
EOF

    chmod +x "$launcher"
    echo "✅ Created launcher: ${launcher##*/}"
done

echo "All done. Refresh EmulationStation to see new entries."

