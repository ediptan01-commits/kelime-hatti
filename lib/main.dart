import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KelimeHattiApp());
}

const _paper = Color(0xFFF2D5A0);
const _dark = Color(0xFF0D2528);
const _gold = Color(0xFFD6A65B);
const _green = Color(0xFF236744);

class Level {
  final String name;
  final String clue;
  final String answer;
  final String story;
  final String incomingClue;
  const Level(this.name, this.clue, this.answer, this.story, this.incomingClue);
}

// Each level has exactly ten distinct rotary letters and a story-linked clue.
const levels = <Level>[
  Level('Kayıp Mesaj', 'Eski bir defterde karşıma çıkan silik ipucu: “Unutulmuş bir eşya.”', 'SAAT', 'Duvardaki saat 23.17’de durmuş. Arkasında bir fotoğraf saklı.', 'Fotoğraftaki iz seni eski istasyona götürecek.'),
  Level('Eski Fotoğraf', 'Fotoğrafın arkasında yazıyor: “Rayların buluştuğu yer.”', 'GAR', 'İstasyondaki bekleme salonunda bir zarf buldun.', 'Zarfın üzerindeki tek kelime: ANAHTAR.'),
  Level('Son Tren', 'Kilidi açan, metalden küçük bir nesne.', 'ANAHTAR', 'Paslı anahtar eski bir otelin üçüncü odasını açıyor.', 'Üçüncü odada duvara asılmış bir şey aramalısın.'),
  Level('Gizli Oda', 'Odanın duvarında zamanı gösteren eşya.', 'TAKVİM', 'Takvimde yalnızca 12 Kasım tarihi işaretli.', 'Bu tarihte şehirde büyük bir karanlık yaşanmış.'),
  Level('Zamanın İzi', 'Karanlıkta yol gösteren ışık kaynağı.', 'FENER', 'Fenerin altında bir harita ve üstü çizili kıyı yolu var.', 'Haritadaki işaret bir kıyı yapısını gösteriyor.'),
  Level('Unutulan İsim', 'Gemilere yol gösteren kıyıdaki kule.', 'DENİZFENERİ', 'Kulende mühürlü bir kutu var. İçinde bir mektup saklı.', 'Mektup yıllar önce durdurulan bir saati anlatıyor.'),
  Level('Kırık Saat', 'Dakikaları ve saatleri gösteren düzenek.', 'SAAT', 'Saatin içinde saklanan sayılar eski bir telefon numarası oluşturuyor.', 'Numarayı çeviren kişinin kim olduğunu öğren.'),
  Level('Son Görüşme', 'Telefonun karşı ucundaki insana söylenen ilk söz.', 'ALO', 'Ahizeden bir ses: “Ben seni yıllardır bekliyorum.”', 'Sesin sahibinin bıraktığı belgenin adını bul.'),
  Level('Gerçek Ortaya Çıkıyor', 'İçinde yazılı sözler taşıyan, zarfla gelen belge.', 'MEKTUP', 'Mektup kaybolan kişinin gerçeği saklamak için gittiğini anlatıyor.', 'Son çağrı, gerçeğin saklandığı yeri tarif ediyor.'),
  Level('Son Çağrı', 'Geçmişten geriye kalan iz ve hatırlanan şey.', 'HATIRA', 'Telefon son kez çaldı. Gizem çözüldü: Tüm aramalar geçmişte bırakılan hatıralardı.', 'Tebrikler! Hikâyenin sonuna ulaştın.'),
];

class KelimeHattiApp extends StatelessWidget {
  const KelimeHattiApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Kelime Hattı', debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, brightness: Brightness.dark, scaffoldBackgroundColor: _dark, colorSchemeSeed: _gold),
        home: const GamePage(),
      );
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int levelIndex = 0;
  int unlocked = 0;
  String typed = '';
  bool loading = true;
  bool moving = false;
  String? notice;
  // Each puzzle uses a ten-hole dial. A long word can reuse the same holes.
  List<String> get letters {
    final base = <String>{...levels[levelIndex].answer.split('')};
    const pool = ['A','E','İ','I','O','U','K','L','M','N','R','S','T','Y','Z','P','D','F','G','H','V','B','Ç','Ş','Ü','Ö'];
    for (final c in pool) {
      if (base.length >= 10) break;
      base.add(c);
    }
    return base.take(10).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final pref = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      unlocked = (pref.getInt('unlocked') ?? 0).clamp(0, levels.length - 1);
      levelIndex = unlocked;
      loading = false;
    });
  }

  void _pick(String letter) {
    if (moving || typed.length >= 16) return;
    setState(() { typed += letter; notice = null; moving = true; });
    HapticFeedback.selectionClick();
    SystemSound.play(SystemSoundType.click);
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => moving = false);
    });
  }

  Future<void> _check() async {
    if (moving || typed.isEmpty) return;
    if (typed != levels[levelIndex].answer) {
      HapticFeedback.heavyImpact();
      setState(() => notice = 'Hat meşgul! Kelimeyi yeniden dene.');
      return;
    }
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.alert);
    final current = levels[levelIndex];
    final last = levelIndex == levels.length - 1;
    if (levelIndex == unlocked && !last) {
      unlocked++;
      final pref = await SharedPreferences.getInstance();
      await pref.setInt('unlocked', unlocked);
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF173438),
        title: const Row(children: [Icon(Icons.phone_in_talk, color: _gold), SizedBox(width: 10), Expanded(child: Text('GELEN ÇAĞRI'))]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(current.story, style: const TextStyle(color: _paper, fontSize: 16)),
          const SizedBox(height: 18),
          const Text('Bilinmeyen numara:', style: TextStyle(color: _gold)),
          Text('“${current.incomingClue}”', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 17)),
        ]),
        actions: [FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _green),
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(last ? 'Hikâyeyi bitir' : 'Sonraki bölüme geç'),
        )],
      ),
    );
    if (!mounted) return;
    setState(() {
      if (!last) levelIndex++;
      typed = '';
      notice = last ? 'Tebrikler! 10 bölüm tamamlandı.' : null;
    });
  }

  void _chooseLevel() {
    showModalBottomSheet<void>(
      context: context, backgroundColor: const Color(0xFF18363A), isScrollControlled: true,
      builder: (sheetContext) => SafeArea(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('BÖLÜM HARİTASI', style: TextStyle(color: _gold, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          ...List.generate(levels.length, (i) => ListTile(
            dense: true,
            leading: Icon(i <= unlocked ? Icons.radio_button_checked : Icons.lock_outline, color: i <= unlocked ? _gold : Colors.grey),
            title: Text('${i + 1}. ${levels[i].name}'),
            onTap: i > unlocked ? null : () {
              Navigator.pop(sheetContext);
              setState(() { levelIndex = i; typed = ''; notice = null; });
            },
          )),
        ]),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final level = levels[levelIndex];
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('KELİME HATTI', style: TextStyle(color: _gold, fontFamily: 'serif', fontWeight: FontWeight.bold, letterSpacing: 2)), actions: [
        IconButton(tooltip: 'Bölümler', onPressed: _chooseLevel, icon: const Icon(Icons.map_outlined, color: _gold)),
      ]),
      body: SafeArea(child: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ConstrainedBox(constraints: BoxConstraints(minHeight: constraints.maxHeight), child: Column(children: [
          Text('BÖLÜM ${levelIndex + 1} / ${levels.length}', style: const TextStyle(color: _gold, letterSpacing: 3)),
          const SizedBox(height: 5),
          Text(level.name.toUpperCase(), style: const TextStyle(fontSize: 23, fontFamily: 'serif', fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: _paper, borderRadius: BorderRadius.circular(8)), child: Text(level.clue, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF402818), fontSize: 17, fontStyle: FontStyle.italic))),
          const SizedBox(height: 15),
          Text(typed.isEmpty ? 'NUMARAYI ÇEVİR...' : typed, textAlign: TextAlign.center, style: const TextStyle(color: _gold, fontSize: 27, letterSpacing: 4, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text('${typed.length} / ${level.answer.length} harf', style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 15),
          RotaryDial(key: ValueKey(levelIndex), letters: letters, onLetter: _pick),
          const SizedBox(height: 18),
          Text(notice ?? 'Harf deliğine dokun, saat yönünde çevir ve bırak.', textAlign: TextAlign.center, style: TextStyle(color: notice == null ? Colors.white70 : Colors.orangeAccent)),
          const SizedBox(height: 15),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            OutlinedButton.icon(onPressed: typed.isEmpty ? null : () => setState(() { typed = typed.substring(0, typed.length - 1); notice = null; }), icon: const Icon(Icons.backspace_outlined), label: const Text('Sil')),
            const SizedBox(width: 12),
            FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: _green), onPressed: typed.isEmpty ? null : _check, icon: const Icon(Icons.phone), label: const Text('Ara / Kontrol et')),
            const SizedBox(width: 12),
            IconButton(tooltip: 'İpucu', onPressed: () => showDialog<void>(context: context, builder: (ctx) => AlertDialog(title: const Text('İpucu'), content: Text('Kelime ${level.answer.length} harfli ve “${level.clue}” ipucuyla ilgili.'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tamam'))])), icon: const Icon(Icons.lightbulb_outline, color: _gold)),
          ]),
          const SizedBox(height: 12),
        ])),
      ))),
    );
  }
}

class RotaryDial extends StatefulWidget {
  final List<String> letters;
  final ValueChanged<String> onLetter;
  const RotaryDial({super.key, required this.letters, required this.onLetter});
  @override
  State<RotaryDial> createState() => _RotaryDialState();
}

class _RotaryDialState extends State<RotaryDial> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  Animation<double>? returning;
  int? active;
  double rotation = 0;
  double initialAngle = 0;
  bool dragged = false;
  static const count = 10;
  static const step = math.pi * 2 / count;
  static const maxTravel = 1.7;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
    controller.addListener(() { if (mounted) setState(() => rotation = returning?.value ?? 0); });
  }

  @override
  void dispose() { controller.dispose(); super.dispose(); }

  double _angle(Offset point, Size size) => math.atan2(point.dy - size.height / 2, point.dx - size.width / 2);
  double _normalize(double a) { while (a < -math.pi) { a += 2 * math.pi; } while (a > math.pi) { a -= 2 * math.pi; } return a; }

  void _start(Offset pos, Size size) {
    if (controller.isAnimating) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (pos - center).distance / (size.shortestSide / 2);
    if (radius < .57 || radius > .97) return;
    final theta = _angle(pos, size);
    for (var i = 0; i < count; i++) {
      final holeAngle = -math.pi / 2 + i * step;
      if (_normalize(theta - holeAngle).abs() < .22) {
        setState(() { active = i; initialAngle = theta; rotation = 0; dragged = false; });
        return;
      }
    }
  }

  void _update(Offset pos, Size size) {
    if (active == null) return;
    final angle = _angle(pos, size);
    final delta = _normalize(angle - initialAngle);
    // Clockwise is positive in screen coordinates. The dial cannot be turned backward.
    final next = delta.clamp(0.0, maxTravel);
    if (next > .16) dragged = true;
    setState(() => rotation = next);
  }

  void _end() {
    if (active == null) return;
    final selected = active!;
    final accepted = dragged && rotation >= .25;
    final from = rotation;
    setState(() => active = null);
    controller.duration = Duration(milliseconds: (260 + 380 * from / maxTravel).round());
    returning = Tween<double>(begin: from, end: 0).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    controller.forward(from: 0).then((_) {
      if (accepted && mounted) widget.onLetter(widget.letters[selected]);
    });
  }

  @override
  Widget build(BuildContext context) => Center(child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 355),
    child: AspectRatio(aspectRatio: 1, child: LayoutBuilder(builder: (context, box) {
      final size = Size(box.maxWidth, box.maxHeight);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (d) => _start(d.localPosition, size),
        onPanUpdate: (d) => _update(d.localPosition, size),
        onPanEnd: (_) => _end(), onPanCancel: _end,
        child: CustomPaint(painter: DialPainter(widget.letters, rotation)),
      );
    })),
  ));
}

class DialPainter extends CustomPainter {
  final List<String> letters;
  final double rotation;
  DialPainter(this.letters, this.rotation);
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;
    void circle(double radius, Color color, {PaintingStyle style = PaintingStyle.fill, double stroke = 1}) {
      canvas.drawCircle(c, radius, Paint()..color = color..style = style..strokeWidth = stroke);
    }
    circle(r * .98, const Color(0xFF050D0E));
    circle(r * .94, const Color(0xFF9A6635));
    circle(r * .89, const Color(0xFF171E20));
    circle(r * .86, _gold, style: PaintingStyle.stroke, stroke: r * .025);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rotation);
    canvas.translate(-c.dx, -c.dy);
    for (var i = 0; i < 10; i++) {
      final theta = -math.pi / 2 + i * math.pi / 5;
      final center = Offset(c.dx + r * .73 * math.cos(theta), c.dy + r * .73 * math.sin(theta));
      canvas.drawCircle(center, r * .145, Paint()..color = const Color(0xFF080D0D));
      canvas.drawCircle(center, r * .12, Paint()..color = const Color(0xFFECDBBC));
      final tp = TextPainter(text: TextSpan(text: letters[i], style: TextStyle(color: const Color(0xFF35271D), fontSize: r * .155, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
    }
    circle(r * .45, const Color(0xFF4B351F));
    circle(r * .4, const Color(0xFFD5A256));
    circle(r * .36, const Color(0xFFB57B3D));
    circle(r * .31, const Color(0xFF98642F));
    canvas.restore();
    // Static finger stop resembles a real rotary telephone stopper.
    final stopper = Rect.fromCenter(center: Offset(c.dx + r * .63, c.dy + r * .69), width: r * .3, height: r * .13);
    canvas.save();
    canvas.translate(stopper.center.dx, stopper.center.dy);
    canvas.rotate(-.7);
    canvas.translate(-stopper.center.dx, -stopper.center.dy);
    canvas.drawRRect(RRect.fromRectAndRadius(stopper, Radius.circular(r * .06)), Paint()..color = const Color(0xFFD9BA81));
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant DialPainter oldDelegate) => oldDelegate.rotation != rotation || oldDelegate.letters != letters;
}
