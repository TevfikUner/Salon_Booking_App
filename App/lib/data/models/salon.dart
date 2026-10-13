import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/data/models/berber.dart';

/// Salonun aktif kampanyası (salon detayında): "Salı İndirimi %20 · Salı · 10:00–14:00"
class Kampanya {
  final int id;
  final String ad;
  final int yuzde;
  final String kosul;
  const Kampanya({required this.id, required this.ad, required this.yuzde, required this.kosul});

  factory Kampanya.fromJson(Map<String, dynamic> j) =>
      Kampanya(id: j['id'], ad: j['ad'] ?? '', yuzde: j['yuzde'] ?? 0, kosul: j['kosul'] ?? '');
}

/// Sadakat kartı: her [esik]. ziyaret %[yuzde] indirimli. [ziyaret] oturum yoksa null.
class SadakatKarti {
  final int esik;
  final int yuzde;
  final int? ziyaret;
  final bool siradakiIndirimli;
  const SadakatKarti({required this.esik, required this.yuzde, this.ziyaret, this.siradakiIndirimli = false});

  factory SadakatKarti.fromJson(Map<String, dynamic> j) => SadakatKarti(
      esik: j['esik'], yuzde: j['yuzde'], ziyaret: j['ziyaret'], siradakiIndirimli: j['siradaki_indirimli'] == true);
}

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

  /// 0 ise salon henüz değerlendirilmemiştir; puan yerine "Yeni" gösterilir.
  final int degerlendirmeSayisi;
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

  /// Aktif kampanyaların en yüksek yüzdesi (0 = kampanya yok) ve sadakat kartı var mı (liste kartı rozetleri)
  final int kampanyaYuzde;
  final bool sadakatVar;

  /// Yalnızca detay yanıtında
  final List<Kampanya> kampanyalar;
  final SadakatKarti? sadakatKarti;

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
    this.degerlendirmeSayisi = 0,
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
    this.kampanyaYuzde = 0,
    this.sadakatVar = false,
    this.kampanyalar = const [],
    this.sadakatKarti,
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
      degerlendirmeSayisi: j['degerlendirme_sayisi'] ?? 0,
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
      kampanyaYuzde: j['kampanya_yuzde'] ?? 0,
      sadakatVar: j['sadakat'] == true,
      kampanyalar: (j['kampanyalar'] as List? ?? const []).cast<Map<String, dynamic>>().map(Kampanya.fromJson).toList(),
      sadakatKarti: j['sadakat_karti'] == null ? null : SadakatKarti.fromJson(j['sadakat_karti']),
    );
  }

  String get konumMetni => [sehir, ilce].whereType<String>().where((s) => s.isNotEmpty).join(', ');

  bool get konumVar => lat != null && lng != null;

  /// "4.8" ya da henüz değerlendirme yoksa "Yeni"
  String get puanMetni => degerlendirmeSayisi > 0 ? puan.toStringAsFixed(1) : Dil.t.yeni;

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
        degerlendirmeSayisi: degerlendirmeSayisi,
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
        kampanyaYuzde: kampanyaYuzde,
        sadakatVar: sadakatVar,
        kampanyalar: kampanyalar,
        sadakatKarti: sadakatKarti,
      );
}
