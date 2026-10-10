"""Kesinti testi: sürekli randevu yazarken API yeniden başlatılır / veritabanı durdurulur.

    python yuk/kesinti.py http://127.0.0.1:8020 90      (süre sn)

Başka bir terminalde test sırasında:  docker compose -p premium-berber restart api
                                       docker compose -p premium-berber stop db; sleep 10; ... start db
Doğrulanan: 200 dönen HER randevu sonradan sunucuda var (veri kaybı yok); hata yanıtları ham hata değil,
Türkçe ve anlaşılır; bağlantı geri gelince istekler kendiliğinden düzeliyor.
"""
import sys
import time
import uuid
from collections import Counter
from datetime import date, timedelta

import httpx

TABAN = sys.argv[1] if len(sys.argv) > 1 else "http://127.0.0.1:8020"
SURE = int(sys.argv[2]) if len(sys.argv) > 2 else 90
SAATLER = [f"{h:02d}:{m:02d}" for h in range(9, 21) for m in (0, 30)]


def main() -> int:
    basarili: list[tuple[int, int]] = []  # (müşteri_no, randevu_id)
    kodlar: Counter = Counter()
    mesajlar: Counter = Counter()
    bitis = time.time() + SURE
    i = 0
    with httpx.Client(base_url=TABAN, timeout=10) as c:
        while time.time() < bitis:
            no = 500 + i % 400
            berber = 1 + i % 200
            gun = (date.today() + timedelta(days=15 + (i // 4800) % 10)).isoformat()
            saat = SAATLER[(i // 200) % len(SAATLER)]
            hizmet = ((berber - 1) // 4) * 8 + 1
            h = {"Authorization": f"Bearer dev:yuk-musteri-{no}", "Idempotency-Key": uuid.uuid4().hex}
            try:
                r = c.post("/randevular/olustur", headers=h,
                           params={"berber_id": berber, "tarih": gun, "saat": saat, "hizmet_ids": hizmet})
                kodlar[r.status_code] += 1
                if r.status_code == 200:
                    basarili.append((no, r.json()["randevu_id"]))
                elif r.status_code >= 500:
                    try:
                        mesajlar[str(r.json().get("detail"))[:90]] += 1
                    except Exception:
                        mesajlar[f"(JSON değil) {r.text[:60]}"] += 1
            except httpx.HTTPError as e:
                kodlar[type(e).__name__] += 1
                time.sleep(0.2)
            i += 1

        print(f"İstek: {i}  durum kodları: {dict(kodlar)}")
        for m, n in mesajlar.most_common():
            print(f"  5xx mesajı ×{n}: {m}")

        # Veri kaybı kontrolü: 200 alınan her randevu müşterinin listesinde olmalı
        kullanicilar = {no for no, _ in basarili}
        kayitli: set[int] = set()
        for no in kullanicilar:
            r = c.get("/randevular/benim-randevularim", headers={"Authorization": f"Bearer dev:yuk-musteri-{no}"})
            r.raise_for_status()
            kayitli |= {x["id"] for x in r.json()}
        kayip = [rid for _, rid in basarili if rid not in kayitli]
        print(f"200 dönen randevu: {len(basarili)}  sunucuda bulunan: {len(basarili) - len(kayip)}  KAYIP: {len(kayip)}")
    return 1 if kayip else 0


if __name__ == "__main__":
    sys.exit(main())
