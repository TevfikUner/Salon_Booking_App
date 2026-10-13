import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/services/bildirim_servisi.dart';

/// "Şimdi değil" denince bir daha sorulmaması için tercih anahtarı.
const bildirimIzniErtelendiAnahtari = 'bildirim_izni_ertelendi';

/// Randevu onayında (değerin en net olduğu an) bildirim iznini açıklamalı bir kartla ister.
/// İzin verilmişse ya da kullanıcı daha önce "Şimdi değil" dediyse hiç görünmez.
/// Reddedilmişse ayarlardan nasıl açılacağını bir kez söyler.
class BildirimIzniKarti extends StatefulWidget {
  /// Testte değiştirilebilir; varsayılan Firebase Messaging.
  final Future<BildirimIzni?> Function() durumGetir;
  final Future<bool> Function() izinIste;

  const BildirimIzniKarti({
    super.key,
    this.durumGetir = BildirimServisi.izinDurumu,
    this.izinIste = BildirimServisi.izinIste,
  });

  @override
  State<BildirimIzniKarti> createState() => _BildirimIzniKartiState();
}

class _BildirimIzniKartiState extends State<BildirimIzniKarti> {
  BildirimIzni? _durum;
  bool _gizli = true;

  @override
  void initState() {
    super.initState();
    _kontrol();
  }

  Future<void> _kontrol() async {
    final durum = await widget.durumGetir();
    var ertelendi = false;
    try {
      ertelendi = (await SharedPreferences.getInstance()).getBool(bildirimIzniErtelendiAnahtari) ?? false;
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _durum = durum;
      _gizli = durum == null || durum == BildirimIzni.verildi || ertelendi;
    });
  }

  Future<void> _ertele() async {
    setState(() => _gizli = true);
    try {
      await (await SharedPreferences.getInstance()).setBool(bildirimIzniErtelendiAnahtari, true);
    } catch (_) {}
  }

  Future<void> _izinVer() async {
    final verildi = await widget.izinIste();
    if (!mounted) return;
    if (verildi) {
      setState(() => _gizli = true); // token girişte zaten kaydedildi
      return;
    }
    setState(() => _durum = BildirimIzni.reddedildi);
  }

  @override
  Widget build(BuildContext context) {
    if (_gizli) return const SizedBox.shrink();
    final reddedildi = _durum == BildirimIzni.reddedildi;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(reddedildi ? Icons.notifications_off_outlined : Icons.notifications_active_outlined,
              color: AppTheme.gold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(reddedildi ? Dil.t.bildirimlerKapali : Dil.t.hatirlatalimMi,
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 6),
        Text(
          reddedildi
              ? Dil.t.bildirimKapaliAciklama
              : Dil.t.bildirimIzniAciklama,
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 10),
        // Büyük yazı boyutunda düğmeler alt alta geçsin (taşma yerine)
        Align(
          alignment: Alignment.centerRight,
          child: Wrap(alignment: WrapAlignment.end, spacing: 8, runSpacing: 4, children: [
            TextButton(onPressed: _ertele, child: Text(reddedildi ? Dil.t.tamam : Dil.t.simdiDegil)),
            if (!reddedildi)
              ElevatedButton(
                onPressed: _izinVer,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10)),
                child: Text(Dil.t.evetHatirlat),
              ),
          ]),
        ),
      ]),
    );
  }
}
