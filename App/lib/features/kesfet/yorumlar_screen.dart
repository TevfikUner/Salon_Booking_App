import 'package:flutter/material.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/durum_gorunumleri.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/salon_api.dart';
import 'package:berber_app_ui/features/kesfet/widgets/yorum_bilesenleri.dart';

/// Salonun tüm değerlendirmeleri; aşağı kaydırdıkça sonraki sayfa yüklenir.
class YorumlarScreen extends StatefulWidget {
  final int salonId;
  final String salonAd;
  const YorumlarScreen({super.key, required this.salonId, required this.salonAd});

  @override
  State<YorumlarScreen> createState() => _YorumlarScreenState();
}

class _YorumlarScreenState extends State<YorumlarScreen> {
  Json? _ozet;
  final List<Json> _yorumlar = [];
  int _sayfa = 0;
  bool _sonrakiVar = true;
  bool _yukleniyor = false;
  String? _hata;

  @override
  void initState() {
    super.initState();
    _sonrakiSayfa();
  }

  Future<void> _sonrakiSayfa() async {
    if (_yukleniyor || !_sonrakiVar) return;
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });
    try {
      final v = await SalonApi.yorumlar(widget.salonId, sayfa: _sayfa + 1);
      if (!mounted) return;
      setState(() {
        _ozet ??= v;
        _sayfa++;
        _sonrakiVar = v['sonraki_var'] == true;
        _yorumlar.addAll(ApiClient.liste(v['yorumlar']));
      });
    } on ApiHata catch (e) {
      if (mounted) setState(() => _hata = e.mesaj);
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.salonAd)),
      body: AsenkronGorunum(
        yukleniyor: _ozet == null && _hata == null,
        hata: _ozet == null ? _hata : null,
        onTekrar: _sonrakiSayfa,
        builder: (_) => _yorumlar.isEmpty
            ? BosGorunum(ikon: Icons.rate_review_outlined, mesaj: Dil.t.henuzDegerlendirmeYok)
            : NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n.metrics.extentAfter < 300) _sonrakiSayfa();
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: _yorumlar.length + 2,
                  itemBuilder: (_, i) {
                    if (i == 0) return PuanOzetKarti(veri: _ozet!);
                    if (i <= _yorumlar.length) return YorumKarti(yorum: _yorumlar[i - 1]);
                    return _alt();
                  },
                ),
              ),
      ),
    );
  }

  Widget _alt() {
    if (_yukleniyor) {
      return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(color: AppTheme.gold)));
    }
    if (_hata != null) {
      return TextButton.icon(onPressed: _sonrakiSayfa, icon: const Icon(Icons.refresh), label: Text(_hata!));
    }
    return const SizedBox.shrink();
  }
}
