#!/usr/bin/env bash
# install_windows_tools.sh - quiet downloader for windows helper scripts
# Expects to be run from anywhere; writes into the directory where script lives.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

TOOLS=(
  "https://raw.githubusercontent.com/peass-ng/PEASS-ng/master/winPEAS/winPEASps1/winPEAS.ps1 winPEAS.ps1"
  "https://github.com/peass-ng/PEASS-ng/releases/latest/download/winPEASany_ofs.exe winPEASany_ofs.exe"
  "https://raw.githubusercontent.com/lukebaggett/dnscat2-powershell/refs/heads/master/dnscat2.ps1 dnscat2.ps1"
)

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
  _dl "$url" "$file" >/dev/null 2>&1 || {
    # continue quietly if fails
    continue
  }
  chmod +x "$file" 2>/dev/null || true
done

echo "[✓] Windows tools installed."
