"""Gerçekçi kullanıcı karışımı ile yük testi (Locust).

    locust -f yuk/locustfile.py --host http://127.0.0.1:8020 --headless -u 200 -r 20 -t 3m --csv yuk/sonuc

Sunucu AUTH_MODE=dev ile çalışmalı (her sanal kullanıcı `Bearer dev:yuk-musteri-N` kimliği taşır).
Ağırlıklar (kabaca gerçek kullanım): listeleme ve saat sorgusu baskın, randevu yazma ~%10.
409 (seçilen saat bu arada doldu) beklenen bir iş sonucudur, hata sayılmaz.
"""
import random
import uuid
from datetime import date, timedelta

from locust import FastHttpUser, between, events, task

SALON_SAYISI = 50
BERBER_BASINA = 4
_sayac = iter(range(10**9))


class Musteri(FastHttpUser):
    wait_time = between(1, 4)  # gerçek kullanıcı ekranlar arasında düşünür

    def on_start(self):
        self.no = next(_sayac) % 1000
        self.h = {"Authorization": f"Bearer dev:yuk-musteri-{self.no}"}
        self.randevularim: list[int] = []

    def _salon(self) -> int:
        return random.randint(1, SALON_SAYISI)

    # ── Okuma ──
    @task(15)
    def salon_listesi(self):
        params = {"sehir": random.choice(["istanbul", "ANKARA", "İzmir"])} if random.random() < 0.5 else \
            {"lat": 39.0, "lng": 32.0}
        self.client.get("/salonlar", params=params, headers=self.h, name="/salonlar")

    @task(8)
    def salon_detay(self):
        self.client.get(f"/salonlar/{self._salon()}", headers=self.h, name="/salonlar/[id]")

    @task(5)
    def takvim(self):
        self.client.get("/randevular/musait-takvim", params={"berber_id": random.randint(1, 200)},
                        headers=self.h, name="/randevular/musait-takvim")

    @task(12)
    def musait_saatler(self):
        self._saatler(random.randint(1, 200), self._gun())

    @task(5)
    def randevularim_listesi(self):
        self.client.get("/randevular/benim-randevularim", headers=self.h, name="/randevular/benim-randevularim")

    @task(2)
    def ben(self):
        self.client.get("/ben", headers=self.h, name="/ben")

    # ── Yazma ──
    @task(6)
    def randevu_al(self):
        berber = random.randint(1, 200)
        salon = (berber - 1) // BERBER_BASINA + 1
        hizmet = (salon - 1) * 8 + random.choice([1, 2, 3])  # salonun ilk hizmetlerinden biri
        gun = self._gun()
        saatler = self._saatler(berber, gun, hizmet)
        if not saatler:
            return
        params = {"berber_id": berber, "tarih": gun, "saat": random.choice(saatler[:6]), "hizmet_ids": hizmet}
        with self.client.post("/randevular/olustur", params=params, name="/randevular/olustur", catch_response=True,
                              headers={**self.h, "Idempotency-Key": uuid.uuid4().hex}) as r:
            if r.status_code == 200:
                self.randevularim.append(r.json()["randevu_id"])
                r.success()
            elif r.status_code == 409:
                r.success()  # saat başkası tarafından alındı — doğru davranış
            else:
                r.failure(f"{r.status_code} {r.text[:120]}")

    @task(2)
    def iptal(self):
        if not self.randevularim:
            return
        rid = self.randevularim.pop(random.randrange(len(self.randevularim)))
        with self.client.post(f"/randevular/{rid}/iptal", headers=self.h, name="/randevular/[id]/iptal",
                              catch_response=True) as r:
            r.success() if r.status_code in (200, 400) else r.failure(f"{r.status_code}")

    # ── yardımcılar ──
    @staticmethod
    def _gun() -> str:
        return (date.today() + timedelta(days=random.randint(1, 14))).isoformat()

    def _saatler(self, berber: int, gun: str, hizmet: int | None = None) -> list[str]:
        salon = (berber - 1) // BERBER_BASINA + 1
        hizmet = hizmet or (salon - 1) * 8 + 1
        r = self.client.get(f"/randevular/musait-saatler/{berber}", params={"tarih": gun, "hizmet_ids": hizmet},
                            headers=self.h, name="/randevular/musait-saatler/[id]")
        try:
            return r.json().get("musait_saatler", []) if r.status_code == 200 else []
        except Exception:
            return []


@events.quitting.add_listener
def _ozet(environment, **_):
    s = environment.stats.total
    print(f"\nTOPLAM istek={s.num_requests} hata={s.num_failures} ({s.fail_ratio * 100:.2f}%) "
          f"p50={s.get_response_time_percentile(0.5):.0f}ms p95={s.get_response_time_percentile(0.95):.0f}ms "
          f"rps={s.total_rps:.1f}")
