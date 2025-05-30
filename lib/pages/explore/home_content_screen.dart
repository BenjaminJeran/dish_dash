import 'package:dish_dash/pages/profile_page_screen.dart';
import 'package:dish_dash/pages/recipes/recipe_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:dish_dash/colors/app_colors.dart'; // Import custom colors // Import the recipe details screen
import 'package:dish_dash/models/recipe.dart'; // Import the Recipe model

class HomeContentScreen extends StatelessWidget {
  const HomeContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example Recipe data. In a real app, this data would come from a database or API.
    final Recipe classicPizza = Recipe(
      name: 'Classic Margherita Pizza',
      imageUrl: 'assets/pizza_margherita.png', // Ensure this image exists
      description:
          'A simple yet delicious Neapolitan pizza with fresh ingredients that highlight the natural flavors of basil, mozzarella, and tomatoes. Perfect for a quick family meal or a party.',
      cookingTime: '15',
      servings: '4',
      ingredients: [
        '200g moke (flour)',
        '150ml vode (water)',
        '5g kvasa (yeast)',
        'Ščepec soli (pinch of salt)',
        'Pelati (canned peeled tomatoes)',
        'Mozzarella sir (mozzarella cheese)',
        'Sveža bazilika (fresh basil)',
        'Olivno olje (olive oil)',
      ],
      instructions: [
        'Zmešajte moko, vodo, kvas in sol, da dobite testo. (Mix flour, water, yeast, and salt to get dough.)',
        'Pustite testo vzhajati 1 uro. (Let the dough rise for 1 hour.)',
        'Testo razvaljajte, dodajte pelate, mozzarello in baziliko. (Roll out the dough, add peeled tomatoes, mozzarella, and basil.)',
        'Pecite v segreti pečici na 220°C 10-15 minut. (Bake in a preheated oven at 220°C for 10-15 minutes.)',
        'Pokapajte z olivnim oljem in postrezite. (Drizzle with olive oil and serve.)',
      ],
    );

    final Recipe strawberryIceCream = Recipe(
      name: 'Jagodni Sladoled', // Strawberry Ice Cream
      imageUrl: 'assets/strawberry_ice_cream.jpg', // Ensure this image exists
      description:
          'Osvežujoč in enostaven jagodni sladoled, kot nalašč za poletne dni. Pripravljen hitro in brez aparata za sladoled, idealen za hitro sladko pregreho.', // Refreshing and simple strawberry ice cream, perfect for summer days. Prepared quickly and without an ice cream maker, ideal for a quick sweet treat.
      cookingTime: '15',
      servings: '4',
      ingredients: [
        '500g svežih jagod (fresh strawberries)',
        '200ml sladke smetane (heavy cream)',
        '100g sladkorja v prahu (powdered sugar)',
        'Sok 1/2 limone (juice of 1/2 lemon)',
      ],
      instructions: [
        'Jagode operite, očistite in jih skupaj s sladkorjem ter limoninim sokom zmešajte v gladko kašo. (Wash and clean strawberries, then blend them with sugar and lemon juice into a smooth puree.)',
        'Sladko smetano stepite do čvrstega. (Whip the heavy cream until stiff.)',
        'Nežno vmešajte jagodno kašo v stepeno smetano. (Gently fold the strawberry puree into the whipped cream.)',
        'Zmes prelijte v posodo, primerno za zamrzovanje, in jo zamrznite vsaj 4 ure, ali dokler ni čvrsta. (Pour the mixture into a freezer-safe container and freeze for at least 4 hours, or until firm.)',
        'Pred serviranjem pustite sladoled nekaj minut na sobni temperaturi, da se nekoliko zmehča. (Before serving, let the ice cream sit at room temperature for a few minutes to soften slightly.)',
      ],
    );

    final Recipe spaghettiCarbonara = Recipe(
      name: 'Špageti Carbonara', // Spaghetti Carbonara
      imageUrl: 'assets/spaghetti_carbonara.jpg', // Ensure this image exists
      description:
          'Klasična italijanska jed s kremasto omako, hrustljavo panceto in svežim parmezanom. Hitro in enostavno za pripravo, popolna za hitro kosilo ali večerjo.', // Classic Italian dish with creamy sauce, crispy pancetta, and fresh Parmesan. Quick and easy to prepare, perfect for a fast lunch or dinner.
      cookingTime: '20',
      servings: '2',
      ingredients: [
        '200g špagetov (spaghetti)',
        '100g pancete ali guancialeja (pancetta or guanciale)',
        '2 jajci (samo rumenjaka) (2 eggs (only yolks))',
        '50g naribanega parmezana (ali pecorino romana) (grated Parmesan (or Pecorino Romano))',
        'Sveže mlet črni poper (freshly ground black pepper)',
        'Sol (salt)',
      ],
      instructions: [
        'Špagete skuhajte v osoljeni vodi po navodilih na embalaži. (Cook spaghetti in salted water according to package instructions.)',
        'Medtem ko se špageti kuhajo, narežite panceto na majhne kocke in jo popečite v ponvi do hrustljavega. Odstranite iz ponve in prihranite maščobo. (While spaghetti cooks, dice pancetta into small cubes and fry in a pan until crispy. Remove from pan and reserve the fat.)',
        'V skledi zmešajte rumenjake s parmezanom in veliko sveže mletega popra. (In a bowl, mix egg yolks with Parmesan and plenty of freshly ground black pepper.)',
        'Ko so špageti kuhani, jih odcedite, vendar prihranite približno 50 ml vode od kuhanja. (When spaghetti is cooked, drain it, but reserve about 50 ml of the cooking water.)',
        'Špagete dodajte v ponev z maščobo od pancete. Odstavite z ognja in hitro vmešajte jajčno zmes. Dodajte malo prihranjene vode od kuhanja, da dobite kremasto omako. (Add spaghetti to the pan with pancetta fat. Remove from heat and quickly stir in the egg mixture. Add a little reserved cooking water to create a creamy sauce.)',
        'Dodajte popečeno panceto in dobro premešajte. Po potrebi dodajte še malo parmezana in popra. (Add the crispy pancetta and mix well. Add more Parmesan and pepper if needed.)',
        'Takoj postrezite. (Serve immediately.)',
      ],
    );

    return Scaffold(
      appBar: AppBar(
        // AppBar will get its styling from ThemeData in main.dart
        leading: null, // No back button on the main tab screen
        automaticallyImplyLeading:
            false, // Prevents Flutter from adding a back button automatically
        title: Center(
          child: Image.asset(
            'assets/logo.png',
            height: 80,
          ), // Use your logo image
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePageScreen(),
                ),
              );
            },
          ),
        ],
        elevation: 0, // No shadow under app bar
        backgroundColor: Colors.transparent, // Transparent background
        foregroundColor: AppColors.charcoal, // Color for icons in app bar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Recipe Card
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                // Use InkWell for tap effect
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              RecipeDetailsScreen(recipe: classicPizza),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image for the large card
                      Image.asset(
                        classicPizza.imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classicPizza.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 18,
                                  color: AppColors.dimGray,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${classicPizza.cookingTime} min',
                                  style: TextStyle(
                                    color: AppColors.dimGray,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.people,
                                  size: 18,
                                  color: AppColors.dimGray,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${classicPizza.servings} servings',
                                  style: TextStyle(
                                    color: AppColors.dimGray,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              classicPizza.description,
                              style: TextStyle(
                                color: AppColors.dimGray,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Smaller Recipe Cards
            _buildSmallRecipeCard(
              context,
              strawberryIceCream, // Pass the Recipe object
            ),
            const SizedBox(height: 15),
            _buildSmallRecipeCard(
              context,
              spaghettiCarbonara, // Pass the Recipe object
            ),
            // Add more as needed
            const SizedBox(height: 50), // Space for FAB if you add one later
          ],
        ),
      ),
    );
  }

  // Helper method to build consistent small recipe cards
  Widget _buildSmallRecipeCard(
    BuildContext context,
    Recipe recipe, // Now accepts a Recipe object
  ) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          // Navigate to Recipe Detail Screen, passing the recipe object
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailsScreen(recipe: recipe),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10), // Match card border radius
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Image for small card
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  recipe.imageUrl, // Use the image URL from the recipe object
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.dimGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.cookingTime} min',
                          style: TextStyle(
                            color: AppColors.dimGray,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.people, size: 16, color: AppColors.dimGray),
                        const SizedBox(width: 4),
                        Text(
                          '${recipe.servings} servings',
                          style: TextStyle(
                            color: AppColors.dimGray,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.dimGray),
            ],
          ),
        ),
      ),
    );
  }
}
