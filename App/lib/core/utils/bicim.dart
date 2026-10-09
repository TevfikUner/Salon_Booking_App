/// Tarih, para ve süre biçimlendirme yardımcıları (Türkçe).
library;

const _aylar = ['', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim',
  'Kasım', 'Aralık'];
const gunAdlari = ['', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];

/// DateTime → "YYYY-MM-DD"
String tarihStr(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// "YYYY-MM-DD" → "9 Ekim Cuma" (yil: true → "9 Ekim 2026 Cuma")
String tarihUzun(String iso, {bool yil = false}) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return '${d.day} ${_aylar[d.month]}${yil ? ' ${d.year}' : ''} ${gunAdlari[d.weekday]}';
}

/// "YYYY-MM-DD" → "Bugün" / "Yarın" / "9 Ekim Cuma"
String tarihGoreli(String iso) {
  final simdi = DateTime.now();
  if (iso == tarihStr(simdi)) return 'Bugün';
  if (iso == tarihStr(simdi.add(const Duration(days: 1)))) return 'Yarın';
  return tarihUzun(iso);
}

String ayAdi(int ay) => _aylar[ay];

String tl(num tutar) => '${tutar.toStringAsFixed(0)} ₺';

String sureMetni(int dk) {
  if (dk < 60) return '$dk dk';
  final s = dk ~/ 60, d = dk % 60;
  return d == 0 ? '$s sa' : '$s sa $d dk';
}

String mesafeMetni(double km) => km < 1 ? '${(km * 1000).round()} m' : '${km.toStringAsFixed(1)} km';

/// "5321234567" / "05321234567" → "0532 123 45 67" (biçim dışı girdiyi olduğu gibi döner)
String telefonBicimli(String tel) {
  final r = tel.replaceAll(RegExp(r'\D'), '');
  final on = r.length == 10 ? '0$r' : r;
  if (on.length != 11) return tel;
  return '${on.substring(0, 4)} ${on.substring(4, 7)} ${on.substring(7, 9)} ${on.substring(9)}';
}
