#!/bin/bash
cd /g3tools/linux/
# Lista de herramientas (URL ARCHIVO)
tools=(
  "https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh linpeas.sh"
  "https://github.com/diego-treitos/linux-smart-enumeration/releases/latest/download/lse.sh lse.sh"
)

# Descargar cada herramienta
for tool in "${tools[@]}"; do
  url=$(echo "$tool" | awk '{print $1}')
  file=$(echo "$tool" | awk '{print $2}')

  echo "[*] Descargando $file..."
  if command -v curl >/dev/null 2>&1; then
    curl -sL "$url" -o "$file"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$file" "$url"
  else
    echo "[!] No tienes ni curl ni wget instalados."
    exit 1
  fi

  chmod +x "$file"
  echo "[+] $file listo."
done

echo "[✓] Todas las herramientas descargadas."

