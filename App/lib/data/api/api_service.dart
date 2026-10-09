import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:berber_app_ui/core/config.dart';
import 'package:berber_app_ui/data/models/berber.dart';
import 'package:berber_app_ui/data/models/hizmet.dart';
import 'package:berber_app_ui/data/models/randevu.dart';

/// Backend'in döndürdüğü, kullanıcıya gösterilebilir hata.
class ApiHata implements Exception {
  final int? kod;
  final String mesaj;
  final List<String> oneriler;

  const ApiHata(this.mesaj, {this.kod, this.oneriler = const []});

  @override
  String toString() => mesaj;
}

/// Tüm HTTP çağrıları. Kimlik: Firebase ID token (Authorization: Bearer).
class ApiService {
  static String get _base => AppConfig.baseUrl;

  // ── Altyapı ──────────────────────────────────────────────
  static Future<Map<String, String>> _basliklar({bool json = false}) async {
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json';
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  static Uri _uri(String path, [Map<String, dynamic>? params]) {
    final parts = <String>[];
    params?.forEach((k, v) {
      if (v == null) return;
      final liste = v is List ? v : [v];
      for (final x in liste) {
        parts.add('${Uri.encodeQueryComponent(k)}=${Uri.encodeQueryComponent(x.toString())}');
      }
    });
    return Uri.parse(parts.isEmpty ? '$_base$path' : '$_base$path?${parts.join('&')}');
  }

  static Future<dynamic> _istek(
    String metod,
    String path, {
    Map<String, dynamic>? params,
    Object? govde,
  }) async {
    final uri = _uri(path, params);
    final h = await _basliklar(json: govde != null);
    final body = govde != null ? json.encode(govde) : null;
    http.Response res;
    try {
      final f = switch (metod) {
        'GET' => http.get(uri, headers: h),
        'POST' => http.post(uri, headers: h, body: body),
        'PUT' => http.put(uri, headers: h, body: body),
        'PATCH' => http.patch(uri, headers: h, body: body),
        'DELETE' => http.delete(uri, headers: h, body: body),
        _ => throw ArgumentError(metod),
      };
      res = await f.timeout(AppConfig.timeout);
    } on TimeoutException {
      throw const ApiHata('Sunucu yanıt vermiyor. İnternet bağlantınızı kontrol edip tekrar deneyin.');
    } on SocketException {
      throw const ApiHata('Sunucuya ulaşılamadı. İnternet bağlantınızı kontrol edin.');
    } on http.ClientException {
      throw const ApiHata('Sunucuya ulaşılamadı. İnternet bağlantınızı kontrol edin.');
    }

    final ham = utf8.decode(res.bodyBytes);
    dynamic veri;
    try {
      veri = ham.isEmpty ? null : json.decode(ham);
    } catch (_) {
      veri = null;
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return veri;
    throw _hataCoz(res.statusCode, veri);
  }

  static ApiHata _hataCoz(int kod, dynamic veri) {
    final detay = veri is Map ? veri['detail'] : null;
    if (detay is String) return ApiHata(detay, kod: kod);
    if (detay is Map) {
      return ApiHata(
        detay['mesaj']?.toString() ?? 'İşlem tamamlanamadı.',
        kod: kod,
        oneriler: List<String>.from(detay['oneriler'] ?? const []),
      );
    }
    if (detay is List && detay.isNotEmpty) {
      return ApiHata('Girilen bilgileri kontrol edin.', kod: kod); // 422 doğrulama
    }
    return switch (kod) {
      401 => ApiHata('Oturumunuzun süresi doldu. Lütfen tekrar giriş yapın.', kod: kod),
      403 => ApiHata('Bu işlem için yetkiniz yok.', kod: kod),
      404 => ApiHata('Kayıt bulunamadı.', kod: kod),
      _ => ApiHata('Sunucu hatası ($kod). Lütfen daha sonra tekrar deneyin.', kod: kod),
    };
  }

  static List<Map<String, dynamic>> _liste(dynamic v) =>
      (v as List? ?? const []).cast<Map<String, dynamic>>();

  // ── Hesap ────────────────────────────────────────────────
  /// Oturumdaki kullanıcının rolü: musteri / isletme / personel / admin
  static Future<Map<String, dynamic>> ben() async => await _istek('GET', '/ben');

  static Future<void> musteriKayit({
    required String ad,
    required String soyad,
    required String telefon,
    required bool kvkkOnay,
    required bool ticariIletiIzni,
  }) =>
      _istek('POST', '/musteriler/kayit', govde: {
        'ad': ad,
        'soyad': soyad,
        'telefon': telefon,
        'kvkk_onay': kvkkOnay,
        'ticari_ileti_izni': ticariIletiIzni,
      });

  static Future<void> fcmTokenKaydet(String token) =>
      _istek('PATCH', '/musteriler/fcm-token-guncelle', params: {'fcm_token': token});

  static Future<void> hesapSil() => _istek('DELETE', '/musteriler/hesabim');

  static Future<Map<String, dynamic>?> profilGetir() async {
    if (FirebaseAuth.instance.currentUser == null) return null;
    try {
      return await _istek('GET', '/musteriler/profil');
    } on ApiHata {
      return null;
    }
  }

  static Future<void> profilGuncelle({required String ad, required String soyad, required String telefon}) =>
      _istek('PUT', '/musteriler/profil', govde: {'ad': ad, 'soyad': soyad, 'telefon': telefon});

  static Future<void> isletmeKayit({
    required String ad,
    required String soyad,
    required String telefon,
    required String email,
    required String isletmeAdi,
  }) =>
      _istek('POST', '/isletmeler/kayit', params: {
        'ad': ad,
        'soyad': soyad,
        'telefon': telefon,
        'email': email,
        'isletme_adi': isletmeAdi,
      });

  // ── Keşfet ───────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getSalonlar({String? sehir, String? ilce}) async =>
      _liste(await _istek('GET', '/dukkan/salonlar', params: {'sehir': sehir, 'ilce': ilce}));

  static Future<Map<String, dynamic>> getSalonDetay(int salonId) async =>
      await _istek('GET', '/dukkan/salon/$salonId');

  static Future<Map<String, dynamic>> getFiltreler() async => await _istek('GET', '/dukkan/filtreler');

  static Future<Map<String, dynamic>> getIstatistik({int? salonId}) async {
    try {
      return await _istek('GET', '/randevular/istatistik', params: {'salon_id': salonId});
    } on ApiHata {
      return {'bugunku_randevu': 0, 'musait_slot_sayisi': 0};
    }
  }

  static Future<List<Hizmet>> getHizmetler({int? salonId}) async =>
      _liste(await _istek('GET', '/hizmetler/', params: {'salon_id': salonId})).map(Hizmet.fromJson).toList();

  static Future<List<Berber>> getBerberler({int? salonId}) async =>
      _liste(await _istek('GET', '/berberler/', params: {'salon_id': salonId})).map(Berber.fromJson).toList();

  // ── Randevu akışı ────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getMusaitTakvim({int? berberId, int? salonId}) async =>
      _liste(await _istek('GET', '/randevular/musait-takvim',
          params: {'berber_id': berberId, 'salon_id': salonId}));

  /// Seçilen gün + hizmetler için backend'in hesapladığı saatler (tek doğruluk kaynağı).
  static Future<Map<String, dynamic>> getMusaitSaatler(int berberId, String tarih, List<int> hizmetIds) async =>
      await _istek('GET', '/randevular/musait-saatler/$berberId',
          params: {'tarih': tarih, 'hizmet_ids': hizmetIds});

  static Future<List<Map<String, dynamic>>> getEnYakinSlotlar(int berberId, List<int> hizmetIds,
          {int adet = 3}) async =>
      _liste((await _istek('GET', '/randevular/en-yakin/$berberId',
          params: {'hizmet_ids': hizmetIds, 'adet': adet}))['slotlar']);

  static Future<Map<String, dynamic>> randevuOlustur({
    required int berberId,
    required String saat,
    required String tarih,
    required List<int> hizmetIds,
    String ad = '',
    String soyad = '',
    String telefon = '',
  }) async =>
      await _istek('POST', '/randevular/olustur', params: {
        'berber_id': berberId,
        'saat': saat,
        'tarih': tarih,
        'hizmet_ids': hizmetIds,
        'ad': ad,
        'soyad': soyad,
        'telefon': telefon,
      });

  static Future<void> beklemeListesineEkle(int berberId, String tarih, List<int> hizmetIds) =>
      _istek('POST', '/randevular/bekleme-listesi',
          govde: {'berber_id': berberId, 'tarih': tarih, 'hizmet_ids': hizmetIds});

  static Future<List<Randevu>> getRandevularim() async {
    try {
      return _liste(await _istek('GET', '/randevular/benim-randevularim')).map(Randevu.fromJson).toList();
    } on ApiHata catch (e) {
      if (e.kod == 404) return []; // henüz müşteri kaydı yok
      rethrow;
    }
  }

  /// İmza özellik: en sık alınan berber+hizmet ve en yakın boş slotlar (geçmiş yoksa null).
  static Future<Map<String, dynamic>?> herZamanki() async {
    try {
      return await _istek('GET', '/randevular/her-zamanki') as Map<String, dynamic>?;
    } on ApiHata catch (e) {
      if (e.kod == 404) return null;
      rethrow;
    }
  }

  static Future<void> randevuIptal(int randevuId) => _istek('POST', '/randevular/$randevuId/iptal');

  static Future<Map<String, dynamic>> degerlendirmeEkle({
    required int randevuId,
    required int puan,
    String? yorum,
  }) async =>
      await _istek('POST', '/degerlendirmeler/ekle', params: {
        'randevu_id': randevuId,
        'puan': puan,
        if (yorum != null && yorum.isNotEmpty) 'yorum': yorum,
      });

  // ── Favoriler ────────────────────────────────────────────
  static Future<Map<String, dynamic>> favoriToggle(int berberId) async =>
      await _istek('POST', '/musteriler/favori-toggle', params: {'berber_id': berberId});

  static Future<List<Map<String, dynamic>>> favorileriGetir() async {
    try {
      return _liste(await _istek('GET', '/musteriler/favoriler'));
    } on ApiHata {
      return [];
    }
  }

  // ── İşletme paneli ───────────────────────────────────────
  static Future<Map<String, dynamic>> panelAkis({String? tarih}) async =>
      await _istek('GET', '/panel/akis', params: {'tarih': tarih});

  static Future<void> panelDurum(int randevuId, String durum) =>
      _istek('PATCH', '/panel/randevular/$randevuId/durum', govde: {'durum': durum});

  static Future<Map<String, dynamic>> panelRandevuEkle({
    required int berberId,
    required String tarih,
    required String saat,
    required List<int> hizmetIds,
    required String musteriAd,
    String musteriTelefon = '',
    String? notlar,
  }) async =>
      await _istek('POST', '/panel/randevular', govde: {
        'berber_id': berberId,
        'tarih': tarih,
        'saat': saat,
        'hizmet_ids': hizmetIds,
        'musteri_ad': musteriAd,
        'musteri_telefon': musteriTelefon,
        'notlar': notlar,
      });

  static Future<Map<String, dynamic>> panelMusaitSaatler(int berberId, String tarih, List<int> hizmetIds) async =>
      await _istek('GET', '/panel/musait-saatler',
          params: {'berber_id': berberId, 'tarih': tarih, 'hizmet_ids': hizmetIds});

  static Future<List<Map<String, dynamic>>> panelPersonel() async => _liste(await _istek('GET', '/panel/personel'));

  static Future<void> panelPersonelEkle(Map<String, dynamic> veri) => _istek('POST', '/panel/personel', govde: veri);

  static Future<void> panelPersonelCikar(int id) => _istek('DELETE', '/panel/personel/$id');

  static Future<List<Map<String, dynamic>>> panelHizmetler() async => _liste(await _istek('GET', '/panel/hizmetler'));

  static Future<void> panelHizmetKaydet(Map<String, dynamic> veri, {int? id}) => id == null
      ? _istek('POST', '/panel/hizmetler', govde: veri)
      : _istek('PUT', '/panel/hizmetler/$id', govde: veri);

  static Future<void> panelHizmetKaldir(int id) => _istek('DELETE', '/panel/hizmetler/$id');

  static Future<Map<String, dynamic>> panelKapaliGunler() async => await _istek('GET', '/panel/tatil');

  static Future<Map<String, dynamic>> panelTatilEkle(String tarih, String? aciklama) async =>
      await _istek('POST', '/panel/tatil', govde: {'tarih': tarih, 'aciklama': aciklama});

  static Future<void> panelTatilSil(int id) => _istek('DELETE', '/panel/tatil/$id');

  static Future<Map<String, dynamic>> panelIzinEkle(int berberId, String tarih, String? aciklama) async =>
      await _istek('POST', '/panel/izin', govde: {'berber_id': berberId, 'tarih': tarih, 'aciklama': aciklama});

  static Future<void> panelIzinSil(int id) => _istek('DELETE', '/panel/izin/$id');

  static Future<Map<String, dynamic>> panelRapor({int? yil, int? ay}) async =>
      await _istek('GET', '/panel/rapor', params: {'yil': yil, 'ay': ay});
}
