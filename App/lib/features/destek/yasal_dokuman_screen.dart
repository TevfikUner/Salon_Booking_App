import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/data/sabit/yasal_metinler.dart';

/// Yasal dokümanları uygulama içinden gösteren ekran
class YasalDokumanScreen extends StatelessWidget {
  final String baslik;
  final String icerik;

  /// Aynı belgenin herkese açık web adresi (varsa AppBar'da "tarayıcıda aç").
  final String? webAdresi;

  const YasalDokumanScreen({super.key, required this.baslik, required this.icerik, this.webAdresi});

  YasalDokumanScreen.belge(YasalMetin m, {Key? key})
      : this(key: key, baslik: m.baslik, icerik: m.icerik, webAdresi: m.webAdresi);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        backgroundColor: AppTheme.black,
        leading: const BackButton(color: AppTheme.gold),
        title: Text(baslik,
            style: GoogleFonts.playfairDisplay(
                color: AppTheme.gold,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        actions: [
          if (webAdresi != null)
            IconButton(
              tooltip: Dil.t.tarayicidaAc,
              icon: const Icon(Icons.open_in_new, color: AppTheme.gold),
              onPressed: () => launchUrl(Uri.parse(webAdresi!), mode: LaunchMode.externalApplication),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: SelectableText(
          // Yasal metinler bağlayıcı olduğu için yalnızca Türkçe; İngilizce arayüzde başta not
          Dil.ingilizce ? '${Dil.t.yasalMetinTurkce}\n\n$icerik' : icerik,
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 14,
            height: 1.7,
          ),
        ),
      ),
    );
  }

}
