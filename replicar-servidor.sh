#!/bin/bash
# Script para replicar la configuración del servidor 18.100.82.140
# Ejecutar como root o con sudo en un servidor Ubuntu 24.04 fresco

set -e

echo "=== Réplica del servidor 18.100.82.140 ==="
echo "Configurando servidor Ubuntu 24.04..."

# Actualizar sistema
apt-get update && apt-get upgrade -y

# Instalar paquetes principales (los más relevantes del servidor original)
apt-get install -y \
    acpid adduser apparmor apt apt-utils base-files bash bash-completion \
    bc bind9-dnsutils bind9-host ca-certificates chrony cloud-init \
    curl cron dbus git gnupg gpg htop jq nano openssh-server openssh-client \
    python3 python3-apt rsync snapd sudo systemd ufw unattended-upgrades \
    vim wget

# SSH: fragmento 50-* antes de 60-cloudimg (primer valor gana en OpenSSH)
cat > /etc/ssh/sshd_config.d/50-replica-18.100.82.140.conf << 'SSHEOF'
PasswordAuthentication yes
KbdInteractiveAuthentication no
SSHEOF
chmod 0644 /etc/ssh/sshd_config.d/50-replica-18.100.82.140.conf
sshd -t && (systemctl restart sshd 2>/dev/null || systemctl restart ssh)

# Instalar Amazon SSM Agent (si es EC2)
if command -v snap &>/dev/null; then
    snap install amazon-ssm-agent --classic 2>/dev/null || true
fi

# Configuración de red (plantilla - ajustar según entorno)
# El servidor original usa DHCP vía cloud-init
cat > /etc/netplan/50-cloud-init.yaml << 'EOF'
network:
  version: 2
  ethernets:
    ens5:
      dhcp4: true
      dhcp6: false
EOF

# UFW (inactivo como en el original)
ufw status || ufw --force disable 2>/dev/null || true

echo ""
echo "=== Réplica completada ==="
echo "Revisa /etc/netplan/ si necesitas ajustar la configuración de red."
echo "El nombre del interfaz (ens5) puede variar - verifica con: ip link"
