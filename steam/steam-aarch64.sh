#!/bin/bash
# install-steam-runimage.sh — Batocera (concatenate split parts; no unzip/7z)
# - Downloads split parts (e.g., runimage-aa, runimage-ab OR .001, .002, …)
# - Concatenates into a single file named "runimage"
# - Installs to /userdata/roms/ports/steam/runimage
# - Creates ensure_fuse.sh + Steam.sh launcher (overlay first, unpack fallback)

# ===== Early check: Xwayland =====
if ! pgrep -x "Xwayland" >/dev/null; then
  echo "❌ Xwayland is not running. Exiting."
  sleep 4
  exit 1
fi
echo "✅ Xwayland detected. Continuing..."
sleep 1

set -euo pipefail

clear
echo "Installing Steam RunImage (concatenated split parts)…"
sleep 1
echo "Using Batocera paths under /userdata"
sleep 1

# ===== Config =====
# Provide your split part URLs here (aa/ab style shown). You can also list .001, .002, etc.
PART_URLS=(
  "https://github.com/profork/profork/releases/download/r1/runimage-aa"
  "https://github.com/profork/profork/releases/download/r1/runimage-ab"
)

# If you still want to support old .zip.001/.zip.002 files, uncomment and replace PART_URLS above.
# PART_URLS=(
#   "https://github.com/profork/profork/releases/download/r1/runimage-steam.zip.001"
#   "https://github.com/profork/profork/releases/download/r1/runimage-steam.zip.002"
# )

PORTS_DIR="/userdata/roms/ports"
STEAM_DIR="${PORTS_DIR}/steam"
DEST_BASE="/userdata/system/runimage"        # persistent support area
BIN_PATH="${STEAM_DIR}/runimage"
OVERLAY_DIR="${DEST_BASE}/overlays"
CACHE_DIR="${DEST_BASE}/cache"
RUNTIME_DIR="${DEST_BASE}/runtime"
LAUNCHER="${PORTS_DIR}/Steam.sh"
ENSURE_FUSE="${DEST_BASE}/ensure_fuse.sh"

TMPDIR="/userdata/system/tmp/install-steam-runimage.$$"

# ===== Helpers =====
fetch() {
  # fetch <url> <outfile>
  if command -v curl >/devnull 2>&1; then
    curl -L --retry 3 -o "$2" "$1"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$2" "$1"
  else
    echo "ERROR: Neither curl nor wget is available." >&2
    exit 1
  fi
}

# ===== Prep =====
echo "➤ Preparing folders…"
mkdir -p "${STEAM_DIR}" "${DEST_BASE}" "${OVERLAY_DIR}" "${CACHE_DIR}" "${RUNTIME_DIR}" "${TMPDIR}"

cleanup() { rm -rf "${TMPDIR}" || true; }
trap cleanup EXIT

# ===== Download parts =====
echo "➤ Downloading split parts…"
PART_FILES=()
idx=0
for url in "${PART_URLS[@]}"; do
  part="${TMPDIR}/part.$(printf '%03d' "$idx")"
  fetch "$url" "$part"
  if [ ! -s "$part" ]; then
    echo "ERROR: Downloaded part is empty: $url" >&2
    exit 1
  fi
  PART_FILES+=("$part")
  idx=$((idx+1))
done

# ===== Concatenate (version-sort to be safe for .001/.002/…/.010) =====
echo "➤ Concatenating parts…"
# shellcheck disable=SC2207
SORTED_PARTS=($(printf "%s\n" "${PART_FILES[@]}" | sort -V))
cat "${SORTED_PARTS[@]}" > "${TMPDIR}/runimage"

# quick sanity: must be non-zero and executable-ish (we just chmod it)
if [ ! -s "${TMPDIR}/runimage" ]; then
  echo "ERROR: Concatenation produced an empty 'runimage'." >&2
  exit 2
fi

# ===== Install RunImage =====
echo "➤ Installing RunImage to ${BIN_PATH}…"
mv -f "${TMPDIR}/runimage" "${BIN_PATH}"
chmod +x "${BIN_PATH}"

# ===== ensure_fuse.sh =====
echo "➤ Writing ${ENSURE_FUSE}…"
cat > "${ENSURE_FUSE}" <<'EOF'
#!/bin/sh
# Minimal FUSE helper for RunImage overlay usage (Batocera)
set -eu
if [ -e /dev/fuse ]; then
  exit 0
fi
if command -v modprobe >/dev/null 2>&1; then
  modprobe fuse 2>/dev/null || true
fi
if [ ! -e /dev/fuse ]; then
  echo "[WARN] /dev/fuse not available; overlay mode may fail (fallback will be used)."
fi
exit 0
EOF
chmod +x "${ENSURE_FUSE}"

# ===== Launcher =====
echo "➤ Creating launcher ${LAUNCHER}…"
cat > "${LAUNCHER}" <<'EOF'
#!/bin/bash
# Batocera Steam RunImage launcher for EmulationStation Ports
set -euo pipefail

DEST_BASE="/userdata/system/runimage"
BIN_PATH="/userdata/roms/ports/steam/runimage"
OVERLAY_DIR="${DEST_BASE}/overlays"
CACHE_DIR="${DEST_BASE}/cache"
RUNTIME_DIR="${DEST_BASE}/runtime"

OVERFS_ID="batocera-steam"
DISPLAY_VAR="${DISPLAY:-:0.0}"   # prefer existing DISPLAY; fallback to :0.0

ensure_fuse() { "${DEST_BASE}/ensure_fuse.sh" || true; }

launch_overlay() {
  RIM_OVERFS_ID="${OVERFS_ID}" \
  RIM_KEEP_OVERFS=1 \
  RIM_UNSHARE_HOME=1 \
  RIM_BIND="/userdata:/userdata" \
  RIM_OVERFSDIR="${OVERLAY_DIR}" \
  RIM_CACHEDIR="${CACHE_DIR}" \
  RIM_ALLOW_ROOT=1 DISPLAY="${DISPLAY_VAR}" \
  "${BIN_PATH}" FEXBash /root/.local/share/Steam/steam.sh
}

launch_unpacked() {
  # No FUSE: extract-and-run into persistent dir so changes survive reboots.
  URUNTIME_TARGET_DIR="${RUNTIME_DIR}" \
  TMPDIR="${RUNTIME_DIR}" \
  RUNTIME_EXTRACT_AND_RUN=1 \
  NO_CLEANUP=1 \
  RIM_UNSHARE_HOME=1 \
  RIM_BIND="/userdata:/userdata" \
  RIM_ALLOW_ROOT=1 DISPLAY="${DISPLAY_VAR}" \
  "${BIN_PATH}" FEXBash /root/.local/share/Steam/steam.sh
}

mkdir -p "${OVERLAY_DIR}" "${CACHE_DIR}" "${RUNTIME_DIR}"

ensure_fuse
set +e
launch_overlay
rc=$?
set -e
if [ $rc -ne 0 ]; then
  echo "[!] Overlay launch failed (likely /dev/fuse unavailable). Falling back to unpacked mode..."
  launch_unpacked
fi
EOF
chmod +x "${LAUNCHER}"

echo ""
echo "✅ Steam RunImage installed for Batocera (concatenated)."
echo "   • RunImage: ${BIN_PATH}"
echo "   • ensure_fuse: ${ENSURE_FUSE}"
echo "   • Launcher: ${LAUNCHER}"
echo ""
echo "🎮 In EmulationStation, refresh the Ports list to see 'Steam'."
echo "ℹ️ First launch can take a while."
sleep 7
