import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:berber_app_ui/core/dil.dart';

import '../test/bildirim_izni_test.dart' as bildirim_izni;
import '../test/birim_test.dart' as birim;
import '../test/duzen_test.dart' as duzen;

/// test/ altındaki birim, widget ve taşma testlerini cihazda/emülatörde çalıştırır (gerçek yazı tipleriyle).
/// Taşma testleri İngilizce metinlerle bir kez daha koşar. Masaüstü test çalıştırıcısı (flutter_tester)
/// kullanılamadığında da işe yarar:
///   flutter test integration_test/birim_cihazda_test.dart -d emulator-5554
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  birim.main();
  duzen.main();
  bildirim_izni.main();
  group('İngilizce', () {
    setUpAll(() => Dil.ornek.zorla('en'));
    tearDownAll(() => Dil.ornek.zorla('tr'));
    duzen.main();
  });
}
