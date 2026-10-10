import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/features/isletme/akis/akis_sekmesi.dart';
import 'package:berber_app_ui/features/isletme/ekip/ekip_sekmesi.dart';
import 'package:berber_app_ui/features/isletme/kapali_gunler/kapali_gunler_sekmesi.dart';
import 'package:berber_app_ui/features/isletme/rapor/rapor_sekmesi.dart';
import 'package:berber_app_ui/features/isletme/widgets/hesap_menusu.dart';

/// İşletme sahibi (ve personel) paneli.
/// Personel yalnızca "Akış" sekmesini görür (backend de yalnızca kendi randevularını döner).
class IsletmePanelScreen extends StatefulWidget {
  final String salonAd;
  final bool personel;
  const IsletmePanelScreen({super.key, required this.salonAd, this.personel = false});

  @override
  State<IsletmePanelScreen> createState() => _IsletmePanelScreenState();
}

class _IsletmePanelScreenState extends State<IsletmePanelScreen> {
  int _sekme = 0;

  @override
  Widget build(BuildContext context) {
    final sekmeler = <(IconData, String, Widget)>[
      (Icons.view_timeline_outlined, 'Akış', AkisSekmesi(personel: widget.personel)),
      if (!widget.personel) ...[
        (Icons.groups_outlined, 'Ekip & Menü', const EkipSekmesi()),
        (Icons.event_busy_outlined, 'Kapalı Günler', const KapaliGunlerSekmesi()),
        (Icons.insights_outlined, 'Rapor', const RaporSekmesi()),
      ],
    ];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(children: [
          Text(widget.salonAd, style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 18,
              fontWeight: FontWeight.bold)),
          Text(widget.personel ? 'Personel Paneli' : 'İşletme Paneli',
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11)),
        ]),
        actions: const [HesapMenusu()],
      ),
      body: IndexedStack(index: _sekme, children: [for (final s in sekmeler) s.$3]),
      bottomNavigationBar: sekmeler.length < 2
          ? null
          : NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: const Color(0xFF141414),
                indicatorColor: AppTheme.gold.withValues(alpha: 0.15),
                labelTextStyle: WidgetStatePropertyAll(GoogleFonts.inter(fontSize: 11, color: AppTheme.gold)),
              ),
              child: NavigationBar(
                selectedIndex: _sekme,
                onDestinationSelected: (i) => setState(() => _sekme = i),
                destinations: [
                  for (final s in sekmeler)
                    NavigationDestination(icon: Icon(s.$1, color: AppTheme.textSecondary),
                        selectedIcon: Icon(s.$1, color: AppTheme.gold), label: s.$2),
                ],
              ),
            ),
    );
  }
}
