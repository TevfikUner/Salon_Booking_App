import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/config.dart';
import 'package:berber_app_ui/core/demo_oturum.dart';

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

  /// JSON olmayan yanıt (ör. .ics dosyası) için ham metin döner; hata yanıtları yine ApiHata'ya çevrilir.
  static Future<String> metin(String path) async => await _istek('GET', path, ham: true) as String;

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

  /// Entegrasyon testi, gerçek Firebase hesabı açmadan backend'in dev modunda (`dev:<uid>`) çalışsın diye.
  /// Uygulama kodunda ATANMAZ; release derlemede null kalır.
  @visibleForTesting
  static Future<String?> Function()? testJetonu;

  static Future<Map<String, String>> _basliklar({required bool json}) async {
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json';
    h['Accept-Language'] = Dil.kod;
    try {
      final demoUid = DemoOturum.uid;
      final token = await (testJetonu ??
          (demoUid != null ? () async => 'dev:$demoUid' : null) ??
          () async => FirebaseAuth.instance.currentUser?.getIdToken())();
      if (token != null) h['Authorization'] = 'Bearer $token';
    } on FirebaseAuthException {
      // Token yenilenemedi (ağ yok / oturum geçersiz): ekran sonsuz yüklemede kalmasın
      throw ApiHata(Dil.t.hataOturumDogrulanamadi);
    }
    return h;
  }

  static Future<dynamic> _istek(String metod, String path,
      {Map<String, dynamic>? params, Object? govde, String? idempotencyKey, bool ham = false}) async {
    final adres = uri(path, params);
    final h = await _basliklar(json: govde != null);
    if (idempotencyKey != null) h['Idempotency-Key'] = idempotencyKey;
    final body = govde != null ? json.encode(govde) : null;
    final res = await _agIstegi(switch (metod) {
      'GET' => http.get(adres, headers: h),
      'POST' => http.post(adres, headers: h, body: body),
      'PUT' => http.put(adres, headers: h, body: body),
      'PATCH' => http.patch(adres, headers: h, body: body),
      'DELETE' => http.delete(adres, headers: h),
      _ => throw ArgumentError(metod),
    });
    return _yanitCoz(res, ham: ham);
  }

  /// Dosya yükleme (multipart/form-data), ör. profil fotoğrafı. Gövde büyük olduğundan zaman aşımı daha uzun.
  static Future<dynamic> dosyaGonder(String path,
      {required String alan, required List<int> baytlar, required String dosyaAdi}) async {
    final istek = http.MultipartRequest('POST', uri(path))
      ..headers.addAll(await _basliklar(json: false))
      ..files.add(http.MultipartFile.fromBytes(alan, baytlar, filename: dosyaAdi));
    final res = await _agIstegi(istek.send().then(http.Response.fromStream), sure: AppConfig.timeout * 4);
    return _yanitCoz(res);
  }

  /// Ağ hatalarını kullanıcı mesajına çevirir.
  static Future<http.Response> _agIstegi(Future<http.Response> istek, {Duration? sure}) async {
    try {
      return await istek.timeout(sure ?? AppConfig.timeout);
    } on TimeoutException {
      throw ApiHata(Dil.t.hataSunucuYanitVermiyor);
    } on HandshakeException {
      throw ApiHata(Dil.t.hataGuvenliBaglanti);
    } on IOException {
      // SocketException vb.
      throw ApiHata(Dil.t.hataSunucuyaUlasilamadi);
    } on http.ClientException {
      throw ApiHata(Dil.t.hataSunucuyaUlasilamadi);
    }
  }

  static dynamic _yanitCoz(http.Response res, {bool ham = false}) {
    if (ham && res.statusCode >= 200 && res.statusCode < 300) return utf8.decode(res.bodyBytes);
    dynamic veri;
    try {
      final govdeMetni = utf8.decode(res.bodyBytes);
      veri = govdeMetni.isEmpty ? null : json.decode(govdeMetni);
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
        detay['mesaj']?.toString() ?? Dil.t.hataIslemTamamlanamadi,
        kod: kod,
        oneriler: List<String>.from(detay['oneriler'] ?? const []),
      );
    }
    if (detay is List && detay.isNotEmpty) return ApiHata(Dil.t.hataBilgileriKontrolEdin, kod: kod);
    if (kod == 429) return ApiHata(Dil.t.hataCokFazlaDeneme, kod: kod);
    if (kod == 503) return ApiHata(Dil.t.hataHizmetKullanilamiyor, kod: kod);
    return switch (kod) {
      401 => ApiHata(Dil.t.hataOturumSuresiDoldu, kod: kod),
      403 => ApiHata(Dil.t.hataYetkiYok, kod: kod),
      404 => ApiHata(Dil.t.hataKayitBulunamadi, kod: kod),
      _ => ApiHata(Dil.t.hataSunucu(kod), kod: kod),
    };
  }
}
