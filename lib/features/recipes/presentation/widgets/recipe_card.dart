import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/recipe.dart';

import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class RecipeCard extends ConsumerWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(isFavoriteProvider(recipe.id));

    return GestureDetector(
      onTap: () => context.go('/home/recettes/${recipe.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  recipe.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: recipe.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.restaurant,
                                  color: Colors.grey, size: 40)),
                          errorWidget: (_, _, _) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.restaurant,
                                  color: Colors.grey, size: 40)),
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.restaurant,
                              color: Colors.grey, size: 40)),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(ref),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_outline,
                          color: isFav ? AppColors.error : Colors.grey,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${recipe.calories} kcal',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        '${recipe.prepTime} min',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFavorite(WidgetRef ref) {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    final isFav = ref.read(isFavoriteProvider(recipe.id));
    final repo = ref.read(favoritesRepositoryProvider);
    if (isFav) {
      repo.removeFavorite(uid, recipe.id);
    } else {
      repo.addFavorite(uid, recipe.id);
    }
  }
}
