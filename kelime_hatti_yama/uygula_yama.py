from pathlib import Path
p=Path('lib/main.dart')
s=p.read_text(encoding='utf-8')

def replace(a,b):
    global s
    if a not in s: raise SystemExit('Beklenen kod bulunamadı: '+a[:70])
    s=s.replace(a,b,1)

replace("import 'dart:async';", "import 'dart:async';\nimport 'dart:ui' as ui;")
replace('  final AudioPlayer sound = AudioPlayer();\n  bool soundReady = false;\n  bool soundPlaying = false;', '  final AudioPlayer windSound = AudioPlayer();\n  final AudioPlayer returnSound = AudioPlayer();\n  bool soundReady = false;\n  bool soundPlaying = false;\n  ui.Image? dialArtwork;')
replace('    _prepareSound();','    _prepareSound();\n    _loadArtwork();')
a=s.index('  Future<void> _prepareSound() async {')
b=s.index('  @override\n  void dispose() {',a)
s=s[:a]+'''  Future<void> _loadArtwork() async {
    try {
      final data = await rootBundle.load('assets/art/dial.png');
      final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
      final frame = await codec.getNextFrame();
      codec.dispose();
      if (!mounted) { frame.image.dispose(); return; }
      setState(() => dialArtwork = frame.image);
    } catch (_) {}
  }

  Future<void> _prepareSound() async {
    try {
      await windSound.setReleaseMode(ReleaseMode.loop);
      await windSound.setSource(AssetSource('sounds/dial_wind.wav'));
      await windSound.setVolume(.42);
      await returnSound.setReleaseMode(ReleaseMode.stop);
      await returnSound.setSource(AssetSource('sounds/dial_return.wav'));
      await returnSound.setVolume(.92);
      soundReady = true;
    } catch (_) {}
  }

  void _startSound() {
    if (!soundReady || soundPlaying) return;
    soundPlaying = true;
    windSound.resume();
  }

  void _stopSound() {
    if (!soundPlaying) return;
    soundPlaying = false;
    windSound.pause();
  }

  Future<void> _returnClick() async {
    if (!soundReady) return;
    try {
      await returnSound.stop();
      await returnSound.play(AssetSource('sounds/dial_return.wav'), volume: .92);
    } catch (_) {}
  }

'''+s[b:]
replace('    sound.dispose();','    windSound.dispose();\n    returnSound.dispose();\n    dialArtwork?.dispose();')
replace('    if (from > .01) _startSound();','    _stopSound();\n    if (from > .01) _returnClick();')
replace('      _stopSound();\n      if (accepted)', '      returnSound.stop();\n      if (accepted)')
replace('        child: CustomPaint(painter: DialPainter(widget.letters, rotation, active)),', '        child: CustomPaint(painter: DialPainter(widget.letters, rotation, active, dialArtwork)),')
replace('  DialPainter(this.letters, this.rotation, this.active);','  final ui.Image? artwork;\n  DialPainter(this.letters, this.rotation, this.active, this.artwork);')
a=s.index('    circle(r * .99, const Color(0xFF0A0D0D));')
b=s.index('    canvas.save();\n    canvas.translate(c.dx, c.dy);',a)
s=s[:a]+'''    if (artwork == null) {
      circle(r * .99, const Color(0xFF0A0D0D));
      circle(r * .96, const Color(0xFF4C2D1E));
      circle(r * .925, const Color(0xFFBA874C));
      circle(r * .88, const Color(0xFF78603C));
      circle(r * .865, const Color(0xFFDAB278),
          style: PaintingStyle.stroke, stroke: r * .022);
    }
'''+s[b:]
a=s.index('    canvas.rotate(rotation);')
c=s.index('    for (var i = 0; i < 10; i++) {',a)
s=s[:c]+'''    if (artwork != null) {
      final src = Rect.fromLTWH(0, 0, artwork!.width.toDouble(), artwork!.height.toDouble());
      canvas.drawImageRect(artwork!, src, Rect.fromCircle(center: c, radius: r * .99),
          Paint()..filterQuality = FilterQuality.high);
    }
'''+s[c:]
replace('    circle(r * .455, const Color(0xFF3B2A1F));','    if (artwork == null) {\n    circle(r * .455, const Color(0xFF3B2A1F));')
replace('    canvas.restore();\n    final stopper =', '    }\n    canvas.restore();\n    final stopper =')
replace('oldDelegate.letters != letters;', 'oldDelegate.letters != letters || oldDelegate.artwork != artwork;')
replace('''      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF263B39), Color(0xFF101F20), Color(0xFF090F10)],
        )),
        child: SafeArea(''', '''      body: Container(
        decoration: const BoxDecoration(image: DecorationImage(
          image: AssetImage('assets/art/scene.png'), fit: BoxFit.cover,
        )),
        child: SafeArea(''')
p.write_text(s,encoding='utf-8')
print('Kelime Hatti tasarim/ses yamasi uygulandi. flutter analyze ve flutter test calistirin.')
