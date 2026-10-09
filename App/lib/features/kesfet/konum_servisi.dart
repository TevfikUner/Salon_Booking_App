import 'package:geolocator/geolocator.dart';

/// Cihaz konumu — izin akışıyla birlikte. Hata mesajları kullanıcıya gösterilebilir Türkçe metinlerdir.
class KonumServisi {
  KonumServisi._();

  static Future<Position> mevcutKonum() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const KonumHatasi('Konum servisi kapalı. Lütfen cihaz ayarlarından açın.');
    }
    var izin = await Geolocator.checkPermission();
    if (izin == LocationPermission.denied) izin = await Geolocator.requestPermission();
    if (izin == LocationPermission.deniedForever) {
      throw const KonumHatasi('Konum izni kalıcı olarak reddedilmiş. Ayarlardan izin verebilirsiniz.');
    }
    if (izin == LocationPermission.denied) {
      throw const KonumHatasi('Yakındaki salonları göstermek için konum izni gerekiyor.');
    }
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 15)),
      );
    } catch (_) {
      throw const KonumHatasi('Konum alınamadı. Lütfen tekrar deneyin.');
    }
  }
}

class KonumHatasi implements Exception {
  final String mesaj;
  const KonumHatasi(this.mesaj);

  @override
  String toString() => mesaj;
}
