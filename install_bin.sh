#!/bin/bash
#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
#!/bin/bash

set -e  # para que el script se detenga si algo falla

# Copiar tools a /
echo "[*] Copiando carpeta tools a / ..."
sudo cp -r "$HOME/tools" /

# Asegurar permisos correctos
echo "[*] Ajustando permisos..."
# Ejecutables en /tools/bin
sudo chmod -R 755 /tools/bin
# Solo lectura en /tools/windows y /tools/linux
sudo chmod -R 644 /tools/windows/* || true
sudo chmod -R 644 /tools/linux/* || true

# Agregar /tools/bin al PATH en .zshrc si no existe
if ! grep -q 'export PATH=.*\/tools\/bin' "$HOME/.zshrc"; then
    echo "[*] Agregando /tools/bin al PATH en .zshrc..."
    echo 'export PATH=$PATH:/tools/bin' >> "$HOME/.zshrc"
fi

# Limpiar carpeta temporal (si se usó TMP_DIR)
if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
    echo "[*] Limpiando archivos temporales..."
    rm -rf "$TMP_DIR"
fi

echo "[✔] Instalación completa."
echo "    Abre una nueva terminal o ejecuta: source ~/.zshrc"
