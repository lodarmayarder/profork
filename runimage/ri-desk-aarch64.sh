#!/bin/bash
# runimage_install_and_port_launcher.sh
# Installs RunImage (correct arch), sets up a Ports launcher,
# enables overlay when FUSE is available, and auto-falls back
# to no-FUSE persistent "extracted" mode on aarch64/x86_64.

set -euo pipefail

# --- Detect arch & choose asset ---
ARCH="$(uname -m)"
case "${ARCH}" in
  aarch64|arm64) ASSET="runimage-aarch64" ;;
  x86_64|amd64)  ASSET="runimage-x86_64"  ;;
  *)
    echo "Unsupported arch: ${ARCH}"
    exit 1
  ;;
esac

BIN_URL="https://github.com/VHSgunzo/runimage/releases/download/continuous/${ASSET}"
DEST_BASE="/userdata/system/runimage"
BIN_PATH="${DEST_BASE}/runimage"
OVERLAY_DIR="${DEST_BASE}/overlays"
CACHE_DIR="${DEST_BASE}/cache"
RUNTIME_DIR="${DEST_BASE}/runtime"     # where we keep the extracted rootfs if FUSE is unavailable
PORTS_DIR="/userdata/roms/ports"
LAUNCHER="${PORTS_DIR}/RunImage Desktop.sh"
README="${DEST_BASE}/README.txt"
OVERFS_ID="ally-xfce"
DISPLAY_VAR=":0.0"

echo "[*] Creating directories..."
mkdir -p "${DEST_BASE}" "${OVERLAY_DIR}" "${CACHE_DIR}" "${RUNTIME_DIR}" "${PORTS_DIR}"

echo "[*] Downloading ${ASSET} -> ${BIN_PATH}"
curl -L --fail --retry 3 --progress-bar "${BIN_URL}" -o "${BIN_PATH}"
chmod +x "${BIN_PATH}"

# Helper that tries to ready FUSE; harmless if it's already ok.
cat > "${DEST_BASE}/ensure_fuse.sh" <<'EOSH'
#!/bin/sh
# Try to ensure /dev/fuse exists & module is loaded (if available)
set -eu
if [ ! -e /dev/fuse ]; then
  modprobe fuse 2>/dev/null || true
  [ -e /dev/fuse ] || mknod /dev/fuse -m 0666 c 10 229 || true
fi
EOSH
chmod +x "${DEST_BASE}/ensure_fuse.sh"

echo "[*] Writing Ports launcher -> ${LAUNCHER}"
cat > "${LAUNCHER}" <<'EOF'
#!/bin/bash
set -euo pipefail

DEST_BASE="/userdata/system/runimage"
BIN_PATH="${DEST_BASE}/runimage"
OVERLAY_DIR="${DEST_BASE}/overlays"
CACHE_DIR="${DEST_BASE}/cache"
RUNTIME_DIR="${DEST_BASE}/runtime"
OVERFS_ID="ally-xfce"
DISPLAY_VAR=":0.0"

ensure_fuse() { "${DEST_BASE}/ensure_fuse.sh" || true; }

launch_overlay() {
  RIM_OVERFS_ID="${OVERFS_ID}" \
  RIM_KEEP_OVERFS=1 \
  RIM_UNSHARE_HOME=1 \
  RIM_BIND="/userdata:/userdata,/media:/media" \
  RIM_OVERFSDIR="${OVERLAY_DIR}" \
  RIM_CACHEDIR="${CACHE_DIR}" \
  RIM_ALLOW_ROOT=1 DISPLAY="${DISPLAY_VAR}" \
  "${BIN_PATH}" rim-desktop
}

launch_unpacked() {
  # No FUSE path: use runtime extract-and-run into a persistent target dir.
  # NO_CLEANUP=1 keeps the extracted tree for reuse so changes persist.
  URUNTIME_TARGET_DIR="${RUNTIME_DIR}" \
  TMPDIR="${RUNTIME_DIR}" \
  RUNTIME_EXTRACT_AND_RUN=1 \
  NO_CLEANUP=1 \
  RIM_UNSHARE_HOME=1 \
  RIM_BIND="/userdata:/userdata,/media:/media" \
  RIM_ALLOW_ROOT=1 DISPLAY="${DISPLAY_VAR}" \
  "${BIN_PATH}" rim-desktop
}

mkdir -p "${OVERLAY_DIR}" "${CACHE_DIR}" "${RUNTIME_DIR}"

# Try FUSE/overlay first; if it fails, fall back to unpacked mode.
ensure_fuse
set +e
launch_overlay
rc=$?
set -e
if [ $rc -ne 0 ]; then
  echo "[!] Overlay launch failed (likely FUSE unavailable). Falling back to unpacked mode..."
  launch_unpacked
fi
EOF
chmod +x "${LAUNCHER}"

# --- README & Info box ---
cat > "${README}" <<'EOF'
RunImage Desktop installed!

Modes:
• Overlay (preferred): requires FUSE; saves your changes to an OverlayFS id.
• Unpacked fallback: if FUSE is missing, the runtime extracts into /userdata/system/runimage/runtime and reuses it for persistence.

Tips:
• Pacman is already set up inside the desktop.

• Chromium-based apps (e.g., Google Chrome/Brave/Chromium) as root:
    use --no-sandbox
    Examples:
    
      chromium --no-sandbox

Overlay maintenance:
  /userdata/system/runimage/runimage rim-ofsls       # list overlays
  /userdata/system/runimage/runimage rim-ofsrm ally-xfce   # remove this overlay

If overlay fails with “failed to utilize FUSE”:
  - Make sure you're using the correct arch build (aarch64 on ARM boards).
  - Ensure /dev/fuse exists (the launcher tries to create it automatically).
EOF

INFO_TEXT="$(cat "${README}")"
if command -v dialog >/dev/null 2>&1; then
  dialog --title "RunImage Desktop" --msgbox "${INFO_TEXT}" 22 78 || true
else
  echo
  echo "================= RunImage Desktop ================="
  echo "${INFO_TEXT}"
  echo "A copy of this info is at: ${README}"
  echo "===================================================="
  echo
fi

clear

echo "[✓] Done."
echo "Binary:   ${BIN_PATH}"
echo "Overlay:  ${OVERLAY_DIR}"
echo "Cache:    ${CACHE_DIR}"
echo "Runtime:  ${RUNTIME_DIR}"
echo "Launcher: ${LAUNCHER}"
echo "README:   ${README}"
echo "Launch via EmulationStation: Ports → “RunImage Desktop” after updating Gamelist"
sleep 7
clear
echo "FIRST LAUNCH CAN TAKE A LONG TIME"
echo "ESPECIALLY ON MICRO SD CARDS / SLOWER MACHINES"
echo "DESKTKOP INSTALLS IN BACKGROUND - 5-10 MINUTES IS NORMAL"
echo ""
echo ""
echo "EXITING IN 10 SECONDS"
sleep 10
