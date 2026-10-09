import 'package:flutter/foundation.dart';

/// Uygulama genelindeki sabit değerler.
///
/// API adresi derleme anında verilir:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8000
///   flutter build apk --dart-define=API_BASE_URL=https://api.premiumberber.app
/// Verilmezse yerel geliştirme adresi kullanılır (Android emülatöründe 10.0.2.2 = bilgisayarın localhost'u).
class AppConfig {
  static const String _tanimli = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_tanimli.isNotEmpty) return _tanimli;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  static const Duration timeout = Duration(seconds: 15);

  /// Paket adı değişince (BENDEN_GEREKENLER #8) burası da güncellenir.
  static const String magazaLinki = 'https://play.google.com/store/apps/details?id=com.premiumberber.app';
  static const String destekEposta = String.fromEnvironment('DESTEK_EPOSTA', defaultValue: 'destek@premiumberber.app');

  /// Göreli (/uploads/...) veya tam URL'yi görüntülenebilir adrese çevirir.
  static String medyaUrl(String yol) => yol.startsWith('http') ? yol : '$baseUrl$yol';
}
