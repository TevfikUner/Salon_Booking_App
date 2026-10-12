class Hizmet {
  final int id;
  final String ad;
  final double fiyat;
  final int sure; // dakika
  final String? aciklama;

  /// Personel arasında fiyat/süre farkı varsa aralık (salon menüsünde gelir); yoksa fiyat/süre ile aynı.
  final double fiyatMin, fiyatMax;
  final int sureMin, sureMax;

  /// Bu hizmete uyan aktif kampanyaların en yüksek yüzdesi (0 = yok; gün/saat koşulu salon detayında)
  final int kampanyaYuzde;

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
    this.kampanyaYuzde = 0,
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
        kampanyaYuzde: j['kampanya_yuzde'] ?? 0,
      );

  bool get fiyatDegisken => fiyatMin != fiyatMax;
  bool get sureDegisken => sureMin != sureMax;

  @override
  bool operator ==(Object other) => other is Hizmet && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
