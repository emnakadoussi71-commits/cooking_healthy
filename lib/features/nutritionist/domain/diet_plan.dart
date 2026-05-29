class DietPlan {
  final String id;
  final String title;
  final String nutritionistId;
  final String targetDiet;
  final String description;
  final Map<String, List<String>> weeklySchedule; // { 'lundi': [recipeId, ...] }
  final DateTime createdAt;

  const DietPlan({
    required this.id,
    required this.title,
    required this.nutritionistId,
    required this.targetDiet,
    required this.description,
    required this.weeklySchedule,
    required this.createdAt,
  });

  factory DietPlan.fromMap(String id, Map<String, dynamic> map) => DietPlan(
        id: id,
        title: map['title'] ?? '',
        nutritionistId: map['nutritionistId'] ?? '',
        targetDiet: map['targetDiet'] ?? '',
        description: map['description'] ?? '',
        weeklySchedule:
            (map['weeklySchedule'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, List<String>.from(v as List)),
        ),
        createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'nutritionistId': nutritionistId,
        'targetDiet': targetDiet,
        'description': description,
        'weeklySchedule': weeklySchedule,
        'createdAt': createdAt,
      };
}
