import 'package:geolocator/geolocator.dart';
import 'package:berber_app_ui/core/dil.dart';

/// Cihaz konumu — izin akışıyla birlikte. Hata mesajları kullanıcıya gösterilebilir Türkçe metinlerdir.
class KonumServisi {
  KonumServisi._();

  static Future<Position> mevcutKonum() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw KonumHatasi(Dil.t.konumServisiKapali);
    }
    var izin = await Geolocator.checkPermission();
    if (izin == LocationPermission.denied) izin = await Geolocator.requestPermission();
    if (izin == LocationPermission.deniedForever) {
      throw KonumHatasi(Dil.t.konumIzniKaliciRed);
    }
    if (izin == LocationPermission.denied) {
      throw KonumHatasi(Dil.t.konumIzniGerekli);
    }
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 15)),
      );
    } catch (_) {
      throw KonumHatasi(Dil.t.konumAlinamadi);
    }
  }
}

class KonumHatasi implements Exception {
  final String mesaj;
  const KonumHatasi(this.mesaj);

  @override
  String toString() => mesaj;
}
