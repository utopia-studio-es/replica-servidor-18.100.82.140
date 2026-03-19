# Migración de archivos y BBDD al espejo (18.100.82.140)

## Qué se copió (marzo 2026)

- **Código:** `/home/ubuntu/rag-xcailex/` (sin `.venv`; el venv se regeneró con `pip install -r requirements.txt`).
- **Archivos subidos:** `uploads/`, `static/`, `searxng/`, `.env` (secretos incluidos: rotar si procede).
- **PostgreSQL:** volcado custom `pg_dump -Fc` → restaurado con `pg_restore --clean --if-exists`.
- **Qdrant:** volumen Docker `rag-xcailex_qdrantdata` empaquetado en `tar` y restaurado.
- **Redis:** volumen `rag-xcailex_redisdata` empaquetado y restaurado.
- **Servicios:** mismos contenedores `docker compose`, `rag-xcailex.service`, `rag-ingest-worker.service`.
- **Nginx:** sitio HTTP en puerto **80** (`default_server`) que hace proxy a `127.0.0.1:8000` (acceso por IP sin certificado).

## Repetir la migración (origen → destino)

En el servidor **origen** (stack en ejecución):

```bash
MIG=/tmp/xcailex-migrate-$(date +%Y%m%d)
mkdir -p "$MIG"
sudo docker exec xcailex_postgres pg_dump -U xcailex_user -Fc rag_xcailex -f /tmp/rag_xcailex.dump
sudo docker cp xcailex_postgres:/tmp/rag_xcailex.dump "$MIG/rag_xcailex.dump"
sudo docker exec xcailex_redis redis-cli SAVE && sleep 2
sudo docker run --rm -v rag-xcailex_qdrantdata:/data:ro -v "$MIG":/backup alpine tar cf /backup/qdrantdata.tar -C /data .
sudo docker run --rm -v rag-xcailex_redisdata:/data:ro -v "$MIG":/backup alpine tar cf /backup/redisdata.tar -C /data .
sudo chown -R "$USER:$USER" "$MIG"

rsync -avz -e ssh "$MIG/" ubuntu@DESTINO:/home/ubuntu/xcailex-migrate/
rsync -avz -e ssh --exclude '.venv' --exclude '__pycache__' \
  /home/ubuntu/rag-xcailex/ ubuntu@DESTINO:/home/ubuntu/rag-xcailex/
```

En el **destino** (tras instalar Docker + nginx + venv y restaurar volúmenes como en el despliegue ya hecho): ver scripts históricos en commits o la conversación de despliegue.

## Seguridad

- El archivo `.env` en el destino contiene **tokens y JWT**. Limita SSH, cambia secretos si el destino es menos confiable.
- Abre en AWS el **security group** del destino solo a los puertos necesarios (22, 80, 443 si aplica).

## Nota sobre HTTPS

El sitio por IP usa solo **HTTP:80**. Para HTTPS con dominio, emite certificados con Certbot y ajusta `server_name` en Nginx como en el servidor original.
