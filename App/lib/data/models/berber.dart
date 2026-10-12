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

  /// Tamamlanan randevu ("tıraş") ve değerlendirme sayısı (salon detayında gelir)
  final int tamamlanan;
  final int degerlendirmeSayisi;

  /// Hizmet seçiminden sonra listelenirken: seçilen hizmetlerin hepsini veriyor mu, vermedikleri ve
  /// bu berberdeki toplam fiyat/süre (berbere özel fiyat olabilir).
  final bool uygun;
  final List<String> vermedigiHizmetler;
  final double? toplamFiyat;
  final int? toplamSureDk;

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
    this.tamamlanan = 0,
    this.degerlendirmeSayisi = 0,
    this.uygun = true,
    this.vermedigiHizmetler = const [],
    this.toplamFiyat,
    this.toplamSureDk,
  });

  String get tamAd => '$ad $soyad'.trim();

  /// "4.8" ya da henüz değerlendirme yoksa "Yeni"
  String get puanMetni => degerlendirmeSayisi > 0 ? puan.toStringAsFixed(1) : 'Yeni';

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
        tamamlanan: j['tamamlanan'] ?? 0,
        degerlendirmeSayisi: j['degerlendirme_sayisi'] ?? 0,
        uygun: j['uygun'] ?? true,
        vermedigiHizmetler: List<String>.from(j['vermedigi_hizmetler'] ?? const []),
        toplamFiyat: (j['toplam_fiyat'] as num?)?.toDouble(),
        toplamSureDk: j['toplam_sure_dk'],
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
        tamamlanan: tamamlanan,
        degerlendirmeSayisi: degerlendirmeSayisi,
        uygun: uygun,
        vermedigiHizmetler: vermedigiHizmetler,
        toplamFiyat: toplamFiyat,
        toplamSureDk: toplamSureDk,
      );
}
