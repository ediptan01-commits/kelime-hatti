part of 'main.dart';

/// Second mechanic: swipe across the brass letter sockets in order.
class ConnectLettersGame extends StatefulWidget {
  const ConnectLettersGame({super.key, required this.letters, required this.answer, required this.onSolved});
  final List<String> letters;
  final String answer;
  final ValueChanged<String> onSolved;
  @override
  State<ConnectLettersGame> createState() => _ConnectLettersGameState();
}

class _ConnectLettersGameState extends State<ConnectLettersGame> {
  final List<int> path = [];
  static const double pad = 30;
  int? _hit(Offset p, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * .36;
    for (var i = 0; i < widget.letters.length; i++) {
      final a = -math.pi / 2 + i * math.pi * 2 / widget.letters.length;
      final target = center + Offset(math.cos(a), math.sin(a)) * radius;
      if ((target - p).distance <= 32) return i;
    }
    return null;
  }

  void _add(Offset p, Size size) {
    final index = _hit(p, size);
    if (index == null || path.length >= widget.answer.length) return;
    if (path.isNotEmpty && path.last == index) return;
    setState(() => path.add(index));
    HapticFeedback.selectionClick();
  }

  void _finish() {
    if (path.isEmpty) return;
    final word = path.map((i) => widget.letters[i]).join();
    setState(path.clear);
    widget.onSolved(word);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (ctx, box) {
        final size = Size(box.maxWidth, box.maxHeight);
        final center = Offset(size.width / 2, size.height / 2);
        final radius = size.shortestSide * .36;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (d) => _add(d.localPosition, size),
          onPanUpdate: (d) => _add(d.localPosition, size),
          onPanEnd: (_) => _finish(),
          onPanCancel: _finish,
          child: CustomPaint(
            painter: _ConnectPainter(widget.letters, List<int>.of(path)),
            child: Stack(children: [
              const Align(alignment: Alignment.topCenter, child: Text('HARFLERİ BİRLEŞTİR', style: TextStyle(color: _paper, fontSize: 12, fontWeight: FontWeight.bold))),
              for (var i = 0; i < widget.letters.length; i++)
                Positioned(
                  left: center.dx + math.cos(-math.pi / 2 + i * 2 * math.pi / widget.letters.length) * radius - pad,
                  top: center.dy + math.sin(-math.pi / 2 + i * 2 * math.pi / widget.letters.length) * radius - pad,
                  child: Container(
                    width: pad * 2, height: pad * 2,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: path.contains(i) ? const Color(0xFFEFC67D) : const Color(0xFFE5CF9E),
                      border: Border.all(color: const Color(0xFF684021), width: 3),
                    ),
                    child: Text(widget.letters[i], style: const TextStyle(color: Color(0xFF302015), fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 25)),
                  ),
                ),
              Align(alignment: Alignment.center, child: IgnorePointer(child: Text(path.map((i) => widget.letters[i]).join(), style: const TextStyle(color: _gold, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 17)))),
              const Align(alignment: Alignment.bottomCenter, child: Text('Parmağını kaldırınca kelime kontrol edilir', style: TextStyle(color: _paper, fontSize: 11))),
            ]),
          ),
        );
      });
}

class _ConnectPainter extends CustomPainter {
  const _ConnectPainter(this.letters, this.path);
  final List<String> letters;
  final List<int> path;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * .36;
    canvas.drawCircle(center, size.shortestSide * .48, Paint()..color = const Color(0xFF37251D));
    canvas.drawCircle(center, size.shortestSide * .46, Paint()..color = const Color(0xFFD0A262)..style = PaintingStyle.stroke..strokeWidth = 5);
    if (path.length < 2) return;
    final ink = Path();
    for (var j = 0; j < path.length; j++) {
      final i = path[j];
      final a = -math.pi / 2 + i * math.pi * 2 / letters.length;
      final p = center + Offset(math.cos(a), math.sin(a)) * radius;
      if (j == 0) { ink.moveTo(p.dx, p.dy); } else { ink.lineTo(p.dx, p.dy); }
    }
    canvas.drawPath(ink, Paint()..color = const Color(0xFFE8B65E)..strokeWidth = 6..strokeCap = StrokeCap.round..style = PaintingStyle.stroke);
  }
  @override
  bool shouldRepaint(covariant _ConnectPainter old) => old.path != path || old.letters != letters;
}

/// Third mechanic: exchange two tiles to unscramble the answer.
class SwapLettersGame extends StatefulWidget {
  const SwapLettersGame({super.key, required this.answer, required this.onSolved});
  final String answer;
  final ValueChanged<String> onSolved;
  @override
  State<SwapLettersGame> createState() => _SwapLettersGameState();
}

class _SwapLettersGameState extends State<SwapLettersGame> {
  late List<String> tiles;
  int? selected;
  @override
  void initState() {
    super.initState();
    tiles = widget.answer.split('');
    final rng = math.Random(
  widget.answer.codeUnits.fold<int>(
    13,
    (a, b) => a * 31 + b,
  ),
);
    for (var tries = 0; tries < 12 && tiles.join() == widget.answer; tries++) {
      tiles.shuffle(rng);
    }
    if (tiles.join() == widget.answer && tiles.length > 1) {
      final t = tiles[0]; tiles[0] = tiles[1]; tiles[1] = t;
    }
  }

  void _tap(int i) {
    HapticFeedback.selectionClick();
    if (selected == null) { setState(() => selected = i); return; }
    final j = selected!;
    setState(() {
      final t = tiles[i]; tiles[i] = tiles[j]; tiles[j] = t;
      selected = null;
    });
    if (tiles.join() == widget.answer) widget.onSolved(widget.answer);
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF38241C), borderRadius: BorderRadius.circular(22), border: Border.all(color: _gold, width: 3)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('HARFLERİN YERİNİ DEĞİŞTİR', style: TextStyle(color: _paper, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          const Text('İki harfe sırayla dokun', style: TextStyle(color: _gold, fontSize: 13)),
          const SizedBox(height: 20),
          Wrap(alignment: WrapAlignment.center, spacing: 5, runSpacing: 9,
            children: List.generate(tiles.length, (i) => GestureDetector(
              key: ValueKey('swap-$i'), onTap: () => _tap(i),
              child: Container(width: 47, height: 53, alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected == i ? const Color(0xFFFFD275) : const Color(0xFFE8D0A0),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: const Color(0xFF996734), width: 3),
                ),
                child: Text(tiles[i], style: const TextStyle(color: Color(0xFF342015), fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 26)),
              ),
            )),
          ),
          const SizedBox(height: 22),
          const Text('Doğru sıraya geldiğinde kilit açılır', style: TextStyle(color: _paper, fontSize: 12)),
        ]),
      );
}
