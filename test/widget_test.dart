import 'package:flutter_test/flutter_test.dart';
import 'package:samui_fids_kiosk/main.dart';

void main() {
  testWidgets('FIDS kiosk renders properly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SamuiFidsApp());
    expect(find.text('Call to Counter'), findsOneWidget);
    expect(find.text('Passport Pick-up'), findsOneWidget);
  });
}

