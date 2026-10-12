import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';

/// Uygulamanın tamamını sarar; cihaz çevrimdışıyken üstte "İnternet bağlantısı yok" bandı gösterir.
/// Ekranlar kendi hatalarını yine gösterir; bu bant kullanıcıya nedenini baştan söyler.
class BaglantiBandi extends StatefulWidget {
  final Widget child;
  final Stream<List<ConnectivityResult>>? akis; // test için
  const BaglantiBandi({super.key, required this.child, this.akis});

  @override
  State<BaglantiBandi> createState() => _BaglantiBandiState();
}

class _BaglantiBandiState extends State<BaglantiBandi> {
  StreamSubscription<List<ConnectivityResult>>? _abonelik;
  bool _cevrimdisi = false;

  @override
  void initState() {
    super.initState();
    try {
      final c = Connectivity();
      _abonelik = (widget.akis ?? c.onConnectivityChanged).listen(_guncelle);
      if (widget.akis == null) c.checkConnectivity().then(_guncelle).catchError((_) {});
    } catch (_) {
      // Platform eklentisi yoksa (ör. widget testi) bant gizli kalır
    }
  }

  void _guncelle(List<ConnectivityResult> sonuc) {
    final yok = sonuc.isEmpty || sonuc.every((r) => r == ConnectivityResult.none);
    if (mounted && yok != _cevrimdisi) setState(() => _cevrimdisi = yok);
  }

  @override
  void dispose() {
    _abonelik?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AnimatedSize(
        duration: const Duration(milliseconds: 250),
        child: _cevrimdisi
            ? Material(
                color: AppTheme.error,
                child: SafeArea(
                  bottom: false,
                  child: Semantics(
                    liveRegion: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(Dil.t.internetYok,
                              style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ]),
                    ),
                  ),
                ),
              )
            : const SizedBox(width: double.infinity),
      ),
      Expanded(
        child: MediaQuery.removePadding(context: context, removeTop: _cevrimdisi, child: widget.child),
      ),
    ]);
  }
}
