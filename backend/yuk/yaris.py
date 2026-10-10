"""Yarış testi: çok süreçli gerçek sunucuya aynı anda yüzlerce randevu isteği.

    python yuk/yaris.py http://127.0.0.1:8020

Senaryo A: 100 farklı kullanıcı aynı berber + gün + saat → tam 1 başarı beklenir.
Senaryo B: aynı berberde kısmen çakışan istekler (10:00 60 dk / 10:30 30 dk / 11:00 30 dk), her biri 30 kez
           eşzamanlı → çakışmayan bir alt küme başarılı, hiçbir iki aktif randevu çakışmamalı.
Sunucu AUTH_MODE=dev olmalı; veri yuk/veri.py ile hazırlanmış olmalı.
"""
import sys
import threading
from collections import Counter
from datetime import date, timedelta

import httpx

TABAN = sys.argv[1] if len(sys.argv) > 1 else "http://127.0.0.1:8020"
GUN = (date.today() + timedelta(days=20)).isoformat()


def ates(istekler: list[tuple[int, str, int, int]]) -> Counter:
    """(müşteri_no, saat, berber_id, hizmet_id) listesini aynı anda gönderir."""
    engel = threading.Barrier(len(istekler))
    sonuc: Counter = Counter()
    kilit = threading.Lock()

    def gonder(no: int, saat: str, berber: int, hizmet: int):
        with httpx.Client(base_url=TABAN, timeout=60) as c:
            engel.wait()  # hepsi aynı anda
            r = c.post("/randevular/olustur", params={"berber_id": berber, "tarih": GUN, "saat": saat,
                                                      "hizmet_ids": hizmet},
                       headers={"Authorization": f"Bearer dev:yuk-musteri-{no}"})
        with kilit:
            sonuc[(saat, r.status_code)] += 1

    t = [threading.Thread(target=gonder, args=i) for i in istekler]
    [x.start() for x in t]
    [x.join() for x in t]
    return sonuc


# Salon 1 → berber 1..4, hizmet 1: Saç Kesimi (30 dk), hizmet 7: Keratin (60 dk)
a = ates([(n, "14:00", 1, 1) for n in range(100)])
basari_a = sum(v for (s, k), v in a.items() if k == 200)
print(f"Senaryo A (100 eşzamanlı, aynı saat): {dict(a)} → başarılı={basari_a}")

b = ates([(200 + n, "10:00", 2, 7) for n in range(30)] + [(300 + n, "10:30", 2, 1) for n in range(30)]
         + [(400 + n, "11:00", 2, 1) for n in range(30)])
print(f"Senaryo B (90 eşzamanlı, çakışan saatler): {dict(b)}")
basari_b = {s for (s, k) in b if k == 200}
# Geçerli sonuçlar: {10:00(60dk)} + {11:00} veya {10:30} + {11:00}; asla 10:00 ile 10:30 birlikte değil
gecerli_b = "10:00" not in basari_b or "10:30" not in basari_b
hatalar = sum(v for (s, k), v in (a + b).items() if k not in (200, 409))
print(f"Beklenmeyen durum kodu sayısı: {hatalar}")
ok = basari_a == 1 and gecerli_b and all(v == 1 for (s, k), v in b.items() if k == 200) and hatalar == 0
print("SONUÇ:", "GEÇTİ ✅" if ok else "KALDI ❌")
sys.exit(0 if ok else 1)
