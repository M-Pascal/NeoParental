import 'package:flutter_test/flutter_test.dart';
import 'package:parents/main.dart';

void main() {
  testWidgets('NeoParental app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NeoParentalApp());

    // Verify that our welcome text is displayed.
    expect(find.text('Welcome to NeoParental'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // Tap the 'Get Started' button and verify it exists
    await tester.tap(find.text('Get Started'));
    await tester.pump();

    // Verify the button still exists after tap
    expect(find.text('Get Started'), findsOneWidget);
  });
}
