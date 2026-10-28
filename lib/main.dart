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
  Level(
      'Kayıp Mesaj',
      'Eski bir defterde karşıma çıkan silik ipucu: “Unutulmuş bir eşya.”',
      'SAAT',
      'Duvardaki saat 23.17’de durmuş. Arkasında bir fotoğraf saklı.',
      'Fotoğraftaki iz seni eski istasyona götürecek.'),
  Level(
      'Eski Fotoğraf',
      'Fotoğrafın arkasında yazıyor: “Rayların buluştuğu yer.”',
      'GAR',
      'İstasyondaki bekleme salonunda bir zarf buldun.',
      'Zarfın üzerindeki tek kelime: ANAHTAR.'),
  Level(
      'Son Tren',
      'Kilidi açan, metalden küçük bir nesne.',
      'ANAHTAR',
      'Paslı anahtar eski bir otelin üçüncü odasını açıyor.',
      'Üçüncü odada duvara asılmış bir şey aramalısın.'),
  Level(
      'Gizli Oda',
      'Odanın duvarında zamanı gösteren eşya.',
      'TAKVİM',
      'Takvimde yalnızca 12 Kasım tarihi işaretli.',
      'Bu tarihte şehirde büyük bir karanlık yaşanmış.'),
  Level(
      'Zamanın İzi',
      'Karanlıkta yol gösteren ışık kaynağı.',
      'FENER',
      'Fenerin altında bir harita ve üstü çizili kıyı yolu var.',
      'Haritadaki işaret bir kıyı yapısını gösteriyor.'),
  Level(
      'Unutulan İsim',
      'Gemilere yol gösteren kıyıdaki kule.',
      'DENİZFENERİ',
      'Kulende mühürlü bir kutu var. İçinde bir mektup saklı.',
      'Mektup yıllar önce durdurulan bir saati anlatıyor.'),
  Level(
      'Kırık Saat',
      'Dakikaları ve saatleri gösteren düzenek.',
      'SAAT',
      'Saatin içinde saklanan sayılar eski bir telefon numarası oluşturuyor.',
      'Numarayı çeviren kişinin kim olduğunu öğren.'),
  Level(
      'Son Görüşme',
      'Telefonun karşı ucundaki insana söylenen ilk söz.',
      'ALO',
      'Ahizeden bir ses: “Ben seni yıllardır bekliyorum.”',
      'Sesin sahibinin bıraktığı belgenin adını bul.'),
  Level(
      'Gerçek Ortaya Çıkıyor',
      'İçinde yazılı sözler taşıyan, zarfla gelen belge.',
      'MEKTUP',
      'Mektup kaybolan kişinin gerçeği saklamak için gittiğini anlatıyor.',
      'Son çağrı, gerçeğin saklandığı yeri tarif ediyor.'),
  Level(
      'Son Çağrı',
      'Geçmişten geriye kalan iz ve hatırlanan şey.',
      'HATIRA',
      'Telefon son kez çaldı. Gizem çözüldü: Tüm aramalar geçmişte bırakılan hatıralardı.',
      'Tebrikler! Hikâyenin sonuna ulaştın.'),
];

class KelimeHattiApp extends StatelessWidget {
  const KelimeHattiApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Kelime Hattı',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: _dark,
            colorSchemeSeed: _gold),
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
    const pool = [
      'A',
      'E',
      'İ',
      'I',
      'O',
      'U',
      'K',
      'L',
      'M',
      'N',
      'R',
      'S',
      'T',
      'Y',
      'Z',
      'P',
      'D',
      'F',
      'G',
      'H',
      'V',
      'B',
      'Ç',
      'Ş',
      'Ü',
      'Ö'
    ];
    final random =
        math.Random(index * 733 + DateTime.now().microsecondsSinceEpoch);
    final extra = pool.where((c) => !base.contains(c)).toList()
      ..shuffle(random);
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
    setState(() {
      typed += letter;
      notice = null;
    });
    HapticFeedback.selectionClick();
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
        title: const Row(children: [
          Icon(Icons.phone_in_talk, color: _gold),
          SizedBox(width: 10),
          Expanded(child: Text('GELEN ÇAĞRI'))
        ]),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(current.story,
                  style: const TextStyle(color: _paper, fontSize: 16)),
              const SizedBox(height: 18),
              const Text('Bilinmeyen numara:', style: TextStyle(color: _gold)),
              Text('“${current.incomingClue}”',
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, fontSize: 17)),
            ]),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _green),
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(last ? 'Hikâyeyi bitir' : 'Sonraki bölüme geç'),
          )
        ],
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
      context: context,
      backgroundColor: const Color(0xFF18363A),
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('BÖLÜM HARİTASI',
              style: TextStyle(
                  color: _gold, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          ...List.generate(
              levels.length,
              (i) => ListTile(
                    dense: true,
                    leading: Icon(
                        i <= unlocked
                            ? Icons.radio_button_checked
                            : Icons.lock_outline,
                        color: i <= unlocked ? _gold : Colors.grey),
                    title: Text('${i + 1}. ${levels[i].name}'),
                    onTap: i > unlocked
                        ? null
                        : () {
                            Navigator.pop(sheetContext);
                            setState(() {
                              levelIndex = i;
                              typed = '';
                              notice = null;
                            });
                          },
                  )),
        ]),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final level = levels[levelIndex];
    return Scaffold(
      body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
        return Center(
            child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 360,
                  height: 760,
                  child: Stack(children: [
                    Positioned.fill(
                        child: Image.asset('assets/art/scene.png',
                            fit: BoxFit.fill)),
                    Positioned(
                        right: 12,
                        top: 10,
                        child: IconButton(
                          tooltip: 'Bölüm haritası',
                          onPressed: _chooseLevel,
                          style: IconButton.styleFrom(
                              backgroundColor: const Color(0x663A4A45),
                              side: const BorderSide(color: Color(0x665C6B5E))),
                          icon: const Icon(Icons.settings,
                              size: 22, color: Color(0xFFABAD99)),
                        )),
                    Positioned(
                        left: 48,
                        right: 48,
                        top: 83,
                        height: 20,
                        child: Text('Bölüm ${levelIndex + 1}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Color(0xFF4E432C),
                                fontFamily: 'serif',
                                fontSize: 16))),
                    Positioned(
                        left: 48,
                        right: 48,
                        top: 106,
                        height: 32,
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(level.name.toUpperCase(),
                                style: const TextStyle(
                                    color: Color(0xFF332D1F),
                                    fontFamily: 'serif',
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold)))),
                    Positioned(
                        left: 47,
                        right: 43,
                        top: 149,
                        height: 84,
                        child: Center(
                            child: Text(level.clue,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Color(0xFF4E3B25),
                                    fontFamily: 'serif',
                                    fontSize: 17,
                                    fontStyle: FontStyle.italic,
                                    height: 1.3)))),
                    Positioned(
                        left: 27,
                        right: 27,
                        top: 268,
                        height: 52,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(level.answer.length, (i) {
                              final cellWidth =
                                  math.min(45.0, 306 / level.answer.length - 4);
                              return Container(
                                  width: cellWidth,
                                  height: 51,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xE6050D0D),
                                            Color(0xB3111B19)
                                          ]),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                          color: const Color(0xFF827C61),
                                          width: 1.7),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black87,
                                            blurRadius: 3,
                                            offset: Offset(1, 3))
                                      ]),
                                  child: Text(i < typed.length ? typed[i] : '',
                                      style: TextStyle(
                                          color: _paper,
                                          fontFamily: 'serif',
                                          fontSize:
                                              math.min(23.0, cellWidth * .7))));
                            }))),
                    Positioned(
                        left: 11,
                        right: 11,
                        top: 337,
                        height: 338,
                        child: RotaryDial(
                            key: ValueKey(levelIndex),
                            letters: letters,
                            onLetter: _pick)),
                    Positioned(
                        left: 87,
                        right: 87,
                        top: 679,
                        height: 66,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                              foregroundColor: const Color(0xFFF6E7BD),
                              backgroundColor: const Color(0xFF246337),
                              disabledBackgroundColor: const Color(0xFF234B2B),
                              disabledForegroundColor: const Color(0xFF8D9F78),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 6),
                              elevation: 5,
                              shadowColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: const BorderSide(
                                      color: Color(0xFF60814B), width: 2))),
                          onPressed: typed.isEmpty ? null : _check,
                          child: const Text('Kelimeyi\nKontrol Et',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'serif',
                                  fontSize: 18,
                                  height: 1.2)),
                        )),
                    Positioned(
                        left: 14,
                        top: 675,
                        width: 65,
                        height: 81,
                        child: Column(children: [
                          _AntiqueButton(
                              tooltip: 'Son harfi sil',
                              icon: Icons.undo,
                              onPressed: typed.isEmpty
                                  ? null
                                  : () => setState(() {
                                        typed = typed.substring(
                                            0, typed.length - 1);
                                        notice = null;
                                      })),
                          const SizedBox(height: 4),
                          const SizedBox(
                              height: 21,
                              child: FittedBox(
                                  child: Text('Sil',
                                      style: TextStyle(
                                          color: _paper,
                                          fontFamily: 'serif',
                                          fontSize: 16)))),
                        ])),
                    Positioned(
                        right: 14,
                        top: 675,
                        width: 65,
                        height: 81,
                        child: Column(children: [
                          _AntiqueButton(
                              tooltip: 'İpucu',
                              icon: Icons.lightbulb,
                              glow: true,
                              onPressed: () => showDialog<void>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                          title: const Text('İpucu'),
                                          content: Text(
                                              'Kelime ${level.answer.length} harfli ve “${level.clue}” ipucuyla ilgili.'),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: const Text('Tamam'))
                                          ]))),
                          const SizedBox(height: 4),
                          const SizedBox(
                              height: 21,
                              child: FittedBox(
                                  child: Text('İpucu',
                                      style: TextStyle(
                                          color: _paper,
                                          fontFamily: 'serif',
                                          fontSize: 16)))),
                        ])),
                    if (notice != null)
                      Positioned(
                          left: 35,
                          right: 35,
                          top: 322,
                          height: 18,
                          child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(notice!,
                                  style: const TextStyle(
                                      color: _gold, fontSize: 13)))),
                  ]),
                )));
      })),
    );
  }
}

class _AntiqueButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool glow;
  const _AntiqueButton(
      {required this.tooltip,
      required this.icon,
      required this.onPressed,
      this.glow = false});

  @override
  Widget build(BuildContext context) => Container(
        width: 51,
        height: 51,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
                center: Alignment(-.3, -.4),
                colors: [Color(0xFF806540), Color(0xFF3D2B19)]),
            border: Border.all(color: const Color(0xFF8F7449), width: 1.5),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black87, blurRadius: 4, offset: Offset(1, 3))
            ]),
        child: IconButton(
            tooltip: tooltip,
            onPressed: onPressed,
            icon: Icon(icon,
                size: 28,
                color: onPressed == null
                    ? const Color(0xFF8D8065)
                    : glow
                        ? const Color(0xFFFFCF60)
                        : _paper,
                shadows: glow
                    ? const [Shadow(color: Color(0xFFFFB627), blurRadius: 13)]
                    : null)),
      );
}

enum DialSoundPhase { idle, winding, returning }

const _dialHoleCenters = <Offset>[
  Offset(.4986, .1530),
  Offset(.7066, .2295),
  Offset(.8300, .4071),
  Offset(.8214, .6068),
  Offset(.6890, .7683),
  Offset(.4986, .8324),
  Offset(.3103, .7680),
  Offset(.1757, .6063),
  Offset(.1696, .4078),
  Offset(.2922, .2304),
];

/// Separate preloaded players keep the quiet hand-winding rasp distinct from
/// the louder 10-pulse-per-second automatic return. Never play on touch-down.
class RotarySound {
  late final AudioPlayer _wind = AudioPlayer();
  late final AudioPlayer _return = AudioPlayer();
  late final Future<void> _ready = _prepare();
  Future<void> _pending = Future<void>.value();
  DialSoundPhase _phase = DialSoundPhase.idle;
  bool _disposed = false;

  Future<void> _prepare() async {
    await _wind.setReleaseMode(ReleaseMode.loop);
    await _return.setReleaseMode(ReleaseMode.loop);
    await _wind.setSource(AssetSource('sounds/dial_wind.wav'));
    await _return.setSource(AssetSource('sounds/dial_return.wav'));
    await _wind.setVolume(.32);
    await _return.setVolume(.8);
  }

  void prepare() {
    _ready.catchError((Object _) {});
  }

  Future<void> setPhase(DialSoundPhase phase) {
    if (_disposed || phase == _phase) return _pending;
    _phase = phase;
    _pending = _pending.then((_) async {
      try {
        await _ready;
        if (_disposed || _phase != phase) return;
        await _wind.pause();
        await _return.pause();
        if (_disposed || _phase != phase || phase == DialSoundPhase.idle) {
          return;
        }
        final player = phase == DialSoundPhase.winding ? _wind : _return;
        await player.seek(Duration.zero);
        if (!_disposed && _phase == phase) await player.resume();
      } catch (_) {
        // Missing audio hardware must never prevent the dial from returning.
      }
    });
    return _pending;
  }

  Future<void> dispose() async {
    _disposed = true;
    try {
      await _ready;
    } catch (_) {/* Audio may be unavailable. */}
    try {
      await _pending;
    } catch (_) {/* Audio may be unavailable. */}
    await _wind.dispose();
    await _return.dispose();
  }
}

class RotaryDial extends StatefulWidget {
  final List<String> letters;
  final ValueChanged<String> onLetter;
  final RotarySound? sound;
  const RotaryDial(
      {super.key, required this.letters, required this.onLetter, this.sound});
  @override
  State<RotaryDial> createState() => _RotaryDialState();
}

class _RotaryDialState extends State<RotaryDial>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final RotarySound sound;
  Timer? movementTimer;
  int? active;
  double rotation = 0;
  double lastPointerAngle = 0;
  bool returning = false;
  static const count = 10;
  static const maxTravel = 2.25;

  @override
  void initState() {
    super.initState();
    sound = widget.sound ?? RotarySound();
    sound.prepare();
    controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    movementTimer?.cancel();
    controller.dispose();
    unawaited(sound.dispose());
    super.dispose();
  }

  double _angle(Offset point, Size size) =>
      math.atan2(point.dy - size.height / 2, point.dx - size.width / 2);
  double _normalize(double angle) =>
      (angle + math.pi) % (math.pi * 2) - math.pi;

  void _start(Offset position, Size size) {
    if (returning || active != null) return;
    final r = size.shortestSide / 2;
    for (var i = 0; i < count; i++) {
      final point = _dialHoleCenters[i];
      final hole = Offset(point.dx * size.width, point.dy * size.height);
      if ((position - hole).distance <= r * .15) {
        setState(() {
          active = i;
          rotation = 0;
          lastPointerAngle = _angle(position, size);
        });
        HapticFeedback.selectionClick();
        return;
      }
    }
  }

  void _update(Offset position, Size size) {
    if (active == null || returning) return;
    final angle = _angle(position, size);
    final delta = _normalize(angle - lastPointerAngle);
    lastPointerAngle = angle;
    final next = (rotation + delta).clamp(0.0, maxTravel);
    // Ignore jitter and movement against the physical stop.
    if ((next - rotation).abs() < .003) return;
    setState(() => rotation = next);
    unawaited(sound.setPhase(DialSoundPhase.winding));
    movementTimer?.cancel();
    movementTimer = Timer(const Duration(milliseconds: 90), () {
      if (!returning) unawaited(sound.setPhase(DialSoundPhase.idle));
    });
  }

  Future<void> _end({bool cancelled = false}) async {
    if (active == null || returning) return;
    movementTimer?.cancel();
    final selected = active!;
    final from = rotation;
    final accepted = !cancelled && from >= .28;
    setState(() {
      active = null;
      returning = from > .005;
    });
    if (!returning) {
      await sound.setPhase(DialSoundPhase.idle);
      return;
    }
    // Start the return motor sound before advancing the return animation.
    // Its regular pulses are never heard during hand-winding.
    await sound.setPhase(DialSoundPhase.returning);
    if (!mounted) return;
    controller.duration =
        Duration(milliseconds: math.max(100, (from / 2.4 * 1000).round()));
    final animation = Tween<double>(begin: from, end: 0).animate(controller);
    void frame() {
      if (mounted) setState(() => rotation = animation.value);
    }

    controller.addListener(frame);
    try {
      await controller.forward(from: 0).orCancel;
    } on TickerCanceled {
      return;
    } finally {
      controller.removeListener(frame);
    }
    await sound.setPhase(DialSoundPhase.idle);
    if (!mounted) return;
    setState(() {
      rotation = 0;
      returning = false;
    });
    if (accepted) widget.onLetter(widget.letters[selected]);
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(builder: (context, box) {
          final size = Size(box.maxWidth, box.maxHeight);
          return Listener(
              onPointerUp: (_) => _end(),
              onPointerCancel: (_) => _end(cancelled: true),
              child: GestureDetector(
                key: const ValueKey('rotary-gesture'),
                behavior: HitTestBehavior.opaque,
                onPanDown: (details) => _start(details.localPosition, size),
                onPanUpdate: (details) => _update(details.localPosition, size),
                child: Stack(children: [
                  Positioned.fill(
                      child: Transform.rotate(
                          angle: rotation,
                          child: Stack(children: [
                            Positioned.fill(
                                child: Image.asset('assets/art/dial.png',
                                    fit: BoxFit.contain)),
                            Positioned.fill(
                                child: CustomPaint(
                                    painter:
                                        _DialLetters(widget.letters, active))),
                          ]))),
                  const Positioned.fill(
                      child: IgnorePointer(
                          child: CustomPaint(painter: _MetalStopper()))),
                ]),
              ));
        }),
      );
}

class _DialLetters extends CustomPainter {
  final List<String> letters;
  final int? active;
  _DialLetters(this.letters, this.active);
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    for (var i = 0; i < letters.length; i++) {
      final point = _dialHoleCenters[i];
      final center = Offset(point.dx * size.width, point.dy * size.height);
      if (active == i) {
        canvas.drawCircle(
            center, r * .15, Paint()..color = const Color(0x337F5100));
      }
      final text = TextPainter(
          text: TextSpan(
              text: letters[i],
              style: TextStyle(
                  color: const Color(0xFF302C1E),
                  fontFamily: 'serif',
                  fontSize: r * .17,
                  fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr)
        ..layout();
      text.paint(canvas, center - Offset(text.width / 2, text.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _DialLetters old) =>
      old.active != active || old.letters != letters;
}

class _MetalStopper extends CustomPainter {
  const _MetalStopper();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 360, size.height / 360);
    final path = Path()
      ..moveTo(259, 235)
      ..cubicTo(265, 258, 282, 272, 315, 280)
      ..quadraticBezierTo(330, 286, 320, 302)
      ..lineTo(309, 314)
      ..quadraticBezierTo(303, 320, 293, 311)
      ..cubicTo(274, 291, 261, 270, 254, 247)
      ..quadraticBezierTo(251, 238, 259, 235)
      ..close();
    canvas.drawShadow(path, Colors.black, 7, false);
    canvas.drawPath(
        path,
        Paint()
          ..shader = const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0,
                .22,
                .43,
                .6,
                .8,
                1
              ],
              colors: [
                Color(0xFF292B25),
                Color(0xFFD5D5BA),
                Color(0xFF747D70),
                Color(0xFF252D27),
                Color(0xFFB2B5A3),
                Color(0xFF3E473F)
              ]).createShader(const Rect.fromLTWH(251, 235, 80, 83)));
    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF90947E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MetalStopper old) => false;
}
