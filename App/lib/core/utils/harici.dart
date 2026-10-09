import 'package:url_launcher/url_launcher.dart';

/// Telefon, WhatsApp, harita, e-posta gibi dış uygulamaları açan yardımcılar.
/// Hepsi açılıp açılmadığını döner; çağıran taraf başarısızlıkta kullanıcıya mesaj gösterir.
class Harici {
  Harici._();

  static Future<bool> ac(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static Future<bool> ara(String telefon) => ac(Uri(scheme: 'tel', path: telefon.replaceAll(' ', '')));

  /// [numara] uluslararası biçimde ya da 0'lı yerel biçimde olabilir.
  static Future<bool> whatsapp(String numara, {String? mesaj}) {
    var r = numara.replaceAll(RegExp(r'\D'), '');
    if (r.startsWith('0')) r = '9$r';
    if (r.length == 10) r = '90$r';
    return ac(Uri.parse('https://wa.me/$r${mesaj != null ? '?text=${Uri.encodeComponent(mesaj)}' : ''}'));
  }

  static Future<bool> harita(double lat, double lng) async {
    if (await ac(Uri.parse('geo:$lat,$lng?q=$lat,$lng'))) return true;
    return ac(Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'));
  }

  static Future<bool> yolTarifi(double lat, double lng) async {
    if (await ac(Uri.parse('google.navigation:q=$lat,$lng&mode=d'))) return true;
    return ac(Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'));
  }

  static Future<bool> instagram(String adresVeyaKullanici) {
    final s = adresVeyaKullanici.trim();
    return ac(Uri.parse(s.startsWith('http') ? s : 'https://instagram.com/${s.replaceAll('@', '')}'));
  }

  static Future<bool> eposta(String adres, {String? konu, String? govde}) => ac(Uri(
        scheme: 'mailto',
        path: adres,
        query: [
          if (konu != null) 'subject=${Uri.encodeComponent(konu)}',
          if (govde != null) 'body=${Uri.encodeComponent(govde)}',
        ].join('&'),
      ));
}
