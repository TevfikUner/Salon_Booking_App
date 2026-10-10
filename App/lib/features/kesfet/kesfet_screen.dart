import 'package:flutter/material.dart';

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
import 'package:berber_app_ui/features/kesfet/widgets/salon_karti.dart';

/// Keşfet sekmesi: il/ilçe filtresi veya konuma göre (yakından uzağa) salon listesi.
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

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });
    try {
      final liste = await SalonApi.salonlar(sehir: _sehir, ilce: _ilce, lat: _konum?.lat, lng: _konum?.lng);
      if (mounted) setState(() => _salonlar = liste);
    } on ApiHata catch (e) {
      if (mounted) setState(() => _hata = e.mesaj);
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  Future<void> _sehirSec() async {
    final secim = await aramaListesiGoster(context,
        baslik: 'Şehir Seçin', secenekler: TurkiyeLokasyon.sehirler, ikon: Icons.location_city);
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
        baslik: 'İlçe Seçin', secenekler: TurkiyeLokasyon.ilcelerGetir(_sehir!), ikon: Icons.map_outlined);
    if (secim == null) return;
    setState(() => _ilce = secim);
    _yukle();
  }

  void _temizle() {
    setState(() {
      _sehir = null;
      _ilce = null;
      _konum = null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keşfet'), automaticallyImplyLeading: false),
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
        ),
        Expanded(
          child: AsenkronGorunum(
            yukleniyor: _yukleniyor,
            hata: _hata,
            onTekrar: _yukle,
            builder: (_) => _salonlar.isEmpty
                ? const BosGorunum(
                    ikon: Icons.store_outlined,
                    mesaj: 'Salon bulunamadı',
                    altMesaj: 'Filtrelerinizi değiştirmeyi deneyin')
                : RefreshIndicator(
                    color: AppTheme.gold,
                    onRefresh: _yukle,
                    child: ListView.builder(
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
