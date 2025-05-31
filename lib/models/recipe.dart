class Recipe {
  final String name;
  final String imageUrl;
  final String description;
  final String cookingTime;
  final String servings;
  final List<String> ingredients;
  final List<String> instructions;

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
