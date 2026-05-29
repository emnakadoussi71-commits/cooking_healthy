import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../recipes/presentation/widgets/recipe_card.dart';
import '../providers/recommendations_provider.dart';

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(recommendationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pour vous'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () =>
                ref.invalidate(recommendationsProvider),
          ),
        ],
      ),
      body: recsAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => const Center(
            child: Text('Impossible de charger les suggestions.')),
        data: (recipes) {
          if (recipes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline,
                        size: 72, color: AppColors.textSecondary),
                    SizedBox(height: 16),
                    Text(
                      'Aucune suggestion pour le moment.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Complétez votre profil pour obtenir des recommandations personnalisées.',
                      style: TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: AppColors.secondary, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${recipes.length} recette(s) sélectionnée(s) pour vous',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
