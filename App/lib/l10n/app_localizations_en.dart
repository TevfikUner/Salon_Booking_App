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
}
