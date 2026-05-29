import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/recipes_provider.dart';
import '../widgets/filter_bar.dart';
import '../widgets/recipe_card.dart';

class RecipesListScreen extends ConsumerWidget {
  const RecipesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(filteredRecipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recettes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () => _showFilterSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: _SearchField(ref: ref),
          ),
          const FilterBar(),
          const SizedBox(height: 4),
          Expanded(
            child: recipesAsync.when(
              loading: () => const AppLoading(),
              error: (e, _) => AppErrorWidget(
                message: 'Erreur lors du chargement des recettes.',
                onRetry: () => ref.invalidate(recipesProvider),
              ),
              data: (recipes) {
                if (recipes.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: AppColors.textSecondary),
                        SizedBox(height: 12),
                        Text('Aucune recette trouvée.',
                            style:
                                TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: recipes.length,
                  itemBuilder: (_, i) => RecipeCard(recipe: recipes[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FilterSheet(ref: ref),
    );
  }
}

class _SearchField extends StatelessWidget {
  final WidgetRef ref;

  const _SearchField({required this.ref});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (q) {
        final current = ref.read(recipeFilterProvider);
        ref.read(recipeFilterProvider.notifier).state =
            current.copyWith(searchQuery: q);
      },
      decoration: InputDecoration(
        hintText: 'Rechercher une recette...',
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class _FilterSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _FilterSheet({required this.ref});

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  double _maxCal = 1000;
  double _maxTime = 120;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtres',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text('Calories max : ${_maxCal.toInt()} kcal',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: _maxCal,
            min: 100,
            max: 1000,
            divisions: 9,
            activeColor: AppColors.primary,
            label: '${_maxCal.toInt()} kcal',
            onChanged: (v) => setState(() => _maxCal = v),
          ),
          const SizedBox(height: 12),
          Text('Temps de préparation max : ${_maxTime.toInt()} min',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: _maxTime,
            min: 5,
            max: 120,
            divisions: 23,
            activeColor: AppColors.primary,
            label: '${_maxTime.toInt()} min',
            onChanged: (v) => setState(() => _maxTime = v),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(recipeFilterProvider.notifier).state =
                        ref.read(recipeFilterProvider).copyWith(
                              maxCalories: null,
                              maxPrepTime: null,
                            );
                    Navigator.pop(context);
                  },
                  child: const Text('Réinitialiser'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(recipeFilterProvider.notifier).state =
                        ref.read(recipeFilterProvider).copyWith(
                              maxCalories: _maxCal.toInt(),
                              maxPrepTime: _maxTime.toInt(),
                            );
                    Navigator.pop(context);
                  },
                  child: const Text('Appliquer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
