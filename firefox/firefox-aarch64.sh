#!/usr/bin/env bash
######################################################################
# PROFORK INSTALLER — FIREFOX (Batocera, aarch64, official .tar.xz)
######################################################################
APPNAME="FIREFOX"
appname=firefox
AppName=firefox
ORIGIN="MOZILLA FIREFOX (Official tar.xz)"

# Batocera roots
ROOT="/userdata"
PRO="$ROOT/system/pro"
APPDIR="$PRO/$appname"
EXTRA="$APPDIR/extra"
DOWNLOADS="$EXTRA/downloads"
ICON_URL="https://github.com/profork/profork/raw/master/firefox/extra/icon.png"

# Official 139.0.4 aarch64 tarball
APPLINK="https://download-installer.cdn.mozilla.net/pub/firefox/releases/139.0.4/linux-aarch64/en-US/firefox-139.0.4.tar.xz"
ARCHIVE_NAME="firefox-139.0.4.tar.xz"

# Targeted paths (post-extract)
EXTRACT_DIR="$APPDIR/app"                  # where we untar firefox/*
FIREFOX_BIN="$EXTRACT_DIR/firefox"         # main binary path
LAUNCHER="$APPDIR/Launcher"                # wrapper we exec from .desktop
ICON="$EXTRA/icon.png"
DESKTOP_SRC="$EXTRA/$appname.desktop"
DESKTOP_DST="/usr/share/applications/$appname.desktop"
PROFILE_DIR="$APPDIR/profile"              # per-app profile, isolated

# --------------------------------------------------------------------
clear; echo; echo; echo -e "PREPARING ${APPNAME} INSTALLER, PLEASE WAIT . . ."; echo; echo; echo; echo
sleep 0.33
clear
echo
echo
echo -e "--------------------------------------------------------"
echo -e "PROFORK/${APPNAME} INSTALLER"
echo -e "--------------------------------------------------------"
echo
sleep 0.33
clear
echo -e "--------------------------------------------------------"
echo -e "--------------------------------------------------------"
echo -e "PROFORK/${APPNAME} INSTALLER"
echo -e "--------------------------------------------------------"
echo -e "--------------------------------------------------------"
echo
sleep 0.33
clear
echo -e "--------------------------------------------------------"
echo -e "--------------------------------------------------------"
echo -e "--------------------------------------------------------"
echo -e "PROFORK/${APPNAME} INSTALLER"
echo -e "--------------------------------------------------------"
echo -e "--------------------------------------------------------"
echo -e "--------------------------------------------------------"
echo
echo "THIS WILL INSTALL ${APPNAME} FOR BATOCERA (aarch64)"
echo "USING ${ORIGIN}"
echo
echo "${APPNAME} WILL BE AVAILABLE IN F1->APPLICATIONS"
echo "AND INSTALLED IN $APPDIR"
echo

# --------------------------------------------------------------------
# Require aarch64 Batocera
if ! uname -m | grep -qE '^aarch64$'; then
  echo
  echo "ERROR: SYSTEM NOT SUPPORTED"
  echo "YOU NEED BATOCERA aarch64"
  echo
  sleep 5
  exit 1
fi

# Prep dirs
mkdir -p "$PRO" "$APPDIR" "$EXTRA" "$DOWNLOADS" "$PROFILE_DIR"

# --------------------------------------------------------------------
# Fetch icon (best-effort)
echo
echo "Fetching icon..."
if command -v wget >/dev/null 2>&1; then
  wget -q -O "$ICON" "$ICON_URL" || true
else
  curl -fsSL -o "$ICON" "$ICON_URL" || true
fi

# --------------------------------------------------------------------
# Download Firefox tarball
echo
echo "DOWNLOADING $APPNAME . . ."
echo "> $APPLINK"
rm -f "$DOWNLOADS/$ARCHIVE_NAME"
if command -v wget >/dev/null 2>&1; then
  wget --progress=bar:force -O "$DOWNLOADS/$ARCHIVE_NAME" "$APPLINK"
else
  curl --progress-bar -Lo "$DOWNLOADS/$ARCHIVE_NAME" "$APPLINK"
fi

# --------------------------------------------------------------------
# Extract
echo
echo "EXTRACTING . . ."
rm -rf "$EXTRACT_DIR"
mkdir -p "$EXTRACT_DIR"
# The tarball contains a top-level 'firefox/' dir; strip it in.
tar -xf "$DOWNLOADS/$ARCHIVE_NAME" -C "$EXTRACT_DIR" --strip-components=1
chmod +x "$FIREFOX_BIN" || true
SIZE_MB=$(($(wc -c < "$DOWNLOADS/$ARCHIVE_NAME")/1048576))
echo "> $DOWNLOADS/$ARCHIVE_NAME ${SIZE_MB}MB OK"
rm -f "$DOWNLOADS/$ARCHIVE_NAME"

# --------------------------------------------------------------------
# Launcher (Batocera: show cursor via batocera-mouse, isolate profile)
echo
echo "INSTALLING LAUNCHER . . ."
cat > "$LAUNCHER" <<'EOF'
#!/usr/bin/env bash
# Batocera Firefox launcher (isolated profile)
set -euo pipefail
APPDIR="$(cd "$(dirname "$0")" && pwd)"
EXTRACT_DIR="$APPDIR/app"
FIREFOX_BIN="$EXTRACT_DIR/firefox"
PROFILE_DIR="$APPDIR/profile"

# Batocera cursor control (replace unclutter-remote)
if command -v batocera-mouse >/dev/null 2>&1; then
  batocera-mouse show || true
fi

export DISPLAY="${DISPLAY:-:0.0}"
export HOME="$PROFILE_DIR"

# DPI/scale knobs (tweak as needed)
export QT_FONT_DPI="${QT_FONT_DPI:-128}"
export QT_SCALE_FACTOR="${QT_SCALE_FACTOR:-1}"
export GDK_SCALE="${GDK_SCALE:-1}"

exec "$FIREFOX_BIN" --profile "$PROFILE_DIR" "$@"
EOF
chmod a+x "$LAUNCHER"

# Normalize line endings if dos2unix exists
if command -v dos2unix >/dev/null 2>&1; then
  dos2unix "$LAUNCHER" >/dev/null 2>&1 || true
fi

# --------------------------------------------------------------------
# .desktop for F1->Applications
echo
echo "WRITING DESKTOP ENTRY . . ."
cat > "$DESKTOP_SRC" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$appname
Exec=$LAUNCHER
Icon=$ICON
Terminal=false
Categories=Game;batocera.linux;
EOF

if command -v dos2unix >/dev/null 2>&1; then
  dos2unix "$DESKTOP_SRC" >/dev/null 2>&1 || true
fi
cp "$DESKTOP_SRC" "$DESKTOP_DST" 2>/dev/null || true

# --------------------------------------------------------------------
# Prelauncher to re-copy .desktop at boot (survives updates)
PRE="$EXTRA/startup"
echo
echo "SETTING STARTUP HOOK . . ."
cat > "$PRE" <<EOF
#!/usr/bin/env bash
cp "$DESKTOP_SRC" "$DESKTOP_DST" 2>/dev/null || true
EOF
chmod a+x "$PRE"
if command -v dos2unix >/dev/null 2>&1; then
  dos2unix "$PRE" >/dev/null 2>&1 || true
fi

# Hook into /userdata/system/custom.sh (Batocera)
CSH="$ROOT/system/custom.sh"
touch "$CSH"
# idempotent insert
if ! grep -Fq "$PRE" "$CSH"; then
  # ensure shebang first line
  if ! head -n1 "$CSH" | grep -q '^#!/bin/bash'; then
    (echo '#!/bin/bash'; cat "$CSH") > "$CSH.tmp" && mv "$CSH.tmp" "$CSH"
  fi
  printf "\n%s\n" "$PRE" >> "$CSH"
  chmod a+x "$CSH"
fi

# --------------------------------------------------------------------
# Autostart aggregator (matches your pattern)
autostart() {
  local pcsh="$ROOT/system/pro-custom.sh"
  local temp_file
  temp_file="$(mktemp)"
  find "$PRO" -type f \( -path "*/extra/startup" -o -path "*/extras/startup.sh" \) > "$temp_file"
  echo "#!/bin/bash" > "$pcsh"
  sort "$temp_file" >> "$pcsh"
  rm -f "$temp_file"
  chmod a+x "$pcsh"

  # ensure referenced by custom.sh exactly once
  local tmpc
  tmpc="$(mktemp)"
  grep -vxFf "$pcsh" "$CSH" > "$tmpc" || true
  mapfile -t lines < "$tmpc"
  if [[ "${#lines[@]}" -eq 0 || "${lines[0]}" != "#!/bin/bash" ]]; then
    lines=( "#!/bin/bash" "${lines[@]}" )
  fi
  if ! grep -Fxq "$pcsh &" "$tmpc"; then
    lines=( "${lines[0]}" "$pcsh &" "${lines[@]:1}" )
  fi
  printf "%s\n" "${lines[@]}" > "$CSH"
  chmod a+x "$CSH"
  rm -f "$tmpc"
}
autostart

# --------------------------------------------------------------------
echo
echo "-----------------------------------------------------------------------"
echo "> $APPNAME INSTALLED OK (Batocera aarch64)"
echo "  • Launcher: $LAUNCHER"
echo "  • Profile : $PROFILE_DIR"
echo "  • Binary  : $FIREFOX_BIN"
echo "-----------------------------------------------------------------------"
sleep 2
exit 0
