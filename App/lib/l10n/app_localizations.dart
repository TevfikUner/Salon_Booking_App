import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @uygulamaAdi.
  ///
  /// In tr, this message translates to:
  /// **'Premium Berber'**
  String get uygulamaAdi;

  /// No description provided for @bugun.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get bugun;

  /// No description provided for @yarin.
  ///
  /// In tr, this message translates to:
  /// **'Yarın'**
  String get yarin;

  /// No description provided for @dun.
  ///
  /// In tr, this message translates to:
  /// **'Dün'**
  String get dun;

  /// No description provided for @ara.
  ///
  /// In tr, this message translates to:
  /// **'Ara…'**
  String get ara;

  /// No description provided for @internetYok.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı yok'**
  String get internetYok;

  /// No description provided for @yenidenDene.
  ///
  /// In tr, this message translates to:
  /// **'Yeniden Dene'**
  String get yenidenDene;

  /// No description provided for @zorunluAlan.
  ///
  /// In tr, this message translates to:
  /// **'Zorunlu alan'**
  String get zorunluAlan;

  /// No description provided for @eposta.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get eposta;

  /// No description provided for @gecerliEpostaGirin.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta girin'**
  String get gecerliEpostaGirin;

  /// No description provided for @cepTelefonu.
  ///
  /// In tr, this message translates to:
  /// **'Cep Telefonu'**
  String get cepTelefonu;

  /// No description provided for @telefonKurali.
  ///
  /// In tr, this message translates to:
  /// **'5 ile başlayan 10 rakam girin'**
  String get telefonKurali;

  /// No description provided for @evet.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get evet;

  /// No description provided for @vazgec.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get vazgec;

  /// No description provided for @hataOturumDogrulanamadi.
  ///
  /// In tr, this message translates to:
  /// **'Oturum doğrulanamadı. İnternet bağlantınızı kontrol edip tekrar deneyin.'**
  String get hataOturumDogrulanamadi;

  /// No description provided for @hataSunucuYanitVermiyor.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu yanıt vermiyor. İnternet bağlantınızı kontrol edip tekrar deneyin.'**
  String get hataSunucuYanitVermiyor;

  /// No description provided for @hataGuvenliBaglanti.
  ///
  /// In tr, this message translates to:
  /// **'Güvenli bağlantı kurulamadı. Lütfen tekrar deneyin.'**
  String get hataGuvenliBaglanti;

  /// No description provided for @hataSunucuyaUlasilamadi.
  ///
  /// In tr, this message translates to:
  /// **'Sunucuya ulaşılamadı. İnternet bağlantınızı kontrol edin.'**
  String get hataSunucuyaUlasilamadi;

  /// No description provided for @hataIslemTamamlanamadi.
  ///
  /// In tr, this message translates to:
  /// **'İşlem tamamlanamadı.'**
  String get hataIslemTamamlanamadi;

  /// No description provided for @hataBilgileriKontrolEdin.
  ///
  /// In tr, this message translates to:
  /// **'Girilen bilgileri kontrol edin.'**
  String get hataBilgileriKontrolEdin;

  /// No description provided for @hataCokFazlaDeneme.
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla deneme yaptınız. Lütfen biraz bekleyin.'**
  String get hataCokFazlaDeneme;

  /// No description provided for @hataHizmetKullanilamiyor.
  ///
  /// In tr, this message translates to:
  /// **'Hizmet geçici olarak kullanılamıyor. Lütfen birazdan tekrar deneyin.'**
  String get hataHizmetKullanilamiyor;

  /// No description provided for @hataOturumSuresiDoldu.
  ///
  /// In tr, this message translates to:
  /// **'Oturumunuzun süresi doldu. Lütfen tekrar giriş yapın.'**
  String get hataOturumSuresiDoldu;

  /// No description provided for @hataYetkiYok.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem için yetkiniz yok.'**
  String get hataYetkiYok;

  /// No description provided for @hataKayitBulunamadi.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt bulunamadı.'**
  String get hataKayitBulunamadi;

  /// No description provided for @hataSunucu.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu hatası ({kod}). Lütfen daha sonra tekrar deneyin.'**
  String hataSunucu(int kod);

  /// No description provided for @hataEpostaGecersiz.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresi geçersiz.'**
  String get hataEpostaGecersiz;

  /// No description provided for @hataEpostaSifreHatali.
  ///
  /// In tr, this message translates to:
  /// **'E-posta veya şifre hatalı.'**
  String get hataEpostaSifreHatali;

  /// No description provided for @hataEpostaKullanimda.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta ile zaten bir hesap var. Giriş yapmayı deneyin.'**
  String get hataEpostaKullanimda;

  /// No description provided for @hataSifreZayif.
  ///
  /// In tr, this message translates to:
  /// **'Şifre çok zayıf. En az 6 karakter kullanın.'**
  String get hataSifreZayif;

  /// No description provided for @hataCokFazlaDenemeYapildi.
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla deneme yapıldı. Lütfen biraz sonra tekrar deneyin.'**
  String get hataCokFazlaDenemeYapildi;

  /// No description provided for @hataKimlikDogrulama.
  ///
  /// In tr, this message translates to:
  /// **'Kimlik doğrulama hatası.'**
  String get hataKimlikDogrulama;

  /// No description provided for @puanla.
  ///
  /// In tr, this message translates to:
  /// **'Puanla'**
  String get puanla;

  /// No description provided for @ac.
  ///
  /// In tr, this message translates to:
  /// **'Aç'**
  String get ac;

  /// No description provided for @berber.
  ///
  /// In tr, this message translates to:
  /// **'Berber'**
  String get berber;

  /// No description provided for @bolumGosterilemiyor.
  ///
  /// In tr, this message translates to:
  /// **'Bu bölüm şu an gösterilemiyor.\nLütfen geri dönüp tekrar deneyin.'**
  String get bolumGosterilemiyor;

  /// No description provided for @takvimeEkle.
  ///
  /// In tr, this message translates to:
  /// **'Takvime Ekle'**
  String get takvimeEkle;

  /// No description provided for @googleTakvim.
  ///
  /// In tr, this message translates to:
  /// **'Google Takvim'**
  String get googleTakvim;

  /// No description provided for @digerTakvimUygulamasi.
  ///
  /// In tr, this message translates to:
  /// **'Diğer takvim uygulaması (.ics)'**
  String get digerTakvimUygulamasi;

  /// No description provided for @digerTakvimOrnekleri.
  ///
  /// In tr, this message translates to:
  /// **'Samsung Takvim, Outlook, Apple Takvim…'**
  String get digerTakvimOrnekleri;

  /// No description provided for @takvimAcilamadi.
  ///
  /// In tr, this message translates to:
  /// **'Takvim açılamadı.'**
  String get takvimAcilamadi;

  /// No description provided for @berberRandevusu.
  ///
  /// In tr, this message translates to:
  /// **'Berber randevusu'**
  String get berberRandevusu;

  /// No description provided for @sureDk.
  ///
  /// In tr, this message translates to:
  /// **'{dk} dk'**
  String sureDk(int dk);

  /// No description provided for @sureSa.
  ///
  /// In tr, this message translates to:
  /// **'{sa} sa'**
  String sureSa(int sa);

  /// No description provided for @sureSaDk.
  ///
  /// In tr, this message translates to:
  /// **'{sa} sa {dk} dk'**
  String sureSaDk(int sa, int dk);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
