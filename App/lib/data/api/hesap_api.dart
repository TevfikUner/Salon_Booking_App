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

  static Future<void> hesapSil() => ApiClient.delete('/musteriler/hesabim');

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
