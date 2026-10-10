import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:berber_app_ui/core/config.dart';

/// Backend'in döndürdüğü, kullanıcıya gösterilebilir hata.
class ApiHata implements Exception {
  final int? kod;
  final String mesaj;
  final List<String> oneriler;

  const ApiHata(this.mesaj, {this.kod, this.oneriler = const []});

  @override
  String toString() => mesaj;
}

typedef Json = Map<String, dynamic>;

/// Düşük seviye HTTP istemcisi: kimlik başlığı, zaman aşımı, hata çözümleme.
/// Ekranlar bunu doğrudan değil, alan servisleri (HesapApi, SalonApi, RandevuApi, PanelApi) üzerinden kullanır.
class ApiClient {
  ApiClient._();

  /// Okuma istekleri geçici hatalarda (ağ kopması, 502/503/504) 2 kez daha denenir.
  static Future<dynamic> get(String path, {Map<String, dynamic>? params}) async {
    const bekleme = [Duration(milliseconds: 400), Duration(milliseconds: 1200)];
    for (var deneme = 0;; deneme++) {
      try {
        return await _istek('GET', path, params: params);
      } on ApiHata catch (e) {
        final gecici = e.kod == null || e.kod == 502 || e.kod == 503 || e.kod == 504;
        if (!gecici || deneme >= bekleme.length) rethrow;
        await Future.delayed(bekleme[deneme]);
      }
    }
  }

  /// [idempotencyKey]: aynı eylemin tekrarı (çift tıklama, zaman aşımı sonrası yeniden deneme) sunucuda
  /// ikinci kayıt oluşturmasın diye eylem başına bir kez üretilip tekrarlarda aynen gönderilir.
  static Future<dynamic> post(String path, {Map<String, dynamic>? params, Object? govde, String? idempotencyKey}) =>
      _istek('POST', path, params: params, govde: govde, idempotencyKey: idempotencyKey);

  static final _rastgele = Random.secure();

  /// Eylem başına benzersiz anahtar (UUID benzeri, 32 hex).
  static String yeniAnahtar() =>
      List.generate(16, (_) => _rastgele.nextInt(256).toRadixString(16).padLeft(2, '0')).join();

  static Future<dynamic> put(String path, {Object? govde}) => _istek('PUT', path, govde: govde);

  static Future<dynamic> patch(String path, {Map<String, dynamic>? params, Object? govde}) =>
      _istek('PATCH', path, params: params, govde: govde);

  static Future<dynamic> delete(String path) => _istek('DELETE', path);

  static List<Json> liste(dynamic v) => (v as List? ?? const []).cast<Json>();

  static Uri uri(String path, [Map<String, dynamic>? params]) {
    final parcalar = <String>[];
    params?.forEach((k, v) {
      if (v == null) return;
      for (final x in v is List ? v : [v]) {
        parcalar.add('${Uri.encodeQueryComponent(k)}=${Uri.encodeQueryComponent(x.toString())}');
      }
    });
    final base = AppConfig.baseUrl;
    return Uri.parse(parcalar.isEmpty ? '$base$path' : '$base$path?${parcalar.join('&')}');
  }

  static Future<Map<String, String>> _basliklar({required bool json}) async {
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json';
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
    } on FirebaseAuthException {
      // Token yenilenemedi (ağ yok / oturum geçersiz): ekran sonsuz yüklemede kalmasın
      throw const ApiHata('Oturum doğrulanamadı. İnternet bağlantınızı kontrol edip tekrar deneyin.');
    }
    return h;
  }

  static Future<dynamic> _istek(String metod, String path,
      {Map<String, dynamic>? params, Object? govde, String? idempotencyKey}) async {
    final adres = uri(path, params);
    final h = await _basliklar(json: govde != null);
    if (idempotencyKey != null) h['Idempotency-Key'] = idempotencyKey;
    final body = govde != null ? json.encode(govde) : null;
    final http.Response res;
    try {
      final istek = switch (metod) {
        'GET' => http.get(adres, headers: h),
        'POST' => http.post(adres, headers: h, body: body),
        'PUT' => http.put(adres, headers: h, body: body),
        'PATCH' => http.patch(adres, headers: h, body: body),
        'DELETE' => http.delete(adres, headers: h),
        _ => throw ArgumentError(metod),
      };
      res = await istek.timeout(AppConfig.timeout);
    } on TimeoutException {
      throw const ApiHata('Sunucu yanıt vermiyor. İnternet bağlantınızı kontrol edip tekrar deneyin.');
    } on HandshakeException {
      throw const ApiHata('Güvenli bağlantı kurulamadı. Lütfen tekrar deneyin.');
    } on IOException {
      // SocketException vb.
      throw const ApiHata('Sunucuya ulaşılamadı. İnternet bağlantınızı kontrol edin.');
    } on http.ClientException {
      throw const ApiHata('Sunucuya ulaşılamadı. İnternet bağlantınızı kontrol edin.');
    }

    dynamic veri;
    try {
      final ham = utf8.decode(res.bodyBytes);
      veri = ham.isEmpty ? null : json.decode(ham);
    } catch (_) {
      veri = null;
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return veri;
    throw hataCoz(res.statusCode, veri);
  }

  /// FastAPI hata gövdesini kullanıcı mesajına çevirir. (Test edilebilir olsun diye public.)
  static ApiHata hataCoz(int kod, dynamic veri) {
    final detay = veri is Map ? veri['detail'] : null;
    if (detay is String) return ApiHata(detay, kod: kod);
    if (detay is Map) {
      return ApiHata(
        detay['mesaj']?.toString() ?? 'İşlem tamamlanamadı.',
        kod: kod,
        oneriler: List<String>.from(detay['oneriler'] ?? const []),
      );
    }
    if (detay is List && detay.isNotEmpty) return ApiHata('Girilen bilgileri kontrol edin.', kod: kod);
    if (kod == 429) return ApiHata('Çok fazla deneme yaptınız. Lütfen biraz bekleyin.', kod: kod);
    if (kod == 503) return ApiHata('Hizmet geçici olarak kullanılamıyor. Lütfen birazdan tekrar deneyin.', kod: kod);
    return switch (kod) {
      401 => ApiHata('Oturumunuzun süresi doldu. Lütfen tekrar giriş yapın.', kod: kod),
      403 => ApiHata('Bu işlem için yetkiniz yok.', kod: kod),
      404 => ApiHata('Kayıt bulunamadı.', kod: kod),
      _ => ApiHata('Sunucu hatası ($kod). Lütfen daha sonra tekrar deneyin.', kod: kod),
    };
  }
}
