#!/bin/bash
# Instala todos los paquetes del servidor original
# Requiere: paquetes-instalados.txt en el mismo directorio
# Uso: sudo bash instalar-paquetes-completos.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAQUETES_FILE="$SCRIPT_DIR/paquetes-instalados.txt"

if [ ! -f "$PAQUETES_FILE" ]; then
    echo "Error: No se encuentra paquetes-instalados.txt"
    exit 1
fi

echo "Actualizando índices..."
apt-get update

echo "Instalando paquetes (esto puede tardar varios minutos)..."
dpkg --set-selections < "$PAQUETES_FILE"
apt-get dselect-upgrade -y

echo "Paquetes instalados correctamente."
