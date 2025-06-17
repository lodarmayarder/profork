#!/bin/bash

# Set target variables
PORT_DIR="/userdata/roms/ports/apotris"
LAUNCHER="/userdata/roms/ports/Apotris.sh"
ZIP_URL="https://apotrisstorage.blob.core.windows.net/binaries/Apotris-v4.1.0Linux-x64.zip"
ZIP_PATH="/tmp/apotris.zip"

echo "📦 Creating Apotris port folder..."
mkdir -p "$PORT_DIR"

echo "🌐 Downloading Apotris..."
curl -L "$ZIP_URL" -o "$ZIP_PATH"

echo "📂 Extracting..."
unzip -o "$ZIP_PATH" -d "$PORT_DIR"
chmod +x "$PORT_DIR/Apotris"

echo "🚀 Creating Apotris.sh launcher..."
cat << 'EOF' > "$LAUNCHER"
#!/bin/bash
cd "/userdata/roms/ports/apotris"
export HOME=/userdata/saves/apotris
mkdir -p "$HOME"
exec ./Apotris
EOF

chmod +x "$LAUNCHER"

echo "✅ Apotris installed!"
echo "👉 Please update your game list in EmulationStation to see it under Ports."
echo "⏳ Continuing or exiting in 8 seconds..."
sleep 8
