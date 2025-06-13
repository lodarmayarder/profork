#!/bin/bash

SOAR_DIR="/userdata/system/pro/soar"
SOAR_BIN="$SOAR_DIR/soar"
SOAR_URL="https://github.com/pkgforge/soar/releases/download/v0.6.3/soar-x86_64-linux"
SOAR_SYMLINK="/usr/bin/soar"
CUSTOM_SH="/userdata/system/custom.sh"

echo "Creating Soar directory..."
mkdir -p "$SOAR_DIR"

echo "Downloading Soar..."
curl -# -L "$SOAR_URL" -o "$SOAR_BIN"

echo "Making Soar executable..."
chmod +x "$SOAR_BIN"

echo "Creating symlink in /usr/bin/soar for immediate use..."
ln -sf "$SOAR_BIN" "$SOAR_SYMLINK"

# Ensure custom.sh exists
if [ ! -f "$CUSTOM_SH" ]; then
    echo "#!/bin/bash" > "$CUSTOM_SH"
    chmod +x "$CUSTOM_SH"
fi

# Add Soar relink on boot (if not already present)
if ! grep -q "ln -sf $SOAR_BIN $SOAR_SYMLINK" "$CUSTOM_SH"; then
    echo "ln -sf $SOAR_BIN $SOAR_SYMLINK" >> "$CUSTOM_SH"
fi

# Display final dialog box
dialog --msgbox "Soar setup is complete!

- Soar has been installed and symlinked to /usr/bin/soar.
- It is available for immediate use and will persist on reboot.
- To verify, run: soar -h 

Enjoy!" 12 60
