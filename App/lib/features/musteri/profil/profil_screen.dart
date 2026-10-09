import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import 'package:berber_app_ui/core/config.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/hesap_api.dart';
import 'package:berber_app_ui/data/sabit/yasal_metinler.dart';
import 'package:berber_app_ui/features/destek/yardim_destek_screen.dart';
import 'package:berber_app_ui/features/destek/yasal_dokuman_screen.dart';
import 'package:berber_app_ui/features/giris/rol_secim_screen.dart';
import 'package:berber_app_ui/features/musteri/profil/widgets/kisisel_bilgiler_formu.dart';
import 'package:berber_app_ui/features/musteri/profil/widgets/menu_bolumu.dart';
import 'package:berber_app_ui/services/auth_service.dart';
import 'package:berber_app_ui/services/bildirim_servisi.dart';

/// Profil: kişisel bilgiler, yasal metinler, destek, çıkış ve hesap silme.
class ProfilEkrani extends StatefulWidget {
  const ProfilEkrani({super.key});

  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  Map<String, dynamic>? _profil;
  String _adSoyad = '';
  bool _islemde = false;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    final p = await HesapApi.profil();
    if (!mounted) return;
    setState(() {
      _profil = p;
      _adSoyad = '${p?['ad'] ?? ''} ${p?['soyad'] ?? ''}'.trim();
    });
  }

  void _ac(Widget ekran) => Navigator.push(context, MaterialPageRoute(builder: (_) => ekran));

  void _yasal(YasalMetin m) => _ac(YasalDokumanScreen(baslik: m.baslik, icerik: m.icerik));

  Future<void> _girisEkraninaDon() async {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const RolSecimScreen()), (_) => false);
  }

  Future<void> _cikis() async {
    if (!await onayIste(context, 'Çıkış Yap', 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
        evet: 'Çıkış Yap')) {
      return;
    }
    await BildirimServisi.durdur();
    await AuthService.cikisYap();
    await _girisEkraninaDon();
  }

  Future<void> _hesabiSil() async {
    final onay = await onayIste(
      context,
      'Hesabı Sil',
      'Kişisel bilgileriniz silinecek ve gelecekteki randevularınız iptal edilecek. Bu işlem geri alınamaz.',
      evet: 'Kalıcı Olarak Sil',
      tehlikeli: true,
    );
    if (!onay || !mounted) return;
    setState(() => _islemde = true);
    try {
      await BildirimServisi.durdur();
      final tamamen = await AuthService.hesabiSil();
      if (!mounted) return;
      bilgiGoster(
          context,
          tamamen
              ? 'Hesabınız ve kişisel verileriniz silindi.'
              : 'Kişisel verileriniz silindi. Güvenlik nedeniyle oturumunuz kapatıldı.');
      await _girisEkraninaDon();
    } catch (e) {
      if (mounted) bilgiGoster(context, 'Hesap silinemedi: $e', hata: true);
    } finally {
      if (mounted) setState(() => _islemde = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil'), automaticallyImplyLeading: false),
      body: AbsorbPointer(
        absorbing: _islemde,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 100), children: [
          _Avatar(adSoyad: _adSoyad, eposta: AuthService.currentUser?.email),
          const SizedBox(height: 24),
          KisiselBilgilerFormu(profil: _profil, onAdDegisti: (v) => setState(() => _adSoyad = v)),
          MenuBolumu(baslik: 'Yasal & Gizlilik', ikon: Icons.shield_outlined, children: [
            MenuSatiri(ikon: Icons.privacy_tip_outlined, etiket: 'Gizlilik Politikası',
                onTap: () => _yasal(YasalMetinler.gizlilik)),
            MenuSatiri(ikon: Icons.article_outlined, etiket: 'KVKK Aydınlatma Metni',
                onTap: () => _yasal(YasalMetinler.kvkk)),
            MenuSatiri(ikon: Icons.description_outlined, etiket: 'Kullanım Koşulları',
                onTap: () => _yasal(YasalMetinler.kullanim)),
          ]),
          MenuBolumu(baslik: 'Yardım & Destek', ikon: Icons.support_agent_outlined, children: [
            MenuSatiri(ikon: Icons.help_outline, etiket: 'Sıkça Sorulan Sorular',
                onTap: () => _ac(const YardimDestekScreen())),
            MenuSatiri(ikon: Icons.mail_outline, etiket: 'Bize Ulaşın',
                onTap: () => _ac(const YardimDestekScreen(baslangicSekmesi: 1))),
          ]),
          MenuBolumu(baslik: 'Hesap', ikon: Icons.settings_outlined, children: [
            MenuSatiri(
              ikon: Icons.share_outlined,
              etiket: 'Uygulamayı Paylaş',
              renk: AppTheme.gold,
              onTap: () => Share.share(
                'Premium Berber ile saniyeler içinde berber randevusu al 💈\n${AppConfig.magazaLinki}',
                subject: 'Premium Berber',
              ),
            ),
            MenuSatiri(ikon: Icons.logout, etiket: 'Çıkış Yap', renk: AppTheme.gold, onTap: _cikis),
            MenuSatiri(ikon: Icons.delete_forever, etiket: 'Hesabımı Sil', renk: AppTheme.error, onTap: _hesabiSil),
          ]),
        ]),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String adSoyad;
  final String? eposta;
  const _Avatar({required this.adSoyad, this.eposta});

  String get _basHarfler =>
      adSoyad.split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0].toUpperCase()).join();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CircleAvatar(
        radius: 46,
        backgroundColor: AppTheme.gold.withValues(alpha: 0.15),
        child: _basHarfler.isEmpty
            ? const Icon(Icons.person, color: AppTheme.gold, size: 46)
            : Text(_basHarfler,
                style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 32, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 10),
      if (adSoyad.isNotEmpty)
        Text(adSoyad, style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      if (eposta != null) Text(eposta!, style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
    ]);
  }
}
