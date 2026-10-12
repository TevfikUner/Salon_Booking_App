import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';
import 'package:berber_app_ui/data/models/randevu.dart';
import 'package:berber_app_ui/data/models/salon.dart';
import 'package:berber_app_ui/features/giris/giris_screen.dart';
import 'package:berber_app_ui/features/giris/isletme_kayit_screen.dart';
import 'package:berber_app_ui/features/giris/kayit_screen.dart';
import 'package:berber_app_ui/features/isletme/akis/musteri_karti_sheet.dart';
import 'package:berber_app_ui/features/isletme/akis/widgets/akis_randevu_karti.dart';
import 'package:berber_app_ui/features/isletme/akis/widgets/gun_takvimi.dart';
import 'package:berber_app_ui/features/isletme/kapali_gunler/widgets/mola_karti.dart';
import 'package:berber_app_ui/features/isletme/kapali_gunler/widgets/onceden_karti.dart';
import 'package:berber_app_ui/data/models/berber.dart';
import 'package:berber_app_ui/features/kesfet/widgets/ekip_listesi.dart';
import 'package:berber_app_ui/features/kesfet/widgets/kampanya_bilesenleri.dart';
import 'package:berber_app_ui/features/randevu_al/widgets/saat_slot.dart';
import 'package:berber_app_ui/features/kesfet/widgets/kesfet_filtre_paneli.dart';
import 'package:berber_app_ui/features/kesfet/widgets/salon_arama_kutusu.dart';
import 'package:berber_app_ui/features/kesfet/widgets/salon_karti.dart';
import 'package:berber_app_ui/features/kesfet/widgets/yorum_bilesenleri.dart';
import 'package:berber_app_ui/features/kesfet/widgets/yorumlar_bolumu.dart';
import 'package:berber_app_ui/features/musteri/randevularim/widgets/randevu_karti.dart';
import 'package:berber_app_ui/features/randevu_al/onay_screen.dart';
import 'package:berber_app_ui/features/randevu_al/widgets/takvim_bilesenleri.dart';

/// Taşma (overflow) testleri: en dar yaygın telefon genişliği (360 dp) ve uygulamanın izin verdiği en büyük
/// yazı ölçeği (1,3×, bkz. main.dart) ile ekran/kartlar çizilir; "RenderFlex overflowed" hatası testi düşürür.
/// Veriler gerçek API yanıtlarından alınıp metinler bilerek uzatıldı.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('tr_TR', null);
    // Uygulamadaki gibi: yalnızca gömülü yazı tipleri (assets/google_fonts). Gömülü olmayan bir ağırlık
    // kullanılırsa google_fonts hata verir ve test düşer.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> ciz(WidgetTester tester, Widget ekran, {double olcek = 1.3, double genislik = 360}) async {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = Size(genislik * 3, 690 * 3);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.theme,
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(olcek)),
        child: child!,
      ),
      home: ekran,
    ));
    await tester.pump(const Duration(seconds: 2)); // giriş animasyonları
    expect(tester.takeException(), isNull, reason: 'genişlik=$genislik ölçek=$olcek');
  }

  Widget liste(List<Widget> c) => Scaffold(body: ListView(padding: const EdgeInsets.all(16), children: c));

  final salon = Salon.fromJson({
    'id': 51, 'ad': 'Kuaför Mehmet Ali & Oğulları Erkek Kuaförü', 'sehir': 'Afyonkarahisar', 'ilce': 'Sandıklı',
    'adres': 'Atatürk Bulvarı No: 125/3 Hükümet Konağı Karşısı', 'puan': 4.7, 'acilis_saati': '09:00',
    'kapanis_saati': '21:00', 'kapali_gunler': '6', 'mesafe_km': 12.4,
    'eslesen_hizmetler': ['Sakal Tıraşı ve Şekillendirme', 'Sakal Boyama', 'Sıcak Havlu Sakal Bakımı'],
    'kampanya_yuzde': 50, 'sadakat': true,
  });

  Randevu randevu(String durum, {String? iptalEden}) => Randevu.fromJson({
        'id': 1152, 'berber_id': 95, 'berber': 'Abdurrahman Çağlayanoğlu', 'salon_id': 24,
        'salon_ad': 'Kuaför Mehmet Ali & Oğulları Erkek Kuaförü', 'hizmetler': ['Saç Kesimi', 'Sakal Tıraşı', 'Cilt Bakımı'],
        'hizmet_ids': [1, 2, 3], 'tarih': '2099-12-31', 'saat': '09:00', 'bitis': '10:30', 'sure_dk': 90,
        'durum': durum, 'toplam_fiyat': 12450.0, 'iptal_eden': iptalEden,
        'liste_fiyati': 15560.0, 'indirim_tutari': 3110.0, 'indirim_aciklama': 'Hafta İçi Sabah Kampanyası %20',
      });

  final akis = {
    'id': 7216, 'tarih': '2020-01-01', 'saat': '09:00', 'bitis': '10:30', 'sure_dk': 90, 'durum': 'onaylandi',
    'kaynak': 'panel', 'notlar': 'Kapıdan geldi, sakalı çok uzun; makine 3 numara istiyor, acelesi var.',
    'toplam_fiyat': 12450.0, 'berber': {'id': 201, 'ad': 'Abdurrahman Çağlayanoğlu'},
    'musteri': {'id': 1001, 'ad': 'Muhammed Mustafa Karaosmanoğlu', 'telefon': '05329999999'},
    'hizmetler': [
      {'id': 1, 'ad': 'Saç Kesimi', 'fiyat': 300.0, 'sure': 30},
      {'id': 2, 'ad': 'Sakal Tıraşı ve Şekillendirme', 'fiyat': 150.0, 'sure': 30},
      {'id': 3, 'ad': 'Keratin Bakımı', 'fiyat': 12000.0, 'sure': 30},
    ],
    'guven': {'skor': 40, 'etiket': 'Riskli', 'tamamlanan': 1, 'gelmedi': 3, 'gec_iptal': 2},
    'whatsapp_link': 'https://wa.me/905329999999',
    'indirim_tutari': 3110.0, 'indirim_aciklama': 'Sadakat kartı: 10. ziyaret %20',
  };

  final yorumVeri = {
    'ortalama_puan': 4.67, 'toplam': 1234, 'dagilim': {'5': 1000, '4': 200, '3': 30, '2': 3, '1': 1},
    'sayfa': 1, 'sonraki_var': true,
    'yorumlar': [
      {'puan': 5, 'tarih': '2026-09-30', 'musteri': 'Muhammed Mustafa K.', 'berber': 'Abdurrahman Çağlayanoğlu',
       'yorum': 'Çok titiz çalışıyor, sakal şekillendirmesi mükemmeldi. Bekleme olmadan tam saatinde aldılar, '
           'kesinlikle tekrar geleceğim ve herkese tavsiye ederim.'},
      {'puan': 3, 'tarih': '2026-09-29', 'musteri': 'Anonim', 'berber': '', 'yorum': null},
    ],
  };
  final berberler = [
    Berber.fromJson({'id': 1, 'ad': 'Abdurrahman', 'soyad': 'Çağlayanoğlu', 'uzmanlik': 'Saç & Sakal Tasarım Uzmanı',
        'puan': 4.83, 'tamamlanan': 12345, 'degerlendirme_sayisi': 1234}),
    Berber.fromJson({'id': 2, 'ad': 'Zeki', 'soyad': '', 'uzmanlik': '', 'puan': 5}),
  ];

  for (final olcek in [1.0, 1.3]) {
    group('360 dp, yazı ölçeği $olcek', () {
      testWidgets('giriş', (t) => ciz(t, const GirisScreen(), olcek: olcek));
      testWidgets('müşteri kaydı', (t) => ciz(t, const KayitScreen(), olcek: olcek));
      testWidgets('işletme kaydı', (t) => ciz(t, const IsletmeKayitScreen(), olcek: olcek));
      testWidgets('salon kartı', (t) => ciz(t, liste([SalonKarti(salon: salon, onTap: () {})]), olcek: olcek));
      testWidgets('randevu kartları (tüm durumlar)', (t) => ciz(
          t,
          liste([
            RandevuKarti(randevu: randevu('onaylandi'), onIptal: () {}, onErtele: () {}),
            RandevuKarti(randevu: randevu('tamamlandi'), onDegerlendir: () {}, onTekrarla: () {}),
            RandevuKarti(randevu: randevu('iptal', iptalEden: 'isletme')),
            RandevuKarti(randevu: randevu('gelmedi')),
          ]),
          olcek: olcek));
      testWidgets('işletme akış kartı', (t) => ciz(
          t,
          liste([
            AkisRandevuKarti(randevu: {...akis, 'not_var': true}, islemde: false, onDurum: (_) {}, onWhatsapp: () {},
                onAra: () {}, onMusteri: () {}),
            AkisRandevuKarti(
                randevu: {...akis, 'durum': 'tamamlandi'}, islemde: false, onDurum: (_) {}, onWhatsapp: () {}, onAra: () {}),
          ]),
          olcek: olcek));
      testWidgets('salon değerlendirmeleri ve ekip', (t) => ciz(
          t,
          liste([
            EkipListesi(berberler: berberler, onFavori: (_) {}, onRandevu: (_) {}),
            YorumlarBolumu(salonId: 1, salonAd: 'Salon', veri: yorumVeri, hata: false, onTekrar: () {}),
            YorumlarBolumu(salonId: 1, salonAd: 'Salon', veri: const {'toplam': 0}, hata: false, onTekrar: () {}),
            YorumlarBolumu(salonId: 1, salonAd: 'Salon', veri: null, hata: true, onTekrar: () {}),
            YorumKarti(yorum: (yorumVeri['yorumlar'] as List).first),
          ]),
          olcek: olcek));
      testWidgets('müşteri kartı', (t) => ciz(
          t,
          Scaffold(body: MusteriKartiSheet(musteriId: 1, testVerisi: {
            'musteri': {'id': 1, 'ad': 'Muhammed Mustafa Karaosmanoğlu', 'telefon': '05329999999'},
            'ozet': {'ziyaret': 128, 'son_ziyaret': '2026-09-30', 'toplam_harcama': 123450, 'gelmedi': 12,
                'en_sik_berber': 'Abdurrahman Çağlayanoğlu',
                'en_sik_hizmetler': ['Saç Kesimi', 'Sakal Tıraşı ve Şekillendirme', 'Keratin Bakımı']},
            'guven': akis['guven'],
            'not': {'metin': 'Yanlar 1 numara, üstü makas.', 'guncelleme': '2026-10-01T14:05', 'guncelleyen': 'İşletme'},
            'son_randevular': [
              {'id': 1, 'tarih': '2026-09-30', 'saat': '09:00', 'durum': 'tamamlandi', 'berber': 'Abdurrahman Çağlayanoğlu',
               'hizmetler': ['Saç Kesimi', 'Sakal Tıraşı ve Şekillendirme'], 'toplam_fiyat': 450},
              {'id': 2, 'tarih': '2026-09-02', 'saat': '18:30', 'durum': 'gelmedi', 'berber': 'Veli',
               'hizmetler': ['Kesim'], 'toplam_fiyat': 300},
            ],
          })),
          olcek: olcek));
      testWidgets('keşfet arama ve filtre paneli', (t) => ciz(
          t,
          Scaffold(
            body: KesfetFiltrePaneli(
              sehir: 'Afyonkarahisar', ilce: 'Sandıklı', konumModu: false, konumAliniyor: false, ekFiltre: true,
              onSehirSec: () {}, onIlceSec: () {}, onTemizle: () {}, onKonum: () {},
              ust: SalonAramaKutusu(
                controller: TextEditingController(text: 'sakal tıraşı ve şekillendirme'),
                onDegisti: (_) {}, onTemizle: () {}, yuksekPuan: true, onYuksekPuan: (_) {}),
            ),
          ),
          olcek: olcek));
      testWidgets('takvim doluluk bilgisi ve lejant', (t) => ciz(
          t,
          liste(const [
            GunDolulukBilgisi(bos: 0),
            GunDolulukBilgisi(bos: 2),
            TakvimLejanti(doluluk: true),
          ]),
          olcek: olcek));
      testWidgets('kampanya, sadakat kartı ve indirimli saat', (t) => ciz(
          t,
          liste([
            const KampanyalarKarti(kampanyalar: [
              Kampanya(id: 1, ad: 'Hafta İçi Sabah Kampanyası Çok Uzun Adıyla', yuzde: 50,
                  kosul: 'Pazartesi, Salı, Çarşamba · 10:00–14:00 · Saç Kesimi, Sakal Tıraşı ve Şekillendirme'),
              Kampanya(id: 2, ad: 'Damat', yuzde: 5, kosul: 'Tüm hizmetlerde, her gün'),
            ]),
            const SadakatKartiWidget(kart: SadakatKarti(esik: 12, yuzde: 100, ziyaret: 11, siradakiIndirimli: true)),
            const SadakatKartiWidget(kart: SadakatKarti(esik: 10, yuzde: 50)),
            SizedBox(
              height: 60,
              child: GridView.count(crossAxisCount: 3, childAspectRatio: 2.2, children: const [
                SaatSlotWidget(saat: '10:00', durum: SlotDurumu.musait, indirimYuzde: 20),
                SaatSlotWidget(saat: '10:30', durum: SlotDurumu.musait, secili: true, indirimYuzde: 100),
                SaatSlotWidget(saat: '11:00', durum: SlotDurumu.dolu, indirimYuzde: 20),
              ]),
            ),
            const TakvimLejanti(doluluk: true, kampanya: true),
          ]),
          olcek: olcek));
      testWidgets('işletme gün takvimi', (t) => ciz(
          t,
          Scaffold(
            body: GunTakvimi(
              veri: {
                'tarih': '2099-12-31',
                'mesai': {'acilis': '09:00', 'kapanis': '21:00'},
                'mola': {'bas': '13:00', 'bit': '14:00'},
                'blokeler': [
                  {'id': 1, 'berber_id': 201, 'bas_saat': '16:00', 'bit_saat': '17:00', 'aciklama': 'Doktor randevusu çok uzun'},
                ],
                'doluluk': [
                  {'berber_id': 201, 'ad': 'Abdurrahman Çağlayanoğlu', 'kapali_neden': null},
                  {'berber_id': 202, 'ad': 'Veli', 'kapali_neden': 'Seçilen personel bu gün izinli.'},
                  {'berber_id': 203, 'ad': 'Zeki', 'kapali_neden': null},
                ],
                'randevular': [
                  {...akis, 'tarih': '2099-12-31', 'not_var': true},
                  {...akis, 'id': 2, 'tarih': '2099-12-31', 'saat': '10:30', 'bitis': '11:00', 'sure_dk': 30},
                ],
              },
              onRandevu: (_) {},
              onBosHucre: (_, _) {},
              onTasi: (_, _, _) async {},
            ),
          ),
          olcek: olcek));
      testWidgets('öğle arası kartı', (t) => ciz(
          t,
          liste([
            MolaKarti(salon: const {'mola_baslangic': '12:30', 'mola_bitis': '13:45'}, onDegisti: (_) {}),
            MolaKarti(salon: const {}, onDegisti: (_) {}),
            OncedenKarti(salon: const {'min_onceden_dk': 1440}, onDegisti: (_) {}),
            OncedenKarti(salon: const {}, onDegisti: (_) {}),
          ]),
          olcek: olcek));
      testWidgets('randevu onay ekranı', (t) => ciz(
          t,
          const OnaySayfasi(
            tarih: '2099-12-31', saat: '09:00', bitis: '10:30', berber: 'Abdurrahman Çağlayanoğlu',
            salonAd: 'Kuaför Mehmet Ali & Oğulları Erkek Kuaförü',
            hizmetler: ['Saç Kesimi', 'Sakal Tıraşı ve Şekillendirme', 'Keratin Bakımı'],
            toplamFiyat: 12450, randevuId: '1152', indirim: 3110,
            indirimAciklama: 'Sadakat kartı: 10. ziyaret %20 — çok uzun açıklama metni',
          ),
          olcek: olcek));
      testWidgets('hata ve boş durum', (t) => ciz(
          t,
          liste([
            SizedBox(height: 260, child: HataGorunumu(
                mesaj: 'Sunucuya ulaşılamadı. İnternet bağlantınızı kontrol edin.', onTekrar: () {})),
            const SizedBox(height: 260, child: BosGorunum(
                ikon: Icons.event_busy, mesaj: 'Henüz randevunuz yok', altMesaj: 'Keşfet sekmesinden salon bulun')),
          ]),
          olcek: olcek));
    });
  }
}
