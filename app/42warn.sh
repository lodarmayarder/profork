#!/bin/bash
# Profork README notice + special V42 video mode warning from profork/profork README

set -u

DIALOG_BIN="$(command -v dialog || true)"
README_URL="https://github.com/profork/profork"
CONF="/userdata/system/batocera.conf"

# --- UI helpers ---
infodelay() {
  local msg="$1"
  local seconds="$2"
  if [ -n "${DIALOG_BIN}" ]; then
    dialog --infobox "$msg" 12 80
    sleep "${seconds}"
    clear
  else
    echo -e "\n$msg\n"
    sleep "${seconds}"
  fi
}

say() {
  if [ -n "${DIALOG_BIN}" ]; then
    dialog --msgbox "$1" 14 80
    clear
  else
    echo -e "\n$1\n"
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

# Always display link to README
infodelay "See the Profork README for recent updates:\n$README_URL" 5

# If v42, display excerpt / warning about video mode
if echo "${VERSION}" | grep -qE '^[0-9]+$' && [ "${VERSION}" -eq 42 ]; then
  infodelay "README WARNING for V42:\n\n\"Due to python rewrites by Batocera devs, custom ES system launchers\nneed a video mode resolution manually set … blank values are no longer tolerated … set your resolution instead of using 'auto'\"\n\n(Excerpt from Profork README)" 10

  say "If using custom ES menus from Profork, Action required for v42:\n\nGo to System Settings → Video Mode and select a specific resolution (e.g. 1920x1080) rather than leaving it on \"auto\".\n\nThen reboot and test your custom systems. See README for more context:\n$README_URL"

else
  # non-42 or v43+ generic tip
  say "Tip:\n\nIf you ever run Batocera v42 with Profork and custom es launchers, you must set a fixed Video Mode (not \"auto\") in System Settings.\n\nFull instructions in the Profork README:\n$README_URL"
fi

exit 0
