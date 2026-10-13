import 'package:flutter/material.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/widgets/bolum_basligi.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/hesap_api.dart';
import 'package:berber_app_ui/data/api/salon_api.dart';
import 'package:berber_app_ui/data/models/berber.dart';
import 'package:berber_app_ui/data/models/salon.dart';
import 'package:berber_app_ui/features/kesfet/widgets/ekip_listesi.dart';
import 'package:berber_app_ui/features/kesfet/widgets/iletisim_butonlari.dart';
import 'package:berber_app_ui/features/kesfet/widgets/kampanya_bilesenleri.dart';
import 'package:berber_app_ui/features/kesfet/widgets/salon_bilgi_kartlari.dart';
import 'package:berber_app_ui/features/kesfet/widgets/yorumlar_bolumu.dart';
import 'package:berber_app_ui/features/randevu_al/randevu_flow.dart';

/// Salon detayı: iletişim, ekip (favori + doğrudan randevu), değerlendirmeler, bugünkü durum, çalışma saatleri.
class SalonDetayScreen extends StatefulWidget {
  final int salonId;
  const SalonDetayScreen({super.key, required this.salonId});

  @override
  State<SalonDetayScreen> createState() => _SalonDetayScreenState();
}

class _SalonDetayScreenState extends State<SalonDetayScreen> {
  Salon? _salon;
  Map<String, dynamic> _istatistik = const {};
  String? _hata;
  Json? _yorumlar;
  bool _yorumHata = false;

  @override
  void initState() {
    super.initState();
    _yukle();
    _yorumlariYukle();
  }

  /// Yorumlar ayrı yüklenir; hata verirse yalnızca kendi bölümü "Tekrar" gösterir.
  Future<void> _yorumlariYukle() async {
    setState(() => _yorumHata = false);
    try {
      final v = await SalonApi.yorumlar(widget.salonId, adet: 3);
      if (mounted) setState(() => _yorumlar = v);
    } on ApiHata {
      if (mounted) setState(() => _yorumHata = true);
    }
  }

  Future<void> _yukle() async {
    setState(() => _hata = null);
    // İstatistik hata fırlatmaz (varsayılan döner); ikisi paralel başlar.
    final istatistik = SalonApi.istatistik(widget.salonId);
    try {
      final salon = await SalonApi.detay(widget.salonId);
      final ist = await istatistik;
      if (mounted) {
        setState(() {
          _salon = salon;
          _istatistik = ist;
        });
      }
    } on ApiHata catch (e) {
      if (mounted) setState(() => _hata = e.mesaj);
    }
  }

  Future<void> _favori(Berber b) async {
    try {
      final favori = await HesapApi.favoriToggle(b.id);
      if (!mounted) return;
      setState(() {
        _salon = _salon!.copyWith(
            berberler: [for (final x in _salon!.berberler) x.id == b.id ? x.copyWith(favori: favori) : x]);
      });
      bilgiGoster(context, favori ? Dil.t.favorilereEklendi(b.tamAd) : Dil.t.favorilerdenCikarildi(b.tamAd));
    } on ApiHata catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    }
  }

  void _randevuAl({Berber? berber}) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => RandevuFlow(salonId: widget.salonId, favoriBerber: berber)));
  }

  @override
  Widget build(BuildContext context) {
    final salon = _salon;
    return Scaffold(
      appBar: AppBar(title: Text(salon?.ad ?? Dil.t.salon)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: salon == null
          ? null
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 55)),
                onPressed: _randevuAl,
                child: Text(Dil.t.randevuAl),
              ),
            ),
      body: AsenkronGorunum(
        yukleniyor: salon == null && _hata == null,
        hata: _hata,
        onTekrar: _yukle,
        builder: (_) => RefreshIndicator(
          onRefresh: () => Future.wait([_yukle(), _yorumlariYukle()]),
          child: ListView(padding: const EdgeInsets.only(bottom: 110), children: [
            SalonBaslikKarti(salon: salon!),
            IletisimButonlari(salon: salon),
            if (salon.kampanyalar.isNotEmpty) ...[
              BolumBasligi(baslik: Dil.t.kampanyalar, ikon: Icons.local_offer_outlined),
              KampanyalarKarti(kampanyalar: salon.kampanyalar),
            ],
            if (salon.sadakatKarti != null) ...[
              BolumBasligi(baslik: Dil.t.sadakatKartiBaslik, ikon: Icons.card_giftcard),
              SadakatKartiWidget(kart: salon.sadakatKarti!),
            ],
            if (salon.berberler.isNotEmpty) ...[
              BolumBasligi(baslik: Dil.t.ekibimiz, ikon: Icons.people_alt_outlined),
              EkipListesi(
                berberler: salon.berberler,
                onFavori: _favori,
                onRandevu: (b) => _randevuAl(berber: b),
              ),
            ],
            BolumBasligi(baslik: Dil.t.degerlendirmeler, ikon: Icons.reviews_outlined),
            YorumlarBolumu(
              salonId: widget.salonId,
              salonAd: salon.ad,
              veri: _yorumlar,
              hata: _yorumHata,
              onTekrar: _yorumlariYukle,
            ),
            BolumBasligi(baslik: Dil.t.bugunkuDurum, ikon: Icons.event_available),
            BugunDurumuKarti(istatistik: _istatistik),
            BolumBasligi(baslik: Dil.t.calismaSaatleri, ikon: Icons.schedule),
            CalismaSaatleriKarti(salon: salon),
          ]),
        ),
      ),
    );
  }
}
