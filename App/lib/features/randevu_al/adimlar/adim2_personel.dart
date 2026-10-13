import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/config.dart';
import 'package:berber_app_ui/data/models/berber.dart';
import 'package:berber_app_ui/features/randevu_al/randevu_provider.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/salon_api.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';

class Adim2Personel extends StatefulWidget {
  const Adim2Personel({super.key});

  @override
  State<Adim2Personel> createState() => _Adim2PersonelState();
}

class _Adim2PersonelState extends State<Adim2Personel> {
  List<Berber>? _berberler;
  bool _yukleniyor = true;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });
    try {
      final p = context.read<RandevuProvider>();
      final data = await SalonApi.berberler(p.salonId, hizmetIds: p.seciliHizmetler.map((h) => h.id).toList());
      if (!mounted) return;
      setState(() => _berberler = data);
      // Hizmetler değiştiyse: seçili berberin toplamını yenile ya da artık uygun değilse seçimi kaldır
      final secili = data.where((b) => b.id == p.seciliBerber?.id).firstOrNull;
      if (secili != null && secili.uygun) {
        p.berberSec(secili);
      } else if (p.seciliBerber != null) {
        p.berberSeciminiKaldir();
      }
    } on ApiHata catch (e) {
      if (mounted) setState(() => _hata = e.mesaj);
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RandevuProvider>();

    if (_yukleniyor) return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
    if (_hata != null) return HataGorunumu(mesaj: _hata!, onTekrar: _yukle);
    if (_berberler == null || _berberler!.isEmpty) {
      return BosGorunum(ikon: Icons.person_off_outlined, mesaj: Dil.t.personelYok);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _berberler!.length,
      itemBuilder: (_, i) {
        final b = _berberler![i];
        final secili = provider.seciliBerber?.id == b.id;

        return Semantics(
          button: true,
          enabled: b.uygun,
          selected: secili,
          label:
              '${Dil.t.salonSemantik(b.tamAd, b.uzmanlik, b.puanMetni)}'
              '${b.uygun ? '' : ', ${Dil.t.vermiyor(b.vermedigiHizmetler.join(', '))}'}',
          child: GestureDetector(
            key: ValueKey('berber_${b.id}'),
            onTap: b.uygun ? () => provider.berberSec(b) : null,
            child: Opacity(
              opacity: b.uygun ? 1 : 0.45,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: secili ? AppTheme.gold.withValues(alpha: 0.1) : AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: secili ? AppTheme.gold : AppTheme.gold.withValues(alpha: 0.15),
                    width: secili ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.card,
                          child: b.fotoUrl != null
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: AppConfig.medyaUrl(b.fotoUrl!),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, _, _) => const Icon(Icons.person, color: AppTheme.gold, size: 32),
                                  ),
                                )
                              : const Icon(Icons.person, color: AppTheme.gold, size: 32),
                        ),
                        if (secili)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(color: AppTheme.gold, shape: BoxShape.circle),
                              child: const Icon(Icons.check, color: AppTheme.black, size: 13),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.tamAd,
                            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.gold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              b.uzmanlik,
                              style: GoogleFonts.inter(color: AppTheme.gold, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (!b.uygun)
                            Text(
                              Dil.t.vermiyor(b.vermedigiHizmetler.join(', ')),
                              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12),
                            )
                          else if (b.toplamFiyat != null)
                            Text(
                              '${tl(b.toplamFiyat!)} · ${sureMetni(b.toplamSureDk ?? 0)}',
                              key: ValueKey('berber_toplam_${b.id}'),
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const Icon(Icons.star, color: AppTheme.gold, size: 18),
                        Text(
                          b.puanMetni,
                          style: GoogleFonts.inter(color: AppTheme.gold, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
