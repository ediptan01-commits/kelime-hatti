import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kelime_hatti/main.dart';

class RecordingSound extends RotarySound {
  final phases = <DialSoundPhase>[];
  DialSoundPhase current = DialSoundPhase.idle;
  @override
  void prepare() {}
  @override
  Future<void> setPhase(DialSoundPhase phase) async {
    if (current != phase) phases.add(phase);
    current = phase;
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  const letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];

  Future<void> mount(
      WidgetTester tester, RecordingSound sound, List<String> picked) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Center(
                child: SizedBox(
      width: 300,
      height: 300,
      child: RotaryDial(letters: letters, sound: sound, onLetter: picked.add),
    )))));
    await tester.pumpAndSettle();
  }

  testWidgets('Touching and holding does not play sound or select a letter',
      (tester) async {
    final sound = RecordingSound();
    final picked = <String>[];
    await mount(tester, sound, picked);
    final box = tester.getRect(find.byKey(const ValueKey('rotary-gesture')));
    final gesture =
        await tester.startGesture(box.center + const Offset(0, -108));
    await tester.pump(const Duration(milliseconds: 250));
    expect(sound.phases, isEmpty);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(sound.phases, isEmpty);
    expect(picked, isEmpty);
  });

  testWidgets('Winding stops when held; return sound follows return animation',
      (tester) async {
    final sound = RecordingSound();
    final picked = <String>[];
    await mount(tester, sound, picked);
    final center =
        tester.getCenter(find.byKey(const ValueKey('rotary-gesture')));
    final gesture = await tester.startGesture(center + const Offset(0, -108));
    for (var i = 1; i <= 5; i++) {
      final angle = -math.pi / 2 + i * .25;
      await gesture
          .moveTo(center + Offset(math.cos(angle), math.sin(angle)) * 108);
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(sound.current, DialSoundPhase.winding);
    expect(picked, isEmpty);
    await tester.pump(const Duration(milliseconds: 120));
    expect(sound.current, DialSoundPhase.idle);
    await gesture.up();
    await tester.pump();
    expect(sound.current, DialSoundPhase.returning);
    expect(picked, isEmpty);
    await tester.pumpAndSettle();
    expect(sound.phases, [
      DialSoundPhase.winding,
      DialSoundPhase.idle,
      DialSoundPhase.returning,
      DialSoundPhase.idle
    ]);
    expect(picked, ['A']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cancelled drag returns the dial without entering a letter',
      (tester) async {
    final sound = RecordingSound();
    final picked = <String>[];
    await mount(tester, sound, picked);
    final center =
        tester.getCenter(find.byKey(const ValueKey('rotary-gesture')));
    final gesture = await tester.startGesture(center + const Offset(0, -108));
    await gesture.moveTo(center + const Offset(70, -80));
    await gesture.moveTo(center + const Offset(105, -20));
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(picked, isEmpty);
    expect(sound.current, DialSoundPhase.idle);
    expect(tester.takeException(), isNull);
  });
}
