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
  }) async => await ApiClient.post(
    '/panel/randevular',
    idempotencyKey: idempotencyKey,
    govde: {
      'berber_id': berberId,
      'tarih': tarih,
      'saat': saat,
      'hizmet_ids': hizmetIds,
      'musteri_ad': musteriAd,
      'musteri_telefon': musteriTelefon,
      'notlar': notlar,
    },
  );

  /// Takvimde sürükle-bırak: randevuyu başka saate/güne/personele taşır. Çakışmada ApiHata (409 + öneriler).
  static Future<Json> randevuTasi(
    int randevuId, {
    required int berberId,
    required String tarih,
    required String saat,
  }) async => await ApiClient.post(
    '/panel/randevular/$randevuId/tasi',
    govde: {'berber_id': berberId, 'tarih': tarih, 'saat': saat},
  );

  static Future<Json> musaitSaatler(int berberId, String tarih, List<int> hizmetIds) async => await ApiClient.get(
    '/panel/musait-saatler',
    params: {'berber_id': berberId, 'tarih': tarih, 'hizmet_ids': hizmetIds},
  );

  // ── Müşteri kartı ──
  static Future<Json> musteriKarti(int musteriId) async => await ApiClient.get('/panel/musteriler/$musteriId');

  /// Boş metin notu siler.
  static Future<Json> musteriNotuKaydet(int musteriId, String metin) async =>
      await ApiClient.put('/panel/musteriler/$musteriId/not', govde: {'metin': metin.trim()});

  // ── Ekip & menü ──
  static Future<List<Json>> personel() async => ApiClient.liste(await ApiClient.get('/panel/personel'));

  static Future<void> personelEkle(Json veri) => ApiClient.post('/panel/personel', govde: veri);

  static Future<void> personelCikar(int id) => ApiClient.delete('/panel/personel/$id');

  /// Tüm alanlar gönderilir; `kapali_gunler` ("0,6") verilmezse backend mevcut değeri korur.
  static Future<void> personelGuncelle(int id, Json veri) => ApiClient.put('/panel/personel/$id', govde: veri);

  // ── Salon ayarları (çalışma saatleri, öğle arası) ──
  static Future<Json> salon() async => await ApiClient.get('/panel/salon');

  static Future<Json> salonGuncelle(Json veri) async => await ApiClient.put('/panel/salon', govde: veri);

  /// [berberId] verilirse yalnızca o personelin verdiği hizmetler, fiyat/süre ona göre.
  static Future<List<Json>> hizmetler({int? berberId}) async =>
      ApiClient.liste(await ApiClient.get('/panel/hizmetler', params: {'berber_id': berberId}));

  /// Personelin her menü hizmeti için: veriyor mu, özel fiyat/süre (null = menüdeki).
  static Future<List<Json>> personelHizmetleri(int berberId) async =>
      ApiClient.liste(await ApiClient.get('/panel/personel/$berberId/hizmetler'));

  static Future<void> personelHizmetleriKaydet(int berberId, List<Json> ayarlar) =>
      ApiClient.put('/panel/personel/$berberId/hizmetler', govde: ayarlar);

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

  /// Berberi bir günün belirli saatlerinde randevuya kapatır; yanıtta çakışan randevu sayısı döner.
  static Future<Json> blokeEkle({
    required int berberId,
    required String tarih,
    required String bas,
    required String bit,
    String? aciklama,
  }) async => await ApiClient.post(
    '/panel/bloke',
    govde: {'berber_id': berberId, 'tarih': tarih, 'bas_saat': bas, 'bit_saat': bit, 'aciklama': aciklama},
  );

  static Future<void> blokeSil(int id) => ApiClient.delete('/panel/bloke/$id');

  // ── Kampanya & sadakat ──
  static Future<List<Json>> kampanyalar() async => ApiClient.liste(await ApiClient.get('/panel/kampanyalar'));

  static Future<void> kampanyaKaydet(Json veri, {int? id}) => id == null
      ? ApiClient.post('/panel/kampanyalar', govde: veri)
      : ApiClient.put('/panel/kampanyalar/$id', govde: veri);

  static Future<void> kampanyaSil(int id) => ApiClient.delete('/panel/kampanyalar/$id');

  /// İkisi de null → sadakat kartı kapanır.
  static Future<void> sadakatAyarla({int? esik, int? yuzde}) =>
      ApiClient.put('/panel/sadakat', govde: {'esik': esik, 'yuzde': yuzde});

  // ── Rapor ──
  static Future<Json> rapor({int? yil, int? ay}) async =>
      await ApiClient.get('/panel/rapor', params: {'yil': yil, 'ay': ay});
}
