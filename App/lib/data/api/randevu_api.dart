import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/models/randevu.dart';

/// Müşteri randevu akışı: takvim, müsait saatler, oluşturma, iptal, bekleme listesi, değerlendirme.
class RandevuApi {
  RandevuApi._();

  /// Rezervasyon ufku içindeki açık günler (tatil, kapalı gün, berber izni hariç).
  static Future<List<Json>> musaitTakvim({int? berberId, int? salonId}) async => ApiClient.liste(
      await ApiClient.get('/randevular/musait-takvim', params: {'berber_id': berberId, 'salon_id': salonId}));

  /// Seçilen gün + hizmetler için backend'in hesapladığı saatler (tek doğruluk kaynağı).
  static Future<Json> musaitSaatler(int berberId, String tarih, List<int> hizmetIds) async =>
      await ApiClient.get('/randevular/musait-saatler/$berberId', params: {'tarih': tarih, 'hizmet_ids': hizmetIds});

  static Future<List<Json>> enYakinSlotlar(int berberId, List<int> hizmetIds, {int adet = 3}) async =>
      ApiClient.liste((await ApiClient.get('/randevular/en-yakin/$berberId',
          params: {'hizmet_ids': hizmetIds, 'adet': adet}))['slotlar']);

  static Future<Json> olustur({
    required int berberId,
    required String saat,
    required String tarih,
    required List<int> hizmetIds,
    String ad = '',
    String soyad = '',
    String telefon = '',
  }) async =>
      await ApiClient.post('/randevular/olustur', params: {
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

  static Future<void> iptal(int randevuId) => ApiClient.post('/randevular/$randevuId/iptal');

  static Future<void> degerlendir({required int randevuId, required int puan, String? yorum}) =>
      ApiClient.post('/degerlendirmeler/ekle', params: {
        'randevu_id': randevuId,
        'puan': puan,
        if (yorum != null && yorum.isNotEmpty) 'yorum': yorum,
      });
}
