import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../recipes/domain/recipe.dart';
import '../../../recipes/presentation/providers/recipes_provider.dart';
import '../providers/nutrition_provider.dart';
import '../../domain/meal_entry.dart';

class AddMealScreen extends ConsumerStatefulWidget {
  const AddMealScreen({super.key});

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  Recipe? _selectedRecipe;
  int _servings = 1;
  bool _saving = false;
  String _search = '';

  Future<void> _save() async {
    if (_selectedRecipe == null) return;
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;

    setState(() => _saving = true);

    final ratio = _servings / _selectedRecipe!.servings;
    final entry = MealEntry(
      recipeId: _selectedRecipe!.id,
      recipeTitle: _selectedRecipe!.title,
      servings: _servings,
      consumedAt: DateTime.now(),
      calories: _selectedRecipe!.calories * ratio,
      protein: _selectedRecipe!.nutritionValues.protein * ratio,
      carbs: _selectedRecipe!.nutritionValues.carbs * ratio,
      fat: _selectedRecipe!.nutritionValues.fat * ratio,
    );

    try {
      await ref.read(nutritionRepositoryProvider).addMealEntry(uid, entry);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repas ajouté avec succès !')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'ajout.')),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un repas')),
      body: recipesAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => const Center(child: Text('Erreur de chargement.')),
        data: (recipes) {
          final filtered = _search.isEmpty
              ? recipes
              : recipes
                  .where((r) =>
                      r.title.toLowerCase().contains(_search.toLowerCase()))
                  .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Rechercher une recette...',
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textSecondary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              if (_selectedRecipe != null)
                _SelectedRecipeCard(
                  recipe: _selectedRecipe!,
                  servings: _servings,
                  onServingsChanged: (v) => setState(() => _servings = v),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final r = filtered[i];
                    final isSelected = _selectedRecipe?.id == r.id;
                    return ListTile(
                      selected: isSelected,
                      selectedTileColor:
                          AppColors.primary.withValues(alpha: 0.08),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.restaurant,
                            color: AppColors.primary),
                      ),
                      title: Text(r.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500)),
                      subtitle: Text('${r.calories} kcal'),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: AppColors.primary)
                          : null,
                      onTap: () => setState(() {
                        _selectedRecipe = r;
                        _servings = 1;
                      }),
                    );
                  },
                ),
              ),
              if (_selectedRecipe != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _saving
                      ? const CircularProgressIndicator(
                          color: AppColors.primary)
                      : ElevatedButton(
                          onPressed: _save,
                          child: const Text('Enregistrer le repas'),
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SelectedRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final int servings;
  final ValueChanged<int> onServingsChanged;

  const _SelectedRecipeCard({
    required this.recipe,
    required this.servings,
    required this.onServingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = servings / recipe.servings;
    final cal = (recipe.calories * ratio).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(recipe.title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.primary,
                onPressed: servings > 1
                    ? () => onServingsChanged(servings - 1)
                    : null,
              ),
              Text('$servings portion(s)',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
                onPressed: () => onServingsChanged(servings + 1),
              ),
            ],
          ),
          Text('≈ $cal kcal',
              style: const TextStyle(
                  color: AppColors.secondary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
