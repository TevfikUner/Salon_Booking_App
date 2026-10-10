import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:berber_app_ui/data/api/hesap_api.dart';
import 'package:berber_app_ui/data/api/randevu_api.dart';
import 'package:berber_app_ui/data/api/salon_api.dart';
import 'package:berber_app_ui/features/kesfet/kesfet_screen.dart';
import 'package:berber_app_ui/features/musteri/main_screen.dart';
import 'package:berber_app_ui/features/randevu_al/widgets/saat_slot.dart';

import 'yardimci.dart';

final _takvim = find.byWidgetPredicate((w) => w is TableCalendar);

/// Müşteri ana akışı: kayıt → salon → hizmet → berber → tarih → saat → onay → Randevularım → iptal.
///
///   bash backend/yuk/yigin.sh entegrasyon
///   flutter test integration_test/musteri_akisi_test.dart --dart-define=API_URL=http://10.0.2.2:8020
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('müşteri: kayıt → randevu → Randevularım → iptal', (tester) async {
    await hazirla('entegrasyon-musteri');

    // 1) Kayıt (Firebase hesabı yerine dev kimliği; backend kaydı uygulamanın kullandığı API ile)
    await HesapApi.musteriKayit(
      ad: 'Entegrasyon',
      soyad: 'Test',
      telefon: '05551112233',
      kvkkOnay: true,
      ticariIletiIzni: false,
    );
    final salon = (await SalonApi.salonlar()).firstWhere((s) => s.ad == 'Entegrasyon Salonu');

    // 2) Keşfet → salon
    await uygulamayiAc(tester, const MainScreen(baslangicSekmesi: 2));
    final salonKarti = find.byKey(ValueKey('salon_${salon.id}'));
    final liste = find.descendant(of: find.byType(KesfetScreen), matching: find.byType(Scrollable)).first;
    await bekle(tester, anahtarOneki('salon_'));
    await tester.scrollUntilVisible(salonKarti, 300, scrollable: liste, maxScrolls: 100);
    await dokun(tester, salonKarti);
    await dokun(tester, find.text('Randevu Al'));

    // 3) Hizmet → personel
    await dokun(tester, anahtarOneki('hizmet_'));
    await dokun(tester, find.text('İleri →'));
    final berberKarti = anahtarOneki('berber_');
    await dokun(tester, berberKarti);
    final berberId = int.parse((tester.widget(berberKarti.first).key as ValueKey<String>).value.split('_').last);
    await dokun(tester, find.text('İleri →'));

    // 4) Tarih: backend'in açık dediği ilk gün
    final ilkGun = DateTime.parse((await RandevuApi.musaitTakvim(berberId: berberId)).first['tarih'] as String);
    await bekle(tester, _takvim);
    if (ilkGun.month != DateTime.now().month) await dokun(tester, find.byIcon(Icons.chevron_right));
    final gunler = find.descendant(of: _takvim, matching: find.text('${ilkGun.day}'));
    await dokun(tester, ilkGun.day > 20 ? gunler.last : gunler.first); // takvimin başı/sonu komşu ayın günleri
    await dokun(tester, find.text('İleri →'));

    // 5) Saat: ilk müsait slot
    await dokun(tester, find.byWidgetPredicate((w) => w is SaatSlotWidget && w.durum == SlotDurumu.musait));
    await dokun(tester, find.text('İleri →'));

    // 6) Bilgiler (profilden dolu gelir) → onay
    await bekle(tester, find.text('Randevumu Onayla'));
    await tester.pump(const Duration(seconds: 1)); // profil yüklemesi
    await dokun(tester, find.text('Randevumu Onayla'));
    await bekle(tester, find.text('Randevunuz Onaylandı!'));

    // 7) Randevularım → iptal
    await dokun(tester, find.text('Randevularımı Gör'));
    await dokun(tester, find.text('Randevuyu İptal Et'));
    await dokun(tester, find.text('İptal Et'));
    await bekle(tester, find.text('Randevunuz iptal edildi.'));

    final randevular = await RandevuApi.randevularim();
    expect(randevular, isNotEmpty);
    expect(randevular.every((r) => r.durum == 'iptal'), isTrue, reason: 'oluşturulan randevu iptal edilmiş olmalı');
  });
}
