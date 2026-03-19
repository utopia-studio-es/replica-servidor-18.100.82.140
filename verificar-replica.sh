#!/bin/bash
# Comprueba en la máquina local que la réplica respecto a paquetes/SSH/UFW está alineada.
# Uso: bash verificar-replica.sh
# Código de salida: 0 si todo OK, 1 si hay fallos.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAQUETES="$SCRIPT_DIR/paquetes-instalados.txt"
FAIL=0

ok() { echo "[OK] $*"; }
bad() { echo "[FALLO] $*"; FAIL=1; }

if [[ ! -f "$PAQUETES" ]]; then
  bad "No existe $PAQUETES"
  exit 1
fi

echo "=== Paquetes de la lista origen ==="
MISSING=$(comm -23 \
  <(awk '{print $1}' "$PAQUETES" | sort -u) \
  <(dpkg --get-selections | awk '/install$/ {print $1}' | sort -u) || true)
if [[ -n "$MISSING" ]]; then
  bad "Faltan paquetes de la lista origen:"
  echo "$MISSING"
else
  ok "Todos los paquetes de paquetes-instalados.txt están instalados ($(wc -l < "$PAQUETES") líneas en lista)"
fi

echo "=== SSH PasswordAuthentication (sudo sshd -T) ==="
# sshd -T puede recibir SIGPIPE; con pipefail el pipeline fallaría aunque grep acierte.
set +o pipefail
if sudo sshd -T 2>/dev/null | grep -q '^passwordauthentication yes$'; then
  SSH_AUTH_OK=1
else
  SSH_AUTH_OK=0
fi
set -o pipefail
if [[ "$SSH_AUTH_OK" -eq 1 ]]; then
  ok "passwordauthentication yes"
else
  bad "passwordauthentication no (revisa /etc/ssh/sshd_config.d/50-replica-18.100.82.140.conf antes de 60-cloudimg)"
fi

echo "=== Fragmento SSH réplica ==="
if [[ -f /etc/ssh/sshd_config.d/50-replica-18.100.82.140.conf ]]; then
  ok "Existe 50-replica-18.100.82.140.conf"
else
  bad "Falta /etc/ssh/sshd_config.d/50-replica-18.100.82.140.conf"
fi

echo "=== UFW ==="
if sudo ufw status 2>/dev/null | grep -qi '^Status: inactive'; then
  ok "UFW inactivo (como origen)"
else
  bad "UFW no está inactive — revisa: sudo ufw status"
fi

echo "=== Zona horaria ==="
if timedatectl | grep -q 'Time zone: Etc/UTC'; then
  ok "Zona horaria UTC"
else
  bad "Zona horaria distinta de Etc/UTC — revisa timedatectl"
fi

echo "=== Kernel en ejecución ==="
echo "     $(uname -r) (origen usaba 6.14.0-1018-aws al capturar la réplica)"

echo ""
echo "=== Aviso: servicios SOLO en este host (no en plantilla mínima origen) ==="
# Opcional: lista servicios enabled extra (docker, nginx, etc.) — informativo
for u in docker.service nginx.service rag-xcailex.service rag-ingest-worker.service; do
  if systemctl is-enabled "$u" &>/dev/null; then
    echo "     - $u está habilitado (esperado si tienes apps en este servidor)"
  fi
done

if [[ $FAIL -ne 0 ]]; then
  echo ""
  echo "Hay incidencias. Revisa arriba o ejecuta: sudo bash $SCRIPT_DIR/desplegar-en-este-servidor.sh"
  exit 1
fi
echo ""
echo "Verificación local completada sin fallos críticos."
exit 0
