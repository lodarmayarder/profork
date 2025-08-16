#!/bin/bash
set -o pipefail

# ===== Settings =====
REPO_URL="https://api.github.com/repos/Kron4ek/Wine-Builds/releases?per_page=300"
INSTALL_DIR="/userdata/system/wine/custom/"
mkdir -p "$INSTALL_DIR"

# ===== Prereqs =====
for cmd in jq dialog wget curl tar xz; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: '$cmd' is required but not installed."
    exit 1
  fi
done

# ===== Fetch releases =====
echo "Fetching release information..."
release_data="$(curl -fsSL "$REPO_URL")" || { echo "Failed to fetch release data."; exit 1; }

# ===== Build filtered list without regex (jq compiled w/o Oniguruma) =====
# Keep ONLY assets whose name contains 'staging-tkg' AND endswith amd64/x86_64 tar.xz
matches="$(echo "$release_data" | jq -c '
  [.[] as $r
   | $r.assets[]?
   | select(.name | contains("staging-tkg"))
   | select((.name | endswith("amd64.tar.xz")) or (.name | endswith("x86_64.tar.xz")))
   | {tag: $r.tag_name, name: .name, url: .browser_download_url}
  ]')"

count="$(echo "$matches" | jq 'length')"
if [[ "$count" -eq 0 ]]; then
  echo "No staging-tkg amd64/x86_64 tarballs found."
  exit 0
fi

# ===== Build dialog options from filtered list =====
cmd=(dialog --separate-output --checklist "Select Wine staging-tkg builds to download:" 22 90 16)
options=()
for ((i=0; i<count; i++)); do
  name="$(echo "$matches" | jq -r ".[$i].name")"
  tag="$(echo "$matches"  | jq -r ".[$i].tag")"
  idx=$((i+1))  # dialog uses 1-based indices
  options+=("$idx" "$name  (tag: $tag)" off)
done

choices="$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)"
clear

if [[ -z "$choices" ]]; then
  echo "No selections made."
  exit 0
fi

# ===== Process selections (using SAME filtered list) =====
for choice in $choices; do
  i=$((choice-1))

  url="$(echo "$matches"  | jq -r ".[$i].url // empty")"
  fname="$(echo "$matches" | jq -r ".[$i].name // empty")"

  if [[ -z "$url" || -z "$fname" ]]; then
    echo "Skipping selection #$choice: missing asset URL or name."
    continue
  fi

  outdir="${INSTALL_DIR}${fname%.tar.xz}"
  mkdir -p "$outdir" || { echo "mkdir failed: $outdir"; continue; }
  cd "$outdir" || { echo "cd failed: $outdir"; continue; }

  echo "Downloading $fname from"
  echo "  $url"
  if ! wget -nv --tries=10 --no-check-certificate --no-cache --no-cookies -O "$fname" "$url"; then
    echo "Download failed: $fname"
    cd - >/dev/null
    continue
  fi

  if [[ ! -s "$fname" ]]; then
    echo "Downloaded file is empty: $fname"
    rm -f "$fname"
    cd - >/dev/null
    continue
  fi

  echo "Unpacking $fname..."
  if ! tar --strip-components=1 -xf "$fname"; then
    echo "Extraction failed: $fname"
    # keep the archive for debugging
    cd - >/dev/null
    continue
  fi

  rm -f "$fname"
  echo "Installation of $(basename "$outdir") complete."
  cd - >/dev/null
done

echo "All selected versions have been processed."
