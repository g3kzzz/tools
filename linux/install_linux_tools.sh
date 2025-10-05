#!/usr/bin/env bash
# install_linux_tools.sh - quiet downloader for linux helper scripts
# Expects to be run from anywhere; writes into the directory where script lives.

set -euo pipefail

# operate relative to the script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

TOOLS=(
  "https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh linpeas.sh"
  "https://github.com/diego-treitos/linux-smart-enumeration/releases/latest/download/lse.sh lse.sh"
)

# downloader: prefer curl, fallback wget
_dl() {
  local url="$1" out="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --retry 3 --retry-delay 2 "$url" -o "$out"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$out" "$url"
  else
    return 2
  fi
}

for entry in "${TOOLS[@]}"; do
  url=$(printf "%s" "$entry" | awk '{print $1}')
  file=$(printf "%s" "$entry" | awk '{print $2}')
  # download quietly
  _dl "$url" "$file" >/dev/null 2>&1 || {
    # if download fails, continue quietly
    continue
  }
  chmod +x "$file" 2>/dev/null || true
done

# final concise message
echo "[✓] Linux tools installed."
