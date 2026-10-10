import 'package:flutter/foundation.dart';

/// Uygulama genelindeki sabit değerler.
///
/// API adresi derleme anında verilir (iki ad da kabul edilir):
///   flutter run --dart-define=API_URL=http://localhost:8010          (USB + adb reverse)
///   flutter build appbundle --release --dart-define=API_URL=https://premium-berber-api.onrender.com
/// Verilmezse yerel geliştirme adresi kullanılır (Android emülatöründe 10.0.2.2 = bilgisayarın localhost'u).
/// Release derlemesinde Android yalnızca HTTPS'e izin verir (cleartext kapalı).
class AppConfig {
  static const String _tanimli = String.fromEnvironment('API_URL',
      defaultValue: String.fromEnvironment('API_BASE_URL'));

  static String get baseUrl {
    if (_tanimli.isNotEmpty) return _tanimli.endsWith('/') ? _tanimli.substring(0, _tanimli.length - 1) : _tanimli;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8010';
    }
    return 'http://localhost:8010';
  }

  /// Release derlemesi HTTPS olmayan bir adresle yapılmışsa true (yanlış yapılandırma uyarısı için).
  static bool get guvensizAdres => kReleaseMode && !baseUrl.startsWith('https://');

  static const Duration timeout = Duration(seconds: 15);

  static const String magazaLinki = 'https://play.google.com/store/apps/details?id=com.tevfikuner.premiumberber';
  static const String destekEposta = String.fromEnvironment('DESTEK_EPOSTA', defaultValue: 'destek@premiumberber.app');

  /// Gizlilik politikası ve KVKK metninin herkese açık adresi (Play Console bu URL'yi ister).
  static String get gizlilikUrl => '$baseUrl/yasal/gizlilik';
  static String get hesapSilmeUrl => '$baseUrl/yasal/hesap-silme';

  /// Göreli (/uploads/...) veya tam URL'yi görüntülenebilir adrese çevirir.
  static String medyaUrl(String yol) => yol.startsWith('http') ? yol : '$baseUrl$yol';
}
