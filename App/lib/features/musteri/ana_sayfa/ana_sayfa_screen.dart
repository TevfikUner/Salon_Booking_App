import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/berber_desen.dart';
import 'package:berber_app_ui/core/widgets/bolum_basligi.dart';
import 'package:berber_app_ui/data/api/hesap_api.dart';
import 'package:berber_app_ui/data/api/randevu_api.dart';
import 'package:berber_app_ui/data/models/berber.dart';
import 'package:berber_app_ui/data/models/randevu.dart';
import 'package:berber_app_ui/features/musteri/ana_sayfa/widgets/favori_berber_seridi.dart';
import 'package:berber_app_ui/features/musteri/ana_sayfa/widgets/her_zamanki_karti.dart';
import 'package:berber_app_ui/features/musteri/ana_sayfa/widgets/randevu_baslat_sheet.dart';
import 'package:berber_app_ui/features/musteri/ana_sayfa/widgets/yaklasan_randevular.dart';
import 'package:berber_app_ui/features/musteri/favoriler/favori_berberler_screen.dart';
import 'package:berber_app_ui/features/randevu_al/randevu_flow.dart';

/// Müşteri ana sayfası: selamlama, "Her Zamanki", randevu al, yaklaşan randevular, favoriler.
class AnaSayfaScreen extends StatefulWidget {
  final VoidCallback? onKesfeteGit;
  final VoidCallback? onRandevularimaGit;
  const AnaSayfaScreen({super.key, this.onKesfeteGit, this.onRandevularimaGit});

  @override
  State<AnaSayfaScreen> createState() => AnaSayfaScreenState();
}

class AnaSayfaScreenState extends State<AnaSayfaScreen> {
  String _ad = '';
  List<Berber> _favoriler = [];
  List<Randevu> _yaklasanlar = [];
  Map<String, dynamic>? _herZamanki;
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    yenile();
  }

  /// Dışarıdan da çağrılır (sekmeye dönüldüğünde).
  Future<void> yenile() async {
    setState(() => _yukleniyor = true);
    // Her parça bağımsız: biri başarısız olursa diğerleri yine gösterilir.
    final profil = HesapApi.profil();
    final favoriler = HesapApi.favoriler();
    final randevular = RandevuApi.randevularim().catchError((_) => <Randevu>[]);
    final herZamanki = RandevuApi.herZamanki().catchError((_) => null);
    final p = await profil;
    final f = await favoriler;
    final r = await randevular;
    final h = await herZamanki;
    if (!mounted) return;
    setState(() {
      _ad = (p?['ad'] as String?) ?? '';
      _favoriler = f.map(Berber.fromJson).toList();
      _yaklasanlar = (r.where((x) => x.yaklasan).toList()..sort((a, b) => a.baslangic.compareTo(b.baslangic)))
          .take(3)
          .toList();
      _herZamanki = h;
      _yukleniyor = false;
    });
  }

  void _berberleRandevu(Berber b) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => RandevuFlow(salonId: b.salonId, favoriBerber: b)));
  }

  Future<void> _randevuAl() async {
    if (_favoriler.isEmpty) return widget.onKesfeteGit?.call();
    final secim = await randevuBaslatSor(context, _favoriler);
    switch (secim) {
      case FavoriSecildi(:final berber):
        _berberleRandevu(berber);
      case KesfetSecildi():
        widget.onKesfeteGit?.call();
      case null:
        break;
    }
  }

  Future<void> _favorileriAc() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriBerberlerScreen()));
    yenile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        const BerberDesenWidget(),
        RefreshIndicator(
          color: AppTheme.gold,
          onRefresh: yenile,
          child: CustomScrollView(slivers: [
            const SliverAppBar(pinned: true, automaticallyImplyLeading: false, title: Text('PREMIUM BERBER')),
            if (_yukleniyor)
              const SliverToBoxAdapter(child: LinearProgressIndicator(color: AppTheme.gold, minHeight: 2)),
            SliverToBoxAdapter(child: _Selamlama(ad: _ad)),
            if (_herZamanki != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: HerZamankiKarti(veri: _herZamanki!, onDegisti: yenile),
                ),
              ),
            SliverToBoxAdapter(child: _RandevuAlButonu(onTap: _randevuAl)),
            if (_yaklasanlar.isNotEmpty) ...[
              const SliverToBoxAdapter(child: BolumBasligi(baslik: 'Yaklaşan Randevularınız', ikon: Icons.calendar_today)),
              SliverToBoxAdapter(
                  child: YaklasanRandevular(randevular: _yaklasanlar, onTap: widget.onRandevularimaGit)),
            ],
            SliverToBoxAdapter(
              child: BolumBasligi(
                baslik: 'Favori Berberlerim',
                ikon: Icons.favorite,
                sag: _favoriler.isEmpty ? null : TextButton(onPressed: _favorileriAc, child: const Text('Tümü')),
              ),
            ),
            SliverToBoxAdapter(
              child: FavoriBerberSeridi(
                favoriler: _favoriler,
                onSec: _berberleRandevu,
                onKesfet: () => widget.onKesfeteGit?.call(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ]),
        ),
      ]),
    );
  }
}

class _Selamlama extends StatelessWidget {
  final String ad;
  const _Selamlama({required this.ad});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(ad.isEmpty ? 'Hoş Geldiniz ✂️' : 'Sıhhatler olsun, $ad!',
            style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Bugün kendinize güzel bir randevu alın',
            style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13)),
      ]),
    );
  }
}

class _RandevuAlButonu extends StatelessWidget {
  final VoidCallback onTap;
  const _RandevuAlButonu({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              gradient: AppTheme.goldGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: AppTheme.gold.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 6))],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.calendar_today, color: AppTheme.black, size: 24),
              const SizedBox(width: 12),
              Text('Randevu Al',
                  style: GoogleFonts.inter(color: AppTheme.black, fontWeight: FontWeight.bold, fontSize: 18)),
            ]),
          ),
        ),
      ),
    );
  }
}
