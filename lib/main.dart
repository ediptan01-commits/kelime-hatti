import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
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
  String? notice;
  // Each puzzle uses a ten-hole dial. A long word can reuse the same holes.
  late List<List<String>> shuffledDials;

  List<String> get letters => shuffledDials[levelIndex];

  List<String> _buildLetters(int index) {
    final base = <String>{...levels[index].answer.split('')};
    const pool = ['A','E','İ','I','O','U','K','L','M','N','R','S','T','Y','Z','P','D','F','G','H','V','B','Ç','Ş','Ü','Ö'];
    final random = math.Random(index * 733 + DateTime.now().microsecondsSinceEpoch);
    final extra = pool.where((c) => !base.contains(c)).toList()..shuffle(random);
    for (final c in extra) {
      if (base.length >= 10) break;
      base.add(c);
    }
    final dial = base.take(10).toList()..shuffle(random);
    return dial;
  }

  @override
  void initState() {
    super.initState();
    shuffledDials = List.generate(levels.length, _buildLetters);
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
    if (typed.length >= levels[levelIndex].answer.length) return;
    setState(() { typed += letter; notice = null; });
    HapticFeedback.selectionClick();
    SystemSound.play(SystemSoundType.click);

  }

  Future<void> _check() async {
    if (typed.isEmpty) return;
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
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF263B39), Color(0xFF101F20), Color(0xFF090F10)],
        )),
        child: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
          final width = math.min(constraints.maxWidth, 420.0);
          return SingleChildScrollView(
            child: Center(child: SizedBox(width: width, child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
              child: Column(children: [
                Align(alignment: Alignment.centerRight, child: IconButton(
                  tooltip: 'Bölüm haritası', onPressed: _chooseLevel,
                  icon: const Icon(Icons.settings, color: Color(0xFFAAAE9F)),
                )),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFFB58B50), Color(0xFFF1D9A5), Color(0xFFE0BE80), Color(0xFFB98E50)]),
                    border: Border.all(color: const Color(0xFF83623D), width: 2),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 10, offset: Offset(2, 5))],
                  ),
                  child: Column(children: [
                    Text('Bölüm ${levelIndex + 1}', style: const TextStyle(color: Color(0xFF51442D), fontFamily: 'serif', fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(level.name.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF332D1C), fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.bold)),
                    const Divider(color: Color(0xFFAD8B58), height: 20),
                    Text(level.clue, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF51402B), fontFamily: 'serif', fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, fontSize: 18, height: 1.35)),
                  ]),
                ),
                const SizedBox(height: 24),
                LayoutBuilder(builder: (context, box) {
                  final count = level.answer.length;
                  final cellWidth = math.min(43.0, (box.maxWidth - count * 4) / count);
                  return Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(count, (i) => Container(
                    width: cellWidth, height: 49, margin: const EdgeInsets.symmetric(horizontal: 2), alignment: Alignment.center,
                    decoration: BoxDecoration(color: const Color(0xFF101B1B), borderRadius: BorderRadius.circular(5), border: Border.all(color: const Color(0xFF948B70), width: 1.5),
                      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 3, offset: Offset(1, 2))]),
                    child: Text(i < typed.length ? typed[i] : '', style: TextStyle(fontSize: math.min(24.0, cellWidth * .65), color: _paper, fontFamily: 'serif')),
                  )));
                }),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.fromLTRB(9, 12, 9, 14),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.elliptical(180, 72), bottom: Radius.circular(20)),
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFF603B27), Color(0xFF321C15), Color(0xFF4B2B1C), Color(0xFF24130F)]),
                    border: Border.all(color: const Color(0xFF765139), width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 14, offset: Offset(0, 7))],
                  ),
                  child: Column(children: [
                    RotaryDial(key: ValueKey(levelIndex), letters: letters, onLetter: _pick),
                    const SizedBox(height: 10),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: Column(children: [
                        IconButton.filledTonal(tooltip: 'Son harfi sil', style: IconButton.styleFrom(backgroundColor: const Color(0xFF655034), foregroundColor: _paper),
                          onPressed: typed.isEmpty ? null : () => setState(() { typed = typed.substring(0, typed.length - 1); notice = null; }), icon: const Icon(Icons.undo)),
                        const Text('Sil', style: TextStyle(color: _paper, fontFamily: 'serif')),
                      ])),
                      Expanded(flex: 2, child: Padding(padding: const EdgeInsets.only(top: 3), child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF27633C), foregroundColor: _paper, padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Color(0xFF65975A), width: 2))),
                        onPressed: typed.isEmpty ? null : _check,
                        child: const Text('Kelimeyi\nKontrol Et', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'serif', fontSize: 17)),
                      ))),
                      Expanded(child: Column(children: [
                        IconButton.filledTonal(tooltip: 'İpucu', style: IconButton.styleFrom(backgroundColor: const Color(0xFF655034), foregroundColor: const Color(0xFFFFCE65)),
                          onPressed: () => showDialog<void>(context: context, builder: (ctx) => AlertDialog(title: const Text('İpucu'), content: Text('Kelime ${level.answer.length} harfli ve “${level.clue}” ipucuyla ilgili.'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tamam'))])),
                          icon: const Icon(Icons.lightbulb)),
                        const Text('İpucu', style: TextStyle(color: _paper, fontFamily: 'serif')),
                      ])),
                    ]),
                  ]),
                ),
                if (notice != null) Padding(padding: const EdgeInsets.only(top: 14), child: Text(notice!, textAlign: TextAlign.center, style: const TextStyle(color: _gold))),
              ]),
            ))),
          );
        })),
      ),
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
  final AudioPlayer sound = AudioPlayer();
  bool soundReady = false;
  bool soundPlaying = false;
  Timer? movementTimer;
  Animation<double>? returning;
  int? active;
  double rotation = 0;
  double lastPointerAngle = 0;
  double traversed = 0;
  int lastTick = 0;
  static const count = 10;
  static const step = math.pi * 2 / count;
  static const maxTravel = 2.25;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
    _prepareSound();
    controller.addListener(() {
      if (mounted) setState(() => rotation = returning?.value ?? 0);
    });
  }

  Future<void> _prepareSound() async {
    try {
      await sound.setReleaseMode(ReleaseMode.loop);
      await sound.setSource(AssetSource('sounds/rotary.wav'));
      await sound.setVolume(.55);
      if (mounted) soundReady = true;
    } catch (_) {
      // Sound is optional; dialing still works if the asset is unavailable.
    }
  }

  void _startSound() {
    if (!soundReady || soundPlaying) return;
    soundPlaying = true;
    sound.resume();
  }

  void _stopSound() {
    if (!soundPlaying) return;
    soundPlaying = false;
    sound.pause();
  }

  @override
  void dispose() {
    movementTimer?.cancel();
    controller.dispose();
    sound.dispose();
    super.dispose();
  }

  double _angle(Offset point, Size size) =>
      math.atan2(point.dy - size.height / 2, point.dx - size.width / 2);
  double _normalize(double a) => (a + math.pi) % (math.pi * 2) - math.pi;

  void _start(Offset pos, Size size) {
    if (controller.isAnimating) return;
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;
    final theta = _angle(pos, size);
    for (var i = 0; i < count; i++) {
      final holeAngle = -math.pi / 2 + i * step;
      final holeCenter = center + Offset(math.cos(holeAngle), math.sin(holeAngle)) * (r * .73);
      if ((pos - holeCenter).distance <= r * .16) {
        setState(() {
          active = i;
          lastPointerAngle = theta;
          rotation = 0;
          traversed = 0;
          lastTick = 0;
        });
        HapticFeedback.mediumImpact();

        return;
      }
    }
  }

  void _update(Offset pos, Size size) {
    if (active == null) return;
    final angle = _angle(pos, size);
    final delta = _normalize(angle - lastPointerAngle);
    lastPointerAngle = angle;
    // Accumulate angular motion so dragging across +/-180 degrees stays smooth.
    // A small backward adjustment is allowed, but rotation never becomes negative.
    traversed = (traversed + delta).clamp(0.0, maxTravel);
    if (delta.abs() > .002 && traversed > 0) {
      _startSound();
      movementTimer?.cancel();
      movementTimer = Timer(const Duration(milliseconds: 85), _stopSound);
    }
    final tick = (traversed / .19).floor();
    if (tick > lastTick) {
      HapticFeedback.selectionClick();

    }
    lastTick = tick;
    setState(() => rotation = traversed);
  }

  void _end() {
    if (active == null) return;
    movementTimer?.cancel();
    final selected = active!;
    final accepted = traversed >= .28;
    final from = rotation;
    setState(() => active = null);
    if (from > .01) _startSound();
    controller.duration = Duration(milliseconds: (370 + 360 * from / maxTravel).round());
    returning = Tween<double>(begin: from, end: 0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );
    controller.forward(from: 0).then((_) {
      if (!mounted) return;
      _stopSound();
      if (accepted) widget.onLetter(widget.letters[selected]);
    });
  }

  @override
  Widget build(BuildContext context) => Center(child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 355),
    child: AspectRatio(aspectRatio: 1, child: LayoutBuilder(builder: (context, box) {
      final size = Size(box.maxWidth, box.maxHeight);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (d) => _start(d.localPosition, size),
        onPanStart: (d) { if (active == null) _start(d.localPosition, size); },
        onPanUpdate: (d) => _update(d.localPosition, size),
        onPanEnd: (_) => _end(),
        onPanCancel: _end,
        child: CustomPaint(painter: DialPainter(widget.letters, rotation, active)),
      );
    })),
  ));
}

class DialPainter extends CustomPainter {
  final List<String> letters;
  final double rotation;
  final int? active;
  DialPainter(this.letters, this.rotation, this.active);
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;
    void circle(double radius, Color color, {PaintingStyle style = PaintingStyle.fill, double stroke = 1}) {
      canvas.drawCircle(c, radius, Paint()..color = color..style = style..strokeWidth = stroke);
    }
    circle(r * .99, const Color(0xFF0A0D0D));
    circle(r * .96, const Color(0xFF4C2D1E));
    circle(r * .925, const Color(0xFFBA874C));
    canvas.drawCircle(c, r * .88, Paint()..shader = const RadialGradient(
      center: Alignment(-.35, -.4), colors: [Color(0xFFBD945A), Color(0xFF78603C), Color(0xFF382C1C)],
    ).createShader(Rect.fromCircle(center: c, radius: r * .88)));
    final grain = math.Random(47);
    for (var i = 0; i < 450; i++) {
      final a = grain.nextDouble() * math.pi * 2;
      final d = math.sqrt(grain.nextDouble()) * r * .86;
      canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * d, .4 + grain.nextDouble(), Paint()..color = const Color(0x22352516));
    }
    circle(r * .865, const Color(0xFFDAB278), style: PaintingStyle.stroke, stroke: r * .022);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rotation);
    canvas.translate(-c.dx, -c.dy);
    for (var i = 0; i < 10; i++) {
      final theta = -math.pi / 2 + i * math.pi / 5;
      final center = Offset(c.dx + r * .73 * math.cos(theta), c.dy + r * .73 * math.sin(theta));
      final selected = active == i;
      canvas.drawCircle(center + Offset(1, 3), r * .157, Paint()..color = Colors.black87);
      canvas.drawCircle(center, r * .148, Paint()..color = selected ? const Color(0xFFFFD575) : const Color(0xFFEBD6B4));
      if (selected) canvas.drawCircle(center, r * .157, Paint()..color = const Color(0xFFFFEAB3)..style = PaintingStyle.stroke..strokeWidth = 4);
      final tp = TextPainter(text: TextSpan(text: letters[i], style: TextStyle(color: const Color(0xFF332518), fontFamily: 'serif', fontSize: r * .157, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
    }
    circle(r * .455, const Color(0xFF3B2A1F));
    circle(r * .412, const Color(0xFFD2A062));
    circle(r * .37, const Color(0xFF9D673C));
    canvas.drawCircle(c, r * .335, Paint()..shader = const SweepGradient(
      colors: [Color(0xFF795025), Color(0xFFE9C47F), Color(0xFF8A592C), Color(0xFFD5A75C), Color(0xFF795025)],
    ).createShader(Rect.fromCircle(center: c, radius: r * .335)));
    for (var i = 1; i < 22; i++) {
      circle(r * (.12 + i * .009), const Color(0x22734A22), style: PaintingStyle.stroke, stroke: .5);
    }

    canvas.restore();
    final stopper = Rect.fromCenter(center: Offset(c.dx + r * .64, c.dy + r * .66), width: r * .30, height: r * .13);
    canvas.save();
    canvas.translate(stopper.center.dx, stopper.center.dy);
    canvas.rotate(-.7);
    canvas.translate(-stopper.center.dx, -stopper.center.dy);
    canvas.drawRRect(RRect.fromRectAndRadius(stopper, Radius.circular(r * .07)), Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE0DFCA), Color(0xFF555D58), Color(0xFFAEB3A4)]).createShader(stopper));
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant DialPainter oldDelegate) => oldDelegate.rotation != rotation || oldDelegate.active != active || oldDelegate.letters != letters;
}
