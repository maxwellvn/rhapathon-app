import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rhapathon_search/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows login after auth check', (WidgetTester tester) async {
    await tester.pumpWidget(const RhapathonApp());
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Rhapathon 2026'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
