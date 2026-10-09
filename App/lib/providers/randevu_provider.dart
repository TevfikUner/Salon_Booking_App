import 'package:flutter/material.dart';
import '../models/hizmet.dart';
import '../models/berber.dart';

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
    notifyListeners();
  }

  bool isHizmetSecili(Hizmet h) => seciliHizmetler.contains(h);

  int get toplamSureDk => seciliHizmetler.fold(0, (s, h) => s + h.sure);
  double get toplamFiyat => seciliHizmetler.fold(0.0, (s, h) => s + h.fiyat);

  // ── Adım 2: Berber ────────────────────────────────────────
  Berber? seciliBerber;

  void berberSec(Berber b) {
    if (seciliBerber?.id != b.id) {
      seciliTarih = null; // berber değişince izin günleri değişebilir
      seciliSaat = null;
    }
    seciliBerber = b;
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
