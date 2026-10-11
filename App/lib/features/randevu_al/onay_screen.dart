import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        baslik: '${widget.salonAd ?? 'Berber'} — ${widget.hizmetler.join(', ')}',
        aciklama: 'Berber: ${widget.berber}\nToplam: ${tl(widget.toplamFiyat)}',
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
                    Text('Randevunuz Onaylandı!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Sizi bekliyoruz 💈', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 15)),
                    const SizedBox(height: 28),
                    RandevuOzeti(
                      toplam: widget.toplamFiyat,
                      satirlar: [
                        if (widget.salonAd != null) (Icons.storefront, 'Salon', widget.salonAd!),
                        (Icons.calendar_today, 'Tarih', tarihUzun(widget.tarih, yil: true)),
                        (Icons.access_time, 'Saat', widget.bitis == null ? widget.saat : '${widget.saat} – ${widget.bitis}'),
                        (Icons.person, 'Personel', widget.berber),
                        (Icons.content_cut, 'Hizmetler', widget.hizmetler.join(', ')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Randevudan 1 saat önce hatırlatma bildirimi alacaksınız.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
                    const BildirimIzniKarti(),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => TakvimPaylasimi.secenekleriGoster(context, _etkinlik),
                      icon: const Icon(Icons.event_available, color: AppTheme.gold),
                      label: const Text('Takvime Ekle', style: TextStyle(color: AppTheme.gold)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.gold)),
                    ),
                    const SizedBox(height: 20),
                    AltinButon(text: 'Ana Sayfaya Dön', onPressed: () => _anaEkrana(0)),
                    TextButton(onPressed: () => _anaEkrana(1), child: const Text('Randevularımı Gör')),
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
