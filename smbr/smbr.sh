#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# URLs
# -----------------------------
ZIP_URL="https://github.com/JHDev2006/Super-Mario-Bros.-Remastered-Public/releases/download/1.0.1/Linux.zip"
URL_COMPOSITOR="https://github.com/profork/profork/raw/master/steam/desktop/service/dir_ob/batocera-compositor"
URL_FULLXML="https://github.com/profork/profork/raw/master/steam/desktop/service/dir_ob/full.xml"
URL_WINXML="https://github.com/profork/profork/raw/master/steam/desktop/service/dir_ob/window.xml"
URL_WINDOWED_SVC="https://github.com/profork/profork/raw/master/steam/desktop/services/windowed"

# -----------------------------
# Paths
# -----------------------------
PORTS_DIR="/userdata/roms/ports"
APP_DIR="${PORTS_DIR}/smbr"
ZIP_PATH="${APP_DIR}/Linux.zip"
LAUNCH_SH="${PORTS_DIR}/SMBR.sh"

CFG_DIR="/userdata/system/.local/share/SMB1R"
CFG_FILE="${CFG_DIR}/settings.cfg"

SERV_HOME="${HOME:-/userdata}"
DIR_OB="${SERV_HOME}/service/dir_ob"
SERVICES_DIR="${SERV_HOME}/services"
WINDOWED_SVC="${SERVICES_DIR}/windowed"

# -----------------------------
# Helpers
# -----------------------------
crlf_fix() {
  # Use dos2unix if available, otherwise strip CRs with sed
  local f="$1"
  if command -v dos2unix >/dev/null 2>&1; then
    dos2unix "$f" >/dev/null 2>&1 || true
  else
    sed -i 's/\r$//' "$f" || true
  fi
}

msg() { echo -e "\n== $* ==\n"; }

# -----------------------------
# SMB REMASTERED INSTALL
# -----------------------------
mkdir -p "${APP_DIR}" "${CFG_DIR}"

msg "Downloading SMB Remastered"
curl -L --fail --retry 3 -o "${ZIP_PATH}.part" "${ZIP_URL}"
mv -f "${ZIP_PATH}.part" "${ZIP_PATH}"

msg "Extracting"
unzip -o "${ZIP_PATH}" -d "${APP_DIR}" >/dev/null

# Find executable and normalize to SMB1R.x86_64
found_exec="$(ls "${APP_DIR}"/*x86_64 2>/dev/null | head -n1 || true)"
if [[ -z "${found_exec}" ]]; then
  echo "ERROR: Could not find the SMB Remastered executable (*x86_64) in ${APP_DIR}"
  exit 1
fi
if [[ "${found_exec}" != "${APP_DIR}/SMB1R.x86_64" ]]; then
  mv -f "${found_exec}" "${APP_DIR}/SMB1R.x86_64"
fi
chmod +x "${APP_DIR}/SMB1R.x86_64"

# Recommended config
cat > "${CFG_FILE}" <<'EOF'
[video]
mode=2
size=1
vsync=1
drop_shadows=1
scaling=1
visuals=1
hud_size=0
EOF

# Launcher directly in /userdata/roms/ports
cat > "${LAUNCH_SH}" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
export DISPLAY=:0.0

# Show mouse in F1 to make drag/drop easier
if command -v batocera-mouse >/dev/null 2>&1; then
  batocera-mouse show || true
fi

DIR="/userdata/roms/ports/smbr"
cd "${DIR}"
chmod +x "./SMB1R.x86_64"

# First run: the game opens a window; drag your SMB (NES) ROM into it to verify.
exec ./SMB1R.x86_64
EOF
chmod +x "${LAUNCH_SH}"

# -----------------------------
# MINIMAL WINDOWED MODE SERVICE
# -----------------------------
mkdir -p "${DIR_OB}" "${SERVICES_DIR}"

msg "Installing minimal Windowed Mode service files"
# Core compositor + profiles
wget -q -O "${DIR_OB}/batocera-compositor" "${URL_COMPOSITOR}"
wget -q -O "${DIR_OB}/full.xml"             "${URL_FULLXML}"
wget -q -O "${DIR_OB}/window.xml"           "${URL_WINXML}"
chmod +x "${DIR_OB}/batocera-compositor"
crlf_fix "${DIR_OB}/full.xml"
crlf_fix "${DIR_OB}/window.xml"

# Service toggle script
curl -Ls -o "${WINDOWED_SVC}" "${URL_WINDOWED_SVC}"
chmod +x "${WINDOWED_SVC}"
crlf_fix "${WINDOWED_SVC}"

# -----------------------------
# DONE + INSTRUCTIONS
# -----------------------------
cat <<'MSG'

✅ Super Mario Bros. Remastered installed.

Folders / files:
• Game folder:   /userdata/roms/ports/smbr
• Executable:     /userdata/roms/ports/smbr/SMB1R.x86_64
• Config:         /userdata/system/.local/share/SMB1R/settings.cfg
• Launcher:       /userdata/roms/ports/SMBR.sh
• Windowed svc:   ~/services/windowed  (toggle via EmulationStation Services)


NEXT STEPS (for first-time verification via drag-drop):

1) In EmulationStation: Main Menu → System Settings → Services → set **windowed = ON**,
   then press **Back** to save.
2) Reboot Batocera.
3) Press **F1** to open the file manager (PCManFM).
4) Launch the game from Ports → **SMBR**, then **drag your Super Mario Bros. (NES) ROM**
   into the SMBR game window to verify.
5) After it’s verified, go back to Services, set **windowed = OFF**, and reboot.

ℹ️ Tip: You can also keep your ROM inside /userdata/roms/ports/smbr for convenience.

👉 IMPORTANT: In EmulationStation, **Refresh Gamelist** so the "SMBR" port and (WINDOWED MODE* service appears.

Enjoy!
MSG
echo "this message will close in 30 seconds"
sleeo 30
