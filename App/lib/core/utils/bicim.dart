/// Tarih, para ve süre biçimlendirme yardımcıları (uygulama diline göre: Türkçe / İngilizce).
library;

import 'package:berber_app_ui/core/dil.dart';

const _aylarTr = ['', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim',
  'Kasım', 'Aralık'];
const _aylarEn = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September',
  'October', 'November', 'December'];
const _gunlerTr = ['', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
const _gunlerEn = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

/// DateTime.weekday (1=Pzt … 7=Paz) → gün adı; [0] boş
List<String> get gunAdlari => Dil.ingilizce ? _gunlerEn : _gunlerTr;

/// Backend gün indeksi (0=Pzt … 6=Paz) → kısa ad
List<String> get gunKisaAdlari =>
    Dil.ingilizce ? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'] : const ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

/// Backend'in "0,3" biçimindeki haftalık gün listesi → {0, 3}
Set<int> gunListesi(String? metin) => {
      for (final p in (metin ?? '').split(','))
        if (int.tryParse(p.trim()) case final g? when g >= 0 && g <= 6) g
    };

/// {3, 0} → "0,3"
String gunListesiMetni(Set<int> gunler) => (gunler.toList()..sort()).join(',');

/// DateTime → "YYYY-MM-DD"
String tarihStr(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// "YYYY-MM-DD" → "9 Ekim Cuma" / "Friday, 9 October" (yil: true → "9 Ekim 2026 Cuma" / "Friday, 9 October 2026")
String tarihUzun(String iso, {bool yil = false}) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  if (Dil.ingilizce) return '${gunAdlari[d.weekday]}, ${d.day} ${_aylarEn[d.month]}${yil ? ' ${d.year}' : ''}';
  return '${d.day} ${_aylarTr[d.month]}${yil ? ' ${d.year}' : ''} ${gunAdlari[d.weekday]}';
}

/// "YYYY-MM-DD" → "Bugün" / "Yarın" / "9 Ekim Cuma"
String tarihGoreli(String iso) {
  final simdi = DateTime.now();
  if (iso == tarihStr(simdi)) return Dil.t.bugun;
  if (iso == tarihStr(simdi.add(const Duration(days: 1)))) return Dil.t.yarin;
  return tarihUzun(iso);
}

String ayAdi(int ay) => (Dil.ingilizce ? _aylarEn : _aylarTr)[ay];

/// "9 Ekim" / "9 October" (yıl ve gün adı olmadan)
String gunAy(DateTime d) => '${d.day} ${ayAdi(d.month)}';

/// "9 Eki" / "9 Oct" (dar alanlar için)
String gunAyKisa(DateTime d) => '${d.day} ${ayAdi(d.month).substring(0, 3)}';

String tl(num tutar) => '${tutar.toStringAsFixed(0)} ₺';

String sureMetni(int dk) {
  if (dk < 60) return Dil.t.sureDk(dk);
  final s = dk ~/ 60, d = dk % 60;
  return d == 0 ? Dil.t.sureSa(s) : Dil.t.sureSaDk(s, d);
}

String mesafeMetni(double km) => km < 1 ? '${(km * 1000).round()} m' : '${km.toStringAsFixed(1)} km';

/// "5321234567" / "05321234567" → "0532 123 45 67" (biçim dışı girdiyi olduğu gibi döner)
String telefonBicimli(String tel) {
  final r = tel.replaceAll(RegExp(r'\D'), '');
  final on = r.length == 10 ? '0$r' : r;
  if (on.length != 11) return tel;
  return '${on.substring(0, 4)} ${on.substring(4, 7)} ${on.substring(7, 9)} ${on.substring(9)}';
}

/// Sayının okunuşuna göre yönelme eki: 10 → 'a, 20 → 'ye, 15 → 'e, 6 → 'ya ("%20'ye varan", "%10'a varan").
String yonelmeEki(int n) {
  const birler = ["", "'e", "'ye", "'e", "'e", "'e", "'ya", "'ye", "'e", "'a"];
  const onlar = ["", "'a", "'ye", "'a", "'a", "'ye", "'a", "'e", "'e", "'a"];
  n = n.abs();
  if (n == 0) return "'a"; // sıfır
  if (n % 10 != 0) return birler[n % 10];
  if (n % 100 != 0) return onlar[(n ~/ 10) % 10];
  return "'e"; // yüz, bin
}
