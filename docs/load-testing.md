# Yük Testi Raporu — Premium Berber API

Tarih: 2026-10-10 · Dal: `feature/v1-hazirlik`

## Sonuç (özet)

| Hedef | Ölçülen (1000 eşzamanlı kullanıcı, 6 worker) | Durum |
|---|---|---|
| Okuma p95 < 500 ms | 190–270 ms (uç noktaya göre) | ✅ |
| Yazma p95 < 800 ms | randevu oluşturma 530 ms, iptal 310 ms | ✅ |
| Hata oranı < %1 | %0,005 (73.319 istekte 4, hepsi istemci tarafı bağlantı kopması) | ✅ |
| **Çift randevu = 0** | Tüm koşulardan sonra çakışan aktif randevu çifti: **0** | ✅ |
| Yarış: aynı saate 100 eşzamanlı istek → tek kazanan | 1 × 200, 99 × 409 | ✅ |
| Yeniden başlatma / DB kesintisi → veri kaybı yok, anlaşılır mesaj | 1.225 / 1.225 randevu kayıtlı, kesintide Türkçe 503 | ✅ |

**Önemli kapasite bulgusu:** 2 worker (Render Starter varsayılanı) ~150 istek/sn civarında doyuyor. Locust senaryosundaki
kullanıcılar 1–4 sn'de bir istek atıyor (gerçek kullanıcıdan çok daha agresif); 1000 kullanıcı ≈ 410 istek/sn. Bu yükte
2 worker çöktü (aşağıda "stres-2w"), 6 worker hedeflerin hepsini tuttu. Plan önerisi [decisions.md](decisions.md)'de.

## Ortam

- Windows 11 + WSL2 Docker, 20 mantıksal çekirdek, 7,6 GB WSL belleği
- `docker compose` yığını: PostgreSQL 16 (alpine, `max_connections=200`), API (gunicorn + `uvicorn_worker.UvicornWorker`,
  production imajıyla aynı Dockerfile), ayrı zamanlayıcı worker'ı
- Havuz: worker başına `DB_POOL_SIZE=5`, `DB_MAX_OVERFLOW=10`
- Veri: `backend/yuk/veri.py` → 50 salon, 200 berber, 400 hizmet, 1000 müşteri
- Yük üretici: Locust 2.46.7, aynı makinede (sonuçlar bu yüzden biraz kötümser)
- Kimlik: `AUTH_MODE=dev` (`Bearer dev:yuk-musteri-N`) — Firebase doğrulama maliyeti ölçüme dahil değil

## Senaryo (`backend/yuk/locustfile.py`)

Her sanal müşteri 1–4 sn düşünme süresiyle şu karışımı yapar (ağırlıklar):
salon listesi (15, şehir veya konumla), müsait saatler (12), salon detayı (8), müsait takvim (5), Randevularım (5),
**randevu oluşturma (6, idempotency anahtarıyla)**, `/ben` (2), **iptal (2)**.
`409` (saat bu arada doldu) doğru iş sonucudur, hata sayılmaz.

## Ölçümler (ms)

### 1) Önce — 200 kullanıcı, 2 worker, 2 dk
| Uç nokta | İstek | Hata | p50 | p95 | p99 |
|---|---:|---:|---:|---:|---:|
| GET /ben | 312 | 0 | 8 | 33 | 99 |
| POST /randevular/[id]/iptal | 237 | 0 | 14 | 36 | 89 |
| GET /randevular/benim-randevularim | 830 | 0 | 9 | 61 | 140 |
| GET /randevular/musait-saatler/[id] | 2909 | 0 | 10 | 44 | 130 |
| GET /randevular/musait-takvim | 842 | 0 | **52** | **130** | 270 |
| POST /randevular/olustur | 918 | 0 | 26 | 79 | 160 |
| GET /salonlar | 2382 | 0 | 7 | 32 | 96 |
| GET /salonlar/[id] | 1279 | 0 | 9 | 36 | 110 |
| **Toplam** | 9709 | 0 | 10 | 69 | 140 |

### 2) Sonra — N+1 düzeltmesi, 200 kullanıcı, 2 worker, 2 dk
| Uç nokta | İstek | Hata | p50 | p95 | p99 |
|---|---:|---:|---:|---:|---:|
| GET /ben | 343 | 0 | 8 | 32 | 180 |
| POST /randevular/[id]/iptal | 264 | 0 | 14 | 35 | 300 |
| GET /randevular/benim-randevularim | 783 | 0 | 9 | 31 | 140 |
| GET /randevular/musait-saatler/[id] | 3052 | 0 | 10 | 36 | 150 |
| GET /randevular/musait-takvim | 845 | 0 | **9** | **43** | 150 |
| POST /randevular/olustur | 1027 | 0 | 25 | 74 | 260 |
| GET /salonlar | 2451 | 0 | 7 | 33 | 140 |
| GET /salonlar/[id] | 1323 | 0 | 9 | 48 | 190 |
| **Toplam** | 10088 | 0 | 9 | 47 | 170 |

(Bu koşu sırasında aynı makinede AAB derlemesi de çalışıyordu.)

### 3) Stres-2w — 1000 kullanıcı, 2 worker, 3 dk → ❌ çöktü
| Uç nokta | İstek | Hata | p50 | p95 | p99 |
|---|---:|---:|---:|---:|---:|
| **Toplam** | 12606 | 1317 (%10,4) | 84 | 60000 | 60000 |

Belirti: yalnızca 70 istek/sn işlenebildi, istekler kuyrukta 60 sn bekleyip zaman aşımına düştü; sunucu logunda
`QueuePool limit of size 5 overflow 10 reached` → **500** dönüyordu.

### 4) Stres-6w — 1000 kullanıcı, 6 worker, 3 dk → ✅
| Uç nokta | İstek | Hata | p50 | p95 | p99 |
|---|---:|---:|---:|---:|---:|
| GET /ben | 2381 | 0 | 20 | 250 | 460 |
| POST /randevular/[id]/iptal | 1916 | 4 | 36 | 310 | 570 |
| GET /randevular/benim-randevularim | 6058 | 0 | 22 | 270 | 490 |
| GET /randevular/musait-saatler/[id] | 21654 | 0 | 22 | 230 | 420 |
| GET /randevular/musait-takvim | 6018 | 0 | 20 | 230 | 460 |
| POST /randevular/olustur | 7196 | 0 | 62 | 530 | 850 |
| GET /salonlar | 18222 | 0 | 14 | 190 | 390 |
| GET /salonlar/[id] | 9874 | 0 | 21 | 250 | 460 |
| **Toplam** | 73319 | 4 (%0,005) | 23 | 270 | 520 |

408 istek/sn. 4 hata: iptal isteğinde durum kodu 0 (istemci bağlantısı koptu; sunucu logunda hata yok) — gunicorn'un
worker'ı her 2000 istekte yenilemesi sırasında açık keep-alive bağlantısının kapanması.

Ham CSV'ler: `backend/yuk/sonuc/{once,sonra,stres1000,stres1000_w6}_*.csv`

## Bulunan darboğazlar ve yapılan düzeltmeler

| # | Bulgu | Düzeltme | Etki |
|---|---|---|---|
| 1 | `/randevular/musait-takvim` 31 günün her biri için ayrı tatil + izin sorgusu atıyordu (~62 sorgu, N+1) | `slot_servisi.kapali_nedenler()` tüm aralığı 2 sorguda çeker | p50 52→9 ms, p95 130→43 ms |
| 2 | Bağlantı havuzu dolunca `sqlalchemy.exc.TimeoutError` → 500 "Beklenmeyen hata" | 503 + `Retry-After: 5` + Türkçe mesaj (`main.py`), test: `test_havuz_doluysa_500_degil_503` | Aşırı yükte istemci "tekrar deneyin" görür, Sentry'ye hata yağmaz |
| 3 | Havuz bekleme süresi 10 sn → istekler uzun asılı kalıyordu | `DB_POOL_TIMEOUT` varsayılanı 5 sn | Aşırı yükte hızlı geri bildirim |
| 4 | 2 worker CPU'da doyuyor (~150 istek/sn) | `WEB_CONCURRENCY` ile ölçeklenir; 6 worker → 408 istek/sn hedefler içinde | Plan önerisi decisions.md |
| 5 | Worker yenilemesinde (her 2000 istek) bağlantı kopması | `--max-requests 10000 --max-requests-jitter 1000` | Yenileme 5 kat seyrek |
| 6 | `yuk/veri.py` PostgreSQL'de ID sayaçlarını sıfırlamıyordu (2. kurulumda 404) | `TRUNCATE ... RESTART IDENTITY CASCADE` | Test tekrarlanabilir |

Not: daha önceki turda eklenen indeksler (`ix_randevu_berber_tarih_durum`, `ix_randevu_salon_tarih`,
`ix_randevu_musteri_tarih`) ve `benim-randevularim`'deki eager loading sayesinde diğer uç noktalarda N+1 görülmedi.

## Çift randevu doğrulaması

`backend/yuk/dogrula.py` her koşudan sonra aynı berberin aynı günde zaman aralığı kesişen aktif randevu çiftlerini SQL ile arar.

| Koşu | Aktif randevu | Çakışan çift |
|---|---:|---:|
| Önce (200 kullanıcı) | 682 | **0** |
| Yarış testi | 3 | **0** |
| Kesinti testi sonrası | 1998 | **0** |
| Stres-2w (1000 kullanıcı) | 872 | **0** |
| Stres-6w (1000 kullanıcı) | 5302 | **0** |

Koruma katmanları: (1) `slot_servisi.randevu_olustur` berber satırını kilitleyip (`SELECT … FOR UPDATE`) çakışmayı
kontrol eder, (2) PostgreSQL kısmi tekil indeksi `uq_randevu_aktif_slot (berber_id, tarih, saat) WHERE durum='onaylandi'`,
(3) `Idempotency-Key` ile aynı isteğin tekrarı ikinci kayıt oluşturmaz.

## Yarış testi (`backend/yuk/yaris.py`)

`threading.Barrier` ile istekler aynı anda bırakılır, gerçek gunicorn sunucusuna (çok süreç) gider.

```
Senaryo A (100 eşzamanlı, aynı saat): {('14:00', 200): 1, ('14:00', 409): 99} → başarılı=1
Senaryo B (90 eşzamanlı, çakışan saatler): {('10:00', 200): 1, ('10:30', 409): 30, ('10:00', 409): 29, ('11:00', 200): 1, ('11:00', 409): 29}
Beklenmeyen durum kodu sayısı: 0
SONUÇ: GEÇTİ ✅
```

Senaryo B: 10:00 (60 dk) kazanınca 10:30 tamamen reddedildi; 11:00 bitişe değdiği için (çakışma sayılmaz) ayrıca alındı.

## Kesinti testi (`backend/yuk/kesinti.py`)

75 sn boyunca sürekli randevu yazılırken: t=15 sn API konteyneri yeniden başlatıldı, t=30 sn PostgreSQL durduruldu, 15 sn sonra başlatıldı.

```
22:02:46 API restart            → 22:02:47 bitti
22:03:02 DB stop
22:03:05 DB kapalıyken /health: 503 {"durum":"hata","veritabani":"erişilemiyor"}
22:03:18 DB start
22:03:27 DB açıldıktan sonra /health: {"durum":"ok","veritabani":"ok","surum":"1.0.0"}

İstek: 1707  durum kodları: {409: 400, 200: 1225, 'ReadError': 3, 'RemoteProtocolError': 7, 503: 72}
  5xx mesajı ×72: Hizmet geçici olarak kullanılamıyor. Lütfen birazdan tekrar deneyin.
200 dönen randevu: 1225  sunucuda bulunan: 1225  KAYIP: 0
```

- **Veri kaybı yok:** 200 alınan her randevu sunucuda.
- DB kesintisinde ham hata yok; Türkçe 503 + `Retry-After`. Bağlantı dönünce `pool_pre_ping` sayesinde ek işlem gerekmeden düzeldi.
- API yeniden başlarken 10 istek bağlantı hatası aldı (yaklaşık 1 sn). Uygulama bu durumda "Sunucuya ulaşılamadı" der;
  okuma istekleri otomatik 2 kez yeniden denenir, randevu isteği aynı `Idempotency-Key` ile tekrarlandığı için çift kayıt oluşmaz.

## Tekrar üretme

```bash
# 1) Yığın (WSL/Linux)
API_PORT=8020 WEB_CONCURRENCY=6 docker compose -p premium-berber up -d --build
bash backend/yuk/yigin.sh veri                      # veri setini kur (TÜM tabloları temizler)

# 2) Yük (backend/ içinde, requirements-dev kurulu)
locust -f yuk/locustfile.py --host http://127.0.0.1:8020 --headless -u 1000 -r 50 -t 3m --csv yuk/sonuc/stres --only-summary
bash yuk/yigin.sh dogrula                           # çakışan çift = 0 olmalı

# 3) Yarış ve kesinti
bash yuk/yigin.sh veri && python yuk/yaris.py http://127.0.0.1:8020
python yuk/kesinti.py http://127.0.0.1:8020 75      # sırasında: docker compose -p premium-berber restart api / stop db / start db
```
