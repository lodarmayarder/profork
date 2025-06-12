!/bin/bash

CHROOT_DIR="/userdata/system/alpine"

# Function to check if Alpine chroot is already installed
install_alpine_chroot() {
    echo "🔍 Checking if Alpine chroot is already installed..."
    if [ -d "$CHROOT_DIR" ] && [ -f "$CHROOT_DIR/bin/busybox" ]; then
        echo "✅ Alpine chroot detected. Skipping installation."
    else
        echo "🚀 Installing Alpine chroot..."
        curl -L  https://github.com/profork/profork/raw/master/scripts/install-alpine.sh | bash
    fi
}
# Function to update Alpine repositories
update_repositories() {
    echo "🌍 Updating Alpine package sources..."

    # Ensure chroot environment exists
    if [ ! -d "$CHROOT_DIR" ] || [ ! -f "$CHROOT_DIR/bin/sh" ]; then
        echo "❌ Alpine chroot is missing! Exiting."
        return 1
    fi

    # Fix repositories from outside chroot
    cat <<EOF > "$CHROOT_DIR/etc/apk/repositories"
https://dl-cdn.alpinelinux.org/alpine/v3.21/main
https://dl-cdn.alpinelinux.org/alpine/v3.21/community
EOF

    # Ensure file has correct line endings
    sed -i 's/\r$//' "$CHROOT_DIR/etc/apk/repositories"

    echo "✅ Alpine repositories updated!"

    # Enter chroot and update
    chroot "$CHROOT_DIR" /bin/sh -c "
        apk update && apk add nano && apk upgrade
    "
}


# Ensure Alpine chroot exists before updating repositories
install_alpine_chroot
update_repositories

echo "🎉 Alpine chroot setup complete!"
