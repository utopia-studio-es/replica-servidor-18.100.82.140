#!/bin/bash
# Despliegue completo de la réplica en la máquina actual (Ubuntu 24.04).
# Uso: sudo bash desplegar-en-este-servidor.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== 1/4 Paquetes (selección dpkg + dselect-upgrade) ==="
bash "$SCRIPT_DIR/instalar-paquetes-completos.sh"

echo "=== 2/4 SSH (equivalente al origen; OpenSSH: primer valor gana → 50 antes de 60) ==="
rm -f /etc/ssh/sshd_config.d/99-replica-18.100.82.140.conf 2>/dev/null || true
install -m 0644 /dev/stdin /etc/ssh/sshd_config.d/50-replica-18.100.82.140.conf <<'EOF'
# Réplica 18.100.82.140 — cargar antes de 60-cloudimg-settings.conf
PasswordAuthentication yes
KbdInteractiveAuthentication no
EOF
sshd -t && systemctl restart ssh

echo "=== 3/4 UFW inactivo (como el original) ==="
ufw --force disable 2>/dev/null || true

echo "=== 4/4 Netplan: DHCP ens5 con MAC local (ajustar si cambia NIC) ==="
MAC="$(ip -br link show ens5 2>/dev/null | awk '{print $3}' || true)"
if [ -n "$MAC" ]; then
  install -m 0600 /dev/stdin /etc/netplan/50-cloud-init.yaml <<EOF
network:
  version: 2
  ethernets:
    ens5:
      match:
        macaddress: "$MAC"
      dhcp4: true
      dhcp6: false
      set-name: "ens5"
EOF
  netplan generate
fi

echo "=== Listo. Reinicia si el kernel lo pide: uname -r ==="
