import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/models/randevu.dart';

/// Müşteri randevu akışı: takvim, müsait saatler, oluşturma, iptal, bekleme listesi, değerlendirme.
class RandevuApi {
  RandevuApi._();

  /// Rezervasyon ufku içindeki açık günler (tatil, kapalı gün, berber izni hariç).
  /// Berber ve hizmetler verilirse her günde `bos_slot` (hizmetin sığdığı saat sayısı) ve `dolu` gelir.
  static Future<List<Json>> musaitTakvim({int? berberId, int? salonId, List<int>? hizmetIds}) async =>
      ApiClient.liste(await ApiClient.get('/randevular/musait-takvim',
          params: {'berber_id': berberId, 'salon_id': salonId, 'hizmet_ids': hizmetIds}));

  /// Seçilen gün + hizmetler için backend'in hesapladığı saatler (tek doğruluk kaynağı).
  /// [ertelenenId]: ertelenen kendi randevusu; eski yeri dolu sayılmaz.
  static Future<Json> musaitSaatler(int berberId, String tarih, List<int> hizmetIds, {int? ertelenenId}) async =>
      await ApiClient.get('/randevular/musait-saatler/$berberId',
          params: {'tarih': tarih, 'hizmet_ids': hizmetIds, 'ertelenen_id': ertelenenId});

  static Future<List<Json>> enYakinSlotlar(int berberId, List<int> hizmetIds, {int adet = 3}) async =>
      ApiClient.liste((await ApiClient.get('/randevular/en-yakin/$berberId',
          params: {'hizmet_ids': hizmetIds, 'adet': adet}))['slotlar']);

  /// Onay öncesi tutar: liste fiyatı, indirim (kampanya veya oturumdaki müşterinin sadakat kartı) ve toplam.
  static Future<Json> fiyatTeklifi(int berberId, String tarih, String saat, List<int> hizmetIds) async =>
      await ApiClient.get('/randevular/fiyat',
          params: {'berber_id': berberId, 'tarih': tarih, 'saat': saat, 'hizmet_ids': hizmetIds});

  static Future<Json> olustur({
    required int berberId,
    required String saat,
    required String tarih,
    required List<int> hizmetIds,
    String ad = '',
    String soyad = '',
    String telefon = '',
    String? idempotencyKey,
  }) async =>
      await ApiClient.post('/randevular/olustur', idempotencyKey: idempotencyKey, params: {
        'berber_id': berberId,
        'saat': saat,
        'tarih': tarih,
        'hizmet_ids': hizmetIds,
        'ad': ad,
        'soyad': soyad,
        'telefon': telefon,
      });

  static Future<void> beklemeListesineEkle(int berberId, String tarih, List<int> hizmetIds) =>
      ApiClient.post('/randevular/bekleme-listesi',
          govde: {'berber_id': berberId, 'tarih': tarih, 'hizmet_ids': hizmetIds});

  static Future<List<Randevu>> randevularim() async {
    try {
      return ApiClient.liste(await ApiClient.get('/randevular/benim-randevularim')).map(Randevu.fromJson).toList();
    } on ApiHata catch (e) {
      if (e.kod == 404) return []; // henüz müşteri kaydı yok
      rethrow;
    }
  }

  /// İmza özellik: en sık alınan berber+hizmet ve en yakın boş slotlar (geçmiş yoksa null).
  static Future<Json?> herZamanki() async {
    try {
      return await ApiClient.get('/randevular/her-zamanki') as Json?;
    } on ApiHata catch (e) {
      if (e.kod == 404) return null;
      rethrow;
    }
  }

  /// "N hafta sonra aynı saatte tekrar" önerisi; [hafta] verilmezse müşterinin olağan gelme aralığı.
  static Future<Json> tekrarOnerisi(int randevuId, {int? hafta}) async =>
      await ApiClient.get('/randevular/$randevuId/tekrar-onerisi', params: {'hafta': hafta});

  static Future<void> iptal(int randevuId) => ApiClient.post('/randevular/$randevuId/iptal');

  /// Randevunun iCalendar (.ics) metni — yalnızca sahibine.
  static Future<String> takvimDosyasi(int randevuId) => ApiClient.metin('/randevular/$randevuId/takvim.ics');

  /// Aynı berberde başka gün/saate taşır (süre ve fiyat değişmez). Çakışmada ApiHata (409 + öneriler).
  static Future<Json> ertele(int randevuId, {required String tarih, required String saat, String? idempotencyKey}) async =>
      await ApiClient.post('/randevular/$randevuId/ertele',
          govde: {'tarih': tarih, 'saat': saat}, idempotencyKey: idempotencyKey);

  /// Yorum kişisel veri: URL'de değil gövdede gider (sorgu parametreleri proxy loglarına düşer).
  static Future<void> degerlendir({required int randevuId, required int puan, String? yorum}) =>
      ApiClient.post('/degerlendirmeler', govde: {
        'randevu_id': randevuId,
        'puan': puan,
        if (yorum != null && yorum.isNotEmpty) 'yorum': yorum,
      });
}
