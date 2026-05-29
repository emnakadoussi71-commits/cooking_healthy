class RecipeFilter {
  final String? dietTag;
  final int? maxCalories;
  final int? maxPrepTime;
  final String searchQuery;

  const RecipeFilter({
    this.dietTag,
    this.maxCalories,
    this.maxPrepTime,
    this.searchQuery = '',
  });

  RecipeFilter copyWith({
    String? dietTag,
    int? maxCalories,
    int? maxPrepTime,
    String? searchQuery,
    bool clearDietTag = false,
  }) {
    return RecipeFilter(
      dietTag: clearDietTag ? null : (dietTag ?? this.dietTag),
      maxCalories: maxCalories ?? this.maxCalories,
      maxPrepTime: maxPrepTime ?? this.maxPrepTime,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
