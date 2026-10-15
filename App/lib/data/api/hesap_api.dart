import 'package:firebase_auth/firebase_auth.dart';

import 'package:berber_app_ui/core/demo_oturum.dart';
import 'package:berber_app_ui/data/api/api_client.dart';

/// Oturum, profil, KVKK, favoriler, işletme başvurusu.
class HesapApi {
  HesapApi._();

  /// Oturumdaki kullanıcının rolü (musteri / isletme / personel / admin) ve bağlamı.
  static Future<Json> ben() async => await ApiClient.get('/ben');

  static Future<void> musteriKayit({
    required String ad,
    required String soyad,
    required String telefon,
    required bool kvkkOnay,
    required bool ticariIletiIzni,
  }) =>
      ApiClient.post('/musteriler/kayit', govde: {
        'ad': ad,
        'soyad': soyad,
        'telefon': telefon,
        'kvkk_onay': kvkkOnay,
        'ticari_ileti_izni': ticariIletiIzni,
      });

  static Future<void> isletmeKayit({
    required String ad,
    required String soyad,
    required String telefon,
    required String email,
    required String isletmeAdi,
  }) =>
      ApiClient.post('/isletmeler/kayit', params: {
        'ad': ad,
        'soyad': soyad,
        'telefon': telefon,
        'email': email,
        'isletme_adi': isletmeAdi,
      });

  static Future<void> fcmTokenKaydet(String token) =>
      ApiClient.patch('/musteriler/fcm-token-guncelle', params: {'fcm_token': token});

  /// Profil fotoğrafını yükler; yeni `foto_url`'i döner (göreli olabilir → AppConfig.medyaUrl).
  static Future<String> profilFotoYukle(List<int> baytlar, String dosyaAdi) async {
    final yanit = await ApiClient.dosyaGonder('/musteriler/profil-foto',
        alan: 'foto', baytlar: baytlar, dosyaAdi: dosyaAdi);
    return (yanit as Map)['foto_url'] as String;
  }

  static Future<void> profilFotoSil() => ApiClient.delete('/musteriler/profil-foto');

  /// Sunucu Firebase kullanıcısını da sildiyse true (istemcinin ayrıca silmesine gerek kalmaz).
  static Future<bool> hesapSil() async {
    final yanit = await ApiClient.delete('/musteriler/hesabim');
    return yanit is Map && yanit['firebase_silindi'] == true;
  }

  /// Profil yoksa veya oturum kapalıysa null.
  static Future<Json?> profil() async {
    if (FirebaseAuth.instance.currentUser == null && !DemoOturum.aktif) return null;
    try {
      return await ApiClient.get('/musteriler/profil');
    } on ApiHata {
      return null;
    }
  }

  static Future<void> profilGuncelle({required String ad, required String soyad, required String telefon}) =>
      ApiClient.put('/musteriler/profil', govde: {'ad': ad, 'soyad': soyad, 'telefon': telefon});

  /// true: favorilere eklendi, false: çıkarıldı.
  static Future<bool> favoriToggle(int berberId) async {
    final v = await ApiClient.post('/musteriler/favori-toggle', params: {'berber_id': berberId});
    return v['favori'] == true;
  }

  static Future<List<Json>> favoriler() async {
    try {
      return ApiClient.liste(await ApiClient.get('/musteriler/favoriler'));
    } on ApiHata {
      return [];
    }
  }
}
