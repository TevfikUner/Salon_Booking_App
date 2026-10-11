import 'package:flutter/material.dart';

import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/randevu_api.dart';
import 'package:berber_app_ui/data/models/randevu.dart';
import 'package:berber_app_ui/features/musteri/degerlendirme/degerlendirme_screen.dart';
import 'package:berber_app_ui/features/musteri/randevularim/erteleme_sheet.dart';
import 'package:berber_app_ui/features/musteri/randevularim/widgets/randevu_karti.dart';
import 'package:berber_app_ui/services/analitik.dart';
import 'package:berber_app_ui/services/takvim_paylasimi.dart';

/// Yaklaşan ve geçmiş randevular; erteleme, iptal ve değerlendirme.
class RandevularimScreen extends StatefulWidget {
  const RandevularimScreen({super.key});

  @override
  State<RandevularimScreen> createState() => RandevularimScreenState();
}

class RandevularimScreenState extends State<RandevularimScreen> {
  List<Randevu> _randevular = [];
  bool _yukleniyor = true;
  String? _hata;

  @override
  void initState() {
    super.initState();
    yenile();
  }

  Future<void> yenile() async {
    setState(() {
      _yukleniyor = _randevular.isEmpty;
      _hata = null;
    });
    try {
      final liste = await RandevuApi.randevularim();
      if (mounted) setState(() => _randevular = liste);
    } on ApiHata catch (e) {
      if (mounted) setState(() => _hata = e.mesaj);
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  Future<void> _ertele(Randevu r) async {
    final ertelendi = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => ErtelemeSheet(randevu: r),
    );
    if (ertelendi != true) return;
    if (mounted) bilgiGoster(context, 'Randevunuz ertelendi.');
    yenile();
  }

  /// İptal etmeden önce, hakkı varsa ertelemeyi önerir (müşteri slotunu, salon müşterisini kaybetmesin).
  Future<void> _iptal(Randevu r) async {
    final mesaj = '${tarihUzun(r.tarih)} ${r.saat} randevunuzu iptal etmek istiyor musunuz?';
    if (r.ertelemeHakki > 0) {
      final secim = await _iptalVeyaErtele(mesaj);
      if (secim == 'ertele') return _ertele(r);
      if (secim != 'iptal') return;
    } else if (!await onayIste(context, 'Randevu İptali', mesaj, evet: 'İptal Et', tehlikeli: true)) {
      return;
    }
    try {
      await RandevuApi.iptal(r.id);
      Analitik.randevuIptal();
      if (mounted) bilgiGoster(context, 'Randevunuz iptal edildi.');
      yenile();
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    }
  }

  Future<String?> _iptalVeyaErtele(String mesaj) => showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Randevu İptali', style: TextStyle(color: AppTheme.error)),
          content: Text('$mesaj\n\nGelemiyorsanız iptal yerine başka bir saate erteleyebilirsiniz.',
              style: const TextStyle(color: Colors.white)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Vazgeç', style: TextStyle(color: AppTheme.textSecondary))),
            TextButton(
                onPressed: () => Navigator.pop(ctx, 'iptal'),
                child: const Text('İptal Et', style: TextStyle(color: AppTheme.error))),
            TextButton(
                onPressed: () => Navigator.pop(ctx, 'ertele'),
                child: const Text('Ertele', style: TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold))),
          ],
        ),
      );

  Future<void> _degerlendir(Randevu r) async {
    final gonderildi = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DegerlendirmeEkrani(randevuId: r.id, berberAdi: r.berber)),
    );
    if (gonderildi == true) yenile();
  }

  @override
  Widget build(BuildContext context) {
    final yaklasanlar = _randevular.where((r) => r.durum == 'onaylandi').toList()
      ..sort((a, b) => a.baslangic.compareTo(b.baslangic));
    final gecmis = _randevular.where((r) => r.durum != 'onaylandi').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Randevularım'),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            indicatorColor: AppTheme.gold,
            labelColor: AppTheme.gold,
            unselectedLabelColor: AppTheme.textSecondary,
            tabs: [
              Tab(text: 'YAKLAŞANLAR', icon: Icon(Icons.calendar_today, size: 20)),
              Tab(text: 'GEÇMİŞ', icon: Icon(Icons.history, size: 20)),
            ],
          ),
        ),
        body: AsenkronGorunum(
          yukleniyor: _yukleniyor,
          hata: _hata,
          onTekrar: yenile,
          builder: (_) => TabBarView(children: [
            _liste(yaklasanlar, 'Henüz aktif randevunuz yok'),
            _liste(gecmis, 'Geçmiş randevu bulunamadı'),
          ]),
        ),
      ),
    );
  }

  Widget _liste(List<Randevu> liste, String bosMesaj) {
    return RefreshIndicator(
      color: AppTheme.gold,
      onRefresh: yenile,
      child: liste.isEmpty
          ? ListView(children: [
              const SizedBox(height: 120),
              BosGorunum(ikon: Icons.calendar_today_outlined, mesaj: bosMesaj),
            ])
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: liste.length,
              itemBuilder: (_, i) {
                final r = liste[i];
                return RandevuKarti(
                  randevu: r,
                  onIptal: r.yaklasan ? () => _iptal(r) : null,
                  onErtele: r.yaklasan && r.ertelemeHakki > 0 ? () => _ertele(r) : null,
                  onTakvim: r.yaklasan
                      ? () => TakvimPaylasimi.secenekleriGoster(
                          context,
                          TakvimEtkinligi(
                            randevuId: r.id,
                            tarih: r.tarih,
                            saat: r.saat,
                            bitis: r.bitis.isEmpty ? null : r.bitis,
                            baslik: '${r.salonAd} — ${r.hizmetler.join(', ')}',
                            aciklama: 'Berber: ${r.berber}\nToplam: ${tl(r.toplamFiyat)}',
                          ))
                      : null,
                  onDegerlendir: () => _degerlendir(r),
                );
              },
            ),
    );
  }
}
