#!/bin/bash

# Instalador de FinalRecon en Arch Linux

# Variables
TMP_DIR=$(mktemp -d)
INSTALL_DIR="/tools/bin/aca"
REPO="https://github.com/thewhiteh4t/FinalRecon.git"

# Crear directorio de destino si no existe
sudo mkdir -p "$INSTALL_DIR"

echo "[*] Clonando FinalRecon en carpeta temporal..."
git clone "$REPO" "$TMP_DIR"

echo "[*] Instalando dependencias..."
pip3 install --user -r "$TMP_DIR/requirements.txt"

echo "[*] Moviendo finalrecon.py a $INSTALL_DIR..."
sudo mv "$TMP_DIR/finalrecon.py" "$INSTALL_DIR/"

echo "[*] Haciendo el script ejecutable..."
sudo chmod +x "$INSTALL_DIR/finalrecon.py"

# Agregar al PATH si no está ya en .zshrc
if ! grep -q 'export PATH=.*\/tools\/bin' "$HOME/.zshrc"; then
    echo "[*] Agregando /tools/bin al PATH en .zshrc..."
    echo 'export PATH=$PATH:/tools/bin' >> "$HOME/.zshrc"
fi

# Limpiar carpeta temporal
echo "[*] Limpiando archivos temporales..."
rm -rf "$TMP_DIR"

echo "[*] Instalación completa. Abre una nueva terminal o ejecuta 'source ~/.zshrc' para actualizar el PATH."
