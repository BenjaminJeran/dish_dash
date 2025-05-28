class Recipe {
  final String name;
  final String imageUrl;
  final String description;
  final String cookingTime;
  final String servings;
  final List<String> ingredients; // Example: ['2 jajca', '100g moke']
  final List<String> instructions; // Example: ['Step 1: Zmešaj jajca', 'Step 2: Dodaj moko']

  Recipe({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.cookingTime,
    required this.servings,
    required this.ingredients,
    required this.instructions,
  });
}