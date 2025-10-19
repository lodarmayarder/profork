#!/bin/bash
# Batocera legacy_custom_sh compatibility installer
# - v43+: custom.sh is removed -> ensure a service runs /userdata/system/custom.sh
# - <=v42: install service if missing (disabled) so it’s ready for an upgrade
# SPDX-License-Identifier: GPL-3.0-only
# SPDX-FileCopyrightText: 2024 foclabroc
# SPDX-FileCopyrightText: 2025 profork
#
# Portions of this script are based on code by foclabroc, used under GPLv3.

set -u

CONF="/userdata/system/batocera.conf"
SERV_DIR="/userdata/system/services"
LOG_DIR="/userdata/system/logs"
SERV_NAME="legacy_custom_sh"
SERV_PATH="${SERV_DIR}/${SERV_NAME}"
DIALOG_BIN="$(command -v dialog || true)"

# --- UI helpers with timed display ---
infodelay() {
  local msg="$1"
  local seconds="$2"
  if [ -n "${DIALOG_BIN}" ]; then
    dialog --infobox "$msg" 10 72
    sleep "${seconds}"
    clear
  else
    echo -e "$msg"
    sleep "${seconds}"
  fi
}

say() {
  if [ -n "${DIALOG_BIN}" ]; then
    dialog --msgbox "$1" 10 72
    clear
  else
    echo -e "$1"
  fi
}

# --- Detect Batocera major version ---
detect_version() {
  local ver=""
  if command -v batocera-es-swissknife >/dev/null 2>&1; then
    ver="$(batocera-es-swissknife --version 2>/dev/null | grep -oE '^[0-9]+')" || true
  fi
  if [ -z "${ver}" ] && [ -f /etc/batocera-release ]; then
    ver="$(grep -oE '([0-9]+)' /etc/batocera-release | head -n1)" || true
  fi
  echo "${ver}"
}

VERSION="$(detect_version)"
if ! echo "${VERSION}" | grep -qE '^[0-9]+$'; then
  say "Unable to detect a valid Batocera version. Installation aborted."
  exit 1
fi

# --- Ensure dirs ---
mkdir -p "${SERV_DIR}" "${LOG_DIR}"

# --- Create service file only if missing ---
create_service_if_missing() {
  if [ ! -f "${SERV_PATH}" ]; then
    cat > "${SERV_PATH}" << 'EOF'
#!/bin/bash
# Batocera service: legacy_custom_sh
# Purpose: Run /userdata/system/custom.sh on boot (compatibility for v43+)
LOG="/userdata/system/logs/legacy_custom_sh.log"
CUSTOM="/userdata/system/custom.sh"

case "$1" in
  start)
    if [ -x "${CUSTOM}" ]; then
      echo "[legacy_custom_sh] Starting custom.sh at $(date)" >> "${LOG}" 2>&1
      "${CUSTOM}" >> "${LOG}" 2>&1 &
    elif [ -f "${CUSTOM}" ]; then
      echo "[legacy_custom_sh] custom.sh exists but is not executable; running with /bin/bash at $(date)" >> "${LOG}" 2>&1
      /bin/bash "${CUSTOM}" >> "${LOG}" 2>&1 &
    else
      echo "[legacy_custom_sh] No custom.sh found at ${CUSTOM} (start skipped) $(date)" >> "${LOG}" 2>&1
    fi
    ;;
  stop)
    # intentionally no-op (Batocera service framework may not need explicit kill here)
    ;;
  restart)
    "$0" stop
    "$0" start
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
    exit 2
    ;;
esac
EOF
    chmod +x "${SERV_PATH}"
  fi
}

# --- Write/update key in batocera.conf ---
ensure_conf_key() {
  local key="$1" val="$2"
  if [ ! -f "${CONF}" ]; then
    mkdir -p "$(dirname "${CONF}")"
    touch "${CONF}"
  fi
  if grep -q "^${key}=" "${CONF}" 2>/dev/null; then
    sed -i "s|^${key}=.*|${key}=${val}|" "${CONF}"
  else
    echo "${key}=${val}" >> "${CONF}"
  fi
}

# --- Read a key from batocera.conf (echo empty if missing) ---
read_conf_key() {
  local key="$1"
  grep -E "^${key}=" "${CONF}" 2>/dev/null | head -n1 | cut -d'=' -f2- || true
}

echo "[legacy_custom_sh] Detected Batocera version: ${VERSION}"

# --- Main logic ---
if [ "${VERSION}" -ge 43 ]; then
  # v43+ — custom.sh is no longer auto-run

  if [ -f "${SERV_PATH}" ]; then
    # Service already present: DO NOT modify; just remind user of current state
    current="$(read_conf_key "system.${SERV_NAME}.enabled")"
    if [ "${current}" = "1" ]; then
      infodelay "Batocera v43 detected.\n\nThe 'legacy_custom_sh' service is already INSTALLED and ENABLED.\n\nReminder: Keep it enabled so Profork and other scripts continue to work.\n\nCheck in System Settings → Services." 20
    else
      infodelay "Batocera v43 detected.\n\nThe 'legacy_custom_sh' service is INSTALLED but currently DISABLED.\n\nReminder: Enable it in System Settings → Services to keep Profork and other scripts working." 20
    fi
  else
    # Service missing: install and enable it
    create_service_if_missing
    ensure_conf_key "system.${SERV_NAME}.enabled" "1"
    infodelay "Batocera v43 detected.\n\nStarting with v43, Batocera no longer runs /userdata/system/custom.sh automatically.\n\nThe 'legacy_custom_sh' service has now been INSTALLED and ENABLED so that Profork and other scripts continue to work.\n\nPlease verify in System Settings → Services that 'legacy_custom_sh' is enabled." 20
  fi

else
  # <= v42 — legacy still runs custom.sh; avoid double-run
  if [ -f "${SERV_PATH}" ]; then
    ensure_conf_key "system.${SERV_NAME}.enabled" "0"
    infodelay "Batocera v${VERSION} detected.\n\nThe 'legacy_custom_sh' service is already present and DISABLED (to avoid running custom.sh twice).\n\nIt is READY for v43—when you upgrade, just enable it." 8
  else
    create_service_if_missing
    ensure_conf_key "system.${SERV_NAME}.enabled" "0"
    infodelay "Batocera v${VERSION} detected.\n\nThe 'legacy_custom_sh' service has been INSTALLED and DISABLED (Batocera already runs custom.sh natively).\n\nIt is now READY for v43—after upgrading, enable it to keep Profork working." 8
  fi
fi

echo "[legacy_custom_sh] Done."
