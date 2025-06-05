class Recipe {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final String cookingTime;
  final String servings;
  final String category;
  final List<String> ingredients;
  final List<String> instructions;
  final int likesCount; 

  Recipe({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.cookingTime,
    required this.servings,
    required this.category,
    required this.ingredients,
    required this.instructions,
    this.likesCount = 0, 
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as String,
      name: map['name'] as String? ?? 'Neznano ime',
      imageUrl: map['image_url'] as String? ?? '',
      description: map['description'] as String? ?? 'Ni opisa.',
      cookingTime: map['cooking_time'] as String? ?? 'Neznano',
      servings: map['servings'] as String? ?? 'Neznano',
      category: map['category'] as String? ?? 'Neznano',
      ingredients: List<String>.from(map['ingredients'] as List? ?? []),
      instructions: List<String>.from(map['instructions'] as List? ?? []),
      likesCount: (map['likes_count'] as int?) ?? 0, 
    );
  }
}