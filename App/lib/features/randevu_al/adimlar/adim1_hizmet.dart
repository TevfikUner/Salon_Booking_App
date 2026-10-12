import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/data/models/hizmet.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/salon_api.dart';
import 'package:berber_app_ui/features/randevu_al/randevu_provider.dart';
import 'package:berber_app_ui/features/kesfet/widgets/kampanya_bilesenleri.dart';

class Adim1Hizmet extends StatefulWidget {
  const Adim1Hizmet({super.key});

  @override
  State<Adim1Hizmet> createState() => _Adim1HizmetState();
}

class _Adim1HizmetState extends State<Adim1Hizmet> {
  List<Hizmet>? _hizmetler;
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
      // Berberle başlayan akış (favori, Her Zamanki): yalnızca onun verdiği hizmetler, onun fiyatlarıyla
      final data = await SalonApi.hizmetler(p.salonId, berberId: p.berberleBasladi ? p.seciliBerber?.id : null);
      if (mounted) setState(() => _hizmetler = data);
    } on ApiHata catch (e) {
      if (mounted) setState(() => _hata = e.mesaj);
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RandevuProvider>();
    if (_yukleniyor || _hata != null) {
      return AsenkronGorunum(yukleniyor: _yukleniyor, hata: _hata, onTekrar: _yukle, builder: (_) => const SizedBox());
    }
    if (_hizmetler!.isEmpty) {
      return const BosGorunum(ikon: Icons.content_cut, mesaj: 'Bu salon henüz hizmet menüsünü eklemedi.');
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _hizmetler!.length,
            itemBuilder: (_, i) {
              final h = _hizmetler![i];
              final secili = provider.isHizmetSecili(h);
              return GestureDetector(
                key: ValueKey('hizmet_${h.id}'),
                onTap: () => provider.hizmetToggle(h),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: secili
                        ? AppTheme.gold.withValues(alpha: 0.12)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: secili ? AppTheme.gold : AppTheme.gold.withValues(alpha: 0.15),
                      width: secili ? 1.5 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Checkbox
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 26, height: 26,
                          decoration: BoxDecoration(
                            color: secili ? AppTheme.gold : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: secili ? AppTheme.gold : AppTheme.textSecondary,
                                width: 1.5),
                          ),
                          child: secili
                              ? const Icon(Icons.check, color: AppTheme.black, size: 16)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        // Bilgi
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Flexible(
                                  child: Text(h.ad,
                                      style: GoogleFonts.inter(
                                          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                                ),
                                if (h.kampanyaYuzde > 0) ...[
                                  const SizedBox(width: 8),
                                  IndirimRozeti(yuzde: h.kampanyaYuzde),
                                ],
                              ]),
                              if (h.aciklama != null && h.aciklama!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(h.aciklama!,
                                    style: GoogleFonts.inter(
                                        color: AppTheme.textSecondary, fontSize: 12)),
                              ],
                              const SizedBox(height: 6),
                              Row(children: [
                                const Icon(Icons.access_time,
                                    color: AppTheme.textSecondary, size: 12),
                                const SizedBox(width: 4),
                                Text(h.sureDegisken ? '${h.sureMin}–${h.sureMax} dk' : '${h.sure} dk',
                                    style: GoogleFonts.inter(
                                        color: AppTheme.textSecondary, fontSize: 12)),
                              ]),
                              if (h.fiyatDegisken || h.sureDegisken) ...[
                                const SizedBox(height: 2),
                                Text('Fiyat ve süre personele göre değişir',
                                    style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
                              ],
                            ],
                          ),
                        ),
                        // Fiyat (personele göre değişiyorsa aralık: "300–350 ₺")
                        Text(
                            h.fiyatDegisken
                                ? '${h.fiyatMin.toStringAsFixed(0)}–${h.fiyatMax.toStringAsFixed(0)} ₺'
                                : '${h.fiyat.toStringAsFixed(0)} ₺',
                            style: GoogleFonts.playfairDisplay(
                                color: AppTheme.gold, fontSize: h.fiyatDegisken ? 16 : 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Alt özet bar
        if (provider.seciliHizmetler.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${provider.seciliHizmetler.length} hizmet seçildi',
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                  Text(_degisken(provider) ? 'Kesin süre personel seçince' : '${provider.toplamSureDk} dakika',
                      style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
                ]),
                Text('${_degisken(provider) ? '~' : ''}${provider.toplamFiyat.toStringAsFixed(0)} ₺',
                    style: GoogleFonts.playfairDisplay(
                        color: AppTheme.gold, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
      ],
    );
  }

  /// Seçilenlerden biri personele göre değişiyorsa özet kesin değildir (berber seçilince netleşir).
  bool _degisken(RandevuProvider p) =>
      !p.toplamKesin && p.seciliHizmetler.any((h) => h.fiyatDegisken || h.sureDegisken);
}
