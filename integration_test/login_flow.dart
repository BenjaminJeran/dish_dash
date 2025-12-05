

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dish_dash/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow Test', () {

    testWidgets('Uporabnik se uspesno prijavi v aplikacijo', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Find the email field and enter text
      final emailField = find.byKey(const Key('loginEmailField'));
      await tester.enterText(emailField, 'benjamin.jeran@gmail.com');
      
      // 2. Find the password field and enter text
      final passwordField = find.byKey(const Key('loginPasswordField'));
      await tester.enterText(passwordField, 'test123!');

      // 3. Find the login button and tap it
      final loginButton = find.byKey(const Key('loginButton'));
      await tester.tap(loginButton);

      // 4. Wait for the app to navigate/update UI after login attempt
      await tester.pumpAndSettle();

      // 5. Verification (Example: Check for a Home Screen widget or the absence of the login button)
      // For instance, if your home screen has a title 'Welcome':
      expect(find.text('Priporočeni recepti'), findsOneWidget); 
    });

    
  });
}