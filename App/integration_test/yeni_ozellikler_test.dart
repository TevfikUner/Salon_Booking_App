import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:berber_app_ui/data/api/hesap_api.dart';
import 'package:berber_app_ui/data/api/panel_api.dart';
import 'package:berber_app_ui/data/api/randevu_api.dart';
import 'package:berber_app_ui/data/api/salon_api.dart';
import 'package:berber_app_ui/features/isletme/ekip/ekip_sekmesi.dart';
import 'package:berber_app_ui/features/isletme/isletme_panel_screen.dart';
import 'package:berber_app_ui/features/musteri/main_screen.dart';
import 'package:berber_app_ui/features/randevu_al/widgets/saat_slot.dart';

import 'yardimci.dart';

/// Tur 5 özellikleri uçtan uca (gerçek backend, AUTH_MODE=dev):
/// - Müşteri: kampanya rozeti → Sakal → vermeyen personel soluk → indirimli saat → özet ve onayda indirim
/// - Müşteri: tamamlanan randevuyu "Aynısını Tekrar Al"
/// - İşletme: gün takviminde sürükle-bırak ile saat taşıma, kampanya formu, personelin hizmetleri
///
///   bash backend/yuk/yigin.sh entegrasyon
///   flutter test integration_test/yeni_ozellikler_test.dart --dart-define=API_URL=http://10.0.2.2:8020
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('müşteri: kampanyalı hizmet, vermeyen personel, indirimli özet', (tester) async {
    await hazirla('entegrasyon-kampanya');
    await HesapApi.musteriKayit(
        ad: 'Kampanya', soyad: 'Test', telefon: '05551113344', kvkkOnay: true, ticariIletiIzni: false);
    final salon = (await SalonApi.salonlar()).firstWhere((s) => s.ad == 'Entegrasyon Salonu');
    expect(salon.kampanyaYuzde, 20);
    final sakal = (await SalonApi.hizmetler(salon.id)).firstWhere((h) => h.ad == 'Sakal');
    final berberler = await SalonApi.berberler(salon.id, hizmetIds: [sakal.id]);
    final usta = berberler.firstWhere((b) => b.uygun), kalfa = berberler.firstWhere((b) => !b.uygun);

    // Keşfet: salon kartında kampanya rozeti
    await uygulamayiAc(tester, const MainScreen(baslangicSekmesi: 2));
    final salonKarti = find.byKey(ValueKey('salon_${salon.id}'));
    final liste = find.descendant(of: find.byKey(const Key('salon_listesi')), matching: find.byType(Scrollable)).first;
    await bekle(tester, anahtarOneki('salon_'));
    await tester.scrollUntilVisible(salonKarti, 300, scrollable: liste, maxScrolls: 100);
    expect(find.descendant(of: salonKarti, matching: find.text("%20'ye varan indirim")), findsOneWidget);
    await dokun(tester, salonKarti);
    await bekle(tester, find.text('Sakal Kampanyası'));
    await dokun(tester, find.text('Randevu Al'));

    // Hizmet: Sakal (rozetli) → personel: Kalfa soluk ve "Vermiyor"
    await dokun(tester, find.byKey(ValueKey('hizmet_${sakal.id}')));
    await dokun(tester, find.text('İleri →'));
    await bekle(tester, find.byKey(ValueKey('berber_${kalfa.id}')));
    expect(find.text('Vermiyor: Sakal'), findsOneWidget);
    await dokun(tester, find.byKey(ValueKey('berber_${kalfa.id}')));
    await dokun(tester, find.text('İleri →'));
    expect(find.text('Lütfen bir personel seçin'), findsOneWidget, reason: 'vermeyen personel seçilemez');
    // Uyarı şeridi alttaki "İleri" düğmesini örter
    ScaffoldMessenger.of(tester.element(find.text('Lütfen bir personel seçin'))).removeCurrentSnackBar();
    await tester.pump(const Duration(milliseconds: 300));
    await dokun(tester, find.byKey(ValueKey('berber_${usta.id}')));
    await dokun(tester, find.text('İleri →'));

    // Tarih: ikinci açık gün (kampanya her gün geçerli)
    final acikGunler = await RandevuApi.musaitTakvim(berberId: usta.id, hizmetIds: [sakal.id]);
    expect(acikGunler.first['indirim_yuzde'], 20);
    final gun = DateTime.parse(acikGunler[acikGunler.length > 1 ? 1 : 0]['tarih'] as String);
    final takvim = find.byWidgetPredicate((w) => w is TableCalendar);
    await bekle(tester, takvim);
    if (gun.month != DateTime.now().month) await dokun(tester, find.byIcon(Icons.chevron_right));
    final gunler = find.descendant(of: takvim, matching: find.text('${gun.day}'));
    await dokun(tester, gun.day > 20 ? gunler.last : gunler.first);
    await dokun(tester, find.text('İleri →'));

    // Saat: indirim etiketli ilk müsait slot
    await dokun(
        tester, find.byWidgetPredicate((w) => w is SaatSlotWidget && w.durum == SlotDurumu.musait && w.indirimYuzde == 20));
    await dokun(tester, find.text('İleri →'));

    // Özet: liste fiyatı üstü çizili + indirim satırı (sunucu teklifi)
    await bekle(tester, find.byKey(const ValueKey('ozet_indirim')));
    expect(find.text('Sakal Kampanyası %20'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Ad'), 'Kampanya');
    await tester.enterText(find.widgetWithText(TextFormField, 'Cep Telefonu'), '5551113344');
    await tester.pump();
    await dokun(tester, find.text('Randevumu Onayla'));
    await bekle(tester, find.text('Randevunuz Onaylandı!'));
    await tester.pump(const Duration(seconds: 1)); // sayfa geçişi bitsin
    expect(find.byKey(const ValueKey('ozet_indirim')), findsWidgets);

    final r = (await RandevuApi.randevularim()).single;
    expect((r.listeFiyati, r.indirimTutari, r.toplamFiyat, r.kampanyali), (150.0, 30.0, 120.0, true));
  });

  testWidgets('müşteri: tamamlanan randevuyu tekrar al', (tester) async {
    await hazirla('entegrasyon-tekrar');
    final once = await RandevuApi.randevularim();
    expect(once.single.durum, 'tamamlandi');

    await uygulamayiAc(tester, const MainScreen(baslangicSekmesi: 1));
    await dokun(tester, find.text('GEÇMİŞ'));
    await dokun(tester, find.byKey(ValueKey('tekrarla_${once.single.id}')));
    await bekle(tester, find.textContaining('randevusunu al'));
    expect(find.text('3 hafta ★'), findsOneWidget, reason: 'geçmiş yetersiz: varsayılan 3 hafta');
    await dokun(tester, find.byKey(const ValueKey('tekrar_hafta_2')));
    await bekle(tester, find.textContaining('randevusunu al'));
    await dokun(tester, find.byKey(const ValueKey('tekrar_al')));
    await bekle(tester, find.text('Randevunuz Onaylandı!'));

    final yeni = (await RandevuApi.randevularim()).firstWhere((x) => x.durum == 'onaylandi');
    final hedef = DateTime.parse(once.single.tarih).add(const Duration(days: 14));
    expect(DateTime.parse(yeni.tarih).weekday, hedef.weekday);
    expect(yeni.hizmetler, once.single.hizmetler);
  });

  testWidgets('işletme: takvimde sürükle-bırak, kampanya formu, personel hizmetleri', (tester) async {
    await hazirla('entegrasyon-isletme');
    final yarin = DateTime.now().add(const Duration(days: 1));
    final yarinStr =
        '${yarin.year}-${yarin.month.toString().padLeft(2, '0')}-${yarin.day.toString().padLeft(2, '0')}';
    final hedef = ((await PanelApi.akis(tarih: yarinStr))['randevular'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere((r) => r['saat'] == '10:00');
    final berberId = hedef['berber']['id'] as int;

    await uygulamayiAc(tester, const IsletmePanelScreen(salonAd: 'Entegrasyon Salonu'));
    await dokun(tester, find.text('Yarın'));
    await dokun(tester, find.byIcon(Icons.calendar_view_day_outlined));
    final blok = find.byKey(ValueKey('takvim_randevu_${hedef['id']}'));
    await bekle(tester, blok);

    // 10:00 → 11:30 (aynı personel): basılı tut, sürükle, bırak, onayla
    final hucre = find.byKey(ValueKey('hucre_${berberId}_11:30'));
    await tester.ensureVisible(blok);
    await tester.pump(const Duration(milliseconds: 300));
    final g = await tester.startGesture(tester.getCenter(blok));
    await tester.pump(const Duration(milliseconds: 800));
    await g.moveBy(const Offset(0, 20));
    await tester.pump(const Duration(milliseconds: 100));
    await g.moveTo(tester.getCenter(hucre));
    await tester.pump(const Duration(milliseconds: 300));
    await g.up();
    await tester.pump(const Duration(milliseconds: 500));
    await dokun(tester, find.descendant(of: find.byType(AlertDialog), matching: find.text('Taşı')));
    await bekle(tester, find.text('Randevu 11:30 saatine taşındı.'));
    final tasinan = ((await PanelApi.akis(tarih: yarinStr))['randevular'] as List)
        .cast<Map<String, dynamic>>()
        .firstWhere((r) => r['id'] == hedef['id']);
    expect(tasinan['saat'], '11:30');

    // Ekip & Menü → kampanya ekle
    await dokun(tester, find.text('Ekip & Menü'));
    await dokun(tester, find.byKey(const ValueKey('kampanya_ekle')));
    await bekle(tester, find.byKey(const ValueKey('kampanya_ad')));
    await tester.enterText(find.byKey(const ValueKey('kampanya_ad')), 'Salı Fırsatı');
    await tester.enterText(find.byKey(const ValueKey('kampanya_yuzde')), '15');
    await dokun(tester, find.text('Sal'));
    await dokun(tester, find.byKey(const ValueKey('kampanya_kaydet')));
    await bekle(tester, find.text('Kampanya eklendi.'));
    final kampanyalar = await PanelApi.kampanyalar();
    final yeni = kampanyalar.firstWhere((k) => k['ad'] == 'Salı Fırsatı');
    expect((yeni['yuzde'], yeni['gunler']), (15, '1'));

    // Personel → Verdiği hizmetler: İkinci Kalfa'da Sakal kapalı görünür
    final personel = (await PanelApi.personel()).firstWhere((p) => p['ad'] == 'İkinci');
    // Kampanya bölümü listenin altında; personel yukarıda kaldı (liste tembel çizilir)
    await tester.scrollUntilVisible(find.text('İkinci Kalfa'), -300,
        scrollable: find.descendant(of: find.byType(EkipSekmesi), matching: find.byType(Scrollable)).first);
    await dokun(tester, find.text('İkinci Kalfa'));
    await dokun(tester, find.byKey(const ValueKey('personel_hizmetleri')));
    final hizmetler = await PanelApi.personelHizmetleri(personel['id']);
    final sakal = hizmetler.firstWhere((h) => h['ad'] == 'Sakal');
    await bekle(tester, find.byKey(ValueKey('personel_hizmet_${sakal['hizmet_id']}')));
    final anahtar = tester.widget<SwitchListTile>(find.descendant(
        of: find.byKey(ValueKey('personel_hizmet_${sakal['hizmet_id']}')), matching: find.byType(SwitchListTile)));
    expect(anahtar.value, isFalse);
  });
}
