import 'package:berber_app_ui/data/models/berber.dart';

/// Salon — Keşfet listesi ve detay sayfası. Detay alanları (iletişim, ekip) yalnızca detay yanıtında dolar.
class Salon {
  final int id;
  final String ad;
  final String? adres;
  final String? telefon;
  final String? whatsapp;
  final String? instagram;
  final String? fotoUrl;
  final String? sehir;
  final String? ilce;
  final double puan;
  final String acilisSaati;
  final String kapanisSaati;
  final String pazarAcilisSaati;
  final String pazarKapanisSaati;

  /// Haftalık kapalı günler (DateTime.weekday: 1=Pzt … 7=Paz)
  final Set<int> kapaliGunler;
  final double? lat;
  final double? lng;
  final double? mesafeKm;
  final List<Berber> berberler;

  /// Aramada hizmet adından eşleştiyse eşleşen hizmetler (ör. "Sakal Tıraşı")
  final List<String> eslesenHizmetler;

  const Salon({
    required this.id,
    required this.ad,
    this.adres,
    this.telefon,
    this.whatsapp,
    this.instagram,
    this.fotoUrl,
    this.sehir,
    this.ilce,
    this.puan = 0,
    this.acilisSaati = '09:00',
    this.kapanisSaati = '20:00',
    this.pazarAcilisSaati = '10:00',
    this.pazarKapanisSaati = '17:00',
    this.kapaliGunler = const {},
    this.lat,
    this.lng,
    this.mesafeKm,
    this.berberler = const [],
    this.eslesenHizmetler = const [],
  });

  factory Salon.fromJson(Map<String, dynamic> j) {
    final konum = j['konum'] as Map<String, dynamic>?;
    return Salon(
      id: j['id'],
      ad: j['ad'] ?? '',
      adres: j['adres'],
      telefon: j['telefon'],
      whatsapp: j['whatsapp'],
      instagram: j['instagram'],
      fotoUrl: j['foto_url'],
      sehir: j['sehir'],
      ilce: j['ilce'],
      puan: (j['puan'] as num?)?.toDouble() ?? 0,
      acilisSaati: j['acilis_saati'] ?? '09:00',
      kapanisSaati: j['kapanis_saati'] ?? '20:00',
      pazarAcilisSaati: j['pazar_acilis_saati'] ?? '10:00',
      pazarKapanisSaati: j['pazar_kapanis_saati'] ?? '17:00',
      // Backend 0=Pzt … 6=Paz tutar; Dart weekday 1..7
      kapaliGunler: (j['kapali_gunler'] as String? ?? '')
          .split(',')
          .map((x) => int.tryParse(x.trim()))
          .whereType<int>()
          .map((x) => x + 1)
          .toSet(),
      lat: (konum?['lat'] as num?)?.toDouble(),
      lng: (konum?['lng'] as num?)?.toDouble(),
      mesafeKm: (j['mesafe_km'] as num?)?.toDouble(),
      berberler: (j['berberler'] as List? ?? const []).cast<Map<String, dynamic>>().map(Berber.fromJson).toList(),
      eslesenHizmetler: List<String>.from(j['eslesen_hizmetler'] ?? const []),
    );
  }

  String get konumMetni => [sehir, ilce].whereType<String>().where((s) => s.isNotEmpty).join(', ');

  bool get konumVar => lat != null && lng != null;

  /// Verilen gün (DateTime.weekday) için "09:00 – 21:00" veya null (kapalı).
  String? calismaSaati(int weekday) {
    if (kapaliGunler.contains(weekday)) return null;
    return weekday == DateTime.sunday ? '$pazarAcilisSaati – $pazarKapanisSaati' : '$acilisSaati – $kapanisSaati';
  }

  Salon copyWith({List<Berber>? berberler}) => Salon(
        id: id,
        ad: ad,
        adres: adres,
        telefon: telefon,
        whatsapp: whatsapp,
        instagram: instagram,
        fotoUrl: fotoUrl,
        sehir: sehir,
        ilce: ilce,
        puan: puan,
        acilisSaati: acilisSaati,
        kapanisSaati: kapanisSaati,
        pazarAcilisSaati: pazarAcilisSaati,
        pazarKapanisSaati: pazarKapanisSaati,
        kapaliGunler: kapaliGunler,
        lat: lat,
        lng: lng,
        mesafeKm: mesafeKm,
        berberler: berberler ?? this.berberler,
        eslesenHizmetler: eslesenHizmetler,
      );
}
