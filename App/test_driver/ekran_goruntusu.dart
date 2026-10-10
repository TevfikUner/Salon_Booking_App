import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// `flutter drive` ana bilgisayar tarafı: cihazdan gelen ekran görüntülerini MAGAZA/ekran_goruntuleri/ altına yazar.
Future<void> main() => integrationDriver(
      onScreenshot: (ad, baytlar, [_]) async {
        final dosya = File('../MAGAZA/ekran_goruntuleri/$ad.png');
        await dosya.create(recursive: true);
        await dosya.writeAsBytes(baytlar);
        return true;
      },
    );
