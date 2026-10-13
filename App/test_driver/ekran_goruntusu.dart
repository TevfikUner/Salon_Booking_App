import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// `flutter drive` ana bilgisayar tarafı: cihazdan gelen ekran görüntülerini yazar.
/// Varsayılan klasör MAGAZA/ekran_goruntuleri/ (Türkçe); README'nin İngilizce görüntüleri için:
///   EKRAN_KLASORU=../docs/screenshots flutter drive ... --dart-define=TEST_DIL=en
Future<void> main() {
  final klasor = Platform.environment['EKRAN_KLASORU'] ?? '../MAGAZA/ekran_goruntuleri';
  return integrationDriver(
    onScreenshot: (ad, baytlar, [_]) async {
      final dosya = File('$klasor/$ad.png');
      await dosya.create(recursive: true);
      await dosya.writeAsBytes(baytlar);
      return true;
    },
  );
}
