class Hizmet {
  final int id;
  final String ad;
  final double fiyat;
  final int sure; // dakika
  final String? aciklama;

  /// Personel arasında fiyat/süre farkı varsa aralık (salon menüsünde gelir); yoksa fiyat/süre ile aynı.
  final double fiyatMin, fiyatMax;
  final int sureMin, sureMax;

  const Hizmet({
    required this.id,
    required this.ad,
    required this.fiyat,
    required this.sure,
    this.aciklama,
    double? fiyatMin,
    double? fiyatMax,
    int? sureMin,
    int? sureMax,
  })  : fiyatMin = fiyatMin ?? fiyat,
        fiyatMax = fiyatMax ?? fiyat,
        sureMin = sureMin ?? sure,
        sureMax = sureMax ?? sure;

  factory Hizmet.fromJson(Map<String, dynamic> j) => Hizmet(
        id: j['id'],
        ad: j['ad'],
        fiyat: (j['fiyat'] as num).toDouble(),
        sure: j['sure'],
        aciklama: j['aciklama'],
        fiyatMin: (j['fiyat_min'] as num?)?.toDouble(),
        fiyatMax: (j['fiyat_max'] as num?)?.toDouble(),
        sureMin: j['sure_min'],
        sureMax: j['sure_max'],
      );

  bool get fiyatDegisken => fiyatMin != fiyatMax;
  bool get sureDegisken => sureMin != sureMax;

  @override
  bool operator ==(Object other) => other is Hizmet && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
