#!/bin/bash
set -e

# =============================================
#        DOTFILES INSTALLER (KALI / XFCE)
#        Author: g3narin
# =============================================

# ---------- NO ROOT ----------
if [[ $EUID -eq 0 ]]; then
  echo "[!] No ejecutes este script como root"
  exit 1
fi

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[+] Iniciando instalación desde: $BASE_DIR"

# =============================================
# 1. LIMPIEZA DE HOME
# =============================================
echo "[+] Limpiando HOME (manteniendo carpetas clave)..."

KEEP_DIRS=("Desktop" "Downloads" "Pictures" "ctf")

for dir in "$HOME"/* "$HOME"/.*; do
  name="$(basename "$dir")"

  # saltar . y ..
  [[ "$name" == "." || "$name" == ".." ]] && continue

  # saltar carpetas a mantener
  if [[ " ${KEEP_DIRS[*]} " =~ " $name " ]]; then
    continue
  fi

  # NO borrar .config (se sobreescribe luego)
  [[ "$name" == ".config" ]] && continue

  # borrar resto
  rm -rf "$dir"
done

# crear carpetas si no existen
for d in "${KEEP_DIRS[@]}"; do
  mkdir -p "$HOME/$d"
done

# =============================================
# 2. COPIAR HOME DOTFILES
# =============================================
echo "[+] Copiando contenido de home/ → \$HOME"

cp -a "$BASE_DIR/home/." "$HOME/"

# =============================================
# 3. COPIAR CONFIG
# =============================================
echo "[+] Copiando config/ → ~/.config"

mkdir -p "$HOME/.config"
cp -a "$BASE_DIR/config/." "$HOME/.config/"

# =============================================
# 4. LIGHTDM (REQUIERE SUDO)
# =============================================
if [[ -d "$BASE_DIR/lightdm" ]]; then
  echo "[+] Instalando configuración de LightDM..."
  sudo mkdir -p /etc/lightdm
  sudo cp -a "$BASE_DIR/lightdm/." /etc/lightdm/
fi

# =============================================
# 5. PAQUETES BASE
# =============================================
echo "[+] Actualizando sistema..."
sudo apt update -y

echo "[+] Instalando paquetes..."
sudo apt install -y \
  zsh \
  git \
  curl \
  wget \
  neovim \
  kitty \
  bat \
  eza \
  coreutils

# =============================================
# 6. ZSH + OH-MY-ZSH
# =============================================
if [[ "$SHELL" != *zsh ]]; then
  echo "[+] Cambiando shell por defecto a zsh..."
  chsh -s "$(which zsh)"
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "[+] Instalando Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "[+] Instalando plugins ZSH..."

git clone https://github.com/zsh-users/zsh-autosuggestions \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null || true

git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null || true

# asegurar plugins en .zshrc
if ! grep -q "zsh-autosuggestions" "$HOME/.zshrc"; then
  sed -i 's/^plugins=(/plugins=(zsh-autosuggestions zsh-syntax-highlighting /' "$HOME/.zshrc"
fi

# =============================================
# 7. PERMISOS
# =============================================
chmod -R u+rwX "$HOME"

# =============================================
# DONE
# =============================================
echo
echo "=============================================="
echo " ✅ Instalación completada correctamente"
echo " 👉 Reinicia sesión o ejecuta: exec zsh"
echo "=============================================="
