import 'package:berber_app_ui/data/api/api_client.dart';

/// İşletme paneli uçları (/panel/*). Yetki backend'de: onaylı işletme sahibi veya personel.
class PanelApi {
  PanelApi._();

  // ── Bugünün Akışı ──
  static Future<Json> akis({String? tarih}) async => await ApiClient.get('/panel/akis', params: {'tarih': tarih});

  static Future<void> durumGuncelle(int randevuId, String durum) =>
      ApiClient.patch('/panel/randevular/$randevuId/durum', govde: {'durum': durum});

  static Future<Json> randevuEkle({
    required int berberId,
    required String tarih,
    required String saat,
    required List<int> hizmetIds,
    required String musteriAd,
    String musteriTelefon = '',
    String? notlar,
    String? idempotencyKey,
  }) async =>
      await ApiClient.post('/panel/randevular', idempotencyKey: idempotencyKey, govde: {
        'berber_id': berberId,
        'tarih': tarih,
        'saat': saat,
        'hizmet_ids': hizmetIds,
        'musteri_ad': musteriAd,
        'musteri_telefon': musteriTelefon,
        'notlar': notlar,
      });

  static Future<Json> musaitSaatler(int berberId, String tarih, List<int> hizmetIds) async =>
      await ApiClient.get('/panel/musait-saatler',
          params: {'berber_id': berberId, 'tarih': tarih, 'hizmet_ids': hizmetIds});

  // ── Ekip & menü ──
  static Future<List<Json>> personel() async => ApiClient.liste(await ApiClient.get('/panel/personel'));

  static Future<void> personelEkle(Json veri) => ApiClient.post('/panel/personel', govde: veri);

  static Future<void> personelCikar(int id) => ApiClient.delete('/panel/personel/$id');

  static Future<List<Json>> hizmetler() async => ApiClient.liste(await ApiClient.get('/panel/hizmetler'));

  static Future<void> hizmetKaydet(Json veri, {int? id}) =>
      id == null ? ApiClient.post('/panel/hizmetler', govde: veri) : ApiClient.put('/panel/hizmetler/$id', govde: veri);

  static Future<void> hizmetKaldir(int id) => ApiClient.delete('/panel/hizmetler/$id');

  // ── Kapalı günler ──
  static Future<Json> kapaliGunler() async => await ApiClient.get('/panel/tatil');

  static Future<Json> tatilEkle(String tarih, String? aciklama) async =>
      await ApiClient.post('/panel/tatil', govde: {'tarih': tarih, 'aciklama': aciklama});

  static Future<void> tatilSil(int id) => ApiClient.delete('/panel/tatil/$id');

  static Future<Json> izinEkle(int berberId, String tarih, String? aciklama) async =>
      await ApiClient.post('/panel/izin', govde: {'berber_id': berberId, 'tarih': tarih, 'aciklama': aciklama});

  static Future<void> izinSil(int id) => ApiClient.delete('/panel/izin/$id');

  // ── Rapor ──
  static Future<Json> rapor({int? yil, int? ay}) async =>
      await ApiClient.get('/panel/rapor', params: {'yil': yil, 'ay': ay});
}
