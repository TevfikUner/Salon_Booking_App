import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/features/kesfet/kesfet_screen.dart';
import 'package:berber_app_ui/features/musteri/ana_sayfa/ana_sayfa_screen.dart';
import 'package:berber_app_ui/features/musteri/profil/profil_screen.dart';
import 'package:berber_app_ui/features/musteri/randevularim/randevularim_screen.dart';

/// Müşteri kabuğu: Ana Sayfa, Randevularım, Keşfet, Profil.
/// Sekmeye dönüldüğünde Ana Sayfa ve Randevularım tazelenir (başka ekranda randevu alınmış/iptal edilmiş olabilir).
class MainScreen extends StatefulWidget {
  final int baslangicSekmesi;
  const MainScreen({super.key, this.baslangicSekmesi = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _sekme = widget.baslangicSekmesi;
  final _anaSayfa = GlobalKey<AnaSayfaScreenState>();
  final _randevularim = GlobalKey<RandevularimScreenState>();

  late final List<Widget> _sayfalar = [
    AnaSayfaScreen(key: _anaSayfa, onKesfeteGit: () => _git(2), onRandevularimaGit: () => _git(1)),
    RandevularimScreen(key: _randevularim),
    const KesfetScreen(),
    const ProfilEkrani(),
  ];

  void _git(int sekme) {
    if (sekme == _sekme) return;
    setState(() => _sekme = sekme);
    if (sekme == 0) _anaSayfa.currentState?.yenile();
    if (sekme == 1) _randevularim.currentState?.yenile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _sekme, children: _sayfalar),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF141414),
          indicatorColor: AppTheme.gold.withValues(alpha: 0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((s) => GoogleFonts.inter(
                fontSize: 11,
                fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
                color: s.contains(WidgetState.selected) ? AppTheme.gold : AppTheme.textSecondary,
              )),
          iconTheme: WidgetStateProperty.resolveWith(
              (s) => IconThemeData(color: s.contains(WidgetState.selected) ? AppTheme.gold : AppTheme.textSecondary)),
        ),
        child: NavigationBar(
          selectedIndex: _sekme,
          onDestinationSelected: _git,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Ana Sayfa'),
            NavigationDestination(
                icon: Icon(Icons.calendar_today_outlined), selectedIcon: Icon(Icons.calendar_today), label: 'Randevularım'),
            NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Keşfet'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
