import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/widgets/bolum_basligi.dart';

/// Aranabilir seçim listesi (şehir, ilçe…). Seçilen öğeyi döner.
Future<String?> aramaListesiGoster(
  BuildContext context, {
  required String baslik,
  required List<String> secenekler,
  required IconData ikon,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppTheme.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _AramaListesi(baslik: baslik, secenekler: secenekler, ikon: ikon),
  );
}

class _AramaListesi extends StatefulWidget {
  final String baslik;
  final List<String> secenekler;
  final IconData ikon;
  const _AramaListesi({required this.baslik, required this.secenekler, required this.ikon});

  @override
  State<_AramaListesi> createState() => _AramaListesiState();
}

class _AramaListesiState extends State<_AramaListesi> {
  String _arama = '';

  @override
  Widget build(BuildContext context) {
    final aranan = _arama.toLowerCase();
    final liste = widget.secenekler.where((s) => s.toLowerCase().contains(aranan)).toList();
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => Column(children: [
        const SheetTutamagi(),
        Text(widget.baslik,
            style: GoogleFonts.playfairDisplay(color: AppTheme.gold, fontSize: 18, fontWeight: FontWeight.bold)),
        if (widget.secenekler.length > 8)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              autofocus: false,
              onChanged: (v) => setState(() => _arama = v),
              decoration: InputDecoration(hintText: Dil.t.ara, prefixIcon: const Icon(Icons.search, color: AppTheme.gold)),
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: ctrl,
            itemCount: liste.length,
            itemBuilder: (_, i) => ListTile(
              leading: Icon(widget.ikon, color: AppTheme.gold, size: 20),
              title: Text(liste[i], style: GoogleFonts.inter(color: Colors.white)),
              onTap: () => Navigator.pop(context, liste[i]),
            ),
          ),
        ),
      ]),
    );
  }
}
