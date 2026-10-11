import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';

/// Şehir / ilçe seçicileri, filtre temizleme ve "Konumuma yakın" düğmesi.
class KesfetFiltrePaneli extends StatelessWidget {
  final String? sehir;
  final String? ilce;
  final bool konumModu;
  final bool konumAliniyor;
  final VoidCallback onSehirSec;
  final VoidCallback onIlceSec;
  final VoidCallback onTemizle;
  final VoidCallback onKonum;

  /// Panelin en üstünde gösterilecek arama satırı
  final Widget? ust;

  /// Arama/puan filtresi de etkin mi (temizle düğmesi görünsün)
  final bool ekFiltre;

  const KesfetFiltrePaneli({
    super.key,
    required this.sehir,
    required this.ilce,
    required this.konumModu,
    required this.konumAliniyor,
    required this.onSehirSec,
    required this.onIlceSec,
    required this.onTemizle,
    required this.onKonum,
    this.ust,
    this.ekFiltre = false,
  });

  bool get _filtreVar => sehir != null || konumModu || ekFiltre;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.gold.withValues(alpha: 0.1))),
      ),
      child: Column(children: [
        ?ust,
        Row(children: [
          Expanded(
            child: _Secici(
              ikon: Icons.location_city,
              deger: sehir,
              ipucu: 'Şehir Seçin',
              onTap: onSehirSec,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Secici(
              ikon: Icons.map_outlined,
              deger: ilce,
              ipucu: 'İlçe Seçin',
              onTap: sehir != null ? onIlceSec : null,
            ),
          ),
          if (_filtreVar) ...[
            const SizedBox(width: 8),
            IconButton.filledTonal(
              tooltip: 'Filtreleri temizle',
              onPressed: onTemizle,
              style: IconButton.styleFrom(backgroundColor: AppTheme.error.withValues(alpha: 0.12)),
              icon: const Icon(Icons.clear, color: AppTheme.error, size: 18),
            ),
          ],
        ]),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: konumAliniyor ? null : onKonum,
            style: OutlinedButton.styleFrom(
              backgroundColor: konumModu ? AppTheme.gold.withValues(alpha: 0.18) : AppTheme.gold.withValues(alpha: 0.06),
              side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.35)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: konumAliniyor
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.gold))
                : const Icon(Icons.my_location, color: AppTheme.gold, size: 18),
            label: Text(konumModu ? 'Yakından uzağa sıralanıyor' : 'Konumuma Yakın Salonlar',
                style: GoogleFonts.inter(color: AppTheme.gold, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }
}

class _Secici extends StatelessWidget {
  final IconData ikon;
  final String? deger;
  final String ipucu;
  final VoidCallback? onTap;

  const _Secici({required this.ikon, required this.deger, required this.ipucu, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final aktif = onTap != null;
    final renk = aktif ? AppTheme.gold : AppTheme.textSecondary;
    return Semantics(
      button: true,
      label: deger ?? ipucu,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.black,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: renk.withValues(alpha: aktif ? 0.25 : 0.1)),
          ),
          child: Row(children: [
            Icon(ikon, color: renk, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(deger ?? ipucu,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(color: deger != null ? Colors.white : AppTheme.textSecondary, fontSize: 13)),
            ),
            Icon(Icons.keyboard_arrow_down, color: renk, size: 20),
          ]),
        ),
      ),
    );
  }
}
