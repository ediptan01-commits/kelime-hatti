import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kelime_hatti/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Kelime Hattı açılır ve ilk bölüm görüntülenir', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const KelimeHattiApp());
    await tester.pumpAndSettle();

    expect(find.text('Bölüm 1'), findsOneWidget);
    expect(find.text('KAYIP MESAJ'), findsOneWidget);
    expect(find.text(levels.first.clue), findsOneWidget);
    expect(find.byType(RotaryDial), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kaydedilmiş bölümden devam eder', (tester) async {
    SharedPreferences.setMockInitialValues({'unlocked': 5});
    await tester.pumpWidget(const KelimeHattiApp());
    await tester.pumpAndSettle();

    expect(find.text('Bölüm 6'), findsOneWidget);
    expect(find.text(levels[5].name.toUpperCase()), findsOneWidget);
    expect(find.text(levels[5].clue), findsOneWidget);
    expect(find.byType(RotaryDial), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('Çevirme ve geri dönüş sesleri ayrı ve geçerli WAV dosyalarıdır',
      () async {
    for (final file in ['dial_wind.wav', 'dial_return.wav']) {
      final data = await rootBundle.load('assets/sounds/$file');
      final bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      expect(bytes.length, greaterThan(44));
      expect(String.fromCharCodes(bytes.take(4)), 'RIFF');
      expect(String.fromCharCodes(bytes.skip(8).take(4)), 'WAVE');
      expect(bytes.skip(44).any((byte) => byte != 0), isTrue);
    }
  });
}
