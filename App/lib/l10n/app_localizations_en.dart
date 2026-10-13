// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get uygulamaAdi => 'Premium Berber';

  @override
  String get bugun => 'Today';

  @override
  String get yarin => 'Tomorrow';

  @override
  String get dun => 'Yesterday';

  @override
  String get ara => 'Search…';

  @override
  String get internetYok => 'No internet connection';

  @override
  String get yenidenDene => 'Try Again';

  @override
  String get zorunluAlan => 'Required';

  @override
  String get eposta => 'Email';

  @override
  String get gecerliEpostaGirin => 'Enter a valid email';

  @override
  String get cepTelefonu => 'Mobile Phone';

  @override
  String get telefonKurali => 'Enter 10 digits starting with 5';

  @override
  String get evet => 'Yes';

  @override
  String get vazgec => 'Cancel';

  @override
  String get hataOturumDogrulanamadi =>
      'Couldn\'t verify your session. Check your internet connection and try again.';

  @override
  String get hataSunucuYanitVermiyor =>
      'The server isn\'t responding. Check your internet connection and try again.';

  @override
  String get hataGuvenliBaglanti =>
      'Couldn\'t establish a secure connection. Please try again.';

  @override
  String get hataSunucuyaUlasilamadi =>
      'Couldn\'t reach the server. Check your internet connection.';

  @override
  String get hataIslemTamamlanamadi => 'The action couldn\'t be completed.';

  @override
  String get hataBilgileriKontrolEdin =>
      'Please check the information you entered.';

  @override
  String get hataCokFazlaDeneme => 'Too many attempts. Please wait a moment.';

  @override
  String get hataHizmetKullanilamiyor =>
      'The service is temporarily unavailable. Please try again shortly.';

  @override
  String get hataOturumSuresiDoldu =>
      'Your session has expired. Please sign in again.';

  @override
  String get hataYetkiYok => 'You don\'t have permission for this action.';

  @override
  String get hataKayitBulunamadi => 'Not found.';

  @override
  String hataSunucu(int kod) {
    return 'Server error ($kod). Please try again later.';
  }

  @override
  String get hataEpostaGecersiz => 'The email address is invalid.';

  @override
  String get hataEpostaSifreHatali => 'Incorrect email or password.';

  @override
  String get hataEpostaKullanimda =>
      'An account with this email already exists. Try signing in.';

  @override
  String get hataSifreZayif =>
      'The password is too weak. Use at least 6 characters.';

  @override
  String get hataCokFazlaDenemeYapildi =>
      'Too many attempts. Please try again later.';

  @override
  String get hataKimlikDogrulama => 'Authentication error.';

  @override
  String get puanla => 'Rate';

  @override
  String get ac => 'Open';

  @override
  String get berber => 'Barber';

  @override
  String get bolumGosterilemiyor =>
      'This section can\'t be shown right now.\nPlease go back and try again.';

  @override
  String get takvimeEkle => 'Add to Calendar';

  @override
  String get googleTakvim => 'Google Calendar';

  @override
  String get digerTakvimUygulamasi => 'Other calendar app (.ics)';

  @override
  String get digerTakvimOrnekleri =>
      'Samsung Calendar, Outlook, Apple Calendar…';

  @override
  String get takvimAcilamadi => 'Couldn\'t open the calendar.';

  @override
  String get berberRandevusu => 'Barber appointment';

  @override
  String sureDk(int dk) {
    return '$dk min';
  }

  @override
  String sureSa(int sa) {
    return '$sa h';
  }

  @override
  String sureSaDk(int sa, int dk) {
    return '$sa h $dk min';
  }

  @override
  String get kvkkOnaylamalisiniz =>
      'To continue, please accept the Privacy Notice (KVKK).';

  @override
  String girisBasarisiz(String neden) {
    return 'Sign-in failed: $neden';
  }

  @override
  String basvuruGonderilemedi(String neden) {
    return 'Couldn\'t send the application: $neden';
  }

  @override
  String kayitBasarisiz(String neden) {
    return 'Sign-up failed: $neden';
  }

  @override
  String sifreSifirlamaGonderildi(String eposta) {
    return 'A password reset link was sent to $eposta.';
  }

  @override
  String get hosGeldiniz => 'Welcome';

  @override
  String get randevunuzSiziBekliyor => 'Your appointment awaits';

  @override
  String get sifremiUnuttum => 'Forgot Password';

  @override
  String get girisYap => 'Sign In';

  @override
  String get hesabinizYokMu => 'Don\'t have an account?';

  @override
  String get kayitOlun => 'Sign Up';

  @override
  String get isletmeBasvurusu => 'Business Application';

  @override
  String get salonunuzuKaydedin =>
      'Register your salon; your dashboard opens once approved';

  @override
  String get isletmeSalonAdi => 'Business / Salon Name';

  @override
  String get ad => 'First name';

  @override
  String get soyad => 'Last name';

  @override
  String get kvkkOkudumKabul =>
      'I have read and accept the Privacy Notice (KVKK). (Required)';

  @override
  String get basvuruyuGonder => 'Submit Application';

  @override
  String get isletmeHesabinizVarMi => 'Already have a business account?';

  @override
  String get girisYapin => 'Sign In';

  @override
  String get hesapOlustur => 'Create Account';

  @override
  String get birkacAdimdaRandevu => 'Start booking in a few steps';

  @override
  String get kvkkMusteriOnay =>
      'I have read the Privacy Notice (KVKK) and consent to the processing of my personal data for the booking service. (Required)';

  @override
  String get ticariIletiOnay =>
      'I\'d like to receive commercial electronic messages about campaigns and offers. (Optional)';

  @override
  String get kayitOl => 'Sign Up';

  @override
  String get rolunuzuSecin => 'Choose your role to continue';

  @override
  String get musteri => 'Customer';

  @override
  String get musteriRolAciklama =>
      'Book appointments, find barbers\nand enjoy their services';

  @override
  String get isletmeSahibi => 'Business Owner';

  @override
  String get isletmeRolAciklama =>
      'Register your salon\nand manage your customers';

  @override
  String get zatenHesabinizVarMi => 'Already have an account?';

  @override
  String get guvensizYapilandirma =>
      'The app isn\'t configured to connect to a secure server. Please update the app.';

  @override
  String get premiumBerberHizmetleri => 'Premium Barber Services';

  @override
  String get geri => 'Back';

  @override
  String get logoEtiketi => 'Premium Berber logo';

  @override
  String get sifre => 'Password';

  @override
  String get sifreyiGoster => 'Show password';

  @override
  String get sifreyiGizle => 'Hide password';

  @override
  String get enAz6Karakter => 'At least 6 characters';

  @override
  String get metniOku => 'Read';

  @override
  String get sifreSifirlamaAciklama =>
      'Enter your email and we\'ll send you a password reset link.';

  @override
  String get iptal => 'Cancel';

  @override
  String get gonder => 'Send';

  @override
  String get yardimDestek => 'Help & Support';

  @override
  String get sss => 'FAQ';

  @override
  String get bizeUlasin => 'Contact Us';

  @override
  String get tarayicidaAc => 'Open in browser';

  @override
  String get yasalMetinTurkce =>
      'This legal text is provided in Turkish, which is the legally binding version.';

  @override
  String get konuRandevu => 'Appointment Issue';

  @override
  String get konuOdeme => 'Payment / Price';

  @override
  String get konuHesap => 'Account Problem';

  @override
  String get konuHata => 'App Error';

  @override
  String get konuOneri => 'Suggestion / Request';

  @override
  String get konuDiger => 'Other';

  @override
  String get fotografCek => 'Take Photo';

  @override
  String get galeridenSec => 'Choose from Gallery';

  @override
  String get dosyaSec => 'Choose File';

  @override
  String get konuSecin => 'Please choose a topic.';

  @override
  String get mesajYazin => 'Please write your message.';

  @override
  String get sorununuzuBildirin =>
      'Tell us about your issue and we\'ll get back to you as soon as possible.';

  @override
  String get konu => 'Topic';

  @override
  String get mesajiniz => 'Your message';

  @override
  String get mesajIpucu => 'Describe your issue or request…';

  @override
  String get ekEkle => 'Attach photo or file';

  @override
  String get ekiKaldir => 'Remove attachment';

  @override
  String get epostaGonder => 'Send Email';

  @override
  String get eklerleGonder => 'Send with Attachments';

  @override
  String epostaAcilamadi(String eposta) {
    return 'Couldn\'t open your email app. You can reach us at $eposta.';
  }

  @override
  String alici(String eposta) {
    return 'To: $eposta';
  }

  @override
  String get yeni => 'New';

  @override
  String get sehirSecin => 'Select City';

  @override
  String get ilceSecin => 'Select District';

  @override
  String get filtreleriTemizle => 'Clear filters';

  @override
  String get salonBulunamadi => 'No salons found';

  @override
  String get farkliKelimeDeneyin =>
      'Try a different word or clear the filters.';

  @override
  String get kesfet => 'Explore';

  @override
  String aramaSonucYok(String aranan) {
    return 'No results for \"$aranan\"';
  }

  @override
  String get konumServisiKapali =>
      'Location services are off. Please turn them on in your device settings.';

  @override
  String get konumIzniKaliciRed =>
      'Location permission was permanently denied. You can allow it in Settings.';

  @override
  String get konumIzniGerekli =>
      'Location permission is needed to show nearby salons.';

  @override
  String get konumAlinamadi => 'Couldn\'t get your location. Please try again.';

  @override
  String get salon => 'Salon';

  @override
  String get randevuAl => 'Book Appointment';

  @override
  String get kampanyalar => 'Campaigns';

  @override
  String get sadakatKartiBaslik => 'Loyalty Card';

  @override
  String get ekibimiz => 'Our Team';

  @override
  String get degerlendirmeler => 'Reviews';

  @override
  String get bugunkuDurum => 'Today';

  @override
  String get calismaSaatleri => 'Opening Hours';

  @override
  String favorilereEklendi(String ad) {
    return '$ad added to favourites.';
  }

  @override
  String favorilerdenCikarildi(String ad) {
    return '$ad removed from favourites.';
  }

  @override
  String get henuzDegerlendirmeYok => 'No reviews yet.';

  @override
  String get favorilerdenCikar => 'Remove from favourites';

  @override
  String get favorilereEkle => 'Add to favourites';

  @override
  String get randevu => 'Book';

  @override
  String trasSayisi(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n haircuts',
      one: '1 haircut',
    );
    return '$_temp0';
  }

  @override
  String get uygulamaAcilamadi => 'Couldn\'t open the app.';

  @override
  String get harita => 'Map';

  @override
  String get yolTarifi => 'Directions';

  @override
  String get indirimOnaydaYansir =>
      'The discount is applied on the confirmation screen when you pick an eligible day and time.';

  @override
  String get sadakatGirisYap => 'Sign in to see your visits counted here.';

  @override
  String yuzde(int y) {
    return '$y%';
  }

  @override
  String sadakatKurali(int esik, int yuzde) {
    return 'Every visit no. $esik is $yuzde% off';
  }

  @override
  String sadakatDamga(int esik, int n) {
    return '$n of $esik visits done';
  }

  @override
  String sadakatSiradaki(int yuzde) {
    return 'Your next appointment is $yuzde% off! 🎉';
  }

  @override
  String sadakatKalan(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'You\'ll earn a discount after $n more visits.',
      one: 'You\'ll earn a discount after 1 more visit.',
    );
    return '$_temp0';
  }

  @override
  String get yakindanUzaga => 'Sorted nearest first';

  @override
  String get konumumaYakin => 'Salons Near Me';

  @override
  String get salonAramaIpucu =>
      'Search salon, district or service (e.g. beard)';

  @override
  String get aramayiTemizle => 'Clear search';

  @override
  String get yuksekPuanIpucu => 'Only salons rated 4.5 and above';

  @override
  String get bugunkuRandevu => 'Today\'s\nBookings';

  @override
  String get bosKontenjan => 'Free\nSlots';

  @override
  String get doluluk => 'Occupancy';

  @override
  String get salonBugunKapali => 'The salon is closed today or fully booked.';

  @override
  String get kapali => 'Closed';

  @override
  String get bugunKapali => 'Closed today';

  @override
  String get sadakatKarti => 'Loyalty card';

  @override
  String salonSemantik(String ad, String konum, String puan) {
    return '$ad, $konum, rating $puan';
  }

  @override
  String bugunSaat(String saat) {
    return 'Today $saat';
  }

  @override
  String varanIndirim(int yuzde, String ek) {
    return 'Up to $yuzde% off';
  }

  @override
  String get anonim => 'Anonymous';

  @override
  String degerlendirmeSayisi(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n reviews',
      one: '1 review',
    );
    return '$_temp0';
  }

  @override
  String yildizSemantik(int n) {
    return '$n out of 5 stars';
  }

  @override
  String get degerlendirmelerYuklenemedi => 'Couldn\'t load reviews.';

  @override
  String get tekrar => 'Retry';

  @override
  String get ilkYorumuSizYapin =>
      'No reviews yet. You can leave the first one after your appointment.';

  @override
  String tumunuGor(int n) {
    return 'See all ($n)';
  }

  @override
  String get tarih => 'Date';

  @override
  String get saat => 'Time';

  @override
  String get personel => 'Staff';

  @override
  String get hizmetler => 'Services';

  @override
  String takvimAciklama(String berber, String toplam) {
    return 'Barber: $berber\nTotal: $toplam';
  }

  @override
  String get randevunuzOnaylandi => 'Appointment Confirmed!';

  @override
  String get siziBekliyoruz => 'See you soon 💈';

  @override
  String get birSaatOnceHatirlatma =>
      'You\'ll get a reminder notification 1 hour before.';

  @override
  String get anaSayfayaDon => 'Back to Home';

  @override
  String get randevularimiGor => 'View My Appointments';

  @override
  String get hizmetSecin => 'Choose Services';

  @override
  String get personelSecin => 'Choose Staff';

  @override
  String get tarihSecin => 'Choose Date';

  @override
  String get saatSecin => 'Choose Time';

  @override
  String get bilgileriniz => 'Your Details';

  @override
  String get enAzBirHizmet => 'Please choose at least one service';

  @override
  String get lutfenTarih => 'Please choose a date';

  @override
  String get lutfenSaat => 'Please choose a time';

  @override
  String get lutfenPersonel => 'Please choose a staff member';

  @override
  String get ileri => 'Next →';

  @override
  String adim(int n, int toplam) {
    return 'Step $n of $toplam';
  }

  @override
  String get menuYok => 'This salon hasn\'t added its service menu yet.';

  @override
  String get fiyatPersoneleGore => 'Price and duration vary by staff';

  @override
  String get kesinSurePersonelle => 'Exact duration once you pick staff';

  @override
  String sureAraligi(int min, int max) {
    return '$min–$max min';
  }

  @override
  String hizmetSecildi(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n services selected',
      one: '1 service selected',
    );
    return '$_temp0';
  }

  @override
  String get personelYok => 'This salon has no staff yet.';

  @override
  String vermiyor(String hizmetler) {
    return 'Doesn\'t offer: $hizmetler';
  }

  @override
  String get ay => 'Month';

  @override
  String get kapaliGunlerOtomatik =>
      'Days the salon is closed and staff days off are unavailable automatically.';

  @override
  String gunKampanyasi(int yuzde, String ek) {
    return 'Up to $yuzde% off on this day; discounted times are marked in the next step.';
  }

  @override
  String get musait => 'Available';

  @override
  String get dolu => 'Booked';

  @override
  String get yerAcilirsaBildirim =>
      'We\'ll notify you right away if a spot opens up on this day.';

  @override
  String get onceTarihSecin => 'Please choose a date first.';

  @override
  String get bosSaatKalmadi =>
      'No free times left on this day for the selected services.';

  @override
  String get beklemeListesindesiniz => 'You\'re on the waitlist';

  @override
  String get yerAcilirsaHaberVer => 'Notify me if a spot opens';

  @override
  String get enYakinBosSaatler => 'Nearest free times';

  @override
  String toplamSureAciklama(String sure) {
    return 'Total duration: $sure — only times that fit the whole service are available.';
  }

  @override
  String enAzOnceden(String sure) {
    return 'This salon takes bookings at least $sure ahead.';
  }

  @override
  String gunSayisi(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get tumAdimlariTamamlayin => 'Please complete all steps.';

  @override
  String get sure => 'Duration';

  @override
  String get iletisimBilgileriniz => 'Your Contact Details';

  @override
  String get randevumuOnayla => 'Confirm Appointment';

  @override
  String uygunSaatler(String saatler) {
    return 'Available times: $saatler';
  }

  @override
  String get bildirimlerKapali => 'Notifications are off';

  @override
  String get hatirlatalimMi => 'Shall we remind you 1 hour before?';

  @override
  String get bildirimKapaliAciklama =>
      'You won\'t get reminders or \"spot opened\" alerts. To turn them on: Phone Settings › Apps › Premium Berber › Notifications.';

  @override
  String get bildirimIzniAciklama =>
      'We\'ll send reminders, salon changes and waitlist openings. No ads.';

  @override
  String get tamam => 'OK';

  @override
  String get simdiDegil => 'Not now';

  @override
  String get evetHatirlat => 'Yes, remind me';

  @override
  String get listeFiyati => 'List price';

  @override
  String get indirim => 'Discount';

  @override
  String get toplam => 'Total';

  @override
  String yuzdeIndirim(int y) {
    return '$y% off';
  }

  @override
  String get gunDoluAciklama =>
      'This day is full. In the next step you can join the waitlist or pick the nearest free time.';

  @override
  String get azYer => 'Few left';

  @override
  String get kampanyali => 'Discounted';

  @override
  String azYerKaldi(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Only $n times left on this day.',
      one: 'Only 1 time left on this day.',
    );
    return '$_temp0';
  }
}
