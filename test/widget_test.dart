// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bluesense/main.dart'; // Make sure this matches your main.dart file

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp()); // Change from BlueSenseApp to MyApp
    
    // Verify that the login screen is shown
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
