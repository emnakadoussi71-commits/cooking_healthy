import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/recipe_repository.dart';
import '../../domain/recipe.dart';
import '../../domain/recipe_filter.dart';

final recipeRepositoryProvider = Provider<RecipeRepository>(
  (_) => RecipeRepository(),
);

final recipeFilterProvider = StateProvider<RecipeFilter>(
  (_) => const RecipeFilter(),
);

final recipesProvider = StreamProvider<List<Recipe>>((ref) {
  final filter = ref.watch(recipeFilterProvider);
  return ref.watch(recipeRepositoryProvider).watchPublishedRecipes(
        dietTag: filter.dietTag,
      );
});

final filteredRecipesProvider = Provider<AsyncValue<List<Recipe>>>((ref) {
  final filter = ref.watch(recipeFilterProvider);
  return ref.watch(recipesProvider).whenData((recipes) {
    var result = recipes;

    if (filter.maxCalories != null) {
      result =
          result.where((r) => r.calories <= filter.maxCalories!).toList();
    }
    if (filter.maxPrepTime != null) {
      result =
          result.where((r) => r.prepTime <= filter.maxPrepTime!).toList();
    }
    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      result = result
          .where((r) =>
              r.title.toLowerCase().contains(q) ||
              r.description.toLowerCase().contains(q))
          .toList();
    }
    return result;
  });
});

final recipeDetailProvider =
    FutureProvider.family<Recipe?, String>((ref, id) {
  return ref.watch(recipeRepositoryProvider).getRecipe(id);
});

final allRecipesAdminProvider = StreamProvider<List<Recipe>>((ref) {
  return ref.watch(recipeRepositoryProvider).watchAllRecipes();
});
