#!/bin/bash


# install-steam-runimage.sh — Batocera (ZIP split version; uses unzip)
# - Downloads split ZIP parts
# - Extracts a single file named "runimage"
# - Installs to /userdata/roms/ports/steam/runimage
# - Creates ensure_fuse.sh + Steam.sh launcher (overlay first, unpack fallback)
# Check if Xwayland is running
if ! pgrep -x "Xwayland" > /dev/null; then
    echo "❌ Xwayland is not running. Exiting."
    sleep 4
    exit 1
fi

echo "✅ Xwayland detected. Continuing..."
sleep 2

clear
echo "Installing Steam RunImage from profork repo..."
sleep 3
clear
echo "Thanks to VHSgunzo for Runimage!"
echo "Thanks to Mash0star for Making the Steam Runimage!"
sleep 5

set -euo pipefail

# ===== Config =====
PART1_URL="https://github.com/profork/profork/releases/download/r1/runimage-steam.zip.001"
PART2_URL="https://github.com/profork/profork/releases/download/r1/runimage-steam.zip.002"

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
ZIPBASE="runimage-steAM"  # temp base name to avoid collisions (case mix to dodge odd matchers)

# ===== UX =====
clear
echo "Installing Steam RunImage (ZIP split) ..."
sleep 1
echo "Using Batocera paths under /userdata"
sleep 1

# ===== Helpers =====
fetch() {
  # fetch <url> <outfile>
  if command -v curl >/dev/null 2>&1; then
    curl -L --retry 3 -o "$2" "$1"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$2" "$1"
  else
    echo "ERROR: Neither curl nor wget is available." >&2
    exit 1
  fi
}

have_unzip() { command -v unzip >/dev/null 2>&1; }

try_unzip_split() {
  # Try standard split layout expected by Info-ZIP:
  #   <base>.z01, <base>.z02, ..., <base>.zip  (last part is .zip)
  local dir="$1" base="$2"
  if ! have_unzip; then return 1; fi
  ( cd "$dir" && unzip -o "${base}.zip" >/dev/null )
}

concat_zip_and_unzip() {
  local dir="$1" out="$2" ; shift 2
  # Concatenate parts to a full .zip then unzip
  cat "$@" > "${dir}/${out}"
  ( cd "$dir" && unzip -o "$out" >/dev/null )
}

# ===== Prep =====
echo "➤ Preparing folders…"
mkdir -p "${STEAM_DIR}" "${DEST_BASE}" "${OVERLAY_DIR}" "${CACHE_DIR}" "${RUNTIME_DIR}" "${TMPDIR}"

cleanup() { rm -rf "${TMPDIR}" || true; }
trap cleanup EXIT

# ===== Check unzip =====
if ! have_unzip; then
  echo "ERROR: 'unzip' is not available on this Batocera build." >&2
  echo "Please add an 'unzip' binary into PATH (e.g., /userdata/system/bin) and rerun." >&2
  exit 1
fi

# ===== Download =====
echo "➤ Downloading Steam RunImage ZIP parts…"
P1="${TMPDIR}/${ZIPBASE}.zip.001"
P2="${TMPDIR}/${ZIPBASE}.zip.002"
fetch "${PART1_URL}" "${P1}"
fetch "${PART2_URL}" "${P2}"

# ===== Extract =====
echo "➤ Extracting…"

# Approach A: rename to Info-ZIP split scheme and use unzip
#   001 -> .z01, 002 -> .zip
Z01="${TMPDIR}/${ZIPBASE}.z01"
ZLAST="${TMPDIR}/${ZIPBASE}.zip"
cp -f "${P1}" "${Z01}"
cp -f "${P2}" "${ZLAST}"

set +e
if try_unzip_split "${TMPDIR}" "${ZIPBASE}"; then
  ok=1
else
  ok=0
fi
set -e

# Approach B: if A failed (some BusyBox variants), concat then unzip
if [ "$ok" -ne 1 ]; then
  echo "   …split-unzip failed; trying concatenation fallback"
  FULL="${TMPDIR}/${ZIPBASE}-full.zip"
  concat_zip_and_unzip "${TMPDIR}" "$(basename "$FULL")" "${P1}" "${P2}"
fi

# Expect a single file named 'runimage' after extraction
if [ ! -f "${TMPDIR}/runimage" ]; then
  # Some creators store inside a folder; try to find it
  CAND="$(busybox find "${TMPDIR}" -maxdepth 2 -type f -name runimage 2>/dev/null | head -n1 || true)"
  if [ -n "${CAND}" ]; then
    mv -f "${CAND}" "${TMPDIR}/runimage"
  fi
fi

if [ ! -f "${TMPDIR}/runimage" ]; then
  echo "ERROR: Extraction did not produce 'runimage'." >&2
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
echo "✅ Steam RunImage installed for Batocera (ZIP split)."
echo "   • RunImage: ${BIN_PATH}"
echo "   • ensure_fuse: ${ENSURE_FUSE}"
echo "   • Launcher: ${LAUNCHER}"
echo ""
echo "🎮 In EmulationStation, refresh the Ports list to see 'Steam'."
echo "First Startup can take a long time..be patient"
