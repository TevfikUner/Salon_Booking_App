#!/bin/sh
# Konteyner girişi. Komut verilmezse web sunucusunu başlatır.
#   RUN_MIGRATIONS=1 (varsayılan): başlamadan önce `alembic upgrade head`.
#   Render'da migration preDeployCommand ile bir kez çalışır → RUN_MIGRATIONS=0.
set -e
if [ "${RUN_MIGRATIONS:-1}" = "1" ]; then
  alembic upgrade head
fi
if [ "$#" -gt 0 ]; then
  exec "$@"
fi
# WEB_CONCURRENCY: gunicorn worker (süreç) sayısı. Kaba kural: 2 × CPU + 1; 512 MB RAM için 2.
# FORWARDED_ALLOW_IPS: X-Forwarded-Proto/For'a güvenilecek proxy adresleri (https şemasının doğru görünmesi için).
#   Render'da '*'. İstemci IP'si bu ayara değil GUVENILIR_PROXY_SAYISI'na göre çözülür (koruma.istemci_ip).
exec gunicorn main:app \
  --worker-class uvicorn_worker.UvicornWorker \
  --workers "${WEB_CONCURRENCY:-2}" \
  --bind "0.0.0.0:${PORT:-8000}" \
  --timeout 60 --graceful-timeout 20 --keep-alive 5 \
  --max-requests 10000 --max-requests-jitter 1000 \
  --forwarded-allow-ips "${FORWARDED_ALLOW_IPS:-127.0.0.1}"
