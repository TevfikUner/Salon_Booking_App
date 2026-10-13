import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/data/api/randevu_api.dart';
import 'package:berber_app_ui/data/api/salon_api.dart';
import 'package:berber_app_ui/features/isletme/ekip/ekip_sekmesi.dart';
import 'package:berber_app_ui/features/isletme/isletme_panel_screen.dart';
import 'package:berber_app_ui/features/kesfet/salon_detay_screen.dart';
import 'package:berber_app_ui/features/musteri/main_screen.dart';
import 'package:berber_app_ui/features/randevu_al/widgets/saat_slot.dart';

import 'yardimci.dart';

/// Görsel inceleme: yeni ekranların gerçek cihazda nasıl göründüğü (demo verisiyle). Test değil, kontrol aracı;
/// görüntüler build/inceleme/ altına yazılır.
///
///   docker compose -p premium-berber exec api python seed_demo.py
///   flutter drive --driver=test_driver/inceleme.dart --target=integration_test/inceleme_test.dart \
///     --dart-define=API_URL=http://10.0.2.2:8020
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  var yuzeyCevrildi = false;
  setUp(() => yuzeyCevrildi = false);

  Future<void> cek(WidgetTester tester, String ad) async {
    await tester.pump(const Duration(seconds: 2));
    if (Platform.isAndroid && !yuzeyCevrildi) {
      await binding.convertFlutterSurfaceToImage();
      yuzeyCevrildi = true;
    }
    await tester.pump();
    await binding.takeScreenshot(ad);
  }

  Future<void> kaydir(WidgetTester tester, double dy) async {
    await tester.drag(find.byType(Scrollable).first, Offset(0, -dy));
    await tester.pump(const Duration(milliseconds: 800));
  }

  testWidgets('müşteri: salon, hizmet, personel, saat, özet', (tester) async {
    await hazirla('demo-musteri');
    final salon = (await SalonApi.salonlar()).firstWhere((s) => s.ad == 'Premium Berber Center');

    await uygulamayiAc(tester, const MainScreen(baslangicSekmesi: 2));
    await bekle(tester, anahtarOneki('salon_'));
    await cek(tester, 'm01_kesfet_rozet');

    await uygulamayiAc(tester, SalonDetayScreen(salonId: salon.id));
    await bekle(tester, find.text(Dil.t.kampanyalar));
    await kaydir(tester, 250);
    await cek(tester, 'm02_salon_kampanya_sadakat');

    await dokun(tester, find.text(Dil.t.randevuAl));
    await bekle(tester, anahtarOneki('hizmet_'));
    await cek(tester, 'm03_hizmet_rozet_aralik');

    await dokun(tester, find.textContaining('Saç Kesimi'));
    await dokun(tester, find.text(Dil.t.ileri));
    await bekle(tester, anahtarOneki('berber_toplam_'));
    await cek(tester, 'm04_personel_fiyatlari');

    await dokun(tester, find.text('Mehmet Kaya'));
    await dokun(tester, find.text(Dil.t.ileri));
    await tester.pump(const Duration(seconds: 2));
    await cek(tester, 'm05_takvim_kampanya');

    // İlk kampanyalı gün (hafta içi sabah 09–12)
    final berber = (await SalonApi.berberler(salon.id)).firstWhere((b) => b.ad == 'Mehmet');
    final kesim = (await SalonApi.hizmetler(salon.id)).firstWhere((h) => h.ad == 'Saç Kesimi');
    final gunler = await RandevuApi.musaitTakvim(berberId: berber.id, hizmetIds: [kesim.id]);
    final gun = DateTime.parse(gunler.firstWhere((g) => (g['indirim_yuzde'] as int) > 0)['tarih'] as String);
    final takvim = find.byWidgetPredicate((w) => w is TableCalendar);
    if (gun.month != DateTime.now().month) await dokun(tester, find.byIcon(Icons.chevron_right));
    final hucreler = find.descendant(of: takvim, matching: find.text('${gun.day}'));
    await dokun(tester, gun.day > 20 ? hucreler.last : hucreler.first);
    await dokun(tester, find.text(Dil.t.ileri));
    await bekle(tester, find.byType(SaatSlotWidget));
    await cek(tester, 'm06_saat_indirim');

    await dokun(tester, find.byWidgetPredicate((w) => w is SaatSlotWidget && w.durum == SlotDurumu.musait).first);
    await dokun(tester, find.text(Dil.t.ileri));
    await tester.pump(const Duration(seconds: 3));
    await cek(tester, 'm07_ozet');
  });

  testWidgets('müşteri: randevularım, tekrar al, erteleme', (tester) async {
    await hazirla('demo-musteri');
    await uygulamayiAc(tester, const MainScreen(baslangicSekmesi: 1));
    await dokun(tester, find.text(Dil.t.gecmis));
    await tester.pump(const Duration(seconds: 2));
    await cek(tester, 'm08_gecmis_tekrar_dugmesi');
    await dokun(tester, find.text(Dil.t.aynisiniTekrarAl));
    await bekle(tester, find.byKey(const ValueKey('tekrar_al')));
    await cek(tester, 'm09_tekrar_sheet');
    await tester.tapAt(const Offset(20, 60)); // sayfayı kapat
    await tester.pump(const Duration(seconds: 1));

    await dokun(tester, find.text(Dil.t.yaklasanlar));
    final yaklasan = (await RandevuApi.randevularim()).where((r) => r.yaklasan && r.ertelemeHakki > 0);
    if (yaklasan.isNotEmpty) {
      await dokun(tester, find.text(Dil.t.ertele));
      await bekle(tester, find.byType(SaatSlotWidget));
      await cek(tester, 'm10_erteleme');
    }
  });

  testWidgets('işletme: takvim, kampanyalar, personel hizmetleri, önceden', (tester) async {
    await hazirla('demo-isletme');
    await uygulamayiAc(tester, const IsletmePanelScreen(salonAd: 'Premium Berber Center'));
    await tester.pump(const Duration(seconds: 3));
    await dokun(tester, find.byIcon(Icons.calendar_view_day_outlined));
    await tester.pump(const Duration(seconds: 2));
    await cek(tester, 'p01_gun_takvimi');

    await dokun(tester, find.text(Dil.t.ekipMenu));
    await bekle(tester, find.text(Dil.t.hizmetMenusu));
    final ekipListesi = find.descendant(of: find.byType(EkipSekmesi), matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.byKey(const ValueKey('sadakat_ayari')), 400, scrollable: ekipListesi);
    await tester.pump(const Duration(seconds: 1));
    await cek(tester, 'p02_kampanyalar');

    await dokun(tester, find.byKey(const ValueKey('kampanya_ekle')));
    await bekle(tester, find.byKey(const ValueKey('kampanya_ad')));
    await cek(tester, 'p03_kampanya_formu');
    await tester.tapAt(const Offset(20, 60));
    await tester.pump(const Duration(seconds: 1));

    await tester.scrollUntilVisible(find.text('Ali Uysal'), -400, scrollable: ekipListesi);
    await dokun(tester, find.text('Ali Uysal'));
    await dokun(tester, find.byKey(const ValueKey('personel_hizmetleri')));
    await bekle(tester, anahtarOneki('personel_hizmet_'));
    await cek(tester, 'p04_personel_hizmetleri');
    await tester.tapAt(const Offset(20, 60));
    await tester.pump(const Duration(seconds: 1));

    await dokun(tester, find.text(Dil.t.kapaliGunler));
    await bekle(tester, find.byKey(const ValueKey('onceden_karti')));
    await cek(tester, 'p05_kapali_gunler_onceden');
  });
}
