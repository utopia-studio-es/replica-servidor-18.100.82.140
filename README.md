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

- `desplegar-en-este-servidor.sh` — Despliegue completo en la máquina actual (apt + SSH + UFW + netplan)
- `instalar-paquetes-completos.sh` — Solo alinear paquetes con `paquetes-instalados.txt`
- `verificar-replica.sh` — Comprueba paquetes, SSH, UFW y UTC en local (sin contraseñas)
- `replicar-servidor.sh` — Paquetes mínimos + ajustes básicos (plantilla ligera)
- `paquetes-instalados.txt` - Lista de paquetes del servidor original
- `config/` - Archivos de configuración exportados

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

## Continuación del despliegue

Después de `desplegar-en-este-servidor.sh`:

```bash
bash verificar-replica.sh
```

- **Kernel:** si `apt` avisa de un kernel nuevo, reinicia cuando puedas: `sudo reboot` (tras el reinicio el kernel puede diferir del `6.14.0-1018-aws` del snapshot; es normal).
- **Snaps:** en el destino suelen estar **más actualizados** que en el origen (SSM Agent, core22, snapd). No es necesario degradarlos salvo política interna.
- **Paridad exacta vs. aplicaciones:** un servidor que ya tenía **Docker, Nginx, Certbot o servicios propios** (p. ej. `rag-xcailex`) tendrá **más paquetes y unidades systemd** que el origen “solo plantilla”. Eso es esperado; la lista `paquetes-instalados.txt` garantiza que **nada de la base del origen falte**.

## Notas

- El servidor original usa DHCP para red (típico de EC2)
- UFW está inactivo
- Amazon SSM Agent instalado vía snap
- PasswordAuthentication habilitado en SSH (`/etc/ssh/sshd_config.d/50-replica-18.100.82.140.conf` **antes** de `60-cloudimg-settings.conf`, porque OpenSSH aplica el **primer** valor definido)
