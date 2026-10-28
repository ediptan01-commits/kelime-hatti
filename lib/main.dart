import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'adventure.dart';

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
        home: const CaseDeskPage(),
      );
}

class GamePage extends StatefulWidget {
  final bool adventure;
  const GamePage({super.key, this.adventure = false});
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int levelIndex = 0;
  int unlocked = 0;
  String typed = '';
  bool loading = true;
  bool checking = false;
  int attempts = 0;
  int combo = 0;
  int points = 0;
  Timer? _wrongAnswerTimer;
  String? notice;
  CaseProgress? progress;
  late List<List<String>> shuffledDials;
  List<Level> get puzzles => widget.adventure ? caseLevels : levels;
  List<String> get letters => shuffledDials[levelIndex];
  List<String> _buildLetters(int index) {
    final base = <String>{...puzzles[index].answer.split('')};
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
    shuffledDials = List.generate(puzzles.length, _buildLetters);
    _load();
  }

  Future<void> _load() async {
    final pref = await SharedPreferences.getInstance();
    final saved = widget.adventure ? await CaseProgress.load() : null;
    if (!mounted) return;
    setState(() {
      progress = saved;
      unlocked = saved?.unlocked ??
          (pref.getInt('unlocked') ?? 0).clamp(0, levels.length - 1);
      levelIndex = saved?.current ?? unlocked;
      loading = false;
    });
  }

  void _pick(String letter) {
    if (checking || typed.length >= puzzles[levelIndex].answer.length) return;
    setState(() {
      typed += letter;
      notice = null;
    });
    HapticFeedback.selectionClick();
    if (typed.length == puzzles[levelIndex].answer.length) {
      // Check only after the dial has returned and the last letter was added.
      Future<void>.delayed(const Duration(milliseconds: 220), () {
        if (mounted && !checking &&
            typed.length == puzzles[levelIndex].answer.length) {
          _check();
        }
      });
    }
  }

  Future<void> _showCall() async {
    if (!widget.adventure || checking || progress == null) return;
    final i = levelIndex;
    final level = caseLevels[i];
    // One short sentence keeps the mystery without interrupting play.
    final shortMessage = level.message.split(RegExp(r'(?<=[.!?])\s+')).first;
    await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF18352F),
              title: Row(children: [
                const Icon(Icons.phone_in_talk, color: _gold),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(level.caller,
                        style: const TextStyle(
                            color: _paper, fontFamily: 'serif', fontSize: 21)))
              ]),
              content: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    Text('${i ~/ 4 + 1}. perde · ${_caseActs[i ~/ 4]}',
                        style: const TextStyle(color: _gold, fontSize: 12)),
                    const SizedBox(height: 14),
                    Text('“$shortMessage”',
                        style: const TextStyle(
                            color: _paper, fontSize: 17, height: 1.5)),
                  ])),
              actions: [
                FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('İpucunu incele'))
              ],
            ));
    if (!mounted) return;
    progress!.calls.add(i);
    await progress!.save();
  }

  Future<void> _showHint() async {
    if (checking) return;
    final level = puzzles[levelIndex];
    if (!widget.adventure) {
      await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
                  title: const Text('İpucu'),
                  content: Text(
                      'Kelime ${level.answer.length} harfli ve “${level.clue}” ipucuyla ilgili.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Tamam'))
                  ]));
      return;
    }
    final i = levelIndex;
    var used = progress!.hints[i] ?? 0;
    await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF17362F),
        builder: (ctx) => StatefulBuilder(
            builder: (context, update) => SafeArea(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Birlikte çözelim',
                              style: TextStyle(
                                  color: _paper,
                                  fontFamily: 'serif',
                                  fontSize: 26)),
                          const SizedBox(height: 12),
                          const Text(
                              'İpuçları ücretsiz. Yanlış cevap vermek ilerlemeni silmez.',
                              style: TextStyle(
                                  color: Color(0xFFACB9A7), height: 1.4)),
                          const SizedBox(height: 16),
                          if (used == 0)
                            const Text('Önce bir anlam ipucu açabilirsin.',
                                style: TextStyle(color: _paper)),
                          for (var n = 0; n < used; n++)
                            Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                    '${n + 1}. ${caseLevels[i].hints[n]}',
                                    style: const TextStyle(
                                        color: _paper,
                                        fontSize: 17,
                                        height: 1.4))),
                          const SizedBox(height: 8),
                          if (used < 3)
                            FilledButton(
                                onPressed: () async {
                                  update(() => used++);
                                  progress!.hints[i] = used;
                                  await progress!.save();
                                },
                                child: Text(used == 0
                                    ? 'Anlam ipucunu aç'
                                    : used == 1
                                        ? 'İlk harfi göster'
                                        : 'Başlangıcı göster'))
                          else
                            OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    typed = level.answer.substring(
                                        0, math.min(3, level.answer.length));
                                    notice = null;
                                  });
                                  Navigator.pop(ctx);
                                },
                                child: const Text(
                                    'İlk harfleri kutulara yerleştir')),
                        ])))));
  }

  Future<void> _check() async {
    if (checking || typed.isEmpty) return;
    if (typed != puzzles[levelIndex].answer) {
      HapticFeedback.heavyImpact();
      _wrongAnswerTimer?.cancel();
      setState(() {
        combo = 0;
        attempts++;
        notice = widget.adventure && attempts >= 2
            ? 'Birlikte çözelim · İpucu düğmesine dokun.'
            : 'Olmadı! Tekrar dene.';
      });
      // Let the player see the incorrect word briefly, then free the dial.
      _wrongAnswerTimer = Timer(const Duration(milliseconds: 750), () {
        if (mounted && !checking) {
          setState(() => typed = '');
        }
      });
      return;
    }
    _wrongAnswerTimer?.cancel();
    setState(() {
      checking = true;
      combo++;
      points += 100 + (combo - 1) * 25;
    });
    HapticFeedback.mediumImpact();
    final i = levelIndex;
    final current = puzzles[i];
    final last = i == puzzles.length - 1;
    try {
      if (widget.adventure) {
        progress!.solved.add(i);
        progress!.current = last ? i : i + 1;
        unlocked = progress!.unlocked;
        await progress!.save();
      } else if (i == unlocked && !last) {
        unlocked++;
        final pref = await SharedPreferences.getInstance();
        await pref.setInt('unlocked', unlocked);
      }
      if (!mounted) return;
      if (!widget.adventure) {
        await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF173438),
                  title: const Text('GELEN ÇAĞRI',
                      style: TextStyle(color: _gold, fontFamily: 'serif')),
                  content: SingleChildScrollView(
                      child: Text('${current.story}\n\n${current.incomingClue}',
                          style: const TextStyle(color: _paper, height: 1.4))),
                  actions: [
                    FilledButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(last ? 'Hikâyeyi bitir' : 'Sonraki çağrı'))
                  ],
                ));
      }
      if (!mounted) return;
      if (last && widget.adventure) {
        await Navigator.pushReplacement<void, void>(
            context, MaterialPageRoute(builder: (_) => const CaseFinalePage()));
        return;
      }
      setState(() {
        if (!last) levelIndex++;
        typed = '';
        attempts = 0;
        notice = widget.adventure
            ? '✓ ${current.answer} · $combo seri · $points puan'
            : last
                ? 'Tebrikler! 10 bölüm tamamlandı.'
                : null;
      });
      if (widget.adventure) {
        progress!.current = levelIndex;
        await progress!.save();
      }
    } finally {
      if (mounted) setState(() => checking = false);
    }
  }

  @override
  void dispose() {
    _wrongAnswerTimer?.cancel();
    super.dispose();
  }

  Future<void> _chooseLevel() async {
    if (checking) return;
    final selected = await showModalBottomSheet<int>(
        context: context,
        backgroundColor: const Color(0xFF18363A),
        isScrollControlled: true,
        builder: (ctx) => SafeArea(
            child: SizedBox(
                height: MediaQuery.sizeOf(ctx).height * .8,
                child: Column(children: [
                  Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                          widget.adventure
                              ? 'Dosya haritası'
                              : 'BÖLÜM HARİTASI',
                          style: const TextStyle(
                              color: _gold,
                              fontSize: 23,
                              fontFamily: 'serif'))),
                  Expanded(
                      child: ListView.builder(
                          itemCount: puzzles.length,
                          itemBuilder: (context, i) => ListTile(
                                leading: Icon(
                                    widget.adventure &&
                                            progress!.solved.contains(i)
                                        ? Icons.check_circle
                                        : i <= unlocked
                                            ? Icons.radio_button_checked
                                            : Icons.lock_outline,
                                    color: i <= unlocked ? _gold : Colors.grey),
                                title: Text('${i + 1}. ${puzzles[i].name}',
                                    style: const TextStyle(color: _paper)),
                                subtitle: widget.adventure
                                    ? Text(_caseActs[i ~/ 4],
                                        style: const TextStyle(
                                            color: Color(0xFF98AD9A)))
                                    : null,
                                onTap: i > unlocked
                                    ? null
                                    : () => Navigator.pop(ctx, i),
                              ))),
                ]))));
    if (!mounted || selected == null) return;
    setState(() {
      levelIndex = selected;
      typed = '';
      attempts = 0;
      notice = null;
    });
    if (widget.adventure) {
      progress!.current = selected;
      await progress!.save();
    }
  }

  Future<void> _caseMenu() async {
    if (checking) return;
    final selected = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: const Color(0xFF18363A),
        builder: (ctx) => SafeArea(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                  leading: const Icon(Icons.phone, color: _gold),
                  title: const Text('Çağrıyı yeniden oku'),
                  onTap: () => Navigator.pop(ctx, 'call')),
              ListTile(
                  leading: const Icon(Icons.menu_book, color: _gold),
                  title: const Text('Kanıt ve Bilgi Defteri'),
                  onTap: () => Navigator.pop(ctx, 'book')),
              ListTile(
                  leading: const Icon(Icons.map_outlined, color: _gold),
                  title: const Text('Dosya haritası'),
                  onTap: () => Navigator.pop(ctx, 'map')),
              ListTile(
                  leading: const Icon(Icons.home_outlined, color: _gold),
                  title: const Text('Dosya masasına dön'),
                  onTap: () => Navigator.pop(ctx, 'home')),
            ])));
    if (!mounted) return;
    switch (selected) {
      case 'call':
        await _showCall();
      case 'book':
        await _showNotebook(context, progress!);
      case 'map':
        await _chooseLevel();
      case 'home':
        Navigator.pop(context);
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final level = puzzles[levelIndex];
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
                    if (widget.adventure)
                      Positioned(
                          left: 12,
                          top: 10,
                          child: IconButton(
                              tooltip: 'Kanıt ve Bilgi Defteri',
                              onPressed: checking
                                  ? null
                                  : () => _showNotebook(context, progress!),
                              style: IconButton.styleFrom(
                                  backgroundColor: const Color(0x663A4A45)),
                              icon: const Icon(Icons.menu_book,
                                  color: _gold, size: 22))),
                    Positioned(
                        right: 12,
                        top: 10,
                        child: IconButton(
                          tooltip: widget.adventure
                              ? 'Dosya menüsü'
                              : 'Bölüm haritası',
                          onPressed:
                              widget.adventure ? _caseMenu : _chooseLevel,
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
                        child: Text(
                            widget.adventure
                                ? 'Dosya 01 · ${levelIndex + 1}/12'
                                : 'Bölüm ${levelIndex + 1}',
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
                          onPressed: checking || typed.isEmpty ? null : _check,
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
                              onPressed: _showHint),
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
    await _wind.setPlayerMode(PlayerMode.lowLatency);
    await _return.setPlayerMode(PlayerMode.lowLatency);
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
        await Future.wait([_wind.pause(), _return.pause()]);
        if (_disposed || _phase != phase || phase == DialSoundPhase.idle) {
          return;
        }
        final player = phase == DialSoundPhase.winding ? _wind : _return;
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
    movementTimer = Timer(const Duration(milliseconds: 45), () {
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
