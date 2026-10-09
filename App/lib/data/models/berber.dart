class Berber {
  final int id;
  final String ad;
  final String soyad;
  final String uzmanlik;
  final String? fotoUrl;
  final double puan;
  final int? salonId;
  final String? salonAd;

  /// Oturumdaki müşterinin favorisi mi (yalnızca salon detayı / favoriler yanıtında anlamlı)
  final bool favori;

  const Berber({
    required this.id,
    required this.ad,
    required this.soyad,
    required this.uzmanlik,
    this.fotoUrl,
    required this.puan,
    this.salonId,
    this.salonAd,
    this.favori = false,
  });

  String get tamAd => '$ad $soyad'.trim();

  factory Berber.fromJson(Map<String, dynamic> j) => Berber(
        // /musteriler/favoriler yanıtı "berber_id" kullanır
        id: j['id'] ?? j['berber_id'],
        ad: j['ad'] ?? '',
        soyad: j['soyad'] ?? '',
        uzmanlik: j['uzmanlik'] ?? '',
        fotoUrl: j['foto_url'],
        puan: (j['puan'] as num? ?? 0).toDouble(),
        salonId: j['salon_id'],
        salonAd: j['salon_ad'],
        favori: j['favori'] == true || j.containsKey('berber_id'),
      );

  Berber copyWith({bool? favori}) => Berber(
        id: id,
        ad: ad,
        soyad: soyad,
        uzmanlik: uzmanlik,
        fotoUrl: fotoUrl,
        puan: puan,
        salonId: salonId,
        salonAd: salonAd,
        favori: favori ?? this.favori,
      );
}
