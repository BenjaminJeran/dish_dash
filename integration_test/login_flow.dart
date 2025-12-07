import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dish_dash/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow Test', () {
    setUp(() async {
      // Da skippamno onboarding zaslone
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenOnboarding', true);
    });

    testWidgets('Uporabnik se uspesno prijavi v aplikacijo in ustvari recept', (
      WidgetTester tester,
    ) async {
      app.main();

      // Počakam da bo konc splashscreena
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byKey(const Key('loginEmailField')), findsOneWidget);

      final emailField = find.byKey(const Key('loginEmailField'));
      await tester.enterText(emailField, 'benjamin.jeran@gmail.com');
      await tester.pumpAndSettle();

      final passwordField = find.byKey(const Key('loginPasswordField'));
      await tester.enterText(passwordField, 'test123!');
      await tester.pumpAndSettle();

      final loginButton = find.byKey(const Key('loginButton'));
      await tester.tap(loginButton);

      await tester.pumpAndSettle(const Duration(seconds: 5));

      final fabButton = find.byKey(const Key('createRecipeFAB'));
      await tester.tap(fabButton);

      // Čakam na odpiranje zaslona za ustvarjanje recepta
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Preverimo, da smo na pravem zaslonu
      expect(find.byKey(const Key('recipeNameInput')), findsOneWidget);

      // 6. Vnos naslova
      final titleField = find.byKey(const Key('recipeNameInput'));
      await tester.enterText(titleField, 'Testni Recept - IT');
      await tester.pumpAndSettle();

      final descriptionField = find.byKey(const Key('descriptionInput'));
      await tester.enterText(
        descriptionField,
        'To je odličen recept za integracijsko testiranje.',
      );
      await tester.pumpAndSettle();

      // 8. Dodajanje sestavine
      final firstIngredientField = find.byKey(const Key('ingredientInput_0'));
      await tester.enterText(firstIngredientField, 'Sol - 1 žlička');
      await tester.pumpAndSettle();

      // Dodaj drugo sestavino
      final addIngredientButton = find.byKey(const Key('addIngredientButton'));
      await tester.tap(addIngredientButton);
      await tester.pumpAndSettle();

      // Vnos v drugo sestavino
      final secondIngredientField = find.byKey(const Key('ingredientInput_1'));
      await tester.enterText(secondIngredientField, 'Poper - po okusu');
      await tester.pumpAndSettle();

      // 9. Dodajanje navodil
      final firstInstructionField = find.byKey(const Key('instructionInput_0'));
      await tester.enterText(firstInstructionField, 'Zmešaj vse sestavine.');
      await tester.pumpAndSettle();

      // Dodaj drugo navodilo
      final addInstructionButton = find.byKey(
        const Key('addInstructionButton'),
      );
      await tester.tap(addInstructionButton);
      await tester.pumpAndSettle();

      // Vnos v drugo navodilo
      final secondInstructionField = find.byKey(
        const Key('instructionInput_1'),
      );
      await tester.enterText(secondInstructionField, 'Kuhaj 30 minut.');
      await tester.pumpAndSettle();

      // Scrollamo navzdol, da so vidna polja za čas in porcije
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      // 11. Vnos časa priprave
      final timeField = find.byKey(const Key('cookingTimeInput'));
      await tester.ensureVisible(timeField);
      await tester.pumpAndSettle();
      await tester.enterText(timeField, '30 minut');
      await tester.pumpAndSettle();

      // 12. Vnos števila porcij
      final servingsField = find.byKey(const Key('servingsInput'));
      await tester.ensureVisible(servingsField);
      await tester.pumpAndSettle();
      await tester.enterText(servingsField, '4 osebe');
      await tester.pumpAndSettle();

      // 14. Izbira kuhinje
      final cuisineDropdown = find.byKey(const Key('cuisineDropdown'));
      await tester.ensureVisible(cuisineDropdown);
      await tester.pumpAndSettle();
      await tester.tap(cuisineDropdown);
      await tester.pumpAndSettle();

      // Izberi prvo možnost (Italijanska)
      await tester.tap(find.text('Italijanska').last);
      await tester.pumpAndSettle();

      // 15. Izbira kategorije
      final categoryDropdown = find.byKey(const Key('categoryDropdown'));
      await tester.ensureVisible(categoryDropdown);
      await tester.pumpAndSettle();
      await tester.tap(categoryDropdown);
      await tester.pumpAndSettle();

      // Izberi prvo možnost (Zajtrk)
      await tester.tap(find.text('Zajtrk').last);
      await tester.pumpAndSettle();

      // 17. Shranjevanje celotnega recepta
      final saveRecipeButton = find.byKey(const Key('saveRecipeButton'));
      await tester.ensureVisible(saveRecipeButton);
      await tester.pumpAndSettle();
      await tester.tap(saveRecipeButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Preverimo, da smo nazaj na domačem zaslonu
      expect(find.text('Priporočeni recepti'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 5));

      final recipe_tab = find.byKey(const Key('nav_Recepti'));
      await tester.ensureVisible(recipe_tab);
      await tester.pumpAndSettle();
      await tester.tap(recipe_tab);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Preverimo, da je nov recept prikazan na seznamu receptov
      expect(find.text('Testni Recept - IT'), findsOneWidget);

      final recipeTitleFinder = find.text('Testni Recept - IT');
      
      // Find the Dismissible parent widget containing the recipe
      final recipeItem = find.ancestor(
        of: recipeTitleFinder,
        matching: find.byType(Dismissible),
      );

      // Simuliraj poteg "od konca do začetka" (endToStart) za brisanje
      await tester.drag(
        recipeItem,
        const Offset(-400.0, 0.0),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Preveri, da se je prikazalo potrditveno pogovorno okno (AlertDialog)
      expect(find.text('Potrdi izbris'), findsOneWidget);

      // Tapni gumb 'Izbriši' v potrditvenem pogovornem oknu
      final deleteButton = find.text('Izbriši');
      await tester.tap(deleteButton);
      
      // Počakaj, da se dialog zapre in izvede dejansko brisanje/osveževanje
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Preveri, da recept ni več prikazan na seznamu
      expect(recipeTitleFinder, findsNothing);


    });
  });
}
