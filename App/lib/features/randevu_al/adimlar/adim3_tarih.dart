import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';
import 'package:berber_app_ui/data/api/randevu_api.dart';
import 'package:berber_app_ui/features/randevu_al/randevu_provider.dart';
import 'package:berber_app_ui/features/randevu_al/widgets/takvim_bilesenleri.dart';

class Adim3Tarih extends StatefulWidget {
  const Adim3Tarih({super.key});

  @override
  State<Adim3Tarih> createState() => _Adim3TarihState();
}

class _Adim3TarihState extends State<Adim3Tarih> {
  Set<String> _musaitTarihler = {};

  /// tarih → boş başlangıç sayısı (yalnızca berber seçiliyse gelir; dolu gün = 0)
  Map<String, int> _bosSlot = {};
  bool _yukleniyor = true;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    final provider = context.read<RandevuProvider>();
    final berberId = provider.seciliBerber?.id;
    try {
      final data = await RandevuApi.musaitTakvim(
          berberId: berberId,
          salonId: provider.salonId,
          hizmetIds: berberId == null ? null : provider.seciliHizmetler.map((h) => h.id).toList());
      if (mounted) {
        setState(() {
          _musaitTarihler = data.map((e) => e['tarih'] as String).toSet();
          _bosSlot = {for (final e in data) if (e['bos_slot'] is int) e['tarih'] as String: e['bos_slot'] as int};
          _yukleniyor = false;
        });
      }
    } on ApiHata catch (e) {
      if (mounted) {
        setState(() => _yukleniyor = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mesaj), backgroundColor: AppTheme.error));
      }
    }
  }

  bool _isDayEnabled(DateTime day) => _musaitTarihler.contains(tarihStr(day));

  /// Takvim işareti rengi: altın = müsait, turuncu = az yer, kırmızı = dolu (bekleme listesine yazılabilir)
  Color? _isaretRengi(DateTime day) {
    final str = tarihStr(day);
    if (!_musaitTarihler.contains(str)) return null;
    final bos = _bosSlot[str];
    if (bos == 0) return AppTheme.error;
    if (bos != null && bos <= azYerEsigi) return Colors.orange;
    return AppTheme.gold;
  }

  String _tarihFormatla(DateTime t) {
    const aylar = [
      '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    const gunler = [
      '', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe',
      'Cuma', 'Cumartesi', 'Pazar'
    ];
    return '${gunler[t.weekday]}, ${t.day} ${aylar[t.month]} ${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RandevuProvider>();
    final now = DateTime.now();
    final ayBaslangic = DateTime(now.year, now.month, now.day);
    // Takvim, backend'in açtığı rezervasyon ufku kadar uzanır
    final sonAcik = _musaitTarihler.isEmpty
        ? ayBaslangic.add(const Duration(days: 30))
        : _musaitTarihler.map(DateTime.parse).reduce((a, b) => a.isAfter(b) ? a : b);
    final ayBitis = sonAcik.isBefore(ayBaslangic) ? ayBaslangic : sonAcik;

    if (_yukleniyor) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.gold));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          // ── Takvim ────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.gold.withValues(alpha: 0.15)),
            ),
            child: TableCalendar(
              locale: 'tr_TR',
              firstDay: ayBaslangic,
              lastDay: ayBitis,
              focusedDay: _focusedDay.isAfter(ayBitis) ? ayBitis : _focusedDay,
              // Ayı değiştirince lockedDay sıfırlanmasın
              startingDayOfWeek: StartingDayOfWeek.monday,
              selectedDayPredicate: (day) =>
                  isSameDay(provider.seciliTarih, day),
              enabledDayPredicate: _isDayEnabled,
              onDaySelected: (selected, focused) {
                if (!_isDayEnabled(selected)) return;
                provider.tarihSec(selected);
                setState(() => _focusedDay = focused);
              },
              onPageChanged: (focused) {
                setState(() => _focusedDay = focused);
              },
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Ay',
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: true,
                outsideTextStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.2), fontSize: 13),
                // Bugün
                todayDecoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.25),
                    shape: BoxShape.circle),
                todayTextStyle:
                    const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold),
                // Seçili gün
                selectedDecoration: const BoxDecoration(
                    color: AppTheme.gold, shape: BoxShape.circle),
                selectedTextStyle: const TextStyle(
                    color: AppTheme.black, fontWeight: FontWeight.bold),
                // Normal açık günler
                defaultTextStyle:
                    const TextStyle(color: Colors.white, fontSize: 13),
                weekendTextStyle:
                    const TextStyle(color: Colors.white, fontSize: 13),
                // Kapalı günler (soluk)
                disabledTextStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.18), fontSize: 13),
                disabledDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.03)),
                // Müsait günlere altın nokta
                markerDecoration: const BoxDecoration(
                    color: AppTheme.gold, shape: BoxShape.circle),
                markersMaxCount: 1,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
                leftChevronIcon:
                    const Icon(Icons.chevron_left, color: AppTheme.gold, size: 28),
                rightChevronIcon:
                    const Icon(Icons.chevron_right, color: AppTheme.gold, size: 28),
                headerPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
                weekendStyle: GoogleFonts.inter(
                    color: AppTheme.gold.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              // Müsait / az yer / dolu günleri renkli noktayla işaretle
              eventLoader: (day) => _musaitTarihler.contains(tarihStr(day)) ? const ['gun'] : const [],
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, _) {
                  final renk = _isaretRengi(day);
                  if (renk == null) return null;
                  return Positioned(
                    bottom: 6,
                    child: Container(
                        width: 6, height: 6, decoration: BoxDecoration(color: renk, shape: BoxShape.circle)),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (provider.seciliTarih != null) GunDolulukBilgisi(bos: _bosSlot[tarihStr(provider.seciliTarih!)]),

          // ── Seçilen gün gösterimi ─────────────────────────
          if (provider.seciliTarih != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today,
                      color: AppTheme.gold, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    _tarihFormatla(provider.seciliTarih!),
                    style: GoogleFonts.inter(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),

          // ── Lejant ────────────────────────────────────────
          TakvimLejanti(doluluk: _bosSlot.isNotEmpty),
          const SizedBox(height: 8),
          Text(
            'Salonun kapalı olduğu günler ve personel izinleri otomatik olarak kapalıdır.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 11,
                height: 1.5),
          ),
        ],
      ),
    );
  }
}
