import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:berber_app_ui/l10n/app_localizations.dart';

/// Uygulama dili: Türkçe (varsayılan) veya İngilizce.
/// Kullanıcı seçmediyse cihaz dili İngilizce olan cihazda İngilizce, diğer her dilde Türkçe.
/// Metinlere bağlam gerekmeden erişilir: `Dil.t.randevuAl`. Dil değişince kök (BerberApp) baştan kurulur,
/// böylece tüm ekranlar yeni dille çizilir.
class Dil extends ChangeNotifier {
  Dil._();
  static final ornek = Dil._();

  static const _anahtar = 'uygulama_dili';

  /// Etkin dil kodu: 'tr' veya 'en'
  static String kod = 'tr';
  static AppLocalizations t = lookupAppLocalizations(const Locale('tr'));

  static bool get ingilizce => kod == 'en';

  String? _secim; // null = cihaz dili

  /// Kullanıcının seçimi; null ise cihaz dili izlenir.
  String? get secim => _secim;

  static String cihazDili() => PlatformDispatcher.instance.locale.languageCode == 'en' ? 'en' : 'tr';

  void _uygula() {
    kod = _secim ?? cihazDili();
    t = lookupAppLocalizations(Locale(kod));
    Intl.defaultLocale = ingilizce ? 'en' : 'tr_TR';
  }

  Future<void> yukle() async {
    try {
      _secim = (await SharedPreferences.getInstance()).getString(_anahtar);
    } catch (_) {
      // Tercih okunamazsa cihaz dili
    }
    _uygula();
  }

  /// [yeni] null → cihaz diline dön.
  Future<void> sec(String? yeni) async {
    _secim = yeni;
    _uygula();
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      yeni == null ? await p.remove(_anahtar) : await p.setString(_anahtar, yeni);
    } catch (_) {
      // Kaydedilemezse yalnızca bu oturum için geçerli
    }
  }

  /// Cihaz dili uygulama açıkken değişti (seçim yoksa izlenir).
  void cihazDiliDegisti() {
    if (_secim != null) return;
    final once = kod;
    _uygula();
    if (once != kod) notifyListeners();
  }

  /// Testler: dili kaydetmeden sabitler.
  @visibleForTesting
  void zorla(String yeni) {
    _secim = yeni;
    _uygula();
    notifyListeners();
  }
}
