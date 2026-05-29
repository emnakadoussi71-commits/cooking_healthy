import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../recipes/presentation/providers/recipes_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);
    final recipesAsync = ref.watch(allRecipesAdminProvider);

    final totalUsers =
        usersAsync.valueOrNull?.length ?? 0;
    final totalRecipes =
        recipesAsync.valueOrNull?.length ?? 0;
    final publishedCount = recipesAsync.valueOrNull
            ?.where((r) => r.status == 'published')
            .length ??
        0;
    final draftCount = totalRecipes - publishedCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home/accueil'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Se déconnecter',
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vue d\'ensemble',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _StatCard(
                    label: 'Utilisateurs',
                    value: totalUsers.toString(),
                    icon: Icons.people,
                    color: AppColors.primary),
                _StatCard(
                    label: 'Recettes',
                    value: totalRecipes.toString(),
                    icon: Icons.restaurant_menu,
                    color: AppColors.secondary),
                _StatCard(
                    label: 'Publiées',
                    value: publishedCount.toString(),
                    icon: Icons.check_circle,
                    color: AppColors.success),
                _StatCard(
                    label: 'Brouillons',
                    value: draftCount.toString(),
                    icon: Icons.drafts,
                    color: Colors.blueGrey),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Actions rapides',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.restaurant_menu,
              label: 'Gérer les recettes',
              subtitle: '$totalRecipes recette(s) au total',
              onTap: () => context.go('/admin/recettes'),
            ),
            _ActionTile(
              icon: Icons.add_circle_outline,
              label: 'Ajouter une recette',
              subtitle: 'Créer une nouvelle recette',
              onTap: () => context.go('/admin/recettes/creer'),
            ),
            _ActionTile(
              icon: Icons.people_outline,
              label: 'Gérer les utilisateurs',
              subtitle: '$totalUsers utilisateur(s) inscrit(s)',
              onTap: () => context.go('/admin/utilisateurs'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color),
            ),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
