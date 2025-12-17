#!/usr/bin/env bash
# install_linux_tools.sh
# Installs linux enum tools into /tools/linux
# Compiles chisel into /tools/linux/chisel

set -euo pipefail

####################################
# PATHS
####################################
TOOLS_DIR="/tools/linux"
CHISEL_DIR="/tools/linux/chisel"
CHISEL_VERSION="v1.11.3"

####################################
# DETECT DISTRO
####################################
_detect_distro() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    case "$ID" in
      kali|debian|ubuntu) echo "apt" ;;
      arch) echo "pacman" ;;
      *) echo "unknown" ;;
    esac
  else
    echo "unknown"
  fi
}

####################################
# INSTALL DEPS
####################################
_install_deps() {
  case "$1" in
    apt)
      sudo apt update -qq
      sudo apt install -y -qq git golang upx-ucl || true
      ;;
    pacman)
      sudo pacman -Sy --noconfirm git go upx || true
      ;;
    *)
      echo "[!] Unknown distro – install git & go manually"
      ;;
  esac
}

####################################
# DOWNLOADER
####################################
_dl() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$1" -o "$2"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$2" "$1"
  else
    return 1
  fi
}

####################################
# PREPARE DIRS
####################################
sudo mkdir -p "$TOOLS_DIR" "$CHISEL_DIR"
sudo chown -R "$USER":"$USER" "$TOOLS_DIR"

####################################
# INSTALL DEPS
####################################
PM="$(_detect_distro)"
_install_deps "$PM"

####################################
# INSTALL ENUM TOOLS (ROOT FOLDER)
####################################
cd "$TOOLS_DIR"

ENUM_TOOLS=(
  "https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh linpeas.sh"
  "https://github.com/diego-treitos/linux-smart-enumeration/releases/latest/download/lse.sh lse.sh"
)

for entry in "${ENUM_TOOLS[@]}"; do
  url=$(awk '{print $1}' <<< "$entry")
  file=$(awk '{print $2}' <<< "$entry")

  _dl "$url" "$file" >/dev/null 2>&1 || continue
  chmod +x "$file" 2>/dev/null || true
done

####################################
# BUILD CHISEL (SUBFOLDER)
####################################
cd "$CHISEL_DIR"

if [[ ! -d src ]]; then
  git clone -q https://github.com/jpillora/chisel.git src
fi

cd src
git fetch -q --tags
git checkout -q "$CHISEL_VERSION"

mkdir -p ../builds

targets=(
  "linux amd64"
  "linux 386"
  "windows amd64"
  "windows 386"
)

for t in "${targets[@]}"; do
  os=${t%% *}
  arch=${t##* }

  echo "[+] Compiling chisel $os/$arch"

  GOOS=$os GOARCH=$arch CGO_ENABLED=0 \
    go build -ldflags="-s -w" \
    -o "../builds/chisel_${os}_${arch}$( [[ $os == windows ]] && echo .exe )"
done

####################################
# OPTIONAL UPX
####################################
if command -v upx >/dev/null 2>&1; then
  upx --best ../builds/chisel_* >/dev/null 2>&1 || true
fi

####################################
# CLEANUP
####################################
cd "$CHISEL_DIR"
mv builds/* .
rm -rf src builds

echo "[✓] Enum tools installed in $TOOLS_DIR"
echo "[✓] Chisel compiled in $CHISEL_DIR"
