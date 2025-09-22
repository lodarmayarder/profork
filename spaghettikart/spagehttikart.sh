#!/usr/bin/env bash
set -euo pipefail

ZIP_URL="https://github.com/HarbourMasters/SpaghettiKart/releases/download/Latest2/Spaghettify-Alfredo-Alfa-1-Linux-Old.zip"

PORTS_DIR="/userdata/roms/ports"
APP_DIR="${PORTS_DIR}/spaghettikart"
SPAGHETTIFY_LINK="${PORTS_DIR}/spaghettify"
LAUNCH_DIR="${PORTS_DIR}/Spaghettikart"
ZIP_PATH="${APP_DIR}/Spaghettify-Alfredo-Alfa-1-Linux-Old.zip"
APPIMAGE_PATH="${APP_DIR}/spaghetti.appimage"

mkdir -p "${APP_DIR}" "${LAUNCH_DIR}"

echo "== Downloading Spaghettikart =="
curl -L --fail --retry 3 -o "${ZIP_PATH}.part" "${ZIP_URL}"
mv -f "${ZIP_PATH}.part" "${ZIP_PATH}"

echo "== Extracting =="
unzip -o "${ZIP_PATH}" -d "${APP_DIR}" >/dev/null

# Normalize AppImage to spaghetti.appimage
found_ai="$(ls "${APP_DIR}"/*.AppImage 2>/dev/null || true)"
if [[ -n "${found_ai}" ]]; then
  mv -f "${found_ai}" "${APPIMAGE_PATH}"
fi
chmod +x "${APPIMAGE_PATH}"

# Install Zenity (required by Spaghettikart prompts)
echo "== Installing Zenity (required) =="
bash -c 'curl -Ls https://github.com/profork/profork/raw/master/.dep/.scripts/zenity.sh | bash'

# Create compat symlink so launcher path works
if [[ -e "${SPAGHETTIFY_LINK}" && ! -L "${SPAGHETTIFY_LINK}" ]]; then
  echo "NOTE: ${SPAGHETTIFY_LINK} exists and is not a symlink; leaving it as-is."
else
  rm -f "${SPAGHETTIFY_LINK}"
  ln -s "${APP_DIR}" "${SPAGHETTIFY_LINK}"
fi

# Create the Ports launcher
LAUNCH_SH="${LAUNCH_DIR}/Spaghettikart.sh"
cat > "${LAUNCH_SH}" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
export DISPLAY=:0.0

# Show mouse in F1
if command -v batocera-mouse >/dev/null 2>&1; then
  batocera-mouse show || true
fi

# Launch via xterm
DISPLAY=:0.0 xterm -fs 30 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c '
    export DISPLAY=:0.0;
    cd "/userdata/roms/ports/spaghettify" || { echo "Error: Failed to change directory"; exit 1; }
    chmod +x "spaghetti.appimage";
    exec ./spaghetti.appimage > /dev/null 2>&1
'
EOF
chmod +x "${LAUNCH_SH}"

cat <<MSG

✅ Spaghettikart installed.

• Installed to: ${APP_DIR}
• Compat path: ${SPAGHETTIFY_LINK} -> ${APP_DIR}
• Launcher:     ${LAUNCH_SH}

On first launch, Spaghettikart will use **Zenity** to prompt you to select your
**Mario Kart 64 (USA) .z64** ROM. Just pick the ROM when asked.

👉 IMPORTANT: Refresh your gamelist in EmulationStation so the new "Spaghettikart"
port entry appears.

Launch from EmulationStation: Ports → Spaghettikart
MSG
echo "Exiting in 20 seconds"
sleep 20
