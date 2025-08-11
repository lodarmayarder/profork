#!/bin/bash
set -euo pipefail

PKG_URL="https://github.com/profork/profork/releases/download/r1/armhf-pack.tgz"
WORK_TGZ="/tmp/armhf-pack.tgz"
DEST_ROOT="/userdata/system/pro/armhf"
CUSTOM_SH="/userdata/system/custom.sh"

mkdir -p "$DEST_ROOT" "$(dirname "$CUSTOM_SH")"

# Download with progress bar
echo "Downloading ARMHF pack..."
curl -L "$PKG_URL" -o "$WORK_TGZ"

# Extract
echo "Extracting..."
tar -xzf "$WORK_TGZ" -C "$DEST_ROOT"

# Function to create symlinks
create_links() {
  mount -o remount,rw / || true
  # Link ld-linux-armhf.so.3 from $DEST_ROOT/lib to /lib
  if [ -f "$DEST_ROOT/lib/ld-linux-armhf.so.3" ]; then
    ln -sfn "$DEST_ROOT/lib/ld-linux-armhf.so.3" /lib/ld-linux-armhf.so.3
  fi

  # Link /lib32 -> $DEST_ROOT/lib32
  ln -sfn "$DEST_ROOT/lib32" /lib32

  # Link /usr/lib32 -> $DEST_ROOT/usr/lib32
  mkdir -p /usr
  ln -sfn "$DEST_ROOT/usr/lib32" /usr/lib32
}

# Write custom.sh to run at boot
cat > "$CUSTOM_SH" <<'EOF'
#!/bin/bash
DEST_ROOT="/userdata/system/pro/armhf"
mount -o remount,rw / || true

# Link ld-linux-armhf.so.3
if [ -f "$DEST_ROOT/lib/ld-linux-armhf.so.3" ]; then
  ln -sfn "$DEST_ROOT/lib/ld-linux-armhf.so.3" /lib/ld-linux-armhf.so.3
fi

# Link /lib32
ln -sfn "$DEST_ROOT/lib32" /lib32

# Link /usr/lib32
mkdir -p /usr
ln -sfn "$DEST_ROOT/usr/lib32" /usr/lib32
EOF

chmod +x "$CUSTOM_SH"

# Create links immediately
create_links

# Final dialog
if command -v dialog >/dev/null 2>&1 && [ -t 1 ]; then
  dialog --title "ARMHF Pack Installer" --msgbox "Install complete!\n\nFiles in $DEST_ROOT\nSymlinks created now and at boot." 8 60
else
  echo "Install complete. Files in $DEST_ROOT. Symlinks created now and at boot."
fi

