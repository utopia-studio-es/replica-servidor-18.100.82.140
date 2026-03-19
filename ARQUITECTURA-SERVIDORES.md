# Aclaración: dos servidores distintos

## Por qué `18.100.82.140` devuelve `ERR_CONNECTION_REFUSED`

Esa IP corresponde al servidor **`ip-172-31-0-132`**, que era la **plantilla base** usada para la lista de paquetes:

- **No tiene Nginx** ni ningún proceso escuchando en **80/443**.
- Por tanto, el navegador recibe **conexión rechazada** al abrir `http://18.100.82.140` — es el comportamiento esperado.

Comprobación desde cualquier máquina: `curl -v http://18.100.82.140` → rechazo en el puerto 80.

## Dónde están “todos los servicios” (RAG, Nginx, HTTPS)

La instancia con **Nginx en 80/443**, **uvicorn en 8000** y los **systemd** `rag-xcailex` / workers es **otra** EC2:

| Rol | Hostname | IP privada (ejemplo) | IP pública (ejemplo) |
|-----|----------|----------------------|----------------------|
| Plantilla / origen paquetes | ip-172-31-0-132 | 172.31.0.132 | 18.100.82.140 |
| Stack web RAG + Nginx | ip-172-31-7-88 | 172.31.7.88 | **15.216.13.91** (puede cambiar si no hay Elastic IP) |

El virtual host de Nginx usa el nombre **`rag.utopialabs.es`**; el acceso por IP sola puede dar **404** o redirecciones si no coinciden `Host` y certificados.

### Qué usar en el navegador

1. **Dominio configurado:** `https://rag.utopialabs.es` (recomendado), con DNS apuntando a la instancia correcta.
2. **Solo IP pública del servidor con servicios:** `https://15.216.13.91` — puede fallar el certificado o el `server_name`; depura con cabecera `Host` si hace falta.

### Grupos de seguridad (AWS)

Para que responda desde Internet:

- Entrada **TCP 80** y **443** desde `0.0.0.0/0` (o tu IP) en el **security group** de la instancia que **sí** ejecuta Nginx (**15.216.13.91**), no solo la de la plantilla.

## Si necesitas que **18.100.82.140** sea un espejo real con la misma web

Hay que **desplegar allí** explícitamente (no basta con la lista de paquetes del origen):

- Instalar y configurar **Nginx** (copiar `sites-enabled` / certificados o volver a emitir con **Certbot**).
- Desplegar la aplicación (**RAG**), variables de entorno, bases de datos o volúmenes que use.
- Replicar **systemd** / **Docker** según el entorno actual.
- Opcional: **Elastic IP** o cambiar DNS para que el nombre apunte a la nueva instancia.

Eso es un ** proyecto de despliegue de aplicación**, distinto de la **réplica de paquetes base** del repo.
