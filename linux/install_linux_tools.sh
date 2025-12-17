#!/usr/bin/env bash
# install_linux_tools.sh - quiet downloader + chisel builder
# Creates /tools/linux/chisel if not exists and compiles chisel for multiple platforms

set -euo pipefail

####################################
# GLOBALS
####################################
CHISEL_DIR="/tools/linux/chisel"
CHISEL_VERSION="v1.11.3"

####################################
# DETECT DISTRO
####################################
_detect_distro() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    case "$ID" in
      kali|debian|ubuntu)
        echo "apt"
        ;;
      arch)
        echo "pacman"
        ;;
      *)
        echo "unknown"
        ;;
    esac
  else
    echo "unknown"
  fi
}

####################################
# INSTALL PACKAGES
####################################
_install_deps() {
  local pm="$1"

  case "$pm" in
    apt)
      sudo apt update -qq
      sudo apt install -y -qq git golang upx-ucl || true
      ;;
    pacman)
      sudo pacman -Sy --noconfirm git go upx || true
      ;;
    *)
      echo "[!] Unsupported distro. Install git & go manually."
      ;;
  esac
}

####################################
# DOWNLOAD HELPER
####################################
_dl() {
  local url="$1" out="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --retry 3 "$url" -o "$out"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$out" "$url"
  else
    return 1
  fi
}

####################################
# PREPARE DIRECTORIES
####################################
sudo mkdir -p "$CHISEL_DIR"
sudo chown -R "$USER":"$USER" "$CHISEL_DIR"
cd "$CHISEL_DIR"

####################################
# INSTALL DEPENDENCIES
####################################
PM="$(_detect_distro)"
_install_deps "$PM"

####################################
# INSTALL ENUM TOOLS (linpeas / lse)
####################################
TOOLS=(
  "https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh linpeas.sh"
  "https://github.com/diego-treitos/linux-smart-enumeration/releases/latest/download/lse.sh lse.sh"
)

for entry in "${TOOLS[@]}"; do
  url=$(awk '{print $1}' <<< "$entry")
  file=$(awk '{print $2}' <<< "$entry")

  _dl "$url" "$file" >/dev/null 2>&1 || continue
  chmod +x "$file" 2>/dev/null || true
done

####################################
# BUILD CHISEL
####################################
if [[ ! -d chisel-src ]]; then
  git clone -q https://github.com/jpillora/chisel.git chisel-src
fi

cd chisel-src
git fetch -q --tags
git checkout -q "$CHISEL_VERSION"

mkdir -p ../builds

targets=(
  "linux amd64"
  "linux 386"
  "windows amd64"
  "windows 386"
)

for target in "${targets[@]}"; do
  os=$(cut -d' ' -f1 <<< "$target")
  arch=$(cut -d' ' -f2 <<< "$target")

  echo "[+] Compiling chisel $os/$arch"

  GOOS=$os GOARCH=$arch CGO_ENABLED=0 \
    go build -ldflags="-s -w" \
    -o "../builds/chisel_${os}_${arch}$( [[ $os == windows ]] && echo .exe )"
done

####################################
# OPTIONAL: UPX COMPRESS
####################################
if command -v upx >/dev/null 2>&1; then
  upx --best ../builds/chisel_* >/dev/null 2>&1 || true
fi

####################################
# FINALIZE
####################################
cd "$CHISEL_DIR"
mv chisel-src/builds/* .
rm -rf chisel-src

echo "[✓] Chisel compiled and installed in $CHISEL_DIR"
echo "[✓] Linux helper tools installed."
