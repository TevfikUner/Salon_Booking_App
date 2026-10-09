import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/services/auth_service.dart';
import 'package:berber_app_ui/services/yonlendirme.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/berber_desen.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/features/giris/rol_secim_screen.dart';

/// İşletme başvurusu onay beklerken / reddedildiğinde gösterilir.
class IsletmeBeklemeScreen extends StatefulWidget {
  final String durum;
  final String isletmeAdi;
  const IsletmeBeklemeScreen({super.key, required this.durum, required this.isletmeAdi});

  @override
  State<IsletmeBeklemeScreen> createState() => _IsletmeBeklemeScreenState();
}

class _IsletmeBeklemeScreenState extends State<IsletmeBeklemeScreen> {
  bool _kontrol = false;

  Future<void> _yenile() async {
    setState(() => _kontrol = true);
    try {
      await Yonlendirme.git(context);
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    } finally {
      if (mounted) setState(() => _kontrol = false);
    }
  }

  Future<void> _cikis() async {
    await AuthService.cikisYap();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RolSecimScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final reddedildi = widget.durum == 'reddedildi';
    return Scaffold(
      body: Stack(children: [
        const BerberDesenWidget(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(reddedildi ? Icons.block : Icons.hourglass_top_rounded,
                  color: reddedildi ? AppTheme.error : AppTheme.gold, size: 72),
              const SizedBox(height: 24),
              Text(reddedildi ? 'Başvurunuz onaylanmadı' : 'Başvurunuz inceleniyor',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                reddedildi
                    ? 'Ayrıntılar için destek ekibimizle iletişime geçebilirsiniz.'
                    : '${widget.isletmeAdi} için başvurunuz alındı. Onaylandığında salon paneliniz açılacak; '
                        'günün randevularını, personelinizi ve hizmetlerinizi buradan yöneteceksiniz.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              if (!reddedildi)
                ElevatedButton.icon(
                  onPressed: _kontrol ? null : _yenile,
                  icon: _kontrol
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh),
                  label: const Text('Durumu Kontrol Et'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                ),
              TextButton(onPressed: _cikis,
                  child: const Text('Çıkış Yap', style: TextStyle(color: AppTheme.textSecondary))),
            ]),
          ),
        ),
      ]),
    );
  }
}
