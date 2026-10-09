import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/features/giris/giris_screen.dart';
import 'package:berber_app_ui/features/giris/isletme_kayit_screen.dart';
import 'package:berber_app_ui/features/giris/widgets/giris_bilesenleri.dart';
import 'package:berber_app_ui/features/giris/widgets/rol_karti.dart';

/// İlk ekran: Müşteri mi, İşletme Sahibi mi?
class RolSecimScreen extends StatefulWidget {
  const RolSecimScreen({super.key});

  @override
  State<RolSecimScreen> createState() => _RolSecimScreenState();
}

class _RolSecimScreenState extends State<RolSecimScreen> with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  Animation<Offset> _kayma(double bas, double son, double x) => Tween(begin: Offset(x, 0), end: Offset.zero)
      .animate(CurvedAnimation(parent: _anim, curve: Interval(bas, son, curve: Curves.easeOut)));

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _git(Widget ekran) => Navigator.push(context, MaterialPageRoute(builder: (_) => ekran));

  @override
  Widget build(BuildContext context) {
    return GirisIskeleti(geriDugmesi: false, children: [
      FadeTransition(
        opacity: CurvedAnimation(parent: _anim, curve: Curves.easeIn),
        child: Column(children: [
          const SizedBox(height: 24),
          const GirisLogosu(boyut: 140),
          const SizedBox(height: 28),
          Text('Hoş Geldiniz',
              style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Devam etmek için rolünüzü seçin', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 48),
          SlideTransition(
            position: _kayma(0.2, 0.7, -0.3),
            child: RolKarti(
              icon: Icons.person_outline,
              baslik: 'Müşteri',
              aciklama: 'Randevu al, berber bul\nve hizmetlerden yararlan',
              gradientColors: const [Color(0xFF2A1F0E), Color(0xFF1A1510)],
              borderColor: AppTheme.gold.withValues(alpha: 0.4),
              onTap: () => _git(const GirisScreen()),
            ),
          ),
          const SizedBox(height: 20),
          SlideTransition(
            position: _kayma(0.35, 0.85, 0.3),
            child: RolKarti(
              icon: Icons.store_outlined,
              baslik: 'İşletme Sahibi',
              aciklama: 'Salonunuzu kaydedin\nve müşterilerinizi yönetin',
              gradientColors: const [Color(0xFF0E1F2A), Color(0xFF101518)],
              borderColor: const Color(0xFF4A90D9).withValues(alpha: 0.4),
              iconColor: const Color(0xFF4A90D9),
              onTap: () => _git(const IsletmeKayitScreen()),
            ),
          ),
          const SizedBox(height: 12),
          AltBaglanti(
            soru: 'Zaten hesabınız var mı?',
            eylem: 'Giriş Yapın',
            onTap: () => _git(const GirisScreen()),
          ),
        ]),
      ),
    ]);
  }
}
