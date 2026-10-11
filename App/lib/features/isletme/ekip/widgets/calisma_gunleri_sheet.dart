import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';

/// Personelin haftalık çalışma günlerini seçtirir. Seçili gün = çalışıyor.
/// Salonun kapalı olduğu günler zaten kapalıdır, seçilemez. Kaydedilirse izinli günleri (0=Pzt … 6=Paz) döner.
Future<Set<int>?> calismaGunleriSec(BuildContext context,
    {required String ad, required Set<int> izinli, required Set<int> salonKapali}) {
  return showModalBottomSheet<Set<int>>(
    context: context,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _CalismaGunleri(ad: ad, izinli: izinli, salonKapali: salonKapali),
  );
}

class _CalismaGunleri extends StatefulWidget {
  final String ad;
  final Set<int> izinli;
  final Set<int> salonKapali;
  const _CalismaGunleri({required this.ad, required this.izinli, required this.salonKapali});

  @override
  State<_CalismaGunleri> createState() => _CalismaGunleriState();
}

class _CalismaGunleriState extends State<_CalismaGunleri> {
  late final Set<int> _izinli = {...widget.izinli};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${widget.ad} · Çalışma günleri',
              style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('İşaretli günlerde çalışır. İşaretsiz günlerde müşteriler bu personelden randevu alamaz.',
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (var g = 0; g < 7; g++)
              FilterChip(
                label: Text(gunKisaAdlari[g]),
                selected: !widget.salonKapali.contains(g) && !_izinli.contains(g),
                onSelected: widget.salonKapali.contains(g)
                    ? null
                    : (calisiyor) => setState(() => calisiyor ? _izinli.remove(g) : _izinli.add(g)),
                selectedColor: AppTheme.gold,
                checkmarkColor: AppTheme.black,
                backgroundColor: AppTheme.card,
                labelStyle: TextStyle(
                    color: !widget.salonKapali.contains(g) && !_izinli.contains(g) ? AppTheme.black : Colors.white),
                tooltip: widget.salonKapali.contains(g) ? 'Salon bu gün kapalı' : null,
              ),
          ]),
          if (widget.salonKapali.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Soluk günlerde salon kapalı.', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _izinli.difference(widget.salonKapali)),
              child: const Text('Kaydet'),
            ),
          ),
        ]),
      ),
    );
  }
}
