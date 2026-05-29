class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String authorId;
  final String status; // 'published' | 'draft'
  final bool isValidated;
  final String? validatorId;
  final int calories;
  final int prepTime; // minutes
  final int servings;
  final List<Ingredient> ingredients;
  final List<String> steps;
  final List<String> dietTags;
  final NutritionValues nutritionValues;
  final DateTime createdAt;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.authorId,
    required this.status,
    this.isValidated = false,
    this.validatorId,
    required this.calories,
    required this.prepTime,
    required this.servings,
    required this.ingredients,
    required this.steps,
    required this.dietTags,
    required this.nutritionValues,
    required this.createdAt,
  });

  factory Recipe.fromMap(String id, Map<String, dynamic> map) {
    return Recipe(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      authorId: map['authorId'] ?? '',
      status: map['status'] ?? 'draft',
      isValidated: map['isValidated'] ?? false,
      validatorId: map['validatorId'] as String?,
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      prepTime: (map['prepTime'] as num?)?.toInt() ?? 0,
      servings: (map['servings'] as num?)?.toInt() ?? 1,
      ingredients: (map['ingredients'] as List<dynamic>? ?? [])
          .map((e) => Ingredient.fromMap(e as Map<String, dynamic>))
          .toList(),
      steps: List<String>.from(map['steps'] ?? []),
      dietTags: List<String>.from(map['dietTags'] ?? []),
      nutritionValues: NutritionValues.fromMap(
        map['nutritionValues'] as Map<String, dynamic>? ?? {},
      ),
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'authorId': authorId,
        'status': status,
        'isValidated': isValidated,
        'validatorId': validatorId,
        'calories': calories,
        'prepTime': prepTime,
        'servings': servings,
        'ingredients': ingredients.map((e) => e.toMap()).toList(),
        'steps': steps,
        'dietTags': dietTags,
        'nutritionValues': nutritionValues.toMap(),
        'createdAt': createdAt,
      };

  Recipe copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? status,
    bool? isValidated,
    String? validatorId,
    int? calories,
    int? prepTime,
    int? servings,
    List<Ingredient>? ingredients,
    List<String>? steps,
    List<String>? dietTags,
    NutritionValues? nutritionValues,
  }) {
    return Recipe(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      authorId: authorId,
      status: status ?? this.status,
      isValidated: isValidated ?? this.isValidated,
      validatorId: validatorId ?? this.validatorId,
      calories: calories ?? this.calories,
      prepTime: prepTime ?? this.prepTime,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      dietTags: dietTags ?? this.dietTags,
      nutritionValues: nutritionValues ?? this.nutritionValues,
      createdAt: createdAt,
    );
  }
}

class Ingredient {
  final String name;
  final double quantity;
  final String unit;

  const Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });

  factory Ingredient.fromMap(Map<String, dynamic> map) => Ingredient(
        name: map['name'] ?? '',
        quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
        unit: map['unit'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'quantity': quantity,
        'unit': unit,
      };
}

class NutritionValues {
  final double protein; // g
  final double carbs; // g
  final double fat; // g
  final double fiber; // g

  const NutritionValues({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });

  const NutritionValues.empty()
      : protein = 0,
        carbs = 0,
        fat = 0,
        fiber = 0;

  factory NutritionValues.fromMap(Map<String, dynamic> map) => NutritionValues(
        protein: (map['protein'] as num?)?.toDouble() ?? 0,
        carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
        fat: (map['fat'] as num?)?.toDouble() ?? 0,
        fiber: (map['fiber'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
      };
}
