import 'package:berber_app_ui/core/dil.dart';

/// Sıkça Sorulan Sorular (uygulama diline göre)
class SSS {
  final String soru;
  final String cevap;
  const SSS({required this.soru, required this.cevap});

  static List<SSS> get sorular => Dil.ingilizce ? _en : _tr;

  static const _tr = [
    SSS(soru: 'Nasıl randevu alabilirim?', cevap: 'Ana sayfadaki "Randevu Al" düğmesine dokunup hizmet, personel, tarih ve saat seçin. Sık aldığınız hizmet "Her Zamanki" kartında en yakın boş saatlerle hazır gelir.'),
    SSS(soru: 'Randevumu nasıl erteler veya iptal ederim?', cevap: 'Randevularım sekmesinde randevunuzun altındaki "Ertele" ile başka bir gün/saate taşıyabilir (en fazla 2 kez) ya da "İptal Et" ile iptal edebilirsiniz. Randevuya 30 dakikadan az kaldıysa lütfen salonu arayın.'),
    SSS(soru: 'Kampanyalar ve sadakat kartı nasıl çalışır?', cevap: 'Salonun kampanyaları salon sayfasında yazar; indirimli saatler takvimde "%" ile işaretlidir. Sadakat kartı olan salonlarda belirli ziyaretiniz indirimlidir. İndirimler üst üste binmez; size en yüksek olanı uygulanır ve onay ekranında tutara yansır.'),
    SSS(soru: 'Favori berber nasıl seçilir?', cevap: 'Salon sayfasındaki ekip listesinde berberin yanındaki kalbe dokunun. Favorileriniz ana sayfada görünür, tek dokunuşla randevu alabilirsiniz.'),
    SSS(soru: 'Profil bilgilerimi nasıl güncellerim?', cevap: 'Profil sekmesindeki "Kişisel Bilgiler" bölümünden ad, soyad ve telefonunuzu güncelleyebilirsiniz.'),
    SSS(soru: 'Şifremi unuttum, ne yapmalıyım?', cevap: 'Giriş ekranındaki "Şifremi Unuttum" bağlantısına dokunun; e-posta adresinize sıfırlama bağlantısı gönderilir.'),
    SSS(soru: 'Uygulama hangi şehirlerde aktif?', cevap: 'Premium Berber Türkiye genelinde 81 ilde kullanılabilir. Keşfet sekmesinde şehir/ilçe seçerek, konumunuza göre veya salon ve hizmet adıyla arayabilirsiniz.'),
    SSS(soru: 'İşletme sahibi olarak nasıl kayıt olabilirim?', cevap: 'Giriş ekranında "İşletme Sahibi"ni seçip başvuru formunu doldurun. Başvurunuz onaylanınca paneliniz açılır.'),
    SSS(soru: 'Değerlendirme nasıl yapılır?', cevap: 'Tamamlanan randevunuzda "Hizmeti Değerlendir" düğmesine dokunup puan ve yorum bırakabilirsiniz.'),
  ];

  static const _en = [
    SSS(soru: 'How do I book an appointment?', cevap: 'Tap "Book Appointment" on the home screen and choose a service, staff member, date and time. Your usual service appears on the "Your Usual" card with the nearest free times.'),
    SSS(soru: 'How do I reschedule or cancel?', cevap: 'In My Appointments, use "Reschedule" to move it to another day/time (up to 2 times) or "Cancel". If the appointment starts in less than 30 minutes, please call the salon.'),
    SSS(soru: 'How do campaigns and loyalty cards work?', cevap: 'A salon\'s campaigns are listed on its page; discounted times are marked with "%" on the calendar. Salons with a loyalty card discount certain visits. Discounts don\'t stack; you get the highest one, shown on the confirmation screen.'),
    SSS(soru: 'How do I choose a favourite barber?', cevap: 'Tap the heart next to a barber in the salon\'s team list. Favourites appear on the home screen for one-tap booking.'),
    SSS(soru: 'How do I update my profile?', cevap: 'Update your first name, last name and phone in the "Personal Information" section of the Profile tab.'),
    SSS(soru: 'I forgot my password. What should I do?', cevap: 'Tap "Forgot Password" on the sign-in screen; we\'ll email you a reset link.'),
    SSS(soru: 'Which cities is the app available in?', cevap: 'Premium Berber is available in all 81 provinces of Türkiye. In Explore, filter by city/district, sort by your location or search by salon or service name.'),
    SSS(soru: 'How do I register as a business owner?', cevap: 'Choose "Business Owner" on the welcome screen and fill in the application. Your dashboard opens once approved.'),
    SSS(soru: 'How do I leave a review?', cevap: 'Tap "Rate Service" on a completed appointment to leave a rating and comment.'),
  ];
}
