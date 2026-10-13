import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/panel_api.dart';

/// Müşterinin en az ne kadar önceden randevu alabileceği (son dakika sınırı). Panelden eklenen randevular muaf.
class OncedenKarti extends StatefulWidget {
  /// `/panel/salon` yanıtı (kayıt tüm çalışma saati alanlarıyla yapılır)
  final Json salon;
  final ValueChanged<Json> onDegisti;
  const OncedenKarti({super.key, required this.salon, required this.onDegisti});

  static const secenekler = [0, 30, 60, 120, 240, 1440];

  @override
  State<OncedenKarti> createState() => _OncedenKartiState();
}

class _OncedenKartiState extends State<OncedenKarti> {
  bool _kaydediliyor = false;

  static String metin(int dk) => dk == 0 ? Dil.t.sinirYok : (dk % 1440 == 0 ? Dil.t.gunSayisi(dk ~/ 1440) : sureMetni(dk));

  Future<void> _sec() async {
    final mevcut = widget.salon['min_onceden_dk'] as int? ?? 0;
    final secim = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Text(Dil.t.oncedenSoru,
                style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(Dil.t.oncedenOrnek,
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
          ),
          for (final dk in OncedenKarti.secenekler)
            ListTile(
              onTap: () => Navigator.pop(ctx, dk),
              selected: dk == mevcut,
              leading: Icon(dk == mevcut ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: AppTheme.gold),
              title: Text(metin(dk), style: const TextStyle(color: Colors.white)),
            ),
          const SizedBox(height: 8),
        ]),
      ),
    );
    if (secim == null || secim == mevcut || !mounted) return;
    setState(() => _kaydediliyor = true);
    try {
      final s = widget.salon;
      final yeni = await PanelApi.salonGuncelle({
        for (final k in ['ad', 'adres', 'telefon', 'whatsapp', 'instagram_url', 'acilis_saati', 'kapanis_saati',
            'pazar_acilis_saati', 'pazar_kapanis_saati', 'kapali_gunler'])
          k: s[k],
        'min_onceden_dk': secim,
      });
      widget.onDegisti(yeni);
      if (mounted) {
        bilgiGoster(context, secim == 0 ? Dil.t.sonDakikaAcikNokta : Dil.t.musterilerEnAz(metin(secim)));
      }
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    } finally {
      if (mounted) setState(() => _kaydediliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dk = widget.salon['min_onceden_dk'] as int? ?? 0;
    return Card(
      child: ListTile(
        key: const ValueKey('onceden_karti'),
        onTap: _kaydediliyor ? null : _sec,
        leading: const Icon(Icons.timer_outlined, color: AppTheme.gold),
        title: Text(dk == 0 ? Dil.t.sonDakikaAcik : Dil.t.enAzOncedenKisa(metin(dk)),
            style: const TextStyle(color: Colors.white)),
        subtitle: Text(Dil.t.oncedenAciklama,
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
        trailing: _kaydediliyor
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.gold))
            : IconButton(
                tooltip: Dil.t.duzenle, icon: const Icon(Icons.edit_outlined, color: AppTheme.gold), onPressed: _sec),
      ),
    );
  }
}
