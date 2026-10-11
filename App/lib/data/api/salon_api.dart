import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/models/berber.dart';
import 'package:berber_app_ui/data/models/hizmet.dart';
import 'package:berber_app_ui/data/models/salon.dart';

/// Keşfet: salonlar, salon detayı, menü ve personel.
class SalonApi {
  SalonApi._();

  /// Şehir/ilçe filtresi harf duyarsızdır; konum verilirse yakından uzağa sıralanır.
  /// [q]: salon adı, ilçe veya hizmet adında arar; [minPuan]: en düşük salon puanı.
  static Future<List<Salon>> salonlar(
          {String? sehir, String? ilce, double? lat, double? lng, String? q, double? minPuan}) async =>
      ApiClient.liste(await ApiClient.get('/salonlar', params: {
        'sehir': sehir,
        'ilce': ilce,
        'lat': lat,
        'lng': lng,
        'q': (q?.trim().isEmpty ?? true) ? null : q!.trim(),
        'min_puan': minPuan,
      })).map(Salon.fromJson).toList();

  static Future<Salon> detay(int salonId) async => Salon.fromJson(await ApiClient.get('/salonlar/$salonId'));

  static Future<Json> istatistik(int salonId) async {
    try {
      return await ApiClient.get('/randevular/istatistik', params: {'salon_id': salonId});
    } on ApiHata {
      return const {'bugunku_randevu': 0, 'musait_slot_sayisi': 0, 'toplam_slot': 0, 'aktif_berber': 0};
    }
  }

  /// Salon değerlendirmeleri: ortalama, 1–5 dağılımı, sayfalı yorumlar (yorum yazılanlar önce).
  static Future<Json> yorumlar(int salonId, {int sayfa = 1, int adet = 20}) async =>
      await ApiClient.get('/degerlendirmeler/salon/$salonId', params: {'sayfa': sayfa, 'adet': adet});

  static Future<List<Hizmet>> hizmetler(int? salonId) async =>
      ApiClient.liste(await ApiClient.get('/hizmetler/', params: {'salon_id': salonId})).map(Hizmet.fromJson).toList();

  static Future<List<Berber>> berberler(int? salonId) async =>
      ApiClient.liste(await ApiClient.get('/berberler/', params: {'salon_id': salonId})).map(Berber.fromJson).toList();
}
