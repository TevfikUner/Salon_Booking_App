import 'dart:async';

import 'package:flutter/material.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/arama_listesi_sheet.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';
import 'package:berber_app_ui/core/widgets/geri_bildirim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/salon_api.dart';
import 'package:berber_app_ui/data/models/salon.dart';
import 'package:berber_app_ui/data/sabit/turkiye_lokasyon.dart';
import 'package:berber_app_ui/features/kesfet/konum_servisi.dart';
import 'package:berber_app_ui/features/kesfet/salon_detay_screen.dart';
import 'package:berber_app_ui/features/kesfet/widgets/kesfet_filtre_paneli.dart';
import 'package:berber_app_ui/features/kesfet/widgets/salon_arama_kutusu.dart';
import 'package:berber_app_ui/features/kesfet/widgets/salon_karti.dart';

/// Keşfet sekmesi: salon/hizmet araması, il/ilçe ve puan filtresi veya konuma göre (yakından uzağa) salon listesi.
class KesfetScreen extends StatefulWidget {
  const KesfetScreen({super.key});

  @override
  State<KesfetScreen> createState() => _KesfetScreenState();
}

class _KesfetScreenState extends State<KesfetScreen> {
  List<Salon> _salonlar = [];
  bool _yukleniyor = true;
  String? _hata;
  String? _sehir;
  String? _ilce;
  ({double lat, double lng})? _konum;
  bool _konumAliniyor = false;
  final _arama = TextEditingController();
  bool _yuksekPuan = false;
  Timer? _gecikme;
  int _istekNo = 0;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  @override
  void dispose() {
    _gecikme?.cancel();
    _arama.dispose();
    super.dispose();
  }

  /// Yazarken her harfte istek atılmasın: 300 ms durunca ara.
  void _aramaDegisti(String _) {
    _gecikme?.cancel();
    _gecikme = Timer(const Duration(milliseconds: 300), _yukle);
  }

  Future<void> _yukle() async {
    final no = ++_istekNo; // geç dönen eski arama yanıtı yenisinin üzerine yazmasın
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });
    try {
      final liste = await SalonApi.salonlar(
          sehir: _sehir, ilce: _ilce, lat: _konum?.lat, lng: _konum?.lng, q: _arama.text,
          minPuan: _yuksekPuan ? 4.5 : null);
      if (mounted && no == _istekNo) setState(() => _salonlar = liste);
    } on ApiHata catch (e) {
      if (mounted && no == _istekNo) setState(() => _hata = e.mesaj);
    } finally {
      if (mounted && no == _istekNo) setState(() => _yukleniyor = false);
    }
  }

  Future<void> _sehirSec() async {
    final secim = await aramaListesiGoster(context,
        baslik: Dil.t.sehirSecin, secenekler: TurkiyeLokasyon.sehirler, ikon: Icons.location_city);
    if (secim == null) return;
    setState(() {
      _sehir = secim;
      _ilce = null;
    });
    _yukle();
  }

  Future<void> _ilceSec() async {
    if (_sehir == null) return;
    final secim = await aramaListesiGoster(context,
        baslik: Dil.t.ilceSecin, secenekler: TurkiyeLokasyon.ilcelerGetir(_sehir!), ikon: Icons.map_outlined);
    if (secim == null) return;
    setState(() => _ilce = secim);
    _yukle();
  }

  void _temizle() {
    _gecikme?.cancel();
    _arama.clear();
    setState(() {
      _sehir = null;
      _ilce = null;
      _konum = null;
      _yuksekPuan = false;
    });
    _yukle();
  }

  Future<void> _konumaGore() async {
    setState(() => _konumAliniyor = true);
    try {
      final p = await KonumServisi.mevcutKonum();
      if (!mounted) return;
      setState(() => _konum = (lat: p.latitude, lng: p.longitude));
      await _yukle();
    } on KonumHatasi catch (e) {
      if (mounted) bilgiGoster(context, e.mesaj, hata: true);
    } finally {
      if (mounted) setState(() => _konumAliniyor = false);
    }
  }

  Widget _bosSonuc() {
    final aranan = _arama.text.trim();
    return ListView(children: [
      const SizedBox(height: 60),
      BosGorunum(
          ikon: Icons.store_outlined,
          mesaj: aranan.isEmpty ? Dil.t.salonBulunamadi : Dil.t.aramaSonucYok(aranan),
          altMesaj: Dil.t.farkliKelimeDeneyin),
      Center(
        child: TextButton.icon(
            onPressed: _temizle, icon: const Icon(Icons.filter_alt_off), label: Text(Dil.t.filtreleriTemizle)),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Dil.t.kesfet), automaticallyImplyLeading: false),
      body: Column(children: [
        KesfetFiltrePaneli(
          sehir: _sehir,
          ilce: _ilce,
          konumModu: _konum != null,
          konumAliniyor: _konumAliniyor,
          onSehirSec: _sehirSec,
          onIlceSec: _ilceSec,
          onTemizle: _temizle,
          onKonum: _konumaGore,
          ekFiltre: _arama.text.trim().isNotEmpty || _yuksekPuan,
          ust: SalonAramaKutusu(
            controller: _arama,
            onDegisti: _aramaDegisti,
            onTemizle: () {
              _arama.clear();
              _yukle();
            },
            yuksekPuan: _yuksekPuan,
            onYuksekPuan: (v) {
              setState(() => _yuksekPuan = v);
              _yukle();
            },
          ),
        ),
        Expanded(
          child: AsenkronGorunum(
            yukleniyor: _yukleniyor,
            hata: _hata,
            onTekrar: _yukle,
            builder: (_) => _salonlar.isEmpty
                ? _bosSonuc()
                : RefreshIndicator(
                    color: AppTheme.gold,
                    onRefresh: _yukle,
                    child: ListView.builder(
                      key: const Key('salon_listesi'),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: _salonlar.length,
                      itemBuilder: (_, i) => SalonKarti(
                        key: ValueKey('salon_${_salonlar[i].id}'),
                        salon: _salonlar[i],
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => SalonDetayScreen(salonId: _salonlar[i].id))),
                      ),
                    ),
                  ),
          ),
        ),
      ]),
    );
  }
}
