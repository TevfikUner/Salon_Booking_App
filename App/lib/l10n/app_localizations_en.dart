// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get profilFotografi => 'Profile photo';

  @override
  String get fotografiKaldir => 'Remove Photo';

  @override
  String get profilFotoGuncellendi => 'Your profile photo has been updated.';

  @override
  String get profilFotoKaldirildi => 'Your profile photo has been removed.';

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
  String get demoModu => 'Demo mode — no Firebase account needed';

  @override
  String get demoMusteri => 'Try as customer';

  @override
  String get demoIsletme => 'Try as business';

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

  @override
  String get randevularim => 'My Appointments';

  @override
  String get iptalEt => 'Cancel';

  @override
  String get ertele => 'Reschedule';

  @override
  String get randevuIptali => 'Cancel Appointment';

  @override
  String get cikisYap => 'Sign Out';

  @override
  String get anaSayfa => 'Home';

  @override
  String get profil => 'Profile';

  @override
  String get yaklasanRandevulariniz => 'Upcoming Appointments';

  @override
  String get favoriBerberlerim => 'My Favourite Barbers';

  @override
  String get tumu => 'All';

  @override
  String get hosGeldinizMakas => 'Welcome ✂️';

  @override
  String get kendinizeRandevu => 'Treat yourself to an appointment today';

  @override
  String sihhatlerOlsun(String ad) {
    return 'Hello, $ad!';
  }

  @override
  String get favoriYok => 'No favourite barbers yet';

  @override
  String get favoriNasil => 'Add them with ♥ on a salon page';

  @override
  String get herZamankiRandevu => 'Your usual appointment';

  @override
  String get randevuyuAl => 'Book It';

  @override
  String get herZamanki => 'Your Usual';

  @override
  String get yakinBosSaatYok => 'No free times soon.';

  @override
  String get enYakinDokun => 'Nearest free times — tap, confirm, done:';

  @override
  String kacKez(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Booked $n times',
      one: 'Booked once',
    );
    return '$_temp0';
  }

  @override
  String get nasilDevam => 'How would you like to continue?';

  @override
  String get yeniSalonKesfet => 'Explore a New Salon';

  @override
  String get farkliSalonlar => 'Discover other salons';

  @override
  String get kapat => 'Close';

  @override
  String get randevunuzuNasilBuldunuz => 'How was your appointment?';

  @override
  String get yorumunuz => 'Your comment (optional)';

  @override
  String get degerlendir => 'Submit';

  @override
  String get tesekkurler => 'Thank you! ⭐';

  @override
  String get degerlendirmeKaydedildi => 'Your review has been saved.';

  @override
  String get puanKotu => 'Poor';

  @override
  String get puanFenaDegil => 'Fair';

  @override
  String get puanIyi => 'Good';

  @override
  String get puanCokIyi => 'Very good';

  @override
  String get puanMukemmel => 'Excellent!';

  @override
  String yildizSayisi(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String get berberlerim => 'My Barbers';

  @override
  String get berberGecmisiYok => 'No favourite or past barbers yet';

  @override
  String get favoriEkleIpucu => 'Add favourites with ♥ on a salon page';

  @override
  String get favorileriniz => 'Your Favourites';

  @override
  String get dahaOnceGittikleriniz => 'Visited Before';

  @override
  String get cikisEminMisiniz => 'Are you sure you want to sign out?';

  @override
  String get hesabiSil => 'Delete Account';

  @override
  String get hesapSilAciklama =>
      'Your personal data will be deleted and your upcoming appointments cancelled. This can\'t be undone.';

  @override
  String get kaliciSil => 'Delete Permanently';

  @override
  String get hesapSilindi =>
      'Your account and personal data have been deleted.';

  @override
  String get verilerSilindiOturum =>
      'Your personal data has been deleted. You\'ve been signed out for security.';

  @override
  String get yasalGizlilik => 'Legal & Privacy';

  @override
  String get gizlilikPolitikasi => 'Privacy Policy';

  @override
  String get kvkkMetni => 'Privacy Notice (KVKK)';

  @override
  String get kullanimKosullari => 'Terms of Use';

  @override
  String get sikcaSorulanSorular => 'Frequently Asked Questions';

  @override
  String get hesap => 'Account';

  @override
  String get uygulamayiPaylas => 'Share the App';

  @override
  String get hesabimiSil => 'Delete My Account';

  @override
  String hesapSilinemedi(String neden) {
    return 'Couldn\'t delete the account: $neden';
  }

  @override
  String get paylasMetni =>
      'Book your barber in seconds with Premium Berber 💈';

  @override
  String get dil => 'Language';

  @override
  String get cihazDili => 'Device language';

  @override
  String get bilgilerKaydedildi => 'Your details have been saved.';

  @override
  String get kisiselBilgiler => 'Personal Information';

  @override
  String get kaydet => 'Save';

  @override
  String get duzenle => 'Edit';

  @override
  String get adiniz => 'First name';

  @override
  String get soyadiniz => 'Last name';

  @override
  String get telefon => 'Phone';

  @override
  String get randevuyuErtele => 'Reschedule Appointment';

  @override
  String get acikGunYok => 'No open days in the coming period.';

  @override
  String get yeniSaatSecin => 'Choose a new time';

  @override
  String get buGunBosSaatYok => 'No free times on this day.';

  @override
  String get baskaGunSecin => 'Choose another day.';

  @override
  String oneri(String saatler) {
    return 'Suggested: $saatler';
  }

  @override
  String suAn(String bilgi) {
    return 'Currently: $bilgi';
  }

  @override
  String kalanErteleme(int n) {
    return 'Reschedules left: $n';
  }

  @override
  String get kampanya => 'campaign';

  @override
  String indirimKalkar(String kampanya, String tutar) {
    return 'This time isn\'t covered by \"$kampanya\": the discount is removed and the price becomes $tutar. Discounted times are marked.';
  }

  @override
  String olarakErtele(String zaman) {
    return 'Reschedule to $zaman';
  }

  @override
  String get randevunuzErtelendi => 'Your appointment has been rescheduled.';

  @override
  String get randevunuzIptalEdildi => 'Your appointment has been cancelled.';

  @override
  String get yaklasanlar => 'UPCOMING';

  @override
  String get gecmis => 'PAST';

  @override
  String get aktifRandevuYok => 'No active appointments yet';

  @override
  String get gecmisRandevuYok => 'No past appointments';

  @override
  String iptalEminMisiniz(String randevu) {
    return 'Do you want to cancel your $randevu appointment?';
  }

  @override
  String get iptalYerineErtele =>
      'If you can\'t make it, you can reschedule instead of cancelling.';

  @override
  String get tekrarRandevuAl => 'Book Again';

  @override
  String get kacHaftaSonra => 'In how many weeks?';

  @override
  String get herZamankiAraliginiz => '★ your usual interval';

  @override
  String get saatSecinKisa => 'Choose a time';

  @override
  String get bosSaatBulunamadi => 'No free times found in the coming days.';

  @override
  String haftaSayisi(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n weeks',
      one: '1 week',
    );
    return '$_temp0';
  }

  @override
  String randevusunuAl(String zaman) {
    return 'Book $zaman';
  }

  @override
  String herZamankiSaatBos(String gun, String saat) {
    return '$gun: your usual time $saat is free.';
  }

  @override
  String kapaliEnYakin(String gun, String neden) {
    return '$gun: $neden Nearest free times:';
  }

  @override
  String saatDoluEnYakin(String gun, String saat) {
    return '$gun $saat is taken. Nearest times that day:';
  }

  @override
  String tekrarFiyatNotu(String bilgi) {
    return 'List price $bilgi. Any campaign or loyalty discount is applied on confirmation.';
  }

  @override
  String get durumOnaylandi => '✓ Confirmed';

  @override
  String get durumTamamlandi => '✔ Completed';

  @override
  String get durumIptal => '✗ Cancelled';

  @override
  String get durumGelinmedi => 'No-show';

  @override
  String get salonIptalEtti => 'Cancelled by the salon.';

  @override
  String get hizmetiDegerlendir => 'Rate Service';

  @override
  String get aynisiniTekrarAl => 'Book the Same Again';

  @override
  String degerlendirildi(String yildiz) {
    return 'Rated ($yildiz)';
  }

  @override
  String get ekle => 'Add';

  @override
  String get kaldir => 'Remove';

  @override
  String get gelmedi => 'No-show';

  @override
  String get tamamlandi => 'Completed';

  @override
  String get iptalKisa => 'Cancelled';

  @override
  String get riskli => 'Risky';

  @override
  String get ogleArasi => 'Lunch break';

  @override
  String get kadrodanCikar => 'Remove from team';

  @override
  String get menudenKaldir => 'Remove from menu';

  @override
  String get basvuruOnaylanmadi => 'Your application wasn\'t approved';

  @override
  String get basvuruInceleniyor => 'Your application is under review';

  @override
  String get destekleIletisim => 'Please contact our support team for details.';

  @override
  String get durumuKontrolEt => 'Check Status';

  @override
  String basvuruAlindi(String ad) {
    return 'We\'ve received your application for $ad. Once approved, your salon dashboard opens and you\'ll manage the day\'s appointments, staff and services from here.';
  }

  @override
  String get akis => 'Today';

  @override
  String get ekipMenu => 'Team & Menu';

  @override
  String get kapaliGunler => 'Closures';

  @override
  String get rapor => 'Report';

  @override
  String get personelPaneli => 'Staff Dashboard';

  @override
  String get isletmePaneli => 'Business Dashboard';

  @override
  String get randevuyuIptalEt => 'Cancel appointment';

  @override
  String get randevuGuncellendi => 'Appointment updated.';

  @override
  String get randevuyuTasi => 'Move appointment';

  @override
  String get tasimaAciklama =>
      'Price and duration stay the same; the customer is notified.';

  @override
  String get tasi => 'Move';

  @override
  String get randevuEkle => 'Add Appointment';

  @override
  String get tasimaIpucu => 'Press and hold an appointment to drag it.';

  @override
  String get liste => 'List';

  @override
  String get takvim => 'Calendar';

  @override
  String get buGunRandevuYok => 'No appointments on this day.';

  @override
  String get randevuEkleIpucu =>
      'Use \"Add Appointment\" for customers who call or walk in.';

  @override
  String get digerPersonel => 'other staff';

  @override
  String saatineTasindi(String saat) {
    return 'Appointment moved to $saat.';
  }

  @override
  String get notKaydedildi => 'Note saved.';

  @override
  String get ziyaret => 'Visits';

  @override
  String get harcama => 'Spent';

  @override
  String get sonZiyaret => 'Last visit';

  @override
  String get isletmeNotu => 'Business note';

  @override
  String get notIpucu =>
      'E.g. sides number 1, scissors on top, straight neckline.';

  @override
  String get ozelVeriYazmayin =>
      'Don\'t record sensitive data such as health information.';

  @override
  String get notYalnizSalon => 'The note is only visible to your salon.';

  @override
  String get notuSil => 'Delete Note';

  @override
  String get sonRandevular => 'Recent appointments';

  @override
  String genelde(String ad) {
    return 'Usually: $ad';
  }

  @override
  String sonGuncelleme(String bilgi) {
    return 'Last: $bilgi';
  }

  @override
  String get musteriAdiGirin => 'Enter the customer\'s name.';

  @override
  String get telefonKuraliOrnek =>
      'The phone must be 10 digits starting with 5 (e.g. 532 123 45 67).';

  @override
  String get randevuEklendi => 'Appointment added.';

  @override
  String get telefonlaGelen => 'For customers who call or walk in';

  @override
  String get tarihSaat => 'Date & Time';

  @override
  String get saatIcinHizmet => 'Choose services to see times.';

  @override
  String get uygunSaatKalmadi => 'No times left on this day.';

  @override
  String get adSoyad => 'Full name';

  @override
  String get telefonIstegeBagli => 'Phone (optional)';

  @override
  String get notIstegeBagli => 'Note (optional)';

  @override
  String get randevuyuKaydet => 'Save Appointment';

  @override
  String get randevuSayisiEtiket => 'Bookings';

  @override
  String get toplamSure => 'Total time';

  @override
  String get beklenenCiro => 'Expected revenue';

  @override
  String get siradaki => 'NEXT UP';

  @override
  String get whatsappOnay => 'WhatsApp confirm';

  @override
  String get araTelefon => 'Call';

  @override
  String get musteriNotuVar => 'Has a customer note';

  @override
  String get bekleniyor => 'Upcoming';

  @override
  String get panelden => 'added in dashboard';

  @override
  String notMetni(String not) {
    return 'Note: $not';
  }

  @override
  String get tasimakIcinBasiliTut => 'press and hold to move';

  @override
  String get personelEkle => 'Add Staff';

  @override
  String get unvan => 'Title (Master, Junior...)';

  @override
  String get epostaIstegeBagli => 'Email (optional)';

  @override
  String get personelEpostaIpucu =>
      'If the staff member signs up with this email, they\'ll see their own calendar.';

  @override
  String get personelEklendi => 'Staff member added.';

  @override
  String get calismaGunleri => 'Working days';

  @override
  String get verdigiHizmetler => 'Services and prices';

  @override
  String get verdigiHizmetlerAciklama =>
      'Custom prices, durations or services this person doesn\'t offer';

  @override
  String get cikar => 'Remove';

  @override
  String get personelCikarildi => 'Removed from the team.';

  @override
  String get hizmetEkle => 'Add Service';

  @override
  String get hizmetiDuzenle => 'Edit Service';

  @override
  String get hizmetAdi => 'Service name';

  @override
  String get fiyat => 'Price';

  @override
  String get dkKisa => 'min';

  @override
  String get aciklamaIstegeBagli => 'Description (optional)';

  @override
  String get fiyatDegisikligi =>
      'Price changes don\'t affect existing appointments.';

  @override
  String get hizmetKurali =>
      'Enter a name, price and a duration of at least 5 minutes.';

  @override
  String get hizmetEklendi => 'Service added.';

  @override
  String get hizmetGuncellendi => 'Service updated.';

  @override
  String get hizmetKaldirildi => 'Service removed.';

  @override
  String get personeleDokunun =>
      'Tap a staff member for working days and services.';

  @override
  String get henuzPersonelYok => 'No staff yet.';

  @override
  String get hizmetMenusu => 'Service Menu';

  @override
  String get henuzHizmetYok => 'No services yet.';

  @override
  String calismaGunleriKaydedildi(String ad) {
    return 'Working days saved for $ad.';
  }

  @override
  String hizmetlerKaydedildi(String ad) {
    return 'Services saved for $ad.';
  }

  @override
  String kadrodanCikarilsinMi(String ad) {
    return 'Remove $ad from the team? Past appointment records are kept.';
  }

  @override
  String menudenKaldirilsinMi(String ad) {
    return 'Remove \"$ad\" from the menu?';
  }

  @override
  String get hesabiBagli => 'account linked';

  @override
  String davet(String eposta) {
    return 'invited: $eposta';
  }

  @override
  String hizmetiVermiyor(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'doesn\'t offer $n services',
      one: 'doesn\'t offer 1 service',
    );
    return '$_temp0';
  }

  @override
  String ozelFiyatli(int n) {
    return 'custom price/duration on $n';
  }

  @override
  String haftalikIzin(String gunler) {
    return 'Weekly days off: $gunler';
  }

  @override
  String get calismaGunleriAciklama =>
      'Works on the selected days. Customers can\'t book this person on unselected days.';

  @override
  String get salonBuGunKapali => 'The salon is closed this day';

  @override
  String get solukGunler => 'The salon is closed on dimmed days.';

  @override
  String get kampanyaEklendi => 'Campaign added.';

  @override
  String get kampanyaGuncellendi => 'Campaign updated.';

  @override
  String get kampanyayiKaldir => 'Remove campaign';

  @override
  String get sadakatAciklama =>
      'Every Nth appointment of a customer at this salon is discounted. Completed and booked appointments count; no-shows and cancellations don\'t.';

  @override
  String get kacinciZiyaret => 'Which visit (2–50)';

  @override
  String get ziyaretEki => 'th visit';

  @override
  String get indirimAraligi => 'Discount (5–100)';

  @override
  String get sadakatKuraliHata => 'Visit must be 2–50 and discount 5–100.';

  @override
  String get sadakatKapatildi => 'Loyalty card turned off.';

  @override
  String get kampanyaAciklama =>
      'To fill quiet times: e.g. \"Tuesday 20%\" or \"Weekdays 10:00–14:00 beard 30%\". Discounts don\'t stack; the customer gets the highest one.';

  @override
  String get henuzKampanyaYok => 'No campaigns yet.';

  @override
  String get sadakatKapaliAc => 'Off · tap to turn on';

  @override
  String get kampanyaKurali =>
      'Enter a name; the discount must be between 5% and 90%.';

  @override
  String get bitisBaslangictanOnce =>
      'The end date can\'t be before the start date.';

  @override
  String get yeniKampanya => 'New Campaign';

  @override
  String get kampanyayiDuzenle => 'Edit Campaign';

  @override
  String get kampanyaFormAciklama =>
      'Conditions left empty don\'t restrict. Changes apply only to future bookings.';

  @override
  String get kampanyaAdi => 'Campaign name';

  @override
  String get kampanyaAdiOrnek => 'Tuesday Deal';

  @override
  String get gunler => 'Days';

  @override
  String get herGun => 'Every day';

  @override
  String get saatAraligi => 'Time range';

  @override
  String get gunBoyu => 'All day';

  @override
  String get saatAraligiSec => 'Choose time range';

  @override
  String get tarihAraligi => 'Date range';

  @override
  String get suresiz => 'No end';

  @override
  String get baslangicHemen => 'Start: now';

  @override
  String get bitisYok => 'End: none';

  @override
  String get temizle => 'Clear';

  @override
  String get tumHizmetler => 'All services';

  @override
  String get kampanyaAcik => 'Campaign on';

  @override
  String get kapatirsanizDuraklatilir =>
      'Turning it off pauses it; it isn\'t deleted.';

  @override
  String sadakatKaydedildi(int esik, int yuzde) {
    return 'Loyalty card: every visit no. $esik is $yuzde% off.';
  }

  @override
  String get duraklatildi => 'Paused';

  @override
  String get suresiDoldu => 'Expired';

  @override
  String baslangic(String tarih) {
    return 'Start: $tarih';
  }

  @override
  String bitis(String tarih) {
    return 'End: $tarih';
  }

  @override
  String get enAzBirHizmetVermeli => 'Staff must offer at least one service.';

  @override
  String get personelHizmetAciklama =>
      'Turned-off services can\'t be booked with this person. Empty price/duration means the menu value; changes don\'t affect existing appointments.';

  @override
  String get menudeHizmetYok => 'No services on the menu.';

  @override
  String get ozelFiyat => 'Custom price';

  @override
  String get ozelSure => 'Custom duration';

  @override
  String sureEnAz5(String ad) {
    return '$ad: duration must be at least 5 minutes.';
  }

  @override
  String menuDegeri(String deger) {
    return 'Menu: $deger';
  }

  @override
  String get kapaliGunEklendi => 'Closure added.';

  @override
  String get oncePersonelEkle => 'First add staff in the Team & Menu tab.';

  @override
  String get hangiPersonel => 'Which staff member?';

  @override
  String get kaydedildi => 'Saved.';

  @override
  String get hangiPersonelIzinli => 'Who\'s taking the day off?';

  @override
  String get izinEklendi => 'Day off added.';

  @override
  String get kapaliAciklama =>
      'Customers can\'t book during the lunch break, closures, days off and blocked hours.';

  @override
  String get salonKapaliGunler => 'Salon closures';

  @override
  String get kapaliGunYok => 'No planned closures.';

  @override
  String get personelIzinleri => 'Staff days off';

  @override
  String get izinYok => 'No planned days off.';

  @override
  String get saatlikKapatmalar => 'Blocked hours';

  @override
  String get kapatilmisSaatYok =>
      'No blocked hours. E.g. \"Ali out 14:00–16:00\".';

  @override
  String salonKapaliTarih(String tarih) {
    return 'Salon closed: $tarih';
  }

  @override
  String saatlerdeRandevuVar(int n) {
    return 'Saved. There are $n active appointments in these hours; let the customers know.';
  }

  @override
  String izinGununderandevuVar(int n) {
    return 'Day off added. There are $n active appointments that day; let the customers know.';
  }

  @override
  String get molaKaldirildi => 'Lunch break removed.';

  @override
  String get molaYok => 'No lunch break set';

  @override
  String get molaAciklama => 'No bookings during these hours every day.';

  @override
  String get molayiKaldir => 'Remove lunch break';

  @override
  String molaKaydedildi(String aralik) {
    return 'Lunch break saved as $aralik.';
  }

  @override
  String get sinirYok => 'No limit';

  @override
  String get oncedenSoru => 'How far ahead must customers book?';

  @override
  String get oncedenOrnek =>
      'E.g. 1 hour: at 12:10 the earliest bookable time is 13:30. Appointments you add in the dashboard aren\'t affected.';

  @override
  String get sonDakikaAcikNokta => 'Open to last-minute bookings.';

  @override
  String get sonDakikaAcik => 'Open to last-minute bookings';

  @override
  String get oncedenAciklama =>
      'The earliest time customers can book in the app.';

  @override
  String musterilerEnAz(String sure) {
    return 'Customers can book at least $sure ahead.';
  }

  @override
  String enAzOncedenKisa(String sure) {
    return 'At least $sure ahead';
  }

  @override
  String get baslangicSaati => 'Start time';

  @override
  String get bitisSaati => 'End time';

  @override
  String get bitisSonraOlmali => 'The end time must be after the start time.';

  @override
  String get oncekiAy => 'Previous month';

  @override
  String get sonrakiAy => 'Next month';

  @override
  String get ciro => 'Revenue';

  @override
  String get tamamlanan => 'Completed';

  @override
  String get ortalamaSepet => 'Average ticket';

  @override
  String get gelmemeOrani => 'No-show rate';

  @override
  String get verilenIndirim => 'Discounts given';

  @override
  String get personelCiro => 'Revenue by staff';

  @override
  String get buAyTamamlananYok => 'No completed appointments this month.';

  @override
  String get populerHizmetler => 'Most popular services';

  @override
  String yuzdeMetin(String y) {
    return '$y%';
  }

  @override
  String randevuSayisi(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n appointments',
      one: '1 appointment',
    );
    return '$_temp0';
  }

  @override
  String raporAlt(int iptal, int gelmedi, int uygulama) {
    return 'Cancelled: $iptal · No-show: $gelmedi · Booked in app: $uygulama';
  }

  @override
  String get ilkZiyaret => 'First visit — no history';

  @override
  String guvenOzet(int tamam, int gelmedi, int gec) {
    return '$tamam completed · $gelmedi no-show · $gec late cancel';
  }

  @override
  String get guvenilir => 'Reliable';

  @override
  String get dikkat => 'Caution';

  @override
  String get isletmeHesapSilAciklama =>
      'Your personal data (name, phone, email) will be deleted and your dashboard access closed. The salon record and past appointments remain without your identity. This can\'t be undone.';

  @override
  String get hesapSilinemediTekrar =>
      'Couldn\'t delete the account. Please try again.';

  @override
  String panelIptalSoru(String randevu) {
    return 'Cancel the $randevu appointment? The customer will be notified.';
  }

  @override
  String get kapaliKucuk => 'closed';

  @override
  String bosSaatSayisi(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n free slots',
      one: '1 free slot',
    );
    return '$_temp0';
  }

  @override
  String kampanyaKaldirSoru(String ad) {
    return 'Remove \"$ad\"? Appointments already booked with it keep their discount.';
  }

  @override
  String randevudaKullanildi(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Used in $n appointments',
      one: 'Used in 1 appointment',
    );
    return '$_temp0';
  }
}
