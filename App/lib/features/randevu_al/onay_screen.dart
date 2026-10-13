import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/core/widgets/altin_buton.dart';
import 'package:berber_app_ui/core/widgets/berber_desen.dart';
import 'package:berber_app_ui/features/musteri/main_screen.dart';
import 'package:berber_app_ui/features/randevu_al/widgets/bildirim_izni_karti.dart';
import 'package:berber_app_ui/features/randevu_al/widgets/randevu_ozeti.dart';
import 'package:berber_app_ui/services/takvim_paylasimi.dart';

/// Randevu alındıktan sonraki onay ekranı.
class OnaySayfasi extends StatefulWidget {
  final String tarih;
  final String saat;
  final String? bitis;
  final String berber;
  final String? salonAd;
  final List<String> hizmetler;
  final double toplamFiyat;
  final double indirim;
  final String? indirimAciklama;
  final String randevuId;

  const OnaySayfasi({
    super.key,
    required this.tarih,
    required this.saat,
    required this.berber,
    required this.hizmetler,
    required this.toplamFiyat,
    required this.randevuId,
    this.bitis,
    this.salonAd,
    this.indirim = 0,
    this.indirimAciklama,
  });

  @override
  State<OnaySayfasi> createState() => _OnaySayfasiState();
}

class _OnaySayfasiState extends State<OnaySayfasi> with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  TakvimEtkinligi get _etkinlik => TakvimEtkinligi(
        randevuId: int.tryParse(widget.randevuId) ?? 0,
        tarih: widget.tarih,
        saat: widget.saat,
        bitis: widget.bitis,
        baslik: '${widget.salonAd ?? Dil.t.berber} — ${widget.hizmetler.join(', ')}',
        aciklama: Dil.t.takvimAciklama(widget.berber, tl(widget.toplamFiyat)),
      );

  void _anaEkrana(int sekme) => Navigator.of(context)
      .pushAndRemoveUntil(MaterialPageRoute(builder: (_) => MainScreen(baslangicSekmesi: sekme)), (_) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        const BerberDesenWidget(),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                ScaleTransition(
                  scale: CurvedAnimation(parent: _anim, curve: Curves.elasticOut),
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.goldGradient,
                      boxShadow: [BoxShadow(color: AppTheme.gold.withValues(alpha: 0.5), blurRadius: 40, spreadRadius: 4)],
                    ),
                    child: const Icon(Icons.check_rounded, color: AppTheme.black, size: 60),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: CurvedAnimation(parent: _anim, curve: Curves.easeIn),
                  child: Column(children: [
                    Text(Dil.t.randevunuzOnaylandi,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(Dil.t.siziBekliyoruz, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 15)),
                    const SizedBox(height: 28),
                    RandevuOzeti(
                      toplam: widget.toplamFiyat,
                      indirim: widget.indirim,
                      indirimAciklama: widget.indirimAciklama,
                      satirlar: [
                        if (widget.salonAd != null) (Icons.storefront, Dil.t.salon, widget.salonAd!),
                        (Icons.calendar_today, Dil.t.tarih, tarihUzun(widget.tarih, yil: true)),
                        (Icons.access_time, Dil.t.saat, widget.bitis == null ? widget.saat : '${widget.saat} – ${widget.bitis}'),
                        (Icons.person, Dil.t.personel, widget.berber),
                        (Icons.content_cut, Dil.t.hizmetler, widget.hizmetler.join(', ')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(Dil.t.birSaatOnceHatirlatma,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
                    const BildirimIzniKarti(),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => TakvimPaylasimi.secenekleriGoster(context, _etkinlik),
                      icon: const Icon(Icons.event_available, color: AppTheme.gold),
                      label: Text(Dil.t.takvimeEkle, style: TextStyle(color: AppTheme.gold)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.gold)),
                    ),
                    const SizedBox(height: 20),
                    AltinButon(text: Dil.t.anaSayfayaDon, onPressed: () => _anaEkrana(0)),
                    TextButton(onPressed: () => _anaEkrana(1), child: Text(Dil.t.randevularimiGor)),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
