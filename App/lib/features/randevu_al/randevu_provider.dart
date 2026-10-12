import 'package:flutter/material.dart';
import 'package:berber_app_ui/data/models/hizmet.dart';
import 'package:berber_app_ui/data/models/berber.dart';

class RandevuProvider extends ChangeNotifier {
  // ── Salon ID (çoklu salon desteği) ─────────────────────────
  int? salonId;

  void salonSec(int id) {
    salonId = id;
    notifyListeners();
  }

  // ── Adım 1: Hizmetler ─────────────────────────────────────
  final List<Hizmet> seciliHizmetler = [];

  void hizmetToggle(Hizmet h) {
    if (seciliHizmetler.contains(h)) {
      seciliHizmetler.remove(h);
    } else {
      seciliHizmetler.add(h);
    }
    seciliSaat = null; // süre değişti, seçili saat artık uygun olmayabilir
    _berberToplami = null; // berbere özel toplam, personel adımında yeniden gelir
    notifyListeners();
  }

  bool isHizmetSecili(Hizmet h) => seciliHizmetler.contains(h);

  /// Seçilen berberdeki toplam (berbere özel fiyat/süre olabilir). Yoksa hizmet listesindeki değerlerin toplamı:
  /// berberle başlayan akışta liste zaten o berberin fiyatlarıdır.
  ({double fiyat, int sure})? _berberToplami;

  /// Akış berberle başladı (favori, Her Zamanki): personel adımı yok, hizmet listesi o berberin.
  bool berberleBasladi = false;

  /// Toplam fiyat/süre kesin mi (berbere göre netleşti mi)
  bool get toplamKesin => _berberToplami != null || berberleBasladi;

  int get toplamSureDk => _berberToplami?.sure ?? seciliHizmetler.fold(0, (s, h) => s + h.sure);
  double get toplamFiyat => _berberToplami?.fiyat ?? seciliHizmetler.fold(0.0, (s, h) => s + h.fiyat);

  // ── Adım 2: Berber ────────────────────────────────────────
  Berber? seciliBerber;

  void berberSec(Berber b) {
    if (seciliBerber?.id != b.id || toplamSureDk != (b.toplamSureDk ?? toplamSureDk)) {
      seciliTarih = null; // berber değişince izin günleri ve süre değişebilir
      seciliSaat = null;
    }
    seciliBerber = b;
    _berberToplami =
        b.toplamFiyat != null && b.toplamSureDk != null ? (fiyat: b.toplamFiyat!, sure: b.toplamSureDk!) : null;
    notifyListeners();
  }

  /// Seçili berber artık seçilen hizmetleri vermiyorsa (hizmetler değişti) seçimi kaldırır.
  void berberSeciminiKaldir() {
    seciliBerber = null;
    _berberToplami = null;
    seciliTarih = null;
    seciliSaat = null;
    notifyListeners();
  }

  // ── Adım 3: Tarih ─────────────────────────────────────────
  DateTime? seciliTarih;

  void tarihSec(DateTime t) {
    seciliTarih = t;
    seciliSaat = null; // Tarih değişince saat sıfırla
    notifyListeners();
  }

  // ── Adım 4: Saat ──────────────────────────────────────────
  String? seciliSaat;

  void saatSec(String s) {
    seciliSaat = s;
    notifyListeners();
  }

  /// Yeni bir randevu akışı başlarken önceki (yarım kalmış) seçimleri temizler.
  void baslat({int? salon, Berber? berber}) {
    salonId = salon;
    seciliHizmetler.clear();
    seciliBerber = berber;
    berberleBasladi = berber != null;
    _berberToplami = null;
    seciliTarih = null;
    seciliSaat = null;
    // notifyListeners yok: akış ekranının initState'inde (build sırasında) çağrılır,
    // adım ekranları zaten bu değerlerle ilk kez oluşturulur.
  }

  // ── Son onaydan sonra sıfırla ─────────────────────────────
  void reset() {
    salonId = null;
    seciliHizmetler.clear();
    seciliBerber = null;
    berberleBasladi = false;
    _berberToplami = null;
    seciliTarih = null;
    seciliSaat = null;
    notifyListeners();
  }

  // ── Validation ────────────────────────────────────────────
  bool get adim1Tamam => seciliHizmetler.isNotEmpty;
  bool get adim2Tamam => seciliBerber != null;
  bool get adim3Tamam => seciliTarih != null;
  bool get adim4Tamam => seciliSaat != null;
}
