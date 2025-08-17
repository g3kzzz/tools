#!/bin/bash
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

sudo cp -r "$HOME/tools" /
# Agregar al PATH si no está ya en .zshrc
if ! grep -q 'export PATH=.*\/tools\/bin' "$HOME/.zshrc"; then
    echo "[*] Agregando /tools/bin al PATH en .zshrc..."
    echo 'export PATH=$PATH:/tools/bin' >> "$HOME/.zshrc"
fi

# Limpiar carpeta temporal
echo "[*] Limpiando archivos temporales..."
rm -rf "$TMP_DIR"

echo "[*] Instalación completa. Abre una nueva terminal o ejecuta 'source ~/.zshrc' para actualizar el PATH."
