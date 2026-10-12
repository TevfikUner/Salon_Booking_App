import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Görsel inceleme sürücüsü: integration_test/inceleme_test.dart ekran görüntülerini build/inceleme/ altına yazar
/// (mağaza görüntülerinden ayrı; git'e girmez).
Future<void> main() => integrationDriver(
      onScreenshot: (ad, baytlar, [_]) async {
        final dosya = File('build/inceleme/$ad.png');
        await dosya.create(recursive: true);
        await dosya.writeAsBytes(baytlar);
        return true;
      },
    );
