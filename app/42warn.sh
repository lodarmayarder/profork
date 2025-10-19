#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
# SPDX-FileCopyrightText: 2024 foclabroc
# SPDX-FileCopyrightText: 2025 profork
#
# Portions of this script are based on code by foclabroc, used under GPLv3.
# Profork README / Video Mode Notice for Batocera v42+

set -u

DIALOG_BIN="$(command -v dialog || true)"
README_URL="https://github.com/profork/profork"

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

# --- Only show if v42 or higher and dialog is available ---
if echo "${VERSION}" | grep -qE '^[0-9]+$' && [ "${VERSION}" -ge 42 ]; then
  if [ -n "${DIALOG_BIN}" ]; then
    dialog --msgbox "\
If using custom ES menus from Profork, Action required for v42+:

Go to System Settings → Video Mode and select a specific resolution (e.g. 1920x1080) rather than leaving it on \"auto\".

Then reboot and test your custom systems. See README for more context:
https://github.com/profork/profork" 14 80
    clear
  else
    echo -e "\nIf using custom ES menus from Profork, Action required for v42+:\n
Go to System Settings → Video Mode and select a specific resolution (e.g. 1920x1080) rather than leaving it on \"auto\".\n
Then reboot and test your custom systems. See README for more context:
https://github.com/profork/profork\n"
  fi
fi

exit 0
