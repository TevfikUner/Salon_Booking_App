import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:berber_app_ui/data/api/salon_api.dart';
import 'package:berber_app_ui/features/isletme/isletme_panel_screen.dart';
import 'package:berber_app_ui/features/kesfet/salon_detay_screen.dart';
import 'package:berber_app_ui/features/musteri/main_screen.dart';

import 'yardimci.dart';

/// Play Store telefon ekran görüntüleri (demo verisiyle). Dosyalar MAGAZA/ekran_goruntuleri/ altına yazılır.
///
///   docker compose -p premium-berber exec api python seed_demo.py
///   adb shell wm size 1080x1920          (Play: en-boy oranı en fazla 2:1 → 9:16)
///   flutter drive --driver=test_driver/ekran_goruntusu.dart --target=integration_test/ekran_goruntusu_test.dart \
///     --dart-define=API_URL=http://10.0.2.2:8020
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> cek(WidgetTester tester, String ad) async {
    await tester.pump(const Duration(seconds: 2)); // görseller ve animasyonlar otursun
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();
    await tester.pump();
    await binding.takeScreenshot(ad);
  }

  testWidgets('müşteri ekranları', (tester) async {
    await hazirla('demo-musteri');
    await uygulamayiAc(tester, const MainScreen());
    await bekle(tester, find.text('Ana Sayfa'));
    await cek(tester, '01_ana_sayfa');

    await dokun(tester, find.text('Keşfet'));
    await bekle(tester, anahtarOneki('salon_'));
    await cek(tester, '02_kesfet');

    final salon = (await SalonApi.salonlar()).first;
    await uygulamayiAc(tester, SalonDetayScreen(salonId: salon.id));
    await bekle(tester, find.text('Randevu Al'));
    await cek(tester, '03_salon_detay');

    await dokun(tester, find.text('Randevu Al'));
    await dokun(tester, anahtarOneki('hizmet_'));
    await cek(tester, '04_hizmet_secimi');

    await uygulamayiAc(tester, const MainScreen(baslangicSekmesi: 1));
    await tester.pump(const Duration(seconds: 3));
    await cek(tester, '05_randevularim');
  });

  testWidgets('işletme ekranları', (tester) async {
    await hazirla('demo-isletme');
    await uygulamayiAc(tester, const IsletmePanelScreen(salonAd: 'Premium Berber Center'));
    await tester.pump(const Duration(seconds: 3));
    await cek(tester, '06_isletme_akis');

    await dokun(tester, find.text('Rapor'));
    await tester.pump(const Duration(seconds: 3));
    await cek(tester, '07_isletme_rapor');
  });
}
