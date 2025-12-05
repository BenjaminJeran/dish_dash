import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dish_dash/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow Test', () {
    setUp(() async {
      // Clear SharedPreferences and set onboarding as seen to skip it
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);
    });

    testWidgets('Uporabnik se uspesno prijavi v aplikacijo', (
      WidgetTester tester,
    ) async {
      app.main();

      // Wait for splash screen (2 seconds delay in splash_screen.dart)
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify we're on the login screen
      expect(find.byKey(const Key('loginEmailField')), findsOneWidget);

      // 1. Find the email field and enter text
      final emailField = find.byKey(const Key('loginEmailField'));
      await tester.enterText(emailField, 'benjamin.jeran@gmail.com');
      await tester.pumpAndSettle();

      // 2. Find the password field and enter text
      final passwordField = find.byKey(const Key('loginPasswordField'));
      await tester.enterText(passwordField, 'test123!');
      await tester.pumpAndSettle();

      // 3. Find the login button and tap it
      final loginButton = find.byKey(const Key('loginButton'));
      await tester.tap(loginButton);

      // 4. Wait for the app to navigate/update UI after login attempt
      // Use longer timeout for authentication
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final fabButton = find.byKey(const Key('createRecipeFAB'));
      await tester.tap(fabButton);

      // Čakam na odpiranje zaslona za ustvarjanje recepta
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 5. Verification - Check for success or return to main screen
      expect(find.text('Priporočeni recepti'), findsOneWidget);
    });
  });
}
