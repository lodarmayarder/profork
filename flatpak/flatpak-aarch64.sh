#!/bin/sh
# install-flatpak-wrapper-batocera.sh — Flatpak via RunImage on Batocera
# - Stores everything under /userdata/system
# - Extracts on /userdata (suid-capable) so bwrap SUID works
# - No UnionFS/overlay (fixes your “Failed to mount … overlay mode” error)
# - Persists /var/lib/flatpak to /userdata/system/flatpak
# - Installs wrapper at /userdata/system/bin/flatpak and exports PATH via custom.sh

set -eu

# ===== CONFIG =====
RUNIMAGE_URL="${RUNIMAGE_URL:-https://github.com/profork/ROCKNIX-apps/releases/download/r1/runimage-flatpak-aarch64}"
RUNIMAGE_SHA256="${RUNIMAGE_SHA256:-}"   # optional

ARCH="$(uname -m)"
if [ "$ARCH" != "aarch64" ]; then
  echo "Warning: this RunImage is aarch64-oriented; detected: $ARCH"
  echo "Set RUNIMAGE_URL to an x86_64 build if needed, then re-run."
fi

# ===== Paths (Batocera) =====
UD="/userdata"
SYS="$UD/system"
NS="flatpak"
RI_BASE="$SYS/ri/$NS"
RI_IMAGE="$RI_BASE/runimage"        # downloaded RunImage
TMPDIR_HOST="$RI_BASE/tmp"          # extraction location (SUID-capable)
FLATPAK_DB="$SYS/flatpak"           # persistent /var/lib/flatpak
BIN_DIR="$SYS/bin"
WRAP="$BIN_DIR/flatpak"             # host-visible command
CUSTOM="$SYS/custom.sh"

# ===== Ensure dirs =====
mkdir -p "$RI_BASE" "$TMPDIR_HOST" "$FLATPAK_DB" "$BIN_DIR"

echo ">>> Downloading RunImage → $RI_IMAGE"
curl -L --fail --retry 3 -o "$RI_IMAGE" "$RUNIMAGE_URL"
chmod +x "$RI_IMAGE"

if [ -n "$RUNIMAGE_SHA256" ]; then
  echo "$RUNIMAGE_SHA256  $RI_IMAGE" | sha256sum -c -
fi

echo ">>> Installing wrapper → $WRAP"
cat > "$WRAP" <<'EOF'
#!/bin/sh
# /userdata/system/bin/flatpak — Run Flatpak inside RunImage on Batocera (overlay-free)

set -eu

ROOT="/userdata"
SYS="$ROOT/system"
NS="flatpak"
RI_BASE="$SYS/ri/$NS"
RI_IMAGE="$RI_BASE/runimage"
TMPDIR_HOST="$RI_BASE/tmp"
FLATPAK_DB="$SYS/flatpak"

# Ensure dirs
mkdir -p "$TMPDIR_HOST" "$FLATPAK_DB" || true

# GUI defaults (Batocera usually has a DISPLAY from EmulationStation)
[ -n "${DISPLAY:-}" ] || export DISPLAY=":0"

# Session bus (many GUI apps need a user bus)
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/0}"
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR" || true

# Show Flatpak-exported desktop files without session restart
EXPORTS_SYSTEM="/var/lib/flatpak/exports/share"
EXPORTS_USER="${HOME:-/root}/.local/share/flatpak/exports/share"
case "${XDG_DATA_DIRS:-}" in
  *"$EXPORTS_SYSTEM"*) : ;;
  *) export XDG_DATA_DIRS="${EXPORTS_SYSTEM}:${EXPORTS_USER}:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}" ;;
esac

# RunImage env — extract on /userdata (SUID honored), no overlay
export TMPDIR="$TMPDIR_HOST"
export RUNTIME_EXTRACT_AND_RUN=1
export URUNTIME_EXTRACT=1
export RIM_PORTABLE_HOME=1
export RIM_PORTABLE_CONFIG=1
export RIM_ALLOW_ROOT=1
# Persist Flatpak DB + expose userdata
export RIM_BIND="$FLATPAK_DB:/var/lib/flatpak,/userdata:/userdata"

# One-time bootstrap inside the RunImage:
# - make sure flatpak + portals + dbus exist
# - set bwrap SUID so inner sandbox works
BOOTSTRAP='
  set -e
  if ! command -v flatpak >/dev/null 2>&1; then
    pacman -Sy --noconfirm || true
    pacman -S --noconfirm flatpak xdg-desktop-portal xdg-desktop-portal-gtk dbus || true
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
  fi
  if command -v bwrap >/dev/null 2>&1; then
    rb="$(readlink -f /usr/bin/bwrap)" || true
    if [ -n "$rb" ] && [ -f "$rb" ]; then chmod u+s "$rb" || true; fi
  fi
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/0}"
  mkdir -p "$XDG_RUNTIME_DIR"; chmod 700 "$XDG_RUNTIME_DIR" || true
'

# Quote/forward args
ARGS=""
for a in "$@"; do
  q=$(printf "%s" "$a" | sed "s/'/'\\\\''/g")
  ARGS="$ARGS '$q'"
done

# Use a user session bus only for GUI app runs
first_arg="${1:-}"
if [ "$first_arg" = "run" ]; then
  CMD="dbus-run-session -- flatpak $ARGS"
else
  CMD="flatpak $ARGS"
fi

exec "$RI_IMAGE" rim-shell -c "$BOOTSTRAP $CMD"
EOF
chmod +x "$WRAP"

# ===== Ensure wrapper is in PATH on boot and now =====
touch "$CUSTOM"
# Shebang if missing
if ! head -n1 "$CUSTOM" 2>/dev/null | grep -qE '^#!/bin/(ba)?sh'; then
  sed -i '1i #!/bin/bash' "$CUSTOM" 2>/dev/null || true
fi
# Add PATH idempotently
if ! grep -Fq '/userdata/system/bin' "$CUSTOM" 2>/dev/null; then
  printf '\nexport PATH="/userdata/system/bin:${PATH:-/usr/bin:/bin}"\n' >> "$CUSTOM"
fi
# Current shell
export PATH="/userdata/system/bin:${PATH:-/usr/bin:/bin}"

echo ">>> Smoke test (flatpak --version)…"
if ! flatpak --version; then
  echo "NOTE: If this failed, re-open your shell or 'source /userdata/system/custom.sh' and try again."
fi

cat <<MSG

✅ Install complete.

Wrapper:        $WRAP
RunImage:       $RI_IMAGE
Flatpak data:   $FLATPAK_DB   (bind-mounted to /var/lib/flatpak inside RunImage)

Next steps (try now or after restarting shell):
  flatpak --version
  flatpak remotes
  flatpak install --system -y flathub io.github.peazip.PeaZip
  flatpak run io.github.peazip.PeaZip   # add --no-sandbox for Chromium-based apps if needed

Tips:
  • We extract on /userdata so SUID on bwrap sticks (inner sandbox works).
  • No overlay flags are used, avoiding your previous "Failed to mount … overlay mode!" error.
  • If GUI won’t show, ensure DISPLAY is valid (Batocera usually sets :0).
MSG
