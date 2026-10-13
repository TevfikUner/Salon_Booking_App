import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:berber_app_ui/core/dil.dart';
import 'package:berber_app_ui/core/theme/app_theme.dart';
import 'package:berber_app_ui/core/utils/bicim.dart';
import 'package:berber_app_ui/data/api/api_client.dart';

/// İşletme paneli gün takvimi: her personel bir sütun, satırlar 30 dakikalık dilimler.
/// - Randevuya dokun → ayrıntı/aksiyonlar; aktif ve henüz başlamamış randevuya basılı tutup sürükle → başka saat
///   ya da (işletme sahibi) başka personel. Bırakılan hücrenin saati randevunun yeni başlangıcıdır.
/// - Boş hücreye dokun → o personel ve saatle "Randevu Ekle".
/// - Öğle arası ve saatlik blokeler taralı, izinli/çalışmayan personelin sütunu kapalı görünür.
/// Kurallar backend'de (çakışma, mola, bloke): geçersiz bırakma 409 ile reddedilir ve öneri gösterilir.
class GunTakvimi extends StatefulWidget {
  /// `/panel/akis` yanıtı (randevular, doluluk, mesai, mola, blokeler)
  final Json veri;
  final void Function(Json randevu) onRandevu;
  final void Function(int berberId, String saat) onBosHucre;
  final Future<void> Function(Json randevu, int berberId, String saat) onTasi;

  /// Personel girişi: yalnızca kendi sütunu gelir; başka sütuna taşıma yok
  final bool personel;

  const GunTakvimi({
    super.key,
    required this.veri,
    required this.onRandevu,
    required this.onBosHucre,
    required this.onTasi,
    this.personel = false,
  });

  static const slotDk = 30;
  static const satirH = 56.0;
  static const sutunW = 132.0;
  static const saatW = 48.0;

  @override
  State<GunTakvimi> createState() => _GunTakvimiState();
}

class _GunTakvimiState extends State<GunTakvimi> {
  final _dikey = ScrollController();
  final _yatay = ScrollController();
  final _baslik = ScrollController();
  final _alanKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _yatay.addListener(() {
      if (_baslik.hasClients && _baslik.offset != _yatay.offset) _baslik.jumpTo(_yatay.offset);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _simdiyeKaydir());
  }

  @override
  void dispose() {
    _dikey.dispose();
    _yatay.dispose();
    _baslik.dispose();
    super.dispose();
  }

  // ── Zaman ölçeği ──
  static int _dk(String s) {
    final p = s.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  static String _saat(int dk) => '${(dk ~/ 60).toString().padLeft(2, '0')}:${(dk % 60).toString().padLeft(2, '0')}';

  List<Json> get _randevular => (widget.veri['randevular'] as List).cast<Json>();

  /// Görünen aralık: salon mesaisi; mesai dışına taşan (ör. eski) randevu varsa onu da kapsar.
  (int, int) get _aralik {
    final mesai = widget.veri['mesai'] as Json?;
    var bas = mesai == null ? 9 * 60 : _dk(mesai['acilis']);
    var bit = mesai == null ? 20 * 60 : _dk(mesai['kapanis']);
    for (final r in _randevular) {
      bas = math.min(bas, _dk(r['saat']));
      bit = math.max(bit, _dk(r['bitis']));
    }
    const s = GunTakvimi.slotDk;
    return (bas ~/ s * s, (bit + s - 1) ~/ s * s);
  }

  double _y(int dk) => (dk - _aralik.$1) / GunTakvimi.slotDk * GunTakvimi.satirH;

  List<Json> get _sutunlar {
    final doluluk = (widget.veri['doluluk'] as List).cast<Json>();
    final idler = doluluk.map((d) => d['berber_id']).toSet();
    return [
      ...doluluk,
      // Kadrodan çıkmış personelin o güne kalmış randevuları da görünsün
      for (final r in _randevular)
        if (!idler.contains(r['berber']['id']) && idler.add(r['berber']['id']))
          {'berber_id': r['berber']['id'], 'ad': r['berber']['ad'], 'kapali_neden': null},
    ];
  }

  bool get _bugun => widget.veri['tarih'] == tarihStr(DateTime.now());

  void _simdiyeKaydir() {
    if (!_bugun || !_dikey.hasClients) return;
    final n = DateTime.now();
    final y = _y(n.hour * 60 + n.minute) - 2 * GunTakvimi.satirH;
    _dikey.jumpTo(y.clamp(0, _dikey.position.maxScrollExtent));
  }

  /// Sürüklerken kenara yaklaşınca kaydır (ScrollView'lar Draggable ile kendiliğinden kaymaz).
  void _kenarKaydir(Offset global) {
    final kutu = _alanKey.currentContext?.findRenderObject() as RenderBox?;
    if (kutu == null) return;
    final yerel = kutu.globalToLocal(global);
    const kenar = 48.0, adim = 14.0;
    void kaydir(ScrollController c, double fark) {
      if (!c.hasClients) return;
      c.jumpTo((c.offset + fark).clamp(0, c.position.maxScrollExtent));
    }

    if (yerel.dy < kenar) kaydir(_dikey, -adim);
    if (yerel.dy > kutu.size.height - kenar) kaydir(_dikey, adim);
    if (yerel.dx < GunTakvimi.saatW + kenar) kaydir(_yatay, -adim);
    if (yerel.dx > kutu.size.width - kenar) kaydir(_yatay, adim);
  }

  bool _tasinabilir(Json r) {
    if (r['durum'] != 'onaylandi') return false;
    final bas = DateTime.tryParse('${r['tarih']}T${r['saat']}:00');
    return bas != null && bas.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final (bas, bit) = _aralik;
    final satir = (bit - bas) ~/ GunTakvimi.slotDk;
    final sutunlar = _sutunlar;
    final yukseklik = satir * GunTakvimi.satirH;
    final genislik = sutunlar.length * GunTakvimi.sutunW;

    return Column(
      children: [
        // Personel adları (gövdeyle birlikte yatay kayar, dikeyde sabit)
        Container(
          height: 40,
          color: AppTheme.black,
          child: Row(
            children: [
              const SizedBox(width: GunTakvimi.saatW),
              Expanded(
                child: SingleChildScrollView(
                  controller: _baslik,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Row(
                    children: [
                      for (final s in sutunlar)
                        SizedBox(
                          width: GunTakvimi.sutunW,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              s['ad'] ?? '',
                              key: ValueKey('takvim_sutun_${s['berber_id']}'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(color: AppTheme.gold, fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            key: _alanKey,
            controller: _dikey,
            padding: const EdgeInsets.only(bottom: 96),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _saatSutunu(bas, satir),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _yatay,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: genislik,
                      height: yukseklik,
                      child: Stack(
                        children: [
                          for (final (i, s) in sutunlar.indexed)
                            Positioned(
                              left: i * GunTakvimi.sutunW,
                              top: 0,
                              width: GunTakvimi.sutunW,
                              height: yukseklik,
                              child: _sutun(s, bas, satir),
                            ),
                          if (_bugun) _simdiCizgisi(genislik),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _saatSutunu(int bas, int satir) => SizedBox(
    width: GunTakvimi.saatW,
    child: Column(
      children: [
        for (var i = 0; i < satir; i++)
          SizedBox(
            height: GunTakvimi.satirH,
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                i.isEven ? _saat(bas + i * GunTakvimi.slotDk) : '',
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _sutun(Json s, int bas, int satir) {
    final berberId = s['berber_id'] as int;
    final kapali = s['kapali_neden'] as String?;
    final mola = widget.veri['mola'] as Json?;
    final blokeler = (widget.veri['blokeler'] as List? ?? const []).cast<Json>().where(
      (b) => b['berber_id'] == berberId,
    );
    final randevular = _randevular.where((r) => r['berber']['id'] == berberId && r['durum'] != 'iptal');
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: AppTheme.gold.withValues(alpha: 0.08))),
      ),
      child: Stack(
        children: [
          // Hücreler: dokun → randevu ekle; sürüklenen randevuyu kabul et
          for (var i = 0; i < satir; i++)
            Positioned(
              top: i * GunTakvimi.satirH,
              left: 0,
              right: 0,
              height: GunTakvimi.satirH,
              child: _hucre(berberId, _saat(bas + i * GunTakvimi.slotDk), i, kapali != null),
            ),
          if (mola != null && kapali == null) _alan(_dk(mola['bas']), _dk(mola['bit']), Dil.t.ogleArasi),
          for (final b in blokeler) _alan(_dk(b['bas_saat']), _dk(b['bit_saat']), b['aciklama'] ?? Dil.t.kapali),
          if (kapali != null)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.04),
                padding: const EdgeInsets.all(8),
                alignment: Alignment.topCenter,
                child: Text(
                  kapali,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11),
                ),
              ),
            ),
          for (final r in randevular) _randevuBlogu(r),
        ],
      ),
    );
  }

  Widget _hucre(int berberId, String saat, int i, bool kapali) {
    final cizgi = BoxDecoration(
      border: Border(
        top: BorderSide(color: Colors.white.withValues(alpha: i.isEven ? 0.08 : 0.03)),
      ),
    );
    if (kapali) return DecoratedBox(decoration: cizgi);
    return DragTarget<Json>(
      onWillAcceptWithDetails: (d) => !widget.personel || d.data['berber']['id'] == berberId,
      onAcceptWithDetails: (d) => widget.onTasi(d.data, berberId, saat),
      builder: (context, aday, _) => InkWell(
        key: ValueKey('hucre_${berberId}_$saat'),
        onTap: () => widget.onBosHucre(berberId, saat),
        child: Container(
          decoration: cizgi.copyWith(color: aday.isNotEmpty ? AppTheme.gold.withValues(alpha: 0.25) : null),
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(left: 4, top: 2),
          child: aday.isNotEmpty
              ? Text(
                  saat,
                  style: GoogleFonts.inter(color: AppTheme.gold, fontSize: 11, fontWeight: FontWeight.w700),
                )
              : null,
        ),
      ),
    );
  }

  Widget _alan(int bas, int bit, String etiket) => Positioned(
    top: _y(bas),
    height: _y(bit) - _y(bas),
    left: 0,
    right: 0,
    child: IgnorePointer(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        padding: const EdgeInsets.all(4),
        child: Text(
          etiket,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 10),
        ),
      ),
    ),
  );

  Color _renk(String durum) => switch (durum) {
    'tamamlandi' => AppTheme.success,
    'gelmedi' => Colors.orange,
    _ => AppTheme.gold,
  };

  Widget _randevuBlogu(Json r) {
    final bas = _dk(r['saat']), bit = _dk(r['bitis']);
    final yukseklik = math.max(_y(bit) - _y(bas), 28.0);
    final renk = _renk(r['durum']);
    final riskli = r['durum'] == 'onaylandi' && r['guven']?['etiket'] == 'Riskli';
    Widget kart({bool golge = false}) => Container(
      width: GunTakvimi.sutunW - 6,
      height: yukseklik - 2,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Color.alphaBlend(renk.withValues(alpha: 0.22), AppTheme.surface),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: riskli ? AppTheme.error : renk, width: 3)),
        boxShadow: golge ? [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 12)] : null,
      ),
      // Kısa (30 dk) blokta büyük yazıyla satırlar sığmayabilir: taşan kısım kırpılır, hata verilmez
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${r['saat']}–${r['bitis']}${r['not_var'] == true ? ' 📝' : ''}',
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: GoogleFonts.inter(color: renk, fontSize: 11, fontWeight: FontWeight.w700),
            ),
            Text(
              r['musteri']['ad'] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            if (yukseklik > 60)
              Text(
                (r['hizmetler'] as List).map((h) => h['ad']).join(', '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 11),
              ),
          ],
        ),
      ),
    );

    final govde = GestureDetector(
      key: ValueKey('takvim_randevu_${r['id']}'),
      onTap: () => widget.onRandevu(r),
      child: kart(),
    );
    return Positioned(
      top: _y(bas) + 1,
      left: 3,
      child: Semantics(
        button: true,
        label: '${r['saat']} ${r['musteri']['ad']}${_tasinabilir(r) ? ', ${Dil.t.tasimakIcinBasiliTut}' : ''}',
        child: !_tasinabilir(r)
            ? govde
            : LongPressDraggable<Json>(
                data: r,
                dragAnchorStrategy: pointerDragAnchorStrategy,
                feedback: Material(
                  color: Colors.transparent,
                  child: Opacity(opacity: 0.9, child: kart(golge: true)),
                ),
                childWhenDragging: IgnorePointer(child: Opacity(opacity: 0.3, child: kart())),
                onDragUpdate: (d) => _kenarKaydir(d.globalPosition),
                child: govde,
              ),
      ),
    );
  }

  Widget _simdiCizgisi(double genislik) {
    final n = DateTime.now();
    final dk = n.hour * 60 + n.minute;
    final (bas, bit) = _aralik;
    if (dk < bas || dk > bit) return const SizedBox.shrink();
    return Positioned(
      top: _y(dk),
      left: 0,
      width: genislik,
      child: IgnorePointer(child: Container(height: 2, color: AppTheme.error.withValues(alpha: 0.8))),
    );
  }
}
