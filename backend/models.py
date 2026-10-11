from sqlalchemy import Boolean, Column, Float, ForeignKey, Index, Integer, String, Table, Text, UniqueConstraint, text
from sqlalchemy.orm import relationship

from database import Base

# Tarih alanları "YYYY-MM-DD", saat alanları "HH:MM" string'i olarak saklanır (salonun yerel saati).
# Zaman damgaları (olusturma vb.) ISO-8601 string'idir.

randevu_hizmetleri = Table(
    "randevu_hizmetleri",
    Base.metadata,
    Column("randevu_id", Integer, ForeignKey("randevular.id", ondelete="CASCADE"), primary_key=True),
    Column("hizmet_id", Integer, ForeignKey("hizmetler.id"), primary_key=True),
)

favori_berberler = Table(
    "favori_berberler",
    Base.metadata,
    Column("musteri_id", Integer, ForeignKey("musteriler.id", ondelete="CASCADE"), primary_key=True),
    Column("berber_id", Integer, ForeignKey("berberler.id", ondelete="CASCADE"), primary_key=True),
)

RANDEVU_DURUMLARI = ("onaylandi", "tamamlandi", "iptal", "gelmedi")
AKTIF_DURUMLAR = ("onaylandi",)  # takvimde yer kaplayan durumlar


class Salon(Base):
    __tablename__ = "salonlar"

    id = Column(Integer, primary_key=True, index=True)
    ad = Column(String, nullable=False)
    adres = Column(String)
    telefon = Column(String)
    foto_url = Column(String, nullable=True)
    instagram_url = Column(String, nullable=True)
    whatsapp = Column(String, nullable=True)
    konum_lat = Column(Float, nullable=True)
    konum_long = Column(Float, nullable=True)
    sehir = Column(String, nullable=True, index=True)
    ilce = Column(String, nullable=True)
    # Pazartesi–Cumartesi
    acilis_saati = Column(String, default="09:00", nullable=False)
    kapanis_saati = Column(String, default="20:00", nullable=False)
    # Pazar
    pazar_acilis_saati = Column(String, default="10:00", nullable=False)
    pazar_kapanis_saati = Column(String, default="17:00", nullable=False)
    # Haftalık kapalı günler: virgülle ayrılmış weekday indeksleri (0=Pzt … 6=Paz). Örn: "6"
    kapali_gunler = Column(String, default="", nullable=False)
    # Günlük öğle arası (tüm personel için, "HH:MM"); ikisi de boşsa mola yok
    mola_baslangic = Column(String, nullable=True)
    mola_bitis = Column(String, nullable=True)
    puan = Column(Float, default=5.0)
    aktif = Column(Boolean, default=True, nullable=False)

    berberler = relationship("Berber", back_populates="salon")
    randevular = relationship("Randevu", back_populates="salon")
    fotograflar = relationship("SalonFotograf", back_populates="salon")


class Berber(Base):
    __tablename__ = "berberler"
    id = Column(Integer, primary_key=True, index=True)
    ad = Column(String, nullable=False)
    soyad = Column(String, default="")
    uzmanlik = Column(String, default="")
    foto_url = Column(String, nullable=True)
    puan = Column(Float, default=5.0)
    salon_id = Column(Integer, ForeignKey("salonlar.id"), index=True)
    whatsapp_no = Column(String, nullable=True)
    instagram_username = Column(String, nullable=True)
    # Personel kendi hesabıyla giriş yaparsa bağlanır (rol: personel).
    # İşletme e-postayı girer; personel bu e-postayla ilk girişte otomatik eşleşir.
    email = Column(String, nullable=True, index=True)
    firebase_uid = Column(String, unique=True, nullable=True, index=True)
    aktif = Column(Boolean, default=True, nullable=False)
    # Berberin haftalık izin günleri (salonunki gibi: "0"=Pzt … "6"=Paz, virgülle). Salon açık olsa da çalışmaz.
    kapali_gunler = Column(String, default="", nullable=False, server_default="")

    salon = relationship("Salon", back_populates="berberler")


class Musteri(Base):
    __tablename__ = "musteriler"
    id = Column(Integer, primary_key=True, index=True)
    firebase_uid = Column(String, unique=True, index=True, nullable=True)  # silinen hesapta NULL
    ad = Column(String, default="")
    soyad = Column(String, default="")
    telefon = Column(String, default="")
    fcm_token = Column(String, nullable=True)
    favori_berber_id = Column(Integer, ForeignKey("berberler.id"), nullable=True)  # eski tekli favori
    # KVKK
    kvkk_onay_tarihi = Column(String, nullable=True)
    ticari_ileti_izni = Column(Boolean, default=False, nullable=False)
    silindi = Column(Boolean, default=False, nullable=False)
    olusturma = Column(String, nullable=True)

    favori_berberler = relationship("Berber", secondary=favori_berberler)


class Hizmet(Base):
    __tablename__ = "hizmetler"
    id = Column(Integer, primary_key=True, index=True)
    # NULL = tüm salonlarda geçerli ortak hizmet (eski veriyle uyumluluk)
    salon_id = Column(Integer, ForeignKey("salonlar.id"), nullable=True, index=True)
    ad = Column(String, nullable=False)
    fiyat = Column(Float, nullable=False)
    sure = Column(Integer, nullable=False)  # dakika
    aciklama = Column(String, nullable=True)
    aktif = Column(Boolean, default=True, nullable=False)


class Dukkan(Base):
    """Tek-dükkan dönemi kaydı (geriye uyumluluk). Yeni kod Salon kullanır."""
    __tablename__ = "dukkan_bilgileri"
    id = Column(Integer, primary_key=True, index=True)
    ad = Column(String)
    adres = Column(String)
    telefon = Column(String)
    email = Column(String, nullable=True)
    instagram = Column(String, nullable=True)
    harita_konum = Column(String)
    haftaici_kapanis = Column(String, default="22:00")
    pazar_kapanis = Column(String, default="17:00")


class Randevu(Base):
    __tablename__ = "randevular"
    __table_args__ = (
        # Slot sorgusu: berberin o günkü aktif randevuları
        Index("ix_randevu_berber_tarih_durum", "berber_id", "tarih", "durum"),
        # İşletme paneli (günün akışı, rapor)
        Index("ix_randevu_salon_tarih", "salon_id", "tarih"),
        # Müşterinin randevuları
        Index("ix_randevu_musteri_tarih", "musteri_id", "tarih"),
        # Son savunma hattı: aynı berbere aynı başlangıç saatinde iki aktif randevu olamaz
        # (asıl koruma slot_servisi'ndeki satır kilidi; bu indeks kilit atlansa bile çift kaydı DB'de engeller)
        Index("uq_randevu_aktif_slot", "berber_id", "tarih", "saat", unique=True,
              postgresql_where=text("durum = 'onaylandi'"), sqlite_where=text("durum = 'onaylandi'")),
    )
    id = Column(Integer, primary_key=True, index=True)
    musteri_id = Column(Integer, ForeignKey("musteriler.id"), index=True)
    berber_id = Column(Integer, ForeignKey("berberler.id"), index=True)
    salon_id = Column(Integer, ForeignKey("salonlar.id"), index=True)
    tarih = Column(String, index=True)
    saat = Column(String)
    # Randevu anındaki toplam hizmet süresi (dk). Hizmet süresi sonradan değişse de takvim kaymaz.
    sure_dk = Column(Integer, nullable=False, default=30)
    durum = Column(String, default="onaylandi", nullable=False, index=True)
    toplam_fiyat = Column(Float)  # randevu anında mühürlenen fiyat
    hatirlatma_gonderildi = Column(Boolean, default=False)
    degerlendirme_bildirimi_gonderildi = Column(Boolean, default=False)
    puan = Column(Integer, nullable=True)
    yorum = Column(Text, nullable=True)
    olusturma = Column(String, nullable=True)
    iptal_eden = Column(String, nullable=True)  # musteri | isletme
    iptal_zamani = Column(String, nullable=True)
    kaynak = Column(String, default="uygulama")  # uygulama | panel
    # Müşterinin kaç kez ertelediği (sınır: ERTELEME_LIMITI)
    erteleme_sayisi = Column(Integer, default=0, nullable=False, server_default="0")
    notlar = Column(String, nullable=True)

    musteri = relationship("Musteri")
    berber = relationship("Berber")
    salon = relationship("Salon", back_populates="randevular")
    hizmetler = relationship("Hizmet", secondary=randevu_hizmetleri)


class Degerlendirme(Base):
    __tablename__ = "degerlendirmeler"
    id = Column(Integer, primary_key=True, index=True)
    musteri_id = Column(Integer, ForeignKey("musteriler.id"))
    berber_id = Column(Integer, ForeignKey("berberler.id"), index=True)
    salon_id = Column(Integer, ForeignKey("salonlar.id"), nullable=True, index=True)
    randevu_id = Column(Integer, ForeignKey("randevular.id"), unique=True)
    puan = Column(Integer)
    yorum = Column(String, nullable=True)
    tarih = Column(String)

    musteri = relationship("Musteri")
    berber = relationship("Berber")


class TatilGunu(Base):
    __tablename__ = "tatil_gunleri"
    __table_args__ = (UniqueConstraint("salon_id", "tarih", name="uq_tatil_salon_tarih"),)
    id = Column(Integer, primary_key=True, index=True)
    salon_id = Column(Integer, ForeignKey("salonlar.id"), nullable=True, index=True)  # NULL = tüm salonlar
    tarih = Column(String, index=True, nullable=False)
    aciklama = Column(String, nullable=True)


class BerberIzin(Base):
    __tablename__ = "berber_izinler"
    __table_args__ = (UniqueConstraint("berber_id", "tarih", name="uq_izin_berber_tarih"),)
    id = Column(Integer, primary_key=True, index=True)
    berber_id = Column(Integer, ForeignKey("berberler.id"), index=True)
    tarih = Column(String, nullable=False)
    aciklama = Column(String, nullable=True)

    berber = relationship("Berber")


class SaatBloke(Base):
    """Berberin belirli bir gündeki kısmi kapalılığı ("14:00–16:00 dışarıdayım"). Tam gün için BerberIzin kullanılır."""
    __tablename__ = "saat_blokeleri"
    __table_args__ = (Index("ix_bloke_berber_tarih", "berber_id", "tarih"),)
    id = Column(Integer, primary_key=True, index=True)
    berber_id = Column(Integer, ForeignKey("berberler.id"), nullable=False)
    tarih = Column(String, nullable=False)
    bas_saat = Column(String, nullable=False)
    bit_saat = Column(String, nullable=False)
    aciklama = Column(String, nullable=True)

    berber = relationship("Berber")


class Isletme(Base):
    """İşletme sahibi hesabı. Admin onayından sonra bir salona bağlanır."""
    __tablename__ = "isletmeler"
    id = Column(Integer, primary_key=True, index=True)
    firebase_uid = Column(String, unique=True, index=True)
    ad = Column(String)
    soyad = Column(String)
    telefon = Column(String)
    email = Column(String)
    isletme_adi = Column(String)
    durum = Column(String, default="beklemede")  # beklemede / onaylandi / reddedildi
    salon_id = Column(Integer, ForeignKey("salonlar.id"), nullable=True)
    olusturma = Column(String, nullable=True)

    salon = relationship("Salon")


class SalonFotograf(Base):
    __tablename__ = "salon_fotograflari"
    id = Column(Integer, primary_key=True, index=True)
    salon_id = Column(Integer, ForeignKey("salonlar.id"))
    foto_url = Column(String)
    sira = Column(Integer, default=0)

    salon = relationship("Salon", back_populates="fotograflar")


class BeklemeListesi(Base):
    """Dolu bir gün için 'boşalırsa haber ver' kaydı."""
    __tablename__ = "bekleme_listesi"
    __table_args__ = (UniqueConstraint("musteri_id", "berber_id", "tarih", name="uq_bekleme"),)
    id = Column(Integer, primary_key=True, index=True)
    musteri_id = Column(Integer, ForeignKey("musteriler.id", ondelete="CASCADE"), index=True)
    berber_id = Column(Integer, ForeignKey("berberler.id"), index=True)
    salon_id = Column(Integer, ForeignKey("salonlar.id"))
    tarih = Column(String, nullable=False, index=True)
    sure_dk = Column(Integer, nullable=False, default=30)
    olusturma = Column(String, nullable=True)
    bildirildi = Column(Boolean, default=False, nullable=False)

    musteri = relationship("Musteri")
    berber = relationship("Berber")


class Yonetici(Base):
    """Admin hesapları (ADMIN_UIDS ortam değişkenine ek). `python araclar.py admin-ekle <e-posta>` ile eklenir."""
    __tablename__ = "yoneticiler"
    firebase_uid = Column(String, primary_key=True)
    email = Column(String, nullable=True)
    olusturma = Column(String, nullable=True)


class GorevKilidi(Base):
    """Zamanlanmış görevlerin aynı anda yalnızca bir süreçte çalışmasını sağlayan kiralama (lease) kaydı."""
    __tablename__ = "gorev_kilitleri"
    ad = Column(String, primary_key=True)
    sahip = Column(String, nullable=True)
    bitis = Column(String, nullable=True)  # ISO zaman; geçmişteyse kilit boştur


class IdempotencyAnahtari(Base):
    """Aynı isteğin (çift tıklama, ağ tekrarı) ikinci kez işlenmemesi için: anahtar → ilk yanıt."""
    __tablename__ = "idempotency_anahtarlari"
    anahtar = Column(String, primary_key=True)
    kullanici = Column(String, nullable=False)
    yanit = Column(Text, nullable=False)
    olusturma = Column(String, nullable=False, index=True)


class HesapSilmeTalebi(Base):
    """Uygulamaya erişemeyen kullanıcının web formundan ilettiği hesap silme talebi (Google Play şartı)."""
    __tablename__ = "hesap_silme_talepleri"
    id = Column(Integer, primary_key=True)
    email = Column(String, nullable=False, index=True)
    aciklama = Column(String, nullable=True)
    olusturma = Column(String, nullable=False)
    durum = Column(String, default="bekliyor", nullable=False)  # bekliyor | tamamlandi
