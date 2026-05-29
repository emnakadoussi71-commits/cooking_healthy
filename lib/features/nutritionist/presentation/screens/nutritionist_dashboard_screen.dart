import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../recipes/presentation/providers/recipes_provider.dart';
import '../providers/nutritionist_provider.dart';

class NutritionistDashboardScreen extends ConsumerWidget {
  const NutritionistDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adviceAsync = ref.watch(adviceProvider);
    final plansAsync = ref.watch(dietPlansProvider);
    final recipesAsync = ref.watch(allRecipesAdminProvider);

    final totalAdvice = adviceAsync.valueOrNull?.length ?? 0;
    final totalPlans = plansAsync.valueOrNull?.length ?? 0;
    final pendingValidation = recipesAsync.valueOrNull
            ?.where((r) => !r.isValidated && r.status == 'published')
            .length ??
        0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Nutritionniste'),
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
              'Ma Contribution',
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
                  label: 'Conseils publiés',
                  value: totalAdvice.toString(),
                  icon: Icons.article,
                  color: AppColors.primary,
                ),
                _StatCard(
                  label: 'Plans créés',
                  value: totalPlans.toString(),
                  icon: Icons.calendar_today,
                  color: AppColors.secondary,
                ),
                _StatCard(
                  label: 'À valider',
                  value: pendingValidation.toString(),
                  icon: Icons.pending_actions,
                  color: AppColors.error,
                ),
                _StatCard(
                  label: 'Certifié',
                  value: 'Oui',
                  icon: Icons.verified_user,
                  color: AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'Outils Expert',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            _ActionTile(
              icon: Icons.edit_note,
              label: 'Rédiger un conseil',
              subtitle: 'Partager vos connaissances nutritionnelles',
              onTap: () => context.go('/nutritionniste/conseil/creer'),
            ),
            _ActionTile(
              icon: Icons.playlist_add_check,
              label: 'Valider des recettes',
              subtitle: '$pendingValidation recette(s) en attente de validation',
              onTap: () => context.go('/home/recettes'),
            ),
            _ActionTile(
              icon: Icons.calendar_month,
              label: 'Créer un plan alimentaire',
              subtitle: 'Établir un régime pour une pathologie',
              onTap: () => context.go('/nutritionniste/plan/creer'),
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
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11),
            ),
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
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
