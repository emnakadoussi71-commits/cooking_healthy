class MealEntry {
  final String recipeId;
  final String recipeTitle;
  final int servings;
  final DateTime consumedAt;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const MealEntry({
    required this.recipeId,
    required this.recipeTitle,
    required this.servings,
    required this.consumedAt,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory MealEntry.fromMap(Map<String, dynamic> map) => MealEntry(
        recipeId: map['recipeId'] ?? '',
        recipeTitle: map['recipeTitle'] ?? '',
        servings: (map['servings'] as num?)?.toInt() ?? 1,
        consumedAt: (map['consumedAt'] as dynamic)?.toDate() ?? DateTime.now(),
        calories: (map['calories'] as num?)?.toDouble() ?? 0,
        protein: (map['protein'] as num?)?.toDouble() ?? 0,
        carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
        fat: (map['fat'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'recipeId': recipeId,
        'recipeTitle': recipeTitle,
        'servings': servings,
        'consumedAt': consumedAt,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };
}
