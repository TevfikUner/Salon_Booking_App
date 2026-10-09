import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

const _aylar = ['', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim',
  'Kasım', 'Aralık'];
const _gunler = ['', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];

/// DateTime → "YYYY-MM-DD"
String tarihStr(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// "YYYY-MM-DD" → "9 Ekim Cuma"
String tarihUzun(String iso, {bool yil = false}) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return '${d.day} ${_aylar[d.month]}${yil ? ' ${d.year}' : ''} ${_gunler[d.weekday]}';
}

/// "YYYY-MM-DD" → "Bugün" / "Yarın" / "9 Ekim Cuma"
String tarihGoreli(String iso) {
  final bugun = tarihStr(DateTime.now());
  final yarin = tarihStr(DateTime.now().add(const Duration(days: 1)));
  if (iso == bugun) return 'Bugün';
  if (iso == yarin) return 'Yarın';
  return tarihUzun(iso);
}

String tl(num tutar) => '${tutar.toStringAsFixed(0)} ₺';

String sureMetni(int dk) {
  if (dk < 60) return '$dk dk';
  final s = dk ~/ 60, d = dk % 60;
  return d == 0 ? '$s sa' : '$s sa $d dk';
}

void bilgiGoster(BuildContext context, String mesaj, {bool hata = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(mesaj),
      backgroundColor: hata ? AppTheme.error : AppTheme.success,
    ));
}

Future<bool> onayIste(BuildContext context, String baslik, String mesaj,
    {String evet = 'Evet', bool tehlikeli = false}) async {
  final sonuc = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(baslik, style: GoogleFonts.playfairDisplay(color: tehlikeli ? AppTheme.error : AppTheme.gold)),
      content: Text(mesaj, style: const TextStyle(color: Colors.white)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç', style: TextStyle(color: AppTheme.textSecondary))),
        TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: Text(evet, style: TextStyle(color: tehlikeli ? AppTheme.error : AppTheme.gold,
                fontWeight: FontWeight.bold))),
      ],
    ),
  );
  return sonuc == true;
}

/// Yükleme hatası + yeniden dene.
class HataGorunumu extends StatelessWidget {
  final String mesaj;
  final VoidCallback onTekrar;
  const HataGorunumu({super.key, required this.mesaj, required this.onTekrar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off, color: AppTheme.error, size: 48),
          const SizedBox(height: 12),
          Text(mesaj, textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onTekrar,
            icon: const Icon(Icons.refresh),
            label: const Text('Yeniden Dene'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
          ),
        ]),
      ),
    );
  }
}

class BosGorunum extends StatelessWidget {
  final IconData ikon;
  final String mesaj;
  const BosGorunum({super.key, required this.ikon, required this.mesaj});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(ikon, color: AppTheme.gold.withValues(alpha: 0.35), size: 56),
          const SizedBox(height: 12),
          Text(mesaj, textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14, height: 1.4)),
        ]),
      ),
    );
  }
}

/// Güven skoru rozeti (Güvenilir / Dikkat / Riskli / Yeni)
class GuvenRozeti extends StatelessWidget {
  final Map<String, dynamic> guven;
  const GuvenRozeti({super.key, required this.guven});

  @override
  Widget build(BuildContext context) {
    final etiket = guven['etiket'] as String? ?? 'Yeni';
    final renk = switch (etiket) {
      'Güvenilir' => AppTheme.success,
      'Dikkat' => Colors.orange,
      'Riskli' => AppTheme.error,
      _ => Colors.lightBlueAccent,
    };
    final skor = guven['skor'];
    final aciklama = etiket == 'Yeni'
        ? 'İlk ziyaret — geçmiş kaydı yok'
        : '${guven['tamamlanan']} tamamlanan · ${guven['gelmedi']} gelmedi · ${guven['gec_iptal']} geç iptal';
    return Tooltip(
      message: aciklama,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: renk.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: renk.withValues(alpha: 0.5)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(etiket == 'Riskli' ? Icons.warning_amber_rounded : Icons.verified_user_outlined, size: 12, color: renk),
          const SizedBox(width: 4),
          Text(skor == null ? etiket : '$etiket · $skor',
              style: GoogleFonts.inter(color: renk, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
