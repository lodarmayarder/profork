#!/bin/bash
set -euo pipefail

ARCH="$(uname -m)"
INSTALL_DIR="/userdata/system/docker"
AARCHIVE_URL="https://github.com/profork/profork/releases/download/r1/docker_aarch64.tar.gz"

say(){ printf "\n=== %s ===\n" "$*"; }

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

if [[ "$ARCH" == "aarch64" ]]; then
  say "Installing Docker (aarch64) from tarball"
  [[ -f docker_aarch64.tar.gz ]] || wget -O docker_aarch64.tar.gz "$AARCHIVE_URL"
  tar -xzf docker_aarch64.tar.gz

  # Figure out where it landed (supports both flat and nested 'docker/' layouts)
  # Prefer INSTALL_DIR/docker if present, else INSTALL_DIR
  if [[ -d "$INSTALL_DIR/docker" ]]; then
    DOCKER_ROOT="$INSTALL_DIR/docker"
  else
    DOCKER_ROOT="$INSTALL_DIR"
  fi

  # Find a reasonable start script
  STARTER=""
  for c in \
    "$DOCKER_ROOT/run.sh" \
    "$DOCKER_ROOT/docker.sh" \
    "$DOCKER_ROOT/start.sh" \
    "$DOCKER_ROOT/scripts/run.sh"
  do
    if [[ -f "$c" ]]; then STARTER="$c"; break; fi
  done

  # If still not found, try nested again (some archives are docker/docker.sh etc.)
  if [[ -z "$STARTER" ]]; then
    for c in \
      "$DOCKER_ROOT/docker/run.sh" \
      "$DOCKER_ROOT/docker/docker.sh" \
      "$DOCKER_ROOT/docker/start.sh"
    do
      if [[ -f "$c" ]]; then STARTER="$c"; DOCKER_ROOT="$DOCKER_ROOT/docker"; break; fi
    done
  fi

  if [[ -z "$STARTER" ]]; then
    echo "ERROR: Could not locate a start script (run.sh/docker.sh/start.sh)."
    echo "Contents of $INSTALL_DIR:"
    ls -lah "$INSTALL_DIR"
    exit 1
  fi

  chmod +x "$STARTER"

  # Pick the docker CLI path
  if [[ -x "$DOCKER_ROOT/bin/docker" ]]; then
    DOCKER_CMD="$DOCKER_ROOT/bin/docker"
  else
    echo "ERROR: docker CLI not found at $DOCKER_ROOT/bin/docker"
    exit 1
  fi

elif [[ "$ARCH" == "x86_64" ]]; then
  say "x86_64: using prior single-file helper"
  URL="https://github.com/profork/profork/releases/download/r1/batocera-containers"
  FILE="$INSTALL_DIR/batocera-containers"
  wget -O "$FILE" "$URL"
  chmod +x "$FILE"
  STARTER="$FILE"
  DOCKER_CMD="$(command -v docker || true)"
  if [[ -z "$DOCKER_CMD" ]]; then
    echo "ERROR: Docker CLI not in PATH on x86_64."
    exit 1
  fi
else
  echo "Unsupported arch: $ARCH (only aarch64/x86_64)"
  exit 1
fi

# Ensure autostart
CUSTOM="/userdata/system/custom.sh"
touch "$CUSTOM"; chmod +x "$CUSTOM"
if ! head -n1 "$CUSTOM" | grep -qE '^#!/bin/(ba)?sh'; then
  sed -i '1i #!/bin/bash' "$CUSTOM"
fi
AUTOSTART_LINE="$STARTER &"
grep -Fqx "$AUTOSTART_LINE" "$CUSTOM" || printf "\n%s\n" "$AUTOSTART_LINE" >> "$CUSTOM"

# Start Docker now
say "Starting Docker -> $STARTER"
"$STARTER" &

# Wait for the socket
say "Waiting for /var/run/docker.sock"
for i in $(seq 1 60); do
  [[ -S /var/run/docker.sock ]] && break
  sleep 1
done
[[ -S /var/run/docker.sock ]] || { echo "Docker not ready."; exit 1; }

# Portainer
say "Launching Portainer"
"$DOCKER_CMD" volume create portainer_data >/dev/null 2>&1 || true
if "$DOCKER_CMD" ps -a --format '{{.Names}}' | grep -q '^portainer$'; then
  "$DOCKER_CMD" rm -f portainer >/dev/null 2>&1 || true
fi

"$DOCKER_CMD" run \
  --device /dev/dri:/dev/dri \
  --privileged \
  --net host \
  --ipc host \
  -d \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /media:/media \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

say "Done. Open https://<batocera-ip>:9443"
