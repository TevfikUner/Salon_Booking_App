import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/data/api/randevu_api.dart';
import 'package:berber_app_ui/data/api/salon_api.dart';
import 'package:berber_app_ui/features/isletme/isletme_panel_screen.dart';
import 'package:berber_app_ui/features/kesfet/salon_detay_screen.dart';
import 'package:berber_app_ui/features/musteri/main_screen.dart';
import 'package:berber_app_ui/features/randevu_al/widgets/saat_slot.dart';

import 'yardimci.dart';

/// Play Store telefon ekran görüntüleri (demo verisiyle). Dosyalar MAGAZA/ekran_goruntuleri/ altına yazılır.
///
///   docker compose -p premium-berber exec api python seed_demo.py
///   adb shell wm size 1080x1920          (Play: en-boy oranı en fazla 2:1 → 9:16)
///   flutter drive --driver=test_driver/ekran_goruntusu.dart --target=integration_test/ekran_goruntusu_test.dart \
///     --dart-define=API_URL=http://10.0.2.2:8020
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  var yuzeyCevrildi = false; // convertFlutterSurfaceToImage test başına yalnızca bir kez çağrılabilir
  setUp(() => yuzeyCevrildi = false);

  Future<void> cek(WidgetTester tester, String ad) async {
    await tester.pump(const Duration(seconds: 2)); // görseller ve animasyonlar otursun
    if (Platform.isAndroid && !yuzeyCevrildi) {
      await binding.convertFlutterSurfaceToImage();
      yuzeyCevrildi = true;
    }
    await tester.pump();
    await binding.takeScreenshot(ad);
  }

  testWidgets('müşteri ekranları', (tester) async {
    await hazirla('demo-musteri');
    await uygulamayiAc(tester, const MainScreen());
    await bekle(tester, find.text(Dil.t.anaSayfa));
    await cek(tester, '01_ana_sayfa');

    await dokun(tester, find.text(Dil.t.kesfet));
    await bekle(tester, anahtarOneki('salon_'));
    await cek(tester, '02_kesfet');

    final salon = (await SalonApi.salonlar()).firstWhere((s) => s.ad == 'Premium Berber Center');
    await uygulamayiAc(tester, SalonDetayScreen(salonId: salon.id));
    await bekle(tester, find.text(Dil.t.kampanyalar));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -250));
    await tester.pump(const Duration(milliseconds: 800));
    await cek(tester, '03_salon_detay');

    await dokun(tester, find.text(Dil.t.randevuAl));
    await bekle(tester, anahtarOneki('hizmet_'));
    await dokun(tester, find.textContaining('Saç Kesimi'));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 400)); // liste başa
    await tester.pump(const Duration(milliseconds: 600));
    await cek(tester, '04_hizmet_secimi');

    // Kampanyalı ilk gün ve saat (demo: hafta içi 09:00–12:00 saç kesimi %20)
    await dokun(tester, find.text(Dil.t.ileri));
    final berber = (await SalonApi.berberler(salon.id)).firstWhere((b) => b.ad == 'Mehmet');
    await dokun(tester, find.byKey(ValueKey('berber_${berber.id}')));
    await dokun(tester, find.text(Dil.t.ileri));
    final kesim = (await SalonApi.hizmetler(salon.id)).firstWhere((h) => h.ad == 'Saç Kesimi');
    final gunler = await RandevuApi.musaitTakvim(berberId: berber.id, hizmetIds: [kesim.id]);
    final gun = DateTime.parse(gunler.firstWhere((g) => (g['indirim_yuzde'] as int) > 0)['tarih'] as String);
    final takvim = find.byWidgetPredicate((w) => w is TableCalendar);
    await bekle(tester, takvim);
    if (gun.month != DateTime.now().month) await dokun(tester, find.byIcon(Icons.chevron_right));
    final hucreler = find.descendant(of: takvim, matching: find.text('${gun.day}'));
    await dokun(tester, gun.day > 20 ? hucreler.last : hucreler.first);
    await dokun(tester, find.text(Dil.t.ileri));
    await bekle(tester, find.byWidgetPredicate((w) => w is SaatSlotWidget && w.indirimYuzde > 0));
    await dokun(tester, find.byWidgetPredicate((w) => w is SaatSlotWidget && w.indirimYuzde > 0).at(1));
    await cek(tester, '05_saat_secimi');

    await uygulamayiAc(tester, const MainScreen(baslangicSekmesi: 1));
    await tester.pump(const Duration(seconds: 3));
    await cek(tester, '06_randevularim');
  });

  testWidgets('işletme ekranları', (tester) async {
    await hazirla('demo-isletme');
    await uygulamayiAc(tester, const IsletmePanelScreen(salonAd: 'Premium Berber Center'));
    await tester.pump(const Duration(seconds: 3));
    await cek(tester, '07_isletme_akis');

    // Gün takvimi: personel sütunları; görüntü için sabah saatlerine kaydırılır (takvim "şimdi"ye açılır)
    await dokun(tester, find.byIcon(Icons.calendar_view_day_outlined));
    await tester.pump(const Duration(seconds: 2));
    await tester.dragFrom(tester.getCenter(find.byType(Scaffold).first), const Offset(0, 3000));
    await cek(tester, '08_isletme_takvim');
  });
}
