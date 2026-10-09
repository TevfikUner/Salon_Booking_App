#!/usr/bin/env sh
# PostgreSQL yedeği: ./scripts/yedekle.sh "$DATABASE_URL"
# Çıktı: yedekler/berber_YYYYmmdd_HHMM.sql.gz  (en yeni 14 yedek tutulur)
set -eu
URL="${1:-${DATABASE_URL:?DATABASE_URL gerekli}}"
mkdir -p yedekler
DOSYA="yedekler/berber_$(date +%Y%m%d_%H%M).sql.gz"
pg_dump --no-owner --no-privileges "$URL" | gzip > "$DOSYA"
ls -1t yedekler/berber_*.sql.gz | tail -n +15 | xargs -r rm --
echo "Yedek alındı: $DOSYA"
# Geri yükleme: gunzip -c yedekler/<dosya>.sql.gz | psql "$URL"
