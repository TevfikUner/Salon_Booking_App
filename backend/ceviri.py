"""İngilizce arayüz için sunucu mesajlarının çevirisi.

Uygulama `Accept-Language: en` gönderirse JSON yanıtlarındaki kullanıcıya görünen alanlar (`detail`, `mesaj`,
`uyari`, `kapali_neden`, `indirim_aciklama`) bu katalogla İngilizceye çevrilir; diğer her dilde Türkçe kalır.
Kod Türkçe mesaj üretmeye devam eder: çeviri tek noktada (DilAraKatmani) yapılır, yeni mesaj eklenince buraya
eklenmezse Türkçe görünür (kırılma yok). Push bildirimleri ve yasal metinler Türkçedir.
"""
import json
import re
from contextvars import ContextVar

_dil: ContextVar[str] = ContextVar("dil", default="tr")

CEVRILEN_ALANLAR = {"detail", "mesaj", "uyari", "kapali_neden", "indirim_aciklama"}


def dil() -> str:
    return _dil.get()


def ingilizce() -> bool:
    return _dil.get() == "en"


def dil_coz(accept_language: str | None) -> str:
    return "en" if (accept_language or "").strip().lower().startswith("en") else "tr"


SABIT = {
    # kimlik / yetki
    "Admin için salon_id parametresi gerekli.": "salon_id is required for admins.",
    "Bu ekran yalnızca işletmeler içindir.": "This screen is for businesses only.",
    "Bu işlem için işletme sahibi yetkisi gerekiyor.": "This action requires business owner access.",
    "Bu işlem için yönetici yetkisi gerekiyor.": "This action requires admin access.",
    "Bu salona erişim yetkiniz yok.": "You don't have access to this salon.",
    "Geçersiz oturum anahtarı.": "Invalid session token.",
    "Giriş yapmanız gerekiyor.": "Please sign in.",
    "Kimlik doğrulama servisi yapılandırılmamış.": "The authentication service isn't configured.",
    "Müşteri kaydı bulunamadı.": "Customer record not found.",
    "Oturum süresi doldu veya geçersiz. Lütfen tekrar giriş yapın.": "Your session has expired. Please sign in again.",
    "İşletme başvurunuz henüz onaylanmadı.": "Your business application hasn't been approved yet.",
    "İşletmenize henüz bir salon bağlanmadı.": "No salon has been linked to your business yet.",
    "İsteğiniz zaten işleniyor, lütfen bekleyin.": "Your request is already being processed, please wait.",
    "Oturum gerekli.": "Please sign in.",
    "Bu hesap silinmiş.": "This account has been deleted.",
    # genel
    "Hizmet geçici olarak kullanılamıyor. Lütfen birazdan tekrar deneyin.":
        "The service is temporarily unavailable. Please try again shortly.",
    "Girilen bilgileri kontrol edin.": "Please check the information you entered.",
    "Çok fazla istek gönderdiniz. Lütfen biraz bekleyip tekrar deneyin.": "Too many requests. Please wait and try again.",
    "İstek çok büyük.": "The request is too large.",
    "Tarih formatı hatalı. Doğru format: YYYY-MM-DD": "Invalid date format. Use YYYY-MM-DD.",
    "Geçersiz saat formatı. Örnek: 14:30": "Invalid time format. Example: 14:30",
    "berber_id veya salon_id gerekli.": "berber_id or salon_id is required.",
    # bulunamadı
    "Berber bulunamadı.": "Barber not found.",
    "Randevu bulunamadı.": "Appointment not found.",
    "Salon bulunamadı.": "Salon not found.",
    "Personel bulunamadı.": "Staff member not found.",
    "Hizmet bulunamadı.": "Service not found.",
    "Kampanya bulunamadı.": "Campaign not found.",
    "Kayıt bulunamadı.": "Record not found.",
    "Müşteri bulunamadı.": "Customer not found.",
    "Başvuru bulunamadı.": "Application not found.",
    "İşletme başvurusu bulunamadı.": "Business application not found.",
    "İzin kaydı bulunamadı.": "Day-off record not found.",
    # randevu kuralları
    "Bu randevu size ait değil.": "This appointment isn't yours.",
    "Bu randevu zaten aktif değil.": "This appointment is no longer active.",
    "Randevunuz zaten bu gün ve saatte.": "Your appointment is already at this day and time.",
    "Randevu zaten bu saatte.": "The appointment is already at this time.",
    "Yalnızca aktif randevular taşınabilir.": "Only active appointments can be moved.",
    "Başlamış veya geçmiş bir randevu taşınamaz.": "An appointment that has started or passed can't be moved.",
    "Bu personel artık randevu almıyor.": "This staff member no longer takes bookings.",
    "Yalnızca alınmış veya tamamlanmış bir randevu tekrarlanabilir.": "Only booked or completed appointments can be repeated.",
    "Geçersiz durum.": "Invalid status.",
    "Henüz başlamamış bir randevu bu şekilde işaretlenemez.": "An appointment that hasn't started can't be marked this way.",
    "Randevu bu personele ait değil.": "The appointment doesn't belong to this staff member.",
    "Yalnızca kendi takviminizi görebilirsiniz.": "You can only see your own calendar.",
    "Yalnızca kendi randevularınızı yönetebilirsiniz.": "You can only manage your own appointments.",
    "Randevuyu yalnızca kendi takviminizde taşıyabilirsiniz.": "You can only move appointments within your own calendar.",
    "Randevu yalnızca aynı salondaki personele taşınabilir.": "An appointment can only be moved to staff in the same salon.",
    "En az bir hizmet seçmelisiniz.": "Please choose at least one service.",
    "Seçilen hizmetlerden biri bu salonda bulunmuyor.": "One of the selected services isn't offered by this salon.",
    "Geçmiş bir tarihe randevu alınamaz.": "You can't book a past date.",
    "Salon bu gün kapalı.": "The salon is closed on this day.",
    "Seçilen personel bu gün izinli.": "The selected staff member is off on this day.",
    "Seçilen personel bu gün çalışmıyor.": "The selected staff member doesn't work on this day.",
    # değerlendirme
    "Bu randevuyu zaten değerlendirdiniz.": "You've already reviewed this appointment.",
    "Puan 1 ile 5 arasında olmalı.": "The rating must be between 1 and 5.",
    "Sadece tamamlanan randevuları değerlendirebilirsiniz.": "You can only review completed appointments.",
    "Değerlendirmeniz için teşekkürler!": "Thank you for your review!",
    # müşteri
    "Devam etmek için KVKK Aydınlatma Metni'ni onaylamalısınız.": "To continue, please accept the Privacy Notice (KVKK).",
    "Cihaz bildirimlere kaydedildi.": "Device registered for notifications.",
    "Hesabınız ve kişisel verileriniz silindi.": "Your account and personal data have been deleted.",
    "Kayıt tamamlandı.": "Registration complete.",
    "Profil güncellendi.": "Profile updated.",
    "Profil başarıyla güncellendi": "Profile updated.",
    "Müşteri kaydedildi.": "Customer saved.",
    "Randevu başarıyla alındı!": "Appointment booked!",
    "Randevunuz ertelendi.": "Your appointment has been rescheduled.",
    "Randevunuz iptal edildi.": "Your appointment has been cancelled.",
    "Bu günde yer açılırsa size hemen bildirim göndereceğiz.": "We'll notify you right away if a spot opens on this day.",
    # işletme
    "Bu hesapla zaten bir işletme başvurusu var.": "There's already a business application for this account.",
    "İşletme başvurunuz alındı! Onay bekleniyor.": "Your business application was received! Awaiting approval.",
    "Bitiş saati başlangıçtan sonra olmalı.": "The end time must be after the start time.",
    "Bu gün zaten kapalı olarak işaretli.": "This day is already marked as closed.",
    "Bu personel için randevu ekleyemezsiniz.": "You can't add appointments for this staff member.",
    "Bu personel sizin salonunuzda değil.": "This staff member isn't in your salon.",
    "Geçmiş bir güne bloke eklenemez.": "You can't block hours on a past day.",
    "Hizmet bu salonun menüsünde yok.": "The service isn't on this salon's menu.",
    "Personel en az bir hizmet vermeli.": "Staff must offer at least one service.",
    "Seçilen hizmetlerden biri menüde yok.": "One of the selected services isn't on the menu.",
    "Bloke kaldırıldı.": "Blocked hours removed.",
    "Kapalı gün eklendi.": "Closure added.",
    "Kapalı gün kaldırıldı.": "Closure removed.",
    "Not kaydedildi.": "Note saved.",
    "Not silindi.": "Note deleted.",
    "Randevu eklendi.": "Appointment added.",
    "Randevu güncellendi.": "Appointment updated.",
    "Randevu taşındı.": "Appointment moved.",
    "İzin kaldırıldı.": "Day off removed.",
}

# Değişken içeren mesajlar: (desen, İngilizce şablon — \1, \2 grup başvuruları)
DESENLER = [
    (r"Bir randevu en fazla (\d+) kez ertelenebilir\. İptal edip yeni randevu alabilirsiniz\.",
     r"An appointment can be rescheduled at most \1 times. You can cancel and book a new one."),
    (r"Geçmiş bir randevu iptal edilemez\.", "A past appointment can't be cancelled."),
    (r"Geçmiş bir randevu ertelenemez\.", "A past appointment can't be rescheduled."),
    (r"Randevuya (\d+) dakikadan az kaldığı için iptal edilemez\. Lütfen salonu arayın\.",
     r"Less than \1 minutes left, so it can't be cancelled. Please call the salon."),
    (r"Randevuya (\d+) dakikadan az kaldığı için ertelenemez\. Lütfen salonu arayın\.",
     r"Less than \1 minutes left, so it can't be rescheduled. Please call the salon."),
    (r"Seçilen personel şu hizmeti vermiyor: (.+)\.", r"The selected staff member doesn't offer: \1."),
    (r"(.+) şu hizmeti vermiyor: (.+)\.", r"\1 doesn't offer: \2."),
    (r"Seçtiğiniz saat \((.+)\) artık uygun değil\. Hizmet (\d+) dk sürüyor\.",
     r"The selected time (\1) is no longer available. The service takes \2 min."),
    (r"Seçtiğiniz saat \((.+)\) uygun değil\. Hizmet (\d+) dk sürüyor\.",
     r"The selected time (\1) isn't available. The service takes \2 min."),
    (r"En fazla (\d+) gün sonrasına randevu alınabilir\.", r"Bookings can be made at most \1 days ahead."),
    (r"Salon bu gün kapalı \((.+)\)\.", r"The salon is closed on this day (\1)."),
    (r"Bu personelin (\d+) aktif randevusu var\. Önce randevuları iptal edin veya taşıyın\.",
     r"This staff member has \1 active appointments. Cancel or move them first."),
    (r"(.+) zaten o gün izinli\.", r"\1 is already off that day."),
    (r"Bu günde (\d+) aktif randevu var; müşterilerinize haber verip iptal etmeyi unutmayın\.",
     r"There are \1 active appointments on this day; remember to notify your customers and cancel them."),
    (r"(.+) için (\d\d:\d\d)–(\d\d:\d\d) kapatıldı\.", r"\2–\3 blocked for \1."),
    (r"(.+) için izin eklendi\.", r"Day off added for \1."),
    (r"'(.+)' menüden kaldırıldı\.", r"'\1' removed from the menu."),
    (r"'(.+)' kaldırıldı\.", r"'\1' removed."),
    (r"(.+) kadrodan çıkarıldı\.", r"\1 removed from the team."),
    (r"(.+) favorilere eklendi!", r"\1 added to favourites!"),
    (r"(.+) favorilerden çıkarıldı\.", r"\1 removed from favourites."),
    (r"Sadakat kartı: (\d+)\. ziyaret %(\d+)", r"Loyalty card: visit \1, \2% off"),
    (r"(.+) %(\d+)", r"\1 \2% off"),
]
_DESENLER = [(re.compile(f"^{d}$"), s) for d, s in DESENLER]


def cevir(metin: str) -> str:
    """Türkçe sunucu mesajı → İngilizce (bilinmiyorsa olduğu gibi)."""
    if metin in SABIT:
        return SABIT[metin]
    for desen, sablon in _DESENLER:
        if desen.match(metin):
            return desen.sub(sablon, metin)
    return metin


def _yuru(veri, anahtar=None):
    if isinstance(veri, dict):
        return {k: _yuru(v, k) for k, v in veri.items()}
    if isinstance(veri, list):
        return [_yuru(v, anahtar) for v in veri]
    if isinstance(veri, str) and anahtar in CEVRILEN_ALANLAR:
        return cevir(veri)
    return veri


def json_cevir(govde: bytes) -> bytes:
    try:
        veri = json.loads(govde)
    except ValueError:
        return govde
    return json.dumps(_yuru(veri), ensure_ascii=False).encode("utf-8")


class DilAraKatmani:
    """Saf ASGI ara katmanı: dili istekten çözer (contextvar), İngilizcede JSON yanıt metinlerini çevirir."""

    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):
        if scope["type"] != "http":
            return await self.app(scope, receive, send)
        basliklar = dict(scope.get("headers") or [])
        secilen = dil_coz(basliklar.get(b"accept-language", b"").decode("latin-1"))
        belirtec = _dil.set(secilen)
        try:
            if secilen != "en":
                return await self.app(scope, receive, send)
            baslangic: dict = {}
            parcalar: list[bytes] = []

            async def gonder(mesaj):
                if mesaj["type"] == "http.response.start":
                    baslangic.update(mesaj)
                    return
                if mesaj["type"] == "http.response.body":
                    hdr = dict(baslangic.get("headers") or [])
                    if not hdr.get(b"content-type", b"").startswith(b"application/json"):
                        if baslangic:
                            await send(dict(baslangic))
                            baslangic.clear()
                        return await send(mesaj)
                    parcalar.append(mesaj.get("body", b""))
                    if mesaj.get("more_body"):
                        return
                    govde = json_cevir(b"".join(parcalar))
                    yeni = [(k, v) for k, v in baslangic.get("headers", []) if k != b"content-length"]
                    yeni.append((b"content-length", str(len(govde)).encode()))
                    await send({**baslangic, "headers": yeni})
                    await send({"type": "http.response.body", "body": govde})
                    return
                await send(mesaj)

            await self.app(scope, receive, gonder)
        finally:
            _dil.reset(belirtec)
