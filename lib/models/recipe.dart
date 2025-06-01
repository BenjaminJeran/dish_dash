// Ensure this file exists and is correctly structured
class Recipe {
  final String name;
  final String imageUrl;
  final String description;
  final String cookingTime; // Added
  final String servings;    // Added
  final String category;    // Added
  final List<String> ingredients;
  final List<String> instructions;

  Recipe({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.cookingTime,
    required this.servings,
    required this.category, // Added
    required this.ingredients,
    required this.instructions,
  });

  // Optional: A factory constructor to create a Recipe object from a Supabase map
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      name: map['name'] as String? ?? 'Neznano ime',
      imageUrl: map['image_url'] as String? ?? '',
      description: map['description'] as String? ?? 'Ni opisa.',
      cookingTime: map['cooking_time'] as String? ?? 'Neznano',
      servings: map['servings'] as String? ?? 'Neznano',
      category: map['category'] as String? ?? 'Neznano', // Assuming 'category' field in Supabase
      ingredients: List<String>.from(map['ingredients'] as List? ?? []),
      instructions: List<String>.from(map['instructions'] as List? ?? []),
    );
  }
}