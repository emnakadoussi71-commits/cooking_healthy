import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../recipes/presentation/providers/recipes_provider.dart';

class ManageRecipesScreen extends ConsumerWidget {
  const ManageRecipesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(allRecipesAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des recettes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => context.go('/admin/recettes/creer'),
          ),
        ],
      ),
      body: recipesAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) =>
            const Center(child: Text('Erreur lors du chargement.')),
        data: (recipes) {
          if (recipes.isEmpty) {
            return const Center(
                child: Text('Aucune recette pour le moment.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: recipes.length,
            itemBuilder: (_, i) {
              final r = recipes[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: r.status == 'published'
                          ? AppColors.success.withValues(alpha: 0.1)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      r.status == 'published'
                          ? Icons.check_circle
                          : Icons.drafts,
                      color: r.status == 'published'
                          ? AppColors.success
                          : Colors.grey,
                    ),
                  ),
                  title: Text(r.title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${r.calories} kcal · ${r.status}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) =>
                        _handleAction(context, ref, r.id, r.status, action),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'toggle',
                        child: Text(r.status == 'published'
                            ? 'Dépublier'
                            : 'Publier'),
                      ),
                      const PopupMenuItem(
                          value: 'edit', child: Text('Modifier')),
                      const PopupMenuItem(
                          value: 'delete',
                          child: Text('Supprimer',
                              style: TextStyle(color: AppColors.error))),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String id,
      String status, String action) async {
    final repo = ref.read(recipeRepositoryProvider);
    switch (action) {
      case 'toggle':
        await repo.togglePublish(id, status != 'published');
      case 'edit':
        if (context.mounted) context.go('/admin/recettes/$id/modifier');
      case 'delete':
        if (context.mounted) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Confirmer la suppression'),
              content: const Text(
                  'Cette recette sera définitivement supprimée.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Annuler')),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error),
                  child: const Text('Supprimer'),
                ),
              ],
            ),
          );
          if (confirmed == true) await repo.deleteRecipe(id);
        }
    }
  }
}
