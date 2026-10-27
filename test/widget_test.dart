import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kelime_hatti/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Kelime Hattı açılır ve ilk bölüm görüntülenir', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const KelimeHattiApp());
    await tester.pumpAndSettle();

    expect(find.text('KELİME HATTI'), findsOneWidget);
    expect(find.text('BÖLÜM 1 / 10'), findsOneWidget);
    expect(find.text('KAYIP MESAJ'), findsOneWidget);
    expect(find.byType(RotaryDial), findsOneWidget);
  });
}
