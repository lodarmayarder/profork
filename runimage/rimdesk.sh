#!/bin/bash
# runimage_install_and_port_launcher.sh
# Installs runimage and adds a Batocera Ports launcher for a persistent desktop.
set -euo pipefail

# --- Config ---
BIN_URL="https://github.com/VHSgunzo/runimage/releases/download/continuous/runimage-x86_64"
DEST_BASE="/userdata/system/runimage"
BIN_PATH="${DEST_BASE}/runimage"
OVERLAY_DIR="${DEST_BASE}/overlays"
CACHE_DIR="${DEST_BASE}/cache"
PORTS_DIR="/userdata/roms/ports"
LAUNCHER="${PORTS_DIR}/RunImage Desktop.sh"
README="${DEST_BASE}/README.txt"
OVERFS_ID="ally-xfce"
DISPLAY_VAR=":0.0"
# ---------------

echo "[*] Creating directories..."
mkdir -p "${DEST_BASE}" "${OVERLAY_DIR}" "${CACHE_DIR}" "${PORTS_DIR}"

echo "[*] Downloading runimage -> ${BIN_PATH}"
curl -L --fail --retry 3 --progress-bar "${BIN_URL}" -o "${BIN_PATH}"
chmod +x "${BIN_PATH}"

echo "[*] Writing Ports launcher -> ${LAUNCHER}"
cat > "${LAUNCHER}" <<'EOF'
#!/bin/bash
set -euo pipefail

DEST_BASE="/userdata/system/runimage"
BIN_PATH="${DEST_BASE}/runimage"
OVERLAY_DIR="${DEST_BASE}/overlays"
CACHE_DIR="${DEST_BASE}/cache"

OVERFS_ID="ally-xfce"
DISPLAY_VAR=":0.0"

mkdir -p "${OVERLAY_DIR}" "${CACHE_DIR}"

RIM_OVERFS_ID="${OVERFS_ID}" \
RIM_KEEP_OVERFS=1 \
RIM_UNSHARE_HOME=1 \
RIM_BIND="/userdata:/userdata,/media:/media" \
RIM_OVERFSDIR="${OVERLAY_DIR}" \
RIM_CACHEDIR="${CACHE_DIR}" \
RIM_ALLOW_ROOT=1 DISPLAY="${DISPLAY_VAR}" \
"${BIN_PATH}" rim-desktop
EOF
chmod +x "${LAUNCHER}"

# --- Info text ---
INFO_TEXT=$'RunImage Desktop installed!\n\n\
• Pacman, AUR, and Chaotic-AUR are already set up inside the desktop.\n\
• GUI package managers you can install:\n\
    pacman -Syu pamac-aur\n\
  (Chaotic-AUR usually has prebuilt binaries.)\n\n\
• Chromium-based apps (like Google Chrome) launched as root require:\n\
    --no-sandbox\n\
  Example:  google-chrome-stable --no-sandbox\n\n\
Tip: Your changes persist via OverlayFS. To reset, remove the overlay id:\n\
  /userdata/system/runimage/runimage rim-ofsrm ally-xfce\n'

printf "%s" "${INFO_TEXT}" > "${README}"

if command -v dialog >/dev/null 2>&1; then
  dialog --title "RunImage Desktop" --msgbox "${INFO_TEXT}" 20 70
else
  echo
  echo "================= RunImage Desktop ================="
  echo -e "${INFO_TEXT}"
  echo "A copy of this info is at: ${README}"
  echo "===================================================="
  echo
fi

echo "[✓] Done."
echo "Binary:   ${BIN_PATH}"
echo "Overlay:  ${OVERLAY_DIR}"
echo "Cache:    ${CACHE_DIR}"
echo "Launcher: ${LAUNCHER}"
echo "README:   ${README}"
echo "Launch via EmulationStation: Ports → “RunImage Desktop”."
echo "Update Gamelist to see in Ports."
sleep 4
