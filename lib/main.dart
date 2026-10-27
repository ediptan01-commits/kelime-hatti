import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KelimeHattiApp());
}

const paper = Color(0xFFF2D6A6);
const gold = Color(0xFFD9A65F);
const night = Color(0xFF10262A);
const wood = Color(0xFF3D2219);

class Level {
  final String name, clue, answer, story, incoming;
  const Level(this.name, this.clue, this.answer, this.story, this.incoming);
}

const levels = <Level>[
  Level('Kayıp Mesaj', 'Eski bir defterde karşıma çıkan silik ipucu: “Unutulmuş bir eşya.”', 'SAAT', 'Duvardaki saat 23.17’de durmuş. Arkasında bir fotoğraf saklı.', 'Fotoğraftaki iz seni eski istasyona götürecek.'),
  Level('Eski Fotoğraf', 'Fotoğrafın arkasında yazıyor: “Rayların buluştuğu yer.”', 'GAR', 'İstasyondaki bekleme salonunda bir zarf buldun.', 'Zarfın üzerindeki tek kelime: ANAHTAR.'),
  Level('Son Tren', 'Kilidi açan, metalden küçük bir nesne.', 'ANAHTAR', 'Paslı anahtar eski bir otelin üçüncü odasını açıyor.', 'Üçüncü odada duvara asılmış bir şey aramalısın.'),
  Level('Gizli Oda', 'Odanın duvarında zamanı gösteren eşya.', 'TAKVİM', 'Takvimde yalnızca 12 Kasım tarihi işaretli.', 'Bu tarihte şehirde büyük bir karanlık yaşanmış.'),
  Level('Zamanın İzi', 'Karanlıkta yol gösteren ışık kaynağı.', 'FENER', 'Fenerin altında bir harita ve üstü çizili kıyı yolu var.', 'Haritadaki işaret bir kıyı yapısını gösteriyor.'),
  Level('Unutulan İsim', 'Gemilere yol gösteren kıyıdaki kule.', 'DENİZFENERİ', 'Kulede mühürlü bir kutu var. İçinde bir mektup saklı.', 'Mektup yıllar önce durdurulan bir saati anlatıyor.'),
  Level('Kırık Saat', 'Dakikaları ve saatleri gösteren düzenek.', 'SAAT', 'Saatin içinde saklanan sayılar eski bir telefon numarası oluşturuyor.', 'Numarayı çeviren kişinin kim olduğunu öğren.'),
  Level('Son Görüşme', 'Telefonun karşı ucundaki insana söylenen ilk söz.', 'ALO', 'Ahizeden bir ses: “Ben seni yıllardır bekliyorum.”', 'Sesin sahibinin bıraktığı belgenin adını bul.'),
  Level('Gerçek Ortaya Çıkıyor', 'İçinde yazılı sözler taşıyan, zarfla gelen belge.', 'MEKTUP', 'Mektup kaybolan kişinin gerçeği saklamak için gittiğini anlatıyor.', 'Son çağrı, gerçeğin saklandığı yeri tarif ediyor.'),
  Level('Son Çağrı', 'Geçmişten geriye kalan iz ve hatırlanan şey.', 'HATIRA', 'Telefon son kez çaldı. Gizem çözüldü: Tüm aramalar geçmişte bırakılan hatıralardı.', 'Tebrikler! Hikâyenin sonuna ulaştın.'),
];

class KelimeHattiApp extends StatelessWidget {
  const KelimeHattiApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Kelime Hattı',
    theme: ThemeData(useMaterial3: true, brightness: Brightness.dark, scaffoldBackgroundColor: night, colorSchemeSeed: gold),
    home: const GamePage(),
  );
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int index = 0;
  int unlocked = 0;
  bool finished = false;
  bool ready = false;
  String typed = '';
  String? message;
  late final List<List<String>> dials = List.generate(levels.length, _makeDial);
  final AudioPlayer ring = AudioPlayer();

  List<String> _makeDial(int n) {
    final required = levels[n].answer.split('').toSet();
    const alphabet = ['A','E','İ','I','O','U','K','L','M','N','R','S','T','Y','Z','P','D','F','G','H','V','B','Ç','Ş','Ü','Ö'];
    final rng = math.Random(DateTime.now().microsecondsSinceEpoch + n * 7919);
    final others = alphabet.where((x) => !required.contains(x)).toList()..shuffle(rng);
    final result = [...required, ...others.take(10 - required.length)];
    // Prevent displaying the answer in a continuous circle by accident.
    for (int i = 0; i < 150; i++) {
      result.shuffle(rng);
      if (!(result + result).join().contains(levels[n].answer)) break;
    }
    return result;
  }

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      unlocked = (p.getInt('unlocked') ?? 0).clamp(0, levels.length - 1);
      finished = p.getBool('story_finished') ?? false;
      index = unlocked;
      ready = true;
    });
  }

  void _pick(String ch) {
    if (typed.length >= levels[index].answer.length) return;
    setState(() { typed += ch; message = null; });
    HapticFeedback.selectionClick();
  }

  Future<void> _check() async {
    if (typed.length != levels[index].answer.length) return;
    if (typed != levels[index].answer) {
      HapticFeedback.heavyImpact();
      setState(() => message = 'Hat meşgul! Harfleri kontrol et.');
      return;
    }
    HapticFeedback.mediumImpact();
    try { await ring.play(AssetSource('sounds/return.wav'), volume: 1); } catch (_) { SystemSound.play(SystemSoundType.alert); }
    final current = levels[index];
    final last = index == levels.length - 1;
    if (index >= unlocked && !last) {
      unlocked = index + 1;
      final pref = await SharedPreferences.getInstance();
      await pref.setInt('unlocked', unlocked);
    }
    if (last) {
      finished = true;
      final pref = await SharedPreferences.getInstance();
      await pref.setBool('story_finished', true);
    }
    if (!mounted) return;
    await showDialog<void>(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF163439),
      title: const Row(children: [Icon(Icons.ring_volume, color: gold), SizedBox(width: 9), Expanded(child: Text('GELEN ÇAĞRI'))]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [Text(current.story, style: const TextStyle(color: paper)), const SizedBox(height: 16), Text('“${current.incoming}”', style: const TextStyle(fontStyle: FontStyle.italic, color: gold))]),
      actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(last ? 'Hikâyeyi bitir' : 'Sonraki bölüm'))],
    ));
    if (!mounted) return;
    setState(() {
      if (!last) index++;
      typed = '';
      message = last ? 'Tebrikler! 10 bölüm tamamlandı.' : null;
    });
  }

  void _chooseLevel() => showModalBottomSheet<void>(context: context, backgroundColor: const Color(0xFF193338), isScrollControlled: true, builder: (ctx) => SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Text('BÖLÜM HARİTASI', style: TextStyle(fontSize: 22, color: gold)),
    ...List.generate(levels.length, (i) => ListTile(leading: Icon(i <= unlocked ? Icons.radio_button_checked : Icons.lock_outline, color: gold), title: Text('${i+1}. ${levels[i].name}'), onTap: i > unlocked ? null : () { Navigator.pop(ctx); setState(() { index = i; typed = ''; message = null; }); })),
  ])))));

  @override
  void dispose() { ring.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!ready) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final level = levels[index];
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF192A2B), title: const Text('KELİME HATTI', style: TextStyle(color: gold, fontFamily: 'serif', fontWeight: FontWeight.bold, letterSpacing: 2)), actions: [IconButton(onPressed: _chooseLevel, icon: const Icon(Icons.map_outlined, color: gold))]),
      body: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF122A2E), Color(0xFF112023), Color(0xFF342018)])), child: SafeArea(child: LayoutBuilder(builder: (ctx, box) => SingleChildScrollView(padding: const EdgeInsets.fromLTRB(12, 10, 12, 20), child: ConstrainedBox(constraints: BoxConstraints(minHeight: box.maxHeight), child: Column(children: [
        Text('BÖLÜM ${index + 1} / 10', style: const TextStyle(color: gold, letterSpacing: 2)),
        const SizedBox(height: 4),
        Text(level.name.toUpperCase(), style: const TextStyle(fontSize: 23, fontFamily: 'serif', fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18), decoration: BoxDecoration(color: paper, border: Border.all(color: const Color(0xFF966D45), width: 3), borderRadius: BorderRadius.circular(5), boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 5))]), child: Column(children: [Text('✦  ${level.name.toUpperCase()}  ✦', style: const TextStyle(color: Color(0xFF745333), letterSpacing: 2)), const SizedBox(height: 9), Text(level.clue, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF3D291B), fontSize: 17, fontStyle: FontStyle.italic))])),
        const SizedBox(height: 18),
        Wrap(alignment: WrapAlignment.center, spacing: 5, runSpacing: 5, children: List.generate(level.answer.length, (i) => Container(width: 30, height: 39, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFF08171A), border: Border.all(color: gold, width: 1.5), borderRadius: BorderRadius.circular(4)), child: Text(i < typed.length ? typed[i] : '', style: const TextStyle(color: paper, fontSize: 22, fontWeight: FontWeight.bold))))),
        const SizedBox(height: 8),
        Text('${typed.length} / ${level.answer.length} harf', style: const TextStyle(color: Colors.white60)),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF734D36), Color(0xFF311A12), Color(0xFF6A402A)]), borderRadius: BorderRadius.circular(35), border: Border.all(color: const Color(0xFFA87949), width: 3), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 8))]), child: RotaryDial(key: ValueKey(index), letters: dials[index], onLetter: _pick)),
        const SizedBox(height: 15),
        Text(message ?? 'Harf deliğine basılı tut, saat yönünde çevir, bırak.', textAlign: TextAlign.center, style: TextStyle(color: message == null ? paper : Colors.orangeAccent, fontSize: 13)),
        const SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [OutlinedButton.icon(onPressed: typed.isEmpty ? null : () => setState(() { typed = typed.substring(0, typed.length - 1); message = null; }), icon: const Icon(Icons.backspace_outlined), label: const Text('Sil')), const SizedBox(width: 10), Flexible(child: FilledButton.icon(onPressed: typed.length == level.answer.length ? _check : null, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF236F4B)), icon: const Icon(Icons.phone), label: const Text('Ara / Kontrol et'))), IconButton(onPressed: () => showDialog<void>(context: context, builder: (ctx) => AlertDialog(title: const Text('İpucu'), content: Text('Yanıt ${level.answer.length} harften oluşuyor. ${level.clue}'), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tamam'))])), icon: const Icon(Icons.lightbulb, color: gold))]),
        if (finished && index == levels.length - 1) const Padding(padding: EdgeInsets.all(8), child: Text('Hikâye tamamlandı', style: TextStyle(color: gold))),
      ]))))))),
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
  late final AnimationController animation;
  final AudioPlayer press = AudioPlayer();
  final AudioPlayer tick = AudioPlayer();
  final AudioPlayer spring = AudioPlayer();
  int? active;
  double angle = 0, previous = 0;
  int ticks = 0;
  static const step = math.pi / 5;
  static const maxRotation = 2.5;
  static const minSelection = .19;
  DateTime lastClick = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    animation = AnimationController(vsync: this);
    animation.addListener(() { if (mounted) setState(() => angle = animation.value); });
  }

  Future<void> sound(AudioPlayer player, String name) async {
    try {
      await player.stop();
      await player.play(AssetSource('sounds/$name.wav'), volume: 1.0);
    } catch (_) { HapticFeedback.selectionClick(); }
  }

  double bearing(Offset p, Size size) => math.atan2(p.dy - size.height / 2, p.dx - size.width / 2);
  double normalize(double rad) => (rad + math.pi) % (math.pi * 2) - math.pi;

  void start(Offset p, Size size) {
    if (animation.isAnimating || active != null) return;
    final radius = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 10; i++) {
      final theta = -math.pi / 2 + i * step;
      final pos = center + Offset(math.cos(theta), math.sin(theta)) * radius * .73;
      if ((p - pos).distance < radius * .19) {
        setState(() { active = i; angle = 0; previous = bearing(p, size); ticks = 0; });
        HapticFeedback.mediumImpact();
        sound(press, 'press');
        break;
      }
    }
  }

  void move(Offset p, Size size) {
    if (active == null) return;
    final now = bearing(p, size);
    final delta = normalize(now - previous);
    previous = now;
    if (delta.abs() > .9) return;
    setState(() => angle = (angle + delta).clamp(0.0, maxRotation));
    final newTicks = (angle / .18).floor();
    if (newTicks > ticks && DateTime.now().difference(lastClick).inMilliseconds >= 65) {
      lastClick = DateTime.now();
      HapticFeedback.selectionClick();
      sound(tick, 'tick');
    }
    ticks = newTicks;
  }

  void release() {
    if (active == null) return;
    final selected = active!;
    final selectedLetter = widget.letters[selected];
    final accepted = angle >= minSelection;
    final from = angle;
    setState(() => active = null);
    if (from > .01) sound(spring, 'return');
    animation.duration = Duration(milliseconds: (360 + from / maxRotation * 380).round());
    animation.stop();
    animation.value = from;
    animation.animateTo(0, curve: Curves.easeOutCubic).then((_) {
      if (accepted && mounted) widget.onLetter(selectedLetter);
    });
  }

  @override
  void dispose() {
    animation.dispose();
    press.dispose(); tick.dispose(); spring.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 355), child: AspectRatio(aspectRatio: 1, child: LayoutBuilder(builder: (context, bounds) {
    final size = Size(bounds.maxWidth, bounds.maxHeight);
    return GestureDetector(behavior: HitTestBehavior.opaque, onPanDown: (d) => start(d.localPosition, size), onPanUpdate: (d) => move(d.localPosition, size), onPanEnd: (_) => release(), onPanCancel: release, child: CustomPaint(painter: DialPainter(widget.letters, angle, active)));
  }))));
}

class DialPainter extends CustomPainter {
  final List<String> letters;
  final double rotation;
  final int? active;
  const DialPainter(this.letters, this.rotation, this.active);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide / 2;
    void ring(double radius, Color color, {double line = 0}) => canvas.drawCircle(c, radius, Paint()..color = color..style = (line > 0 ? PaintingStyle.stroke : PaintingStyle.fill)..strokeWidth = line);
    ring(r * .99, const Color(0xFF050708));
    ring(r * .966, const Color(0xFF614027));
    ring(r * .935, const Color(0xFFD4A160));
    ring(r * .898, const Color(0xFF171817));
    ring(r * .867, const Color(0xFFC6A075), line: r * .019);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rotation);
    canvas.translate(-c.dx, -c.dy);
    for (int i = 0; i < 10; i++) {
      final theta = -math.pi / 2 + i * math.pi / 5;
      final hole = c + Offset(math.cos(theta), math.sin(theta)) * r * .73;
      final chosen = i == active;
      canvas.drawCircle(hole + Offset(1, 3), r * .168, Paint()..color = Colors.black);
      canvas.drawCircle(hole, r * .162, Paint()..color = const Color(0xFF8A6236));
      canvas.drawCircle(hole, r * .141, Paint()..shader = RadialGradient(center: const Alignment(-.4, -.4), colors: chosen ? [const Color(0xFFFFF1B0), const Color(0xFFD59A34)] : [const Color(0xFFFFEDD0), const Color(0xFFD3AC78)]).createShader(Rect.fromCircle(center: hole, radius: r * .141)));
      if (chosen) canvas.drawCircle(hole, r * .167, Paint()..color = const Color(0xFFFFD35A)..style = PaintingStyle.stroke..strokeWidth = r * .018);
      final tp = TextPainter(text: TextSpan(text: letters[i], style: TextStyle(color: const Color(0xFF33271A), fontSize: r * .167, fontWeight: FontWeight.w900)), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, hole - Offset(tp.width / 2, tp.height / 2));
    }
    ring(r * .457, const Color(0xFF302116));
    ring(r * .416, const Color(0xFFCC9D62));
    ring(r * .37, const Color(0xFF75502E));
    canvas.drawCircle(c, r * .328, Paint()..shader = RadialGradient(center: const Alignment(-.35, -.45), colors: const [Color(0xFFE0BA7A), Color(0xFF966033), Color(0xFF4A2D1B)]).createShader(Rect.fromCircle(center: c, radius: r * .328)));
    canvas.restore();
    final stopper = Rect.fromCenter(center: c + Offset(r * .64, r * .64), width: r * .33, height: r * .12);
    canvas.save();
    canvas.translate(stopper.center.dx, stopper.center.dy);
    canvas.rotate(-.73);
    canvas.translate(-stopper.center.dx, -stopper.center.dy);
    canvas.drawRRect(RRect.fromRectAndRadius(stopper, Radius.circular(r * .05)), Paint()..color = const Color(0xFFD8B77B));
    canvas.restore();
  }

  @override
  bool shouldRepaint(DialPainter old) => old.rotation != rotation || old.active != active || old.letters != letters;
}
