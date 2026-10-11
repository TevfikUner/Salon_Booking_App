import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/models/berber.dart';
import 'package:berber_app_ui/data/models/salon.dart';
import 'package:berber_app_ui/data/models/randevu.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/features/musteri/randevularim/widgets/randevu_karti.dart';
import 'package:berber_app_ui/features/randevu_al/widgets/saat_slot.dart';
import 'package:berber_app_ui/features/randevu_al/widgets/takvim_bilesenleri.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Yardımcılar', () {
    test('haftalık gün listesi ayrıştırma ve yazma', () {
      expect(gunListesi('3, 0,9,x,,6'), {0, 3, 6});
      expect(gunListesi(null), isEmpty);
      expect(gunListesiMetni({6, 0, 3}), '0,3,6');
      expect(gunKisaAdlari[gunListesi('4').single], 'Cum');
    });
    test('tarihStr sıfır doldurur', () {
      expect(tarihStr(DateTime(2026, 3, 7)), '2026-03-07');
    });
    test('sureMetni', () {
      expect(sureMetni(45), '45 dk');
      expect(sureMetni(60), '1 sa');
      expect(sureMetni(135), '2 sa 15 dk');
    });
    test('tarihUzun Türkçe gün ve ay', () {
      expect(tarihUzun('2026-10-09'), '9 Ekim Cuma');
      expect(tarihUzun('2026-10-11', yil: true), '11 Ekim 2026 Pazar');
    });
    test('tarihGoreli bugün/yarın', () {
      expect(tarihGoreli(tarihStr(DateTime.now())), 'Bugün');
      expect(tarihGoreli(tarihStr(DateTime.now().add(const Duration(days: 1)))), 'Yarın');
    });
  });

  group('Modeller', () {
    test('Randevu.fromJson yeni alanları okur, eksik alanları tolere eder', () {
      final r = Randevu.fromJson({
        'id': 5,
        'berber_id': 2,
        'berber': 'Ali Usta',
        'salon_id': 1,
        'salon_ad': 'Salon A',
        'hizmetler': ['Kesim'],
        'hizmet_ids': [3],
        'tarih': '2099-01-01',
        'saat': '10:00',
        'bitis': '10:45',
        'sure_dk': 45,
        'durum': 'onaylandi',
        'toplam_fiyat': 450,
      });
      expect(r.toplamFiyat, 450.0);
      expect(r.bitis, '10:45');
      expect(r.yaklasan, isTrue);
      expect(r.ertelemeHakki, 0);
      expect(Randevu.fromJson({'id': 2, 'erteleme_hakki': 2}).ertelemeHakki, 2);
      final eksik = Randevu.fromJson({'id': 1, 'toplam_fiyat': null});
      expect(eksik.toplamFiyat, 0);
      expect(eksik.hizmetler, isEmpty);
    });
    test('Berber.fromJson boş soyad ve null puan', () {
      final b = Berber.fromJson({'id': 1, 'ad': 'Zeki', 'soyad': null, 'puan': null});
      expect(b.tamAd, 'Zeki');
      expect((b.tamamlanan, b.degerlendirmeSayisi), (0, 0));
      final s = Berber.fromJson({'id': 2, 'ad': 'Ali', 'tamamlanan': 120, 'degerlendirme_sayisi': 9});
      expect((s.tamamlanan, s.degerlendirmeSayisi), (120, 9));
      expect(s.copyWith(favori: true).tamamlanan, 120);
      expect(b.puan, 0);
    });
  });

  group('Salon', () {
    test('kapalı günler backend 0=Pzt biçiminden Dart weekday biçimine çevrilir', () {
      final s = Salon.fromJson({'id': 1, 'ad': 'A', 'kapali_gunler': '6', 'acilis_saati': '09:00',
        'kapanis_saati': '21:00', 'pazar_acilis_saati': '10:00', 'pazar_kapanis_saati': '17:00'});
      expect(s.kapaliGunler, {DateTime.sunday});
      expect(s.calismaSaati(DateTime.sunday), isNull);
      expect(s.calismaSaati(DateTime.monday), '09:00 – 21:00');
    });
    test('değerlendirmesi olmayan salon ve berber "Yeni" gösterilir', () {
      expect(Salon.fromJson({'id': 1, 'puan': 5.0}).puanMetni, 'Yeni');
      expect(Salon.fromJson({'id': 1, 'puan': 4.75, 'degerlendirme_sayisi': 8}).puanMetni, '4.8');
      expect(Salon.fromJson({'id': 1, 'puan': 4.75, 'degerlendirme_sayisi': 8}).copyWith().degerlendirmeSayisi, 8);
      expect(Berber.fromJson({'id': 1, 'ad': 'A', 'puan': 5}).puanMetni, 'Yeni');
      expect(Berber.fromJson({'id': 1, 'ad': 'A', 'puan': 4.5, 'degerlendirme_sayisi': 2}).puanMetni, '4.5');
    });
    test('aramada eşleşen hizmetler okunur, yoksa boş', () {
      expect(Salon.fromJson({'id': 1, 'eslesen_hizmetler': ['Sakal']}).eslesenHizmetler, ['Sakal']);
      expect(Salon.fromJson({'id': 1}).eslesenHizmetler, isEmpty);
      expect(Salon.fromJson({'id': 1, 'eslesen_hizmetler': ['Sakal']}).copyWith().eslesenHizmetler, ['Sakal']);
    });
    test('Pazar açıksa Pazar saatleri kullanılır; mesafe ve konum okunur', () {
      final s = Salon.fromJson({'id': 1, 'ad': 'A', 'mesafe_km': 2.4, 'konum': {'lat': 37.8, 'lng': 32.4}});
      expect(s.calismaSaati(DateTime.sunday), '10:00 – 17:00');
      expect(s.mesafeKm, 2.4);
      expect(s.konumVar, isTrue);
    });
  });

  group('API hata çözümleme', () {
    test('düz metin detay', () {
      final h = ApiClient.hataCoz(400, {'detail': 'Geçmiş tarih'});
      expect(h.mesaj, 'Geçmiş tarih');
      expect(h.kod, 400);
    });
    test('çakışma: mesaj + öneriler', () {
      final h = ApiClient.hataCoz(409, {
        'detail': {'mesaj': 'Saat dolu', 'oneriler': ['10:30', '11:00']}
      });
      expect(h.mesaj, 'Saat dolu');
      expect(h.oneriler, ['10:30', '11:00']);
    });
    test('gövdesiz 401 Türkçe mesaj', () {
      expect(ApiClient.hataCoz(401, null).mesaj, contains('tekrar giriş'));
    });
  });

  test('favoriler yanıtındaki berber_id favori olarak okunur', () {
    final b = Berber.fromJson({'berber_id': 3, 'ad': 'Ali', 'soyad': 'Usta', 'salon_ad': 'X', 'puan': 4.5});
    expect(b.id, 3);
    expect(b.favori, isTrue);
    expect(b.salonAd, 'X');
  });

  test('telefonBicimli', () {
    expect(telefonBicimli('5321234567'), '0532 123 45 67');
    expect(telefonBicimli('05321234567'), '0532 123 45 67');
    expect(telefonBicimli('123'), '123');
  });

  group('Widget', () {
    testWidgets('Dolu slot dokunmaya tepki vermez, müsait slot verir', (tester) async {
      var tiklandi = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: [
            SaatSlotWidget(saat: '10:00', durum: SlotDurumu.dolu, onTap: () => tiklandi++),
            SaatSlotWidget(saat: '10:30', durum: SlotDurumu.musait, onTap: () => tiklandi++),
          ]),
        ),
      ));
      await tester.tap(find.text('10:00'));
      expect(tiklandi, 0);
      await tester.tap(find.text('10:30'));
      expect(tiklandi, 1);
    });

    testWidgets('Dolu/az yer bilgisi yalnızca eşiğin altında görünür', (tester) async {
      Future<void> ciz(int? bos) => tester.pumpWidget(MaterialApp(home: Scaffold(body: GunDolulukBilgisi(bos: bos))));
      await ciz(0);
      expect(find.textContaining('Bu gün dolu'), findsOneWidget);
      await ciz(2);
      expect(find.textContaining('yalnızca 2 uygun saat'), findsOneWidget);
      await ciz(5);
      expect(find.byType(Text), findsNothing);
      await ciz(null);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('Randevu kartı: erteleme hakkı varsa Ertele düğmesi çalışır, yoksa görünmez', (tester) async {
      var ertele = 0;
      final r = Randevu.fromJson({'id': 1, 'tarih': '2099-01-01', 'saat': '10:00', 'durum': 'onaylandi',
          'toplam_fiyat': 300, 'erteleme_hakki': 1, 'hizmetler': ['Kesim']});
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: ListView(children: [
          RandevuKarti(randevu: r, onIptal: () {}, onErtele: () => ertele++),
          RandevuKarti(randevu: r, onIptal: () {}),
        ])),
      ));
      expect(find.text('Ertele'), findsOneWidget);
      expect(find.text('İptal Et'), findsNWidgets(2));
      await tester.tap(find.text('Ertele'));
      expect(ertele, 1);
    });
  });
}
