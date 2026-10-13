import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import 'package:berber_app_ui/core/dil.dart';
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

  void _yasal(YasalMetin m) => _ac(YasalDokumanScreen.belge(m));

  Future<void> _girisEkraninaDon() async {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const RolSecimScreen()), (_) => false);
  }

  Future<void> _cikis() async {
    if (!await onayIste(context, Dil.t.cikisYap, Dil.t.cikisEminMisiniz,
        evet: Dil.t.cikisYap)) {
      return;
    }
    await BildirimServisi.durdur();
    await AuthService.cikisYap();
    await _girisEkraninaDon();
  }

  /// null → cihaz dili
  String _dilAdi(String? kod) => switch (kod) {
        'tr' => 'Türkçe',
        'en' => 'English',
        _ => Dil.t.cihazDili,
      };

  Future<void> _dilSec() async {
    final secim = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final kod in const ['', 'tr', 'en'])
            ListTile(
              key: ValueKey('dil_$kod'),
              leading: Icon(
                  (Dil.ornek.secim ?? '') == kod ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: AppTheme.gold),
              title: Text(_dilAdi(kod.isEmpty ? null : kod), style: const TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(ctx, kod),
            ),
        ]),
      ),
    );
    if (secim == null || secim == (Dil.ornek.secim ?? '')) return;
    // Uygulama seçilen dille baştan açılır (kök yeniden kurulur)
    await Dil.ornek.sec(secim.isEmpty ? null : secim);
  }

  Future<void> _hesabiSil() async {
    final onay = await onayIste(
      context,
      Dil.t.hesabiSil,
      Dil.t.hesapSilAciklama,
      evet: Dil.t.kaliciSil,
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
              ? Dil.t.hesapSilindi
              : Dil.t.verilerSilindiOturum);
      await _girisEkraninaDon();
    } catch (e) {
      if (mounted) bilgiGoster(context, Dil.t.hesapSilinemedi('$e'), hata: true);
    } finally {
      if (mounted) setState(() => _islemde = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Dil.t.profil), automaticallyImplyLeading: false),
      body: AbsorbPointer(
        absorbing: _islemde,
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 100), children: [
          _Avatar(adSoyad: _adSoyad, eposta: AuthService.currentUser?.email),
          const SizedBox(height: 24),
          KisiselBilgilerFormu(profil: _profil, onAdDegisti: (v) => setState(() => _adSoyad = v)),
          MenuBolumu(baslik: Dil.t.yasalGizlilik, ikon: Icons.shield_outlined, children: [
            MenuSatiri(ikon: Icons.privacy_tip_outlined, etiket: Dil.t.gizlilikPolitikasi,
                onTap: () => _yasal(YasalMetinler.gizlilik)),
            MenuSatiri(ikon: Icons.article_outlined, etiket: Dil.t.kvkkMetni,
                onTap: () => _yasal(YasalMetinler.kvkk)),
            MenuSatiri(ikon: Icons.description_outlined, etiket: Dil.t.kullanimKosullari,
                onTap: () => _yasal(YasalMetinler.kullanim)),
          ]),
          MenuBolumu(baslik: Dil.t.yardimDestek, ikon: Icons.support_agent_outlined, children: [
            MenuSatiri(ikon: Icons.help_outline, etiket: Dil.t.sikcaSorulanSorular,
                onTap: () => _ac(const YardimDestekScreen())),
            MenuSatiri(ikon: Icons.mail_outline, etiket: Dil.t.bizeUlasin,
                onTap: () => _ac(const YardimDestekScreen(baslangicSekmesi: 1))),
          ]),
          MenuBolumu(baslik: Dil.t.hesap, ikon: Icons.settings_outlined, children: [
            MenuSatiri(
              ikon: Icons.language,
              etiket: '${Dil.t.dil}: ${_dilAdi(Dil.ornek.secim)}',
              renk: AppTheme.gold,
              onTap: _dilSec,
            ),
            MenuSatiri(
              ikon: Icons.share_outlined,
              etiket: Dil.t.uygulamayiPaylas,
              renk: AppTheme.gold,
              onTap: () => Share.share(
                '${Dil.t.paylasMetni}\n${AppConfig.magazaLinki}',
                subject: 'Premium Berber',
              ),
            ),
            MenuSatiri(ikon: Icons.logout, etiket: Dil.t.cikisYap, renk: AppTheme.gold, onTap: _cikis),
            MenuSatiri(ikon: Icons.delete_forever, etiket: Dil.t.hesabimiSil, renk: AppTheme.error, onTap: _hesabiSil),
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
