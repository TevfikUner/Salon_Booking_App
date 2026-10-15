"""Güvenlik sertleştirmesi regresyon testleri: hız sınırının atlatılamaması (sahte X-Forwarded-For, rastgele token),
chunked gövde sınırı, bütünlük hatası → 409, dosya depolama, yorumun gövdede gelmesi, izin açıklamasının gizliliği,
hesap silmede iptal kontrolü ve sunucu tarafı Firebase silme, X-Request-ID doğrulaması."""
import os

import pytest
from sqlalchemy.exc import IntegrityError
from starlette.requests import Request

import auth as auth_modulu
import depolama as dp
import models
from config import ayarlar
from conftest import YARIN, auth, randevu_al
from koruma import istemci_anahtari, istemci_ip, limiter


def _istek(xff: str | None = None, yetki: str | None = None, ip: str = "10.0.0.9") -> Request:
    basliklar = []
    if xff is not None:
        basliklar.append((b"x-forwarded-for", xff.encode()))
    if yetki is not None:
        basliklar.append((b"authorization", yetki.encode()))
    return Request({"type": "http", "method": "GET", "path": "/", "headers": basliklar, "client": (ip, 1234)})


@pytest.fixture
def hiz_siniri():
    limiter.enabled = True
    limiter.reset()
    yield
    limiter.enabled = False
    limiter.reset()


# ── İstemci IP'si ve hız sınırı anahtarı ─────────────────────

def test_proxy_yokken_x_forwarded_for_yok_sayilir():
    assert istemci_ip(_istek(xff="1.2.3.4")) == "10.0.0.9"


def test_proxy_arkasinda_sagdan_sayilir_sol_taraf_sahte_olabilir(monkeypatch):
    monkeypatch.setattr(ayarlar(), "guvenilir_proxy_sayisi", 1)
    # istemci "6.6.6.6" yazdı, Render proxy'si gerçek adresi (5.5.5.5) sona ekledi
    assert istemci_ip(_istek(xff="6.6.6.6, 5.5.5.5")) == "5.5.5.5"
    assert istemci_ip(_istek(xff="7.7.7.7, 8.8.8.8, 5.5.5.5")) == "5.5.5.5"
    # beklenenden az girdi: proxy'den gelmemiş → başlığa güvenilmez
    monkeypatch.setattr(ayarlar(), "guvenilir_proxy_sayisi", 2)
    assert istemci_ip(_istek(xff="6.6.6.6")) == "10.0.0.9"


def test_dogrulanmamis_token_kullanici_anahtari_uretmez():
    assert istemci_anahtari(_istek(yetki="Bearer rastgele-cop")) == "ip:10.0.0.9"
    assert istemci_anahtari(_istek(yetki="Basic abc")) == "ip:10.0.0.9"
    assert istemci_anahtari(_istek(yetki="Bearer dev:musteri-1")) == "k:musteri-1"


def test_rastgele_tokenlarla_ip_siniri_atlatilamaz(client, hiz_siniri):
    """Önceden her farklı 'Bearer xyz' ayrı bir kova açıyordu; artık doğrulanamayan token IP'ye düşer."""
    kodlar = [client.get("/salonlar/filtreler", headers={"Authorization": f"Bearer cop-{i}"}).status_code
              for i in range(301)]
    assert kodlar[:300] == [200] * 300 and kodlar[300] == 429


def test_sahte_x_forwarded_for_ile_ip_siniri_atlatilamaz(client, hiz_siniri, monkeypatch):
    monkeypatch.setattr(ayarlar(), "guvenilir_proxy_sayisi", 1)
    kodlar = [client.get("/salonlar/filtreler", headers={"X-Forwarded-For": f"9.9.{i // 256}.{i % 256}, 5.5.5.5"})
              .status_code for i in range(301)]
    assert kodlar[300] == 429
    # başka gerçek istemci etkilenmez
    assert client.get("/salonlar/filtreler", headers={"X-Forwarded-For": "4.4.4.4"}).status_code == 200


# ── Gövde boyutu (chunked) ───────────────────────────────────

def test_content_length_olmadan_buyuk_govde_413(client):
    parcalar = iter([b"x" * 600_000, b"x" * 600_000])  # iterator → Transfer-Encoding: chunked
    r = client.post("/musteriler/kayit", content=parcalar,
                    headers={**auth("musteri-1"), "content-type": "application/json"})
    assert r.status_code == 413 and r.json()["detail"] == "İstek çok büyük."


def test_kucuk_chunked_govde_calisir(client):
    r = client.post("/musteriler/kayit", content=iter([b'{"ad": "A", "kvkk_onay": true}']),
                    headers={**auth("yeni-kisi"), "content-type": "application/json"})
    assert r.status_code == 200


# ── Bütünlük hatası ──────────────────────────────────────────

def test_benzersizlik_ihlali_503_degil_409(client, veri, monkeypatch):
    import slot_servisi as ss

    def cakisma(*_a, **_k):
        raise IntegrityError("INSERT", {}, Exception("UNIQUE constraint failed"))

    monkeypatch.setattr(ss, "gun_musaitligi", cakisma)
    yol = f"/randevular/musait-saatler/{veri['ali']}"
    r = client.get(yol, params=[("tarih", YARIN), ("hizmet_ids", veri["kesim"])])
    assert r.status_code == 409 and "retry-after" not in r.headers
    assert "zaten mevcut" in r.json()["detail"]
    en = client.get(yol, params=[("tarih", YARIN), ("hizmet_ids", veri["kesim"])], headers={"Accept-Language": "en"})
    assert en.json()["detail"].startswith("This record already exists")


# ── Dosya depolama ───────────────────────────────────────────

PNG = bytes.fromhex("89504e470d0a1a0a")


@pytest.fixture
def gecici_yerel_depo(tmp_path, monkeypatch):
    monkeypatch.setattr(ayarlar(), "uploads_dir", str(tmp_path))
    dp.depolama.cache_clear()
    yield tmp_path
    dp.depolama.cache_clear()


def test_foto_degisince_url_degisir_eski_dosya_silinir(client, veri, gecici_yerel_depo):
    h = auth("admin-uid")
    u1 = client.post(f"/berberler/foto-yukle/{veri['ali']}", headers=h,
                     files={"foto": ("a.png", PNG + b"\x01" * 64, "image/png")}).json()["foto_url"]
    u2 = client.post(f"/berberler/foto-yukle/{veri['ali']}", headers=h,
                     files={"foto": ("b.png", PNG + b"\x02" * 64, "image/png")}).json()["foto_url"]
    assert u1 != u2 and u1.startswith("/uploads/berberler/berber_") and u2.endswith(".png")
    dosyalar = os.listdir(gecici_yerel_depo / "berberler")
    assert dosyalar == [u2.rsplit("/", 1)[1]]


def test_yerel_depolama_dis_adres_ve_yol_gezinmesini_silmez(tmp_path):
    d = dp.YerelDepolama(str(tmp_path))
    disarida = tmp_path.parent / "dokunma.txt"
    disarida.write_text("x")
    d.sil("https://baska.site/foto.jpg")
    d.sil("/uploads/../dokunma.txt")
    assert disarida.exists()


class _SahteS3:
    def __init__(self):
        self.nesneler, self.silinen = {}, []

    def put_object(self, Bucket, Key, Body, ContentType, CacheControl):  # noqa: N803 (boto3 imzası)
        self.nesneler[(Bucket, Key)] = (Body, ContentType, CacheControl)

    def delete_object(self, Bucket, Key):  # noqa: N803
        self.silinen.append((Bucket, Key))


def test_s3_depolama_url_icerik_turu_ve_silme():
    s3 = _SahteS3()
    d = dp.S3Depolama("kova", "https://cdn.ornek.app/", istemci=s3)
    anahtar = dp.dosya_anahtari("berberler", "berber_7", b"veri", "webp")
    url = d.kaydet(anahtar, b"veri", "webp")
    assert url == f"https://cdn.ornek.app/{anahtar}"
    govde, tur, onbellek = s3.nesneler[("kova", anahtar)]
    assert govde == b"veri" and tur == "image/webp" and "immutable" in onbellek
    d.sil(url)
    d.sil("/uploads/berberler/eski.jpg")  # başka depolamanın adresi: dokunulmaz
    assert s3.silinen == [("kova", anahtar)]


def test_s3_yapilandirilmamissa_anlasilir_hata(client, veri, monkeypatch):
    monkeypatch.setattr(ayarlar(), "depolama", "s3")
    monkeypatch.setattr(ayarlar(), "s3_bucket", "")
    dp.depolama.cache_clear()
    try:
        r = client.post(f"/berberler/foto-yukle/{veri['ali']}", headers=auth("admin-uid"),
                        files={"foto": ("a.png", PNG + b"\x00" * 64, "image/png")})
    finally:
        dp.depolama.cache_clear()
    assert r.status_code == 503 and r.json()["detail"] == "Dosya depolama yapılandırılmamış."


# ── Değerlendirme gövdede, izin açıklaması gizli ─────────────

def test_degerlendirme_json_govdeyle(client, veri, db):
    rid = randevu_al(client, "musteri-2", veri["ali"], YARIN, "10:00", [veri["kesim"]]).json()["randevu_id"]
    db.get(models.Randevu, rid).durum = "tamamlandi"
    db.commit()
    govde = {"randevu_id": rid, "puan": 5, "yorum": "Harika"}
    assert client.post("/degerlendirmeler", json={**govde, "puan": 0}, headers=auth("musteri-2")).status_code == 400
    assert client.post("/degerlendirmeler", json=govde, headers=auth("musteri-1")).status_code == 403
    assert client.post("/degerlendirmeler", json=govde, headers=auth("musteri-2")).status_code == 200
    assert client.post("/degerlendirmeler", json=govde, headers=auth("musteri-2")).status_code == 400
    db.expire_all()
    assert db.get(models.Randevu, rid).yorum == "Harika"


def test_berber_izin_aciklamasi_herkese_acik_uca_cikmaz(client, veri):
    client.post("/berberler/izin-ekle", params={"berber_id": veri["ali"], "tarih": YARIN, "aciklama": "Doktor"},
                headers=auth("admin-uid"))
    liste = client.get(f"/berberler/izinler/{veri['ali']}").json()
    assert [x["tarih"] for x in liste] == [YARIN] and "aciklama" not in liste[0]


# ── Hesap silme ──────────────────────────────────────────────

def test_hesap_silme_iptal_kontrolu_ve_sunucuda_firebase_silme(client, veri, monkeypatch):
    cagrilar = []
    gercek = auth_modulu.token_coz

    def izleyen(token, iptal_kontrolu=False):
        cagrilar.append(iptal_kontrolu)
        return gercek(token, iptal_kontrolu)

    monkeypatch.setattr(auth_modulu, "token_coz", izleyen)
    import routers.musteriler as rm
    silinen = []
    monkeypatch.setattr(rm, "firebase_kullanicisini_sil", lambda uid: silinen.append(uid) or True)

    r = client.delete("/musteriler/hesabim", headers=auth("musteri-1"))
    assert r.status_code == 200 and r.json()["firebase_silindi"] is True
    assert True in cagrilar and silinen == ["musteri-1"]


def test_firebase_kullanicisini_sil(monkeypatch):
    import firebase_admin.auth as fb_auth

    import firebase_app
    from hesap_servisi import firebase_kullanicisini_sil

    assert firebase_kullanicisini_sil("x") is False  # AUTH_MODE=dev: Firebase'e dokunulmaz
    monkeypatch.setattr(ayarlar(), "auth_mode", "firebase")
    monkeypatch.setattr(firebase_app, "firebase_hazir", lambda: True)
    silinen = []
    monkeypatch.setattr(fb_auth, "delete_user", silinen.append)
    assert firebase_kullanicisini_sil("u1") is True and silinen == ["u1"]

    def yok(_):
        raise fb_auth.UserNotFoundError("yok")

    monkeypatch.setattr(fb_auth, "delete_user", yok)
    assert firebase_kullanicisini_sil("u2") is True

    def bozuk(_):
        raise RuntimeError("ağ hatası")

    monkeypatch.setattr(fb_auth, "delete_user", bozuk)
    assert firebase_kullanicisini_sil("u3") is False


# ── X-Request-ID ─────────────────────────────────────────────

def test_gecerli_istek_kimligi_korunur_gecersizi_yenilenir(client):
    assert client.get("/health", headers={"X-Request-ID": "abc-123"}).headers["x-request-id"] == "abc-123"
    for kotu in ("a" * 65, "kotu kimlik", "a;b=c", "x/../y"):
        yeni = client.get("/health", headers={"X-Request-ID": kotu}).headers["x-request-id"]
        assert yeni != kotu and len(yeni) == 12


# ── Müşteri profil fotoğrafı ─────────────────────────────────

def test_profil_fotografi_yukle_degistir_kaldir(client, veri, gecici_yerel_depo):
    h = auth("musteri-1")
    assert client.get("/musteriler/profil", headers=h).json()["foto_url"] is None
    u1 = client.post("/musteriler/profil-foto", headers=h,
                     files={"foto": ("a.png", PNG + b"\x01" * 64, "image/png")}).json()["foto_url"]
    # tahmin edilemez ad: müşteri kimliği değil rastgele önek
    assert u1.startswith("/uploads/musteriler/") and "musteri" not in u1.rsplit("/", 1)[1]
    u2 = client.post("/musteriler/profil-foto", headers=h,
                     files={"foto": ("b.png", PNG + b"\x02" * 64, "image/png")}).json()["foto_url"]
    assert u1 != u2 and client.get("/musteriler/profil", headers=h).json()["foto_url"] == u2
    assert os.listdir(gecici_yerel_depo / "musteriler") == [u2.rsplit("/", 1)[1]]
    assert client.delete("/musteriler/profil-foto", headers=h).status_code == 200
    assert client.get("/musteriler/profil", headers=h).json()["foto_url"] is None
    assert os.listdir(gecici_yerel_depo / "musteriler") == []


def test_profil_fotografi_icerik_denetimi_ve_oturum(client, veri, gecici_yerel_depo):
    sahte = client.post("/musteriler/profil-foto", headers=auth("musteri-1"),
                        files={"foto": ("x.jpg", b"<script>", "image/jpeg")})
    assert sahte.status_code == 400
    assert client.post("/musteriler/profil-foto", files={"foto": ("a.png", PNG, "image/png")}).status_code == 401
    # 5 MB'tan büyük ama genel 1 MB sınırına takılmadan uca ulaşır (fotoğraf yolu daha yüksek sınırda)
    buyuk = client.post("/musteriler/profil-foto", headers=auth("musteri-1"),
                        files={"foto": ("b.png", PNG + b"\x00" * (5 * 1024 * 1024), "image/png")})
    assert buyuk.status_code == 413 and "5 MB" in buyuk.json()["detail"]


def test_hesap_silinince_profil_fotografi_da_silinir(client, veri, db, gecici_yerel_depo):
    h = auth("musteri-1")
    client.post("/musteriler/profil-foto", headers=h, files={"foto": ("a.png", PNG + b"\x03" * 64, "image/png")})
    assert len(os.listdir(gecici_yerel_depo / "musteriler")) == 1
    assert client.delete("/musteriler/hesabim", headers=h).status_code == 200
    assert os.listdir(gecici_yerel_depo / "musteriler") == []
    m = db.query(models.Musteri).filter_by(silindi=True).one()
    assert m.foto_url is None
