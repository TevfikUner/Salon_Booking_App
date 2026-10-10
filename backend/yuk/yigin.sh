#!/usr/bin/env bash
# Yerel docker compose yığınında (proje adı premium-berber) yük testi yardımcıları.
#   bash backend/yuk/yigin.sh veri      → yuk/ klasörünü api konteynerine kopyalar, veri setini kurar
#   bash backend/yuk/yigin.sh dogrula   → çakışan aktif randevu sayısını raporlar
#   bash backend/yuk/yigin.sh entegrasyon → Flutter entegrasyon testi verisini kurar
set -euo pipefail
cd "$(dirname "$0")/../.."
dc() { docker compose -p premium-berber "$@"; }
dc cp backend/yuk api:/app/
case "${1:-}" in
  veri) dc exec -T api python yuk/veri.py ;;
  dogrula) dc exec -T api python yuk/dogrula.py ;;
  entegrasyon) dc exec -T api python yuk/entegrasyon_veri.py ;;
  *) echo "kullanım: $0 veri|dogrula|entegrasyon"; exit 2 ;;
esac
