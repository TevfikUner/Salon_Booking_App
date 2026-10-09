import 'package:berber_app_ui/data/models/berber.dart';
import 'package:berber_app_ui/data/models/randevu.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/features/randevu_al/widgets/saat_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Yardımcılar', () {
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
      final eksik = Randevu.fromJson({'id': 1, 'toplam_fiyat': null});
      expect(eksik.toplamFiyat, 0);
      expect(eksik.hizmetler, isEmpty);
    });
    test('Berber.fromJson boş soyad ve null puan', () {
      final b = Berber.fromJson({'id': 1, 'ad': 'Zeki', 'soyad': null, 'puan': null});
      expect(b.tamAd, 'Zeki');
      expect(b.puan, 0);
    });
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
  });
}
