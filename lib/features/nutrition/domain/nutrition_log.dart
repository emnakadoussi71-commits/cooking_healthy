import 'meal_entry.dart';

class NutritionLog {
  final String date; // 'yyyy-MM-dd'
  final List<MealEntry> meals;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  const NutritionLog({
    required this.date,
    required this.meals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  factory NutritionLog.empty(String date) => NutritionLog(
        date: date,
        meals: const [],
        totalCalories: 0,
        totalProtein: 0,
        totalCarbs: 0,
        totalFat: 0,
      );

  factory NutritionLog.fromMap(String date, Map<String, dynamic> map) {
    return NutritionLog(
      date: date,
      meals: (map['meals'] as List<dynamic>? ?? [])
          .map((e) => MealEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      totalCalories: (map['totalCalories'] as num?)?.toDouble() ?? 0,
      totalProtein: (map['totalProtein'] as num?)?.toDouble() ?? 0,
      totalCarbs: (map['totalCarbs'] as num?)?.toDouble() ?? 0,
      totalFat: (map['totalFat'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'meals': meals.map((e) => e.toMap()).toList(),
        'totalCalories': totalCalories,
        'totalProtein': totalProtein,
        'totalCarbs': totalCarbs,
        'totalFat': totalFat,
      };
}
