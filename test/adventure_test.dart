import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kelime_hatti/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Every mystery answer fits the ten-hole dial and has three hints', () {
    expect(caseLevels.length, 12);
    expect(caseLevels.map((level) => level.evidence).toSet().length, 12);
    for (final level in caseLevels) {
      expect(level.answer.split('').toSet().length, lessThanOrEqualTo(10),
          reason: level.name);
      expect(level.answer.length, inInclusiveRange(3, 12));
      expect(level.hints.length, 3);
      expect(level.message, isNotEmpty);
      expect(level.fact, isNotEmpty);
    }
  });

  test(
      'Evidence, calls, hints and position survive a restart; classic save is preserved',
      () async {
    SharedPreferences.setMockInitialValues({'unlocked': 7});
    final progress = CaseProgress(
        solved: {0, 1, 2}, calls: {0, 1, 2}, hints: {1: 2}, current: 3);
    await progress.save();
    final restored = await CaseProgress.load();
    expect(restored.solved, {0, 1, 2});
    expect(restored.calls, {0, 1, 2});
    expect(restored.hints[1], 2);
    expect(restored.current, 3);
    expect(restored.unlocked, 3);
    expect((await SharedPreferences.getInstance()).getInt('unlocked'), 7);
  });

  test('Corrupted save cannot unlock the finale or an inaccessible chapter',
      () async {
    SharedPreferences.setMockInitialValues({
      'case_kayip_emanet_v1': jsonEncode({
        'solved': [-1, 0, 99],
        'calls': [99],
        'hints': {'0': 999, '50': 2},
        'current': 999,
        'closed': true,
      })
    });
    final progress = await CaseProgress.load();
    expect(progress.solved, {0});
    expect(progress.current, 1);
    expect(progress.hints[0], 3);
    expect(progress.closed, isFalse);
    expect(progress.calls, isEmpty);
    SharedPreferences.setMockInitialValues(
        {'case_kayip_emanet_v1': '{bad json'});
    expect((await CaseProgress.load()).solved, isEmpty);
  });

  testWidgets(
      'Desk opens the first written call and keeps the original mode available',
      (tester) async {
    await tester.pumpWidget(const KelimeHattiApp());
    await tester.pumpAndSettle();
    expect(find.text('Kayıp Emanet'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Eski Hat · İlk 10 bölüm'), 200);
    expect(find.text('Eski Hat · İlk 10 bölüm'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.byKey(const ValueKey('open-case')), -200);
    await tester.tap(find.byKey(const ValueKey('open-case')));
    await tester.pumpAndSettle();
    expect(find.text(caseLevels.first.caller), findsOneWidget);
    await tester.tap(find.text('İpucunu incele'));
    await tester.pumpAndSettle();
    expect(find.text('Dosya 01 · 1/12'), findsOneWidget);
    expect(find.byType(RotaryDial), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Correct answer collects a single evidence card and advances the next call',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GamePage(adventure: true)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('İpucunu incele'));
    await tester.pumpAndSettle();
    for (final letter in caseLevels.first.answer.split('')) {
      tester.widget<RotaryDial>(find.byType(RotaryDial)).onLetter(letter);
      await tester.pump();
    }
    await tester.tap(find.text('Kelimeyi\nKontrol Et'));
    await tester.pumpAndSettle();
    expect(find.text('Yeni kanıt bulundu'), findsOneWidget);
    expect(find.text(caseLevels.first.evidence), findsOneWidget);
    expect((await CaseProgress.load()).solved, {0});
    expect((await CaseProgress.load()).current, 1);
    await tester.tap(find.text('Sonraki çağrı'));
    await tester.pumpAndSettle();
    expect(find.text(caseLevels[1].caller), findsOneWidget);
    await tester.tap(find.text('İpucunu incele'));
    await tester.pumpAndSettle();
    expect(find.text('Dosya 01 · 2/12'), findsOneWidget);
    expect((await CaseProgress.load()).current, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Hints persist and do not solve the puzzle automatically',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: GamePage(adventure: true)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('İpucunu incele'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('İpucu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Anlam ipucunu aç'));
    await tester.pumpAndSettle();
    expect(find.text('1. ${caseLevels.first.hints.first}'), findsOneWidget);
    final saved = await CaseProgress.load();
    expect(saved.hints[0], 1);
    expect(saved.solved, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Notebook shows only discovered evidence and its learning card',
      (tester) async {
    await CaseProgress(solved: {0}, current: 1).save();
    await tester.pumpWidget(const KelimeHattiApp());
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Kanıt ve Bilgi Defteri'), 200);
    await tester.tap(find.text('Kanıt ve Bilgi Defteri'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('evidence-0')));
    await tester.pumpAndSettle();
    expect(find.text(caseLevels.first.fact), findsOneWidget);
    expect(find.byKey(const ValueKey('evidence-1')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Entire case can be solved and reaches the deduction finale',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: GamePage(adventure: true)));
    await tester.pumpAndSettle();
    for (var i = 0; i < caseLevels.length; i++) {
      expect(find.text(caseLevels[i].caller), findsOneWidget);
      await tester.tap(find.text('İpucunu incele'));
      await tester.pumpAndSettle();
      for (final letter in caseLevels[i].answer.split('')) {
        tester.widget<RotaryDial>(find.byType(RotaryDial)).onLetter(letter);
        await tester.pump();
      }
      await tester.tap(find.text('Kelimeyi\nKontrol Et'));
      await tester.pumpAndSettle();
      expect(find.text(caseLevels[i].evidence), findsOneWidget);
      await tester.tap(find.text(
          i == caseLevels.length - 1 ? 'Son kararını ver' : 'Sonraki çağrı'));
      await tester.pumpAndSettle();
    }
    expect(find.byType(CaseFinalePage), findsOneWidget);
    expect((await CaseProgress.load()).solved.length, 12);
    expect((await CaseProgress.load()).closed, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Finale requires all evidence and saves only the supported conclusion',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CaseFinalePage()));
    await tester.pumpAndSettle();
    expect(find.text('Son kararı vermeden önce 12 kanıtı da bulmalısın.'),
        findsOneWidget);
    expect(find.byKey(const ValueKey('resolve-case')), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await CaseProgress(
            solved: Set.from(List.generate(12, (i) => i)), current: 11)
        .save();
    await tester.pumpWidget(const MaterialApp(home: CaseFinalePage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('conclusion-0')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.byKey(const ValueKey('resolve-case')), 200);
    await tester.ensureVisible(find.byKey(const ValueKey('resolve-case')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('resolve-case')));
    await tester.pumpAndSettle();
    expect((await CaseProgress.load()).closed, isFalse);
    await tester.scrollUntilVisible(
        find.byKey(const ValueKey('conclusion-1')), -200);
    await tester.tap(find.byKey(const ValueKey('conclusion-1')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.byKey(const ValueKey('resolve-case')), 200);
    await tester.ensureVisible(find.byKey(const ValueKey('resolve-case')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('resolve-case')));
    await tester.pumpAndSettle();
    expect((await CaseProgress.load()).closed, isTrue);
    expect(find.text('Saat çalınmamıştı.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
