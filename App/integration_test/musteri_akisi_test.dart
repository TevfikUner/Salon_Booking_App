import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:berber_app_ui/data/api/hesap_api.dart';
import 'package:berber_app_ui/data/api/randevu_api.dart';
import 'package:berber_app_ui/data/api/salon_api.dart';
import 'package:berber_app_ui/features/musteri/main_screen.dart';
import 'package:berber_app_ui/features/musteri/randevularim/erteleme_sheet.dart';
import 'package:berber_app_ui/features/randevu_al/widgets/saat_slot.dart';

import 'yardimci.dart';

final _takvim = find.byWidgetPredicate((w) => w is TableCalendar);

/// Müşteri ana akışı: kayıt → salon → hizmet → berber → tarih → saat → onay → Randevularım → ertele → iptal.
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
    // Arama kutusu (TextField) da bir Scrollable içerir; listeyi anahtarıyla bul
    final liste = find.descendant(of: find.byKey(const Key('salon_listesi')), matching: find.byType(Scrollable)).first;
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

    // 4) Tarih: backend'in açık dediği ikinci gün. İlk gün bugünse ve saat geçse tek boş slot
    // ızgaranın en altında kalır; GridView.builder onu çizmediği için bulunamaz.
    final acikGunler = await RandevuApi.musaitTakvim(berberId: berberId);
    final ilkGun = DateTime.parse(acikGunler[acikGunler.length > 1 ? 1 : 0]['tarih'] as String);
    await bekle(tester, _takvim);
    if (ilkGun.month != DateTime.now().month) await dokun(tester, find.byIcon(Icons.chevron_right));
    final gunler = find.descendant(of: _takvim, matching: find.text('${ilkGun.day}'));
    await dokun(tester, ilkGun.day > 20 ? gunler.last : gunler.first); // takvimin başı/sonu komşu ayın günleri
    await dokun(tester, find.text('İleri →'));

    // 5) Saat: ilk müsait slot
    await dokun(tester, find.byWidgetPredicate((w) => w is SaatSlotWidget && w.durum == SlotDurumu.musait));
    await dokun(tester, find.text('İleri →'));

    // 6) Bilgiler → onay. Firebase oturumu olmadığı için profil önceden doldurulmaz; elle girilir.
    await bekle(tester, find.widgetWithText(TextFormField, 'Cep Telefonu'));
    await tester.enterText(find.widgetWithText(TextFormField, 'Ad'), 'Entegrasyon');
    await tester.enterText(find.widgetWithText(TextFormField, 'Cep Telefonu'), '5551112233');
    await tester.pump();
    await dokun(tester, find.text('Randevumu Onayla'));
    await bekle(tester, find.text('Randevunuz Onaylandı!'));

    // 7) Randevularım → ertele (aynı gün başka saat)
    await dokun(tester, find.text('Randevularımı Gör'));
    final once = (await RandevuApi.randevularim()).single;
    await dokun(tester, find.text('Ertele'));
    await dokun(tester, find.descendant(
        of: find.byType(ErtelemeSheet),
        matching: find.byWidgetPredicate((w) => w is SaatSlotWidget && w.durum == SlotDurumu.musait)));
    await dokun(tester, find.textContaining('olarak ertele'));
    await bekle(tester, find.text('Randevunuz ertelendi.'));
    final sonra = (await RandevuApi.randevularim()).single;
    expect(sonra.saat, isNot(once.saat), reason: 'randevu yeni saate taşınmalı');
    expect(sonra.ertelemeHakki, once.ertelemeHakki - 1);

    // 8) İptal: diyalog önce ertelemeyi önerir, "İptal Et" seçilir
    await dokun(tester, find.text('İptal Et'));
    await dokun(tester, find.descendant(of: find.byType(AlertDialog), matching: find.text('İptal Et')));
    await bekle(tester, find.text('Randevunuz iptal edildi.'));

    final randevular = await RandevuApi.randevularim();
    expect(randevular, isNotEmpty);
    expect(randevular.every((r) => r.durum == 'iptal'), isTrue, reason: 'oluşturulan randevu iptal edilmiş olmalı');
  });
}
