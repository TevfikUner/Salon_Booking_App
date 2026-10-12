// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get uygulamaAdi => 'Premium Berber';

  @override
  String get bugun => 'Bugün';

  @override
  String get yarin => 'Yarın';

  @override
  String get dun => 'Dün';

  @override
  String get ara => 'Ara…';

  @override
  String get internetYok => 'İnternet bağlantısı yok';

  @override
  String get yenidenDene => 'Yeniden Dene';

  @override
  String get zorunluAlan => 'Zorunlu alan';

  @override
  String get eposta => 'E-posta';

  @override
  String get gecerliEpostaGirin => 'Geçerli bir e-posta girin';

  @override
  String get cepTelefonu => 'Cep Telefonu';

  @override
  String get telefonKurali => '5 ile başlayan 10 rakam girin';

  @override
  String get evet => 'Evet';

  @override
  String get vazgec => 'Vazgeç';

  @override
  String get hataOturumDogrulanamadi =>
      'Oturum doğrulanamadı. İnternet bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get hataSunucuYanitVermiyor =>
      'Sunucu yanıt vermiyor. İnternet bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get hataGuvenliBaglanti =>
      'Güvenli bağlantı kurulamadı. Lütfen tekrar deneyin.';

  @override
  String get hataSunucuyaUlasilamadi =>
      'Sunucuya ulaşılamadı. İnternet bağlantınızı kontrol edin.';

  @override
  String get hataIslemTamamlanamadi => 'İşlem tamamlanamadı.';

  @override
  String get hataBilgileriKontrolEdin => 'Girilen bilgileri kontrol edin.';

  @override
  String get hataCokFazlaDeneme =>
      'Çok fazla deneme yaptınız. Lütfen biraz bekleyin.';

  @override
  String get hataHizmetKullanilamiyor =>
      'Hizmet geçici olarak kullanılamıyor. Lütfen birazdan tekrar deneyin.';

  @override
  String get hataOturumSuresiDoldu =>
      'Oturumunuzun süresi doldu. Lütfen tekrar giriş yapın.';

  @override
  String get hataYetkiYok => 'Bu işlem için yetkiniz yok.';

  @override
  String get hataKayitBulunamadi => 'Kayıt bulunamadı.';

  @override
  String hataSunucu(int kod) {
    return 'Sunucu hatası ($kod). Lütfen daha sonra tekrar deneyin.';
  }

  @override
  String get hataEpostaGecersiz => 'E-posta adresi geçersiz.';

  @override
  String get hataEpostaSifreHatali => 'E-posta veya şifre hatalı.';

  @override
  String get hataEpostaKullanimda =>
      'Bu e-posta ile zaten bir hesap var. Giriş yapmayı deneyin.';

  @override
  String get hataSifreZayif => 'Şifre çok zayıf. En az 6 karakter kullanın.';

  @override
  String get hataCokFazlaDenemeYapildi =>
      'Çok fazla deneme yapıldı. Lütfen biraz sonra tekrar deneyin.';

  @override
  String get hataKimlikDogrulama => 'Kimlik doğrulama hatası.';

  @override
  String get puanla => 'Puanla';

  @override
  String get ac => 'Aç';

  @override
  String get berber => 'Berber';

  @override
  String get bolumGosterilemiyor =>
      'Bu bölüm şu an gösterilemiyor.\nLütfen geri dönüp tekrar deneyin.';

  @override
  String get takvimeEkle => 'Takvime Ekle';

  @override
  String get googleTakvim => 'Google Takvim';

  @override
  String get digerTakvimUygulamasi => 'Diğer takvim uygulaması (.ics)';

  @override
  String get digerTakvimOrnekleri => 'Samsung Takvim, Outlook, Apple Takvim…';

  @override
  String get takvimAcilamadi => 'Takvim açılamadı.';

  @override
  String get berberRandevusu => 'Berber randevusu';

  @override
  String sureDk(int dk) {
    return '$dk dk';
  }

  @override
  String sureSa(int sa) {
    return '$sa sa';
  }

  @override
  String sureSaDk(int sa, int dk) {
    return '$sa sa $dk dk';
  }
}
