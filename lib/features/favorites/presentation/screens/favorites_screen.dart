import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../recipes/presentation/providers/recipes_provider.dart';
import '../../../recipes/presentation/widgets/recipe_card.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIdsAsync = ref.watch(favoriteIdsProvider);
    final allRecipesAsync = ref.watch(recipesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: favoriteIdsAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) =>
            const Center(child: Text('Erreur lors du chargement.')),
        data: (ids) {
          if (ids.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_outline,
                      size: 72, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('Aucun favori pour le moment.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Appuyez sur ♥ sur une recette pour l\'ajouter.',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return allRecipesAsync.when(
            loading: () => const AppLoading(),
            error: (e, _) =>
                const Center(child: Text('Erreur lors du chargement.')),
            data: (allRecipes) {
              final favRecipes = allRecipes
                  .where((r) => ids.contains(r.id))
                  .toList();

              if (favRecipes.isEmpty) {
                return const Center(child: AppLoading());
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
                itemCount: favRecipes.length,
                itemBuilder: (_, i) => RecipeCard(recipe: favRecipes[i]),
              );
            },
          );
        },
      ),
    );
  }
}
