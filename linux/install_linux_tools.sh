#!/usr/bin/env bash
# install_linux_tools.sh
# Installs linux enum tools into /tools/linux
# Compiles CLEAN chisel binaries into /tools/linux/chisel
# FAST_MODE=1 -> NO UPX (rápido, recomendado)
# FAST_MODE=0 -> UPX (más pequeño, más lento al ejecutar)

set -euo pipefail

####################################
# CONFIG
####################################
FAST_MODE=1
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
      sudo apt install -y -qq git golang gzip upx-ucl || true
      ;;
    pacman)
      sudo pacman -Sy --noconfirm git go gzip upx || true
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
# INSTALL ENUM TOOLS (ROOT)
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
# BUILD CHISEL (TEMP)
####################################
cd "$CHISEL_DIR"
rm -rf src out

git clone -q https://github.com/jpillora/chisel.git src
cd src
git fetch -q --tags
git checkout -q "$CHISEL_VERSION"

mkdir -p ../out

build() {
  GOOS=$1 GOARCH=$2 CGO_ENABLED=0 \
    go build -ldflags="-s -w" -o "$3"
}

# PRINCIPALES
build linux   amd64   ../out/chisel_linux_amd64_principal
build windows amd64   ../out/chisel_windows_amd64_principal.exe

# SECUNDARIOS
build linux   386     ../out/chisel_linux_386_secundario
build windows 386     ../out/chisel_windows_386_secundario.exe

####################################
# OPTIONAL UPX (LENTO AL EJECUTAR)
####################################
if [[ "$FAST_MODE" -eq 0 ]] && command -v upx >/dev/null 2>&1; then
  upx --best ../out/chisel_* >/dev/null 2>&1 || true
fi

####################################
# FINAL CLEANUP
####################################
cd "$CHISEL_DIR"
mv out/* .
rm -rf src out

chmod +x chisel_linux_* 2>/dev/null || true

echo "[✓] Enum tools installed in $TOOLS_DIR"
echo "[✓] Chisel ready in $CHISEL_DIR (FAST_MODE=$FAST_MODE)"
