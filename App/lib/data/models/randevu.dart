class Randevu {
  final int id;
  final int berberId;
  final String berber;
  final int? salonId;
  final String salonAd;
  final String? salonTelefon;
  final List<String> hizmetler;
  final List<int> hizmetIds;
  final String tarih;
  final String saat;
  final String bitis;
  final int sureDk;
  final String durum;
  final double toplamFiyat;
  final int? puan;
  final String? yorum;
  final String? iptalEden;

  /// Kalan erteleme hakkı (backend sınırı, varsayılan 2).
  final int ertelemeHakki;

  const Randevu({
    required this.id,
    required this.berberId,
    required this.berber,
    this.salonId,
    required this.salonAd,
    this.salonTelefon,
    required this.hizmetler,
    this.hizmetIds = const [],
    required this.tarih,
    required this.saat,
    this.bitis = '',
    this.sureDk = 0,
    required this.durum,
    required this.toplamFiyat,
    this.puan,
    this.yorum,
    this.iptalEden,
    this.ertelemeHakki = 0,
  });

  factory Randevu.fromJson(Map<String, dynamic> j) => Randevu(
        id: j['id'],
        berberId: j['berber_id'] ?? 0,
        berber: j['berber'] ?? '',
        salonId: j['salon_id'],
        salonAd: j['salon_ad'] ?? '',
        salonTelefon: j['salon_telefon'],
        hizmetler: List<String>.from(j['hizmetler'] ?? []),
        hizmetIds: List<int>.from(j['hizmet_ids'] ?? []),
        tarih: j['tarih'] ?? '',
        saat: j['saat'] ?? '',
        bitis: j['bitis'] ?? '',
        sureDk: j['sure_dk'] ?? 0,
        durum: j['durum'] ?? '',
        toplamFiyat: (j['toplam_fiyat'] as num? ?? 0).toDouble(),
        puan: j['puan'],
        yorum: j['yorum'],
        iptalEden: j['iptal_eden'],
        ertelemeHakki: j['erteleme_hakki'] ?? 0,
      );

  DateTime get baslangic => DateTime.parse('${tarih}T$saat:00');

  /// Henüz başlamamış ve aktif mi?
  bool get yaklasan => durum == 'onaylandi' && baslangic.isAfter(DateTime.now());
}
