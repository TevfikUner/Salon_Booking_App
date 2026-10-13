import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/core/utils/harici.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/models/salon.dart';

/// Salonun WhatsApp / Instagram / harita / yol tarifi / telefon düğmeleri.
/// Bilgisi olmayan düğme gösterilmez.
class IletisimButonlari extends StatelessWidget {
  final Salon salon;
  const IletisimButonlari({super.key, required this.salon});

  Future<void> _calistir(BuildContext context, Future<bool> Function() islem) async {
    if (!await islem() && context.mounted) bilgiGoster(context, Dil.t.uygulamaAcilamadi, hata: true);
  }

  @override
  Widget build(BuildContext context) {
    final s = salon;
    final ust = <Widget>[
      if ((s.whatsapp ?? '').isNotEmpty)
        _Buton(ikon: Icons.chat_outlined, etiket: 'WhatsApp', renk: const Color(0xFF25D366),
            onTap: () => _calistir(context, () => Harici.whatsapp(s.whatsapp!))),
      if ((s.instagram ?? '').isNotEmpty)
        _Buton(ikon: Icons.camera_alt_outlined, etiket: 'Instagram', renk: Colors.purpleAccent,
            onTap: () => _calistir(context, () => Harici.instagram(s.instagram!))),
    ];
    final alt = <Widget>[
      if (s.konumVar) ...[
        _Buton(ikon: Icons.map_outlined, etiket: Dil.t.harita,
            onTap: () => _calistir(context, () => Harici.harita(s.lat!, s.lng!))),
        _Buton(ikon: Icons.navigation_outlined, etiket: Dil.t.yolTarifi, dolu: true,
            onTap: () => _calistir(context, () => Harici.yolTarifi(s.lat!, s.lng!))),
      ],
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        if (ust.isNotEmpty) _satir(ust),
        if (alt.isNotEmpty) _satir(alt),
        if ((s.telefon ?? '').isNotEmpty)
          _Buton(ikon: Icons.phone, etiket: telefonBicimli(s.telefon!),
              onTap: () => _calistir(context, () => Harici.ara(s.telefon!))),
      ]),
    );
  }

  Widget _satir(List<Widget> butonlar) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          for (var i = 0; i < butonlar.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: butonlar[i]),
          ],
        ]),
      );
}

class _Buton extends StatelessWidget {
  final IconData ikon;
  final String etiket;
  final Color renk;
  final bool dolu;
  final VoidCallback onTap;

  const _Buton({required this.ikon, required this.etiket, required this.onTap, this.renk = AppTheme.gold, this.dolu = false});

  @override
  Widget build(BuildContext context) {
    final yazi = dolu ? AppTheme.black : renk;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: dolu ? AppTheme.gold : renk.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: renk.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(ikon, color: yazi, size: 20),
          const SizedBox(width: 8),
          Text(etiket, style: GoogleFonts.inter(color: yazi, fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      ),
    );
  }
}
