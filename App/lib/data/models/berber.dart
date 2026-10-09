class Berber {
  final int id;
  final String ad;
  final String soyad;
  final String uzmanlik;
  final String? fotoUrl;
  final double puan;
  final int? salonId;
  final String? whatsappNo;
  final String? instagramUsername;

  const Berber({
    required this.id,
    required this.ad,
    required this.soyad,
    required this.uzmanlik,
    this.fotoUrl,
    required this.puan,
    this.salonId,
    this.whatsappNo,
    this.instagramUsername,
  });

  String get tamAd => '$ad $soyad'.trim();

  factory Berber.fromJson(Map<String, dynamic> j) => Berber(
        id: j['id'],
        ad: j['ad'] ?? '',
        soyad: j['soyad'] ?? '',
        uzmanlik: j['uzmanlik'] ?? '',
        fotoUrl: j['foto_url'],
        puan: (j['puan'] as num? ?? 0).toDouble(),
        salonId: j['salon_id'],
        whatsappNo: j['whatsapp_no'],
        instagramUsername: j['instagram_username'],
      );
}
