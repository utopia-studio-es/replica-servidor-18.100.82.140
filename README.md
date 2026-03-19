# Réplica del Servidor 18.100.82.140

Documentación y scripts para replicar el servidor remoto `ip-172-31-0-132` (18.100.82.140).

## Información del Servidor Original

| Característica | Valor |
|----------------|-------|
| **Hostname** | ip-172-31-0-132 |
| **IP Pública** | 18.100.82.140 |
| **IP Privada** | 172.31.0.132 |
| **Sistema** | Ubuntu 24.04.3 LTS (Noble Numbat) |
| **Kernel** | 6.14.0-1018-aws |
| **Arquitectura** | x86_64 |
| **Disco** | 48GB (1.8GB usados) |
| **RAM** | 3.7GB |
| **Tipo** | EC2 AWS (eu-south-2) |

## Contenido de esta Réplica

- `replicar-servidor.sh` - Script principal para configurar un nuevo servidor Ubuntu
- `paquetes-instalados.txt` - Lista de paquetes del servidor original
- `config/` - Archivos de configuración exportados
- `cloud-init/` - Configuración para despliegue automatizado

## Uso Rápido

```bash
# En un nuevo servidor Ubuntu 24.04 — réplica completa (paquetes + SSH + UFW + netplan por MAC):
sudo bash desplegar-en-este-servidor.sh
```

O solo paquetes mínimos + ajustes básicos:

```bash
sudo bash replicar-servidor.sh
```

## Credenciales Originales

- **Usuario:** ubuntu
- **Contraseña:** (configurar según necesidad en el nuevo servidor)

## Notas

- El servidor original usa DHCP para red (típico de EC2)
- UFW está inactivo
- Amazon SSM Agent instalado vía snap
- PasswordAuthentication habilitado en SSH
