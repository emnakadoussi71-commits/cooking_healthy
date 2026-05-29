import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/recipes_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../nutritionist/presentation/providers/nutritionist_provider.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(recipeDetailProvider(recipeId));
    final isFav = ref.watch(isFavoriteProvider(recipeId));

    return Scaffold(
      body: recipeAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (recipe) {
          if (recipe == null) {
            return const AppErrorWidget(message: 'Recette introuvable.');
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: recipe.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: recipe.imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Container(color: AppColors.primary),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_outline,
                      color: isFav ? Colors.red : Colors.white,
                    ),
                    onPressed: () => _toggleFavorite(ref),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              recipe.title,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (recipe.isValidated)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified,
                                      color: AppColors.success, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Validé',
                                    style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                              icon: Icons.local_fire_department,
                              label: '${recipe.calories} kcal',
                              color: AppColors.secondary),
                          _InfoChip(
                              icon: Icons.access_time,
                              label: '${recipe.prepTime} min',
                              color: AppColors.primary),
                          _InfoChip(
                              icon: Icons.people_outline,
                              label: '${recipe.servings} pers.',
                              color: Colors.blueGrey),
                          ...recipe.dietTags.map(
                            (t) => Chip(
                              label: Text(t,
                                  style: const TextStyle(fontSize: 12)),
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.1),
                              side: BorderSide.none,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        recipe.description,
                        style: const TextStyle(
                            color: AppColors.textSecondary, height: 1.5),
                      ),
                      if (!recipe.isValidated &&
                          (ref.watch(currentAppUserProvider).valueOrNull?.isNutritionist == true ||
                              ref.watch(currentAppUserProvider).valueOrNull?.isAdmin == true)) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _validateRecipe(context, ref),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Valider les valeurs nutritionnelles'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      const _SectionTitle('Valeurs nutritionnelles'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _MacroTile(
                              label: 'Protéines',
                              value: recipe.nutritionValues.protein,
                              color: AppColors.protein),
                          _MacroTile(
                              label: 'Glucides',
                              value: recipe.nutritionValues.carbs,
                              color: AppColors.carbs),
                          _MacroTile(
                              label: 'Lipides',
                              value: recipe.nutritionValues.fat,
                              color: AppColors.fat),
                          _MacroTile(
                              label: 'Fibres',
                              value: recipe.nutritionValues.fiber,
                              color: AppColors.fiber),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const _SectionTitle('Ingrédients'),
                      const SizedBox(height: 12),
                      ...recipe.ingredients.map(
                        (ing) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${ing.name} — ${ing.quantity} ${ing.unit}',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _SectionTitle('Préparation'),
                      const SizedBox(height: 12),
                      ...recipe.steps.asMap().entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${e.key + 1}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      e.value,
                                      style: const TextStyle(
                                          fontSize: 15, height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggleFavorite(WidgetRef ref) {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    final isFav = ref.read(isFavoriteProvider(recipeId));
    final repo = ref.read(favoritesRepositoryProvider);
    if (isFav) {
      repo.removeFavorite(uid, recipeId);
    } else {
      repo.addFavorite(uid, recipeId);
    }
  }

  Future<void> _validateRecipe(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentAppUserProvider).valueOrNull;
    if (user == null) return;

    try {
      await ref
          .read(nutritionistRepositoryProvider)
          .validateRecipe(recipeId, user.uid);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recette validée avec succès !')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MacroTile(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text('${value.toStringAsFixed(1)}g',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 14)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary),
    );
  }
}
