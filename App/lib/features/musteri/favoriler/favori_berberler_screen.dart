import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/hesap_api.dart';
import 'package:berber_app_ui/data/api/randevu_api.dart';
import 'package:berber_app_ui/data/models/berber.dart';
import 'package:berber_app_ui/features/randevu_al/randevu_flow.dart';

/// Favori berberler + daha önce gidilen berberler. Kalp ile favori ekle/çıkar, dokun → randevu.
class FavoriBerberlerScreen extends StatefulWidget {
  const FavoriBerberlerScreen({super.key});

  @override
  State<FavoriBerberlerScreen> createState() => _FavoriBerberlerScreenState();
}

class _FavoriBerberlerScreenState extends State<FavoriBerberlerScreen> {
  List<Berber> _berberler = [];
  bool _yukleniyor = true;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() => _hata = null);
    try {
      final favoriler = HesapApi.favoriler();
      final randevular = await RandevuApi.randevularim();
      final harita = <int, Berber>{for (final f in await favoriler) f['berber_id'] as int: Berber.fromJson(f)};
      // Geçmişte gidilen ama favori olmayan berberler
      for (final r in randevular) {
        harita.putIfAbsent(
          r.berberId,
          () => Berber(id: r.berberId, ad: r.berber, soyad: '', uzmanlik: '', puan: 0, salonId: r.salonId,
              salonAd: r.salonAd),
        );
      }
      if (mounted) setState(() => _berberler = _sirala(harita.values.toList()));
    } on ApiHata catch (e) {
      if (mounted) setState(() => _hata = e.mesaj);
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  List<Berber> _sirala(List<Berber> l) => l
    ..sort((a, b) => a.favori == b.favori ? a.tamAd.compareTo(b.tamAd) : (a.favori ? -1 : 1));

  Future<void> _toggle(Berber b) async {
    try {
      final favori = await HesapApi.favoriToggle(b.id);
      if (!mounted) return;
      setState(() => _berberler = _sirala([for (final x in _berberler) x.id == b.id ? x.copyWith(favori: favori) : x]));
      bilgiGoster(context, favori ? Dil.t.favorilereEklendi(b.tamAd) : Dil.t.favorilerdenCikarildi(b.tamAd));
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Dil.t.berberlerim)),
      body: AsenkronGorunum(
        yukleniyor: _yukleniyor,
        hata: _hata,
        onTekrar: _yukle,
        builder: (_) => _berberler.isEmpty
            ? BosGorunum(
                ikon: Icons.favorite_border,
                mesaj: Dil.t.berberGecmisiYok,
                altMesaj: Dil.t.favoriEkleIpucu)
            : RefreshIndicator(
                color: AppTheme.gold,
                onRefresh: _yukle,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _berberler.length,
                  itemBuilder: (_, i) {
                    final b = _berberler[i];
                    final baslik = i == 0 || _berberler[i - 1].favori != b.favori;
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (baslik) _Ayirici(favori: b.favori),
                      _BerberSatiri(berber: b, onFavori: () => _toggle(b), onRandevu: () => _randevu(b)),
                    ]);
                  },
                ),
              ),
      ),
    );
  }

  void _randevu(Berber b) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => RandevuFlow(salonId: b.salonId, favoriBerber: b)));
}

class _Ayirici extends StatelessWidget {
  final bool favori;
  const _Ayirici({required this.favori});

  @override
  Widget build(BuildContext context) {
    final renk = favori ? AppTheme.gold : AppTheme.textSecondary;
    return Padding(
      padding: EdgeInsets.only(bottom: 8, top: favori ? 4 : 16),
      child: Row(children: [
        Icon(favori ? Icons.favorite : Icons.history, color: renk, size: 16),
        const SizedBox(width: 8),
        Text(favori ? Dil.t.favorileriniz : Dil.t.dahaOnceGittikleriniz,
            style: GoogleFonts.inter(color: renk, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: renk.withValues(alpha: 0.2))),
      ]),
    );
  }
}

class _BerberSatiri extends StatelessWidget {
  final Berber berber;
  final VoidCallback onFavori;
  final VoidCallback onRandevu;
  const _BerberSatiri({required this.berber, required this.onFavori, required this.onRandevu});

  @override
  Widget build(BuildContext context) {
    final b = berber;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: b.favori ? AppTheme.gold.withValues(alpha: 0.06) : AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.gold.withValues(alpha: b.favori ? 0.3 : 0.1)),
      ),
      child: ListTile(
        onTap: onRandevu,
        leading: CircleAvatar(
            backgroundColor: AppTheme.gold.withValues(alpha: 0.12), child: const Icon(Icons.person, color: AppTheme.gold)),
        title: Text(b.tamAd, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text(b.salonAd ?? '', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12)),
        trailing: IconButton(
          tooltip: b.favori ? Dil.t.favorilerdenCikar : Dil.t.favorilereEkle,
          onPressed: onFavori,
          icon: Icon(b.favori ? Icons.favorite : Icons.favorite_border,
              color: b.favori ? Colors.redAccent : AppTheme.textSecondary),
        ),
      ),
    );
  }
}
