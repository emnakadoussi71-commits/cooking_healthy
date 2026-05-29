import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loading.dart';
import '../providers/nutritionist_provider.dart';
import '../../domain/diet_plan.dart';

class DietPlansScreen extends ConsumerWidget {
  const DietPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(dietPlansProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Plans alimentaires')),
      body: plansAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) =>
            const Center(child: Text('Erreur lors du chargement.')),
        data: (plans) {
          if (plans.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_month_outlined,
                      size: 72, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('Aucun plan alimentaire disponible.',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plans.length,
            itemBuilder: (_, i) => _DietPlanCard(plan: plans[i]),
          );
        },
      ),
    );
  }
}

class _DietPlanCard extends StatelessWidget {
  final DietPlan plan;

  const _DietPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ExpansionTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.calendar_month,
              color: AppColors.primary),
        ),
        title: Text(plan.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(plan.targetDiet,
            style: const TextStyle(color: AppColors.textSecondary)),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (plan.description.isNotEmpty) ...[
                  Text(plan.description,
                      style: const TextStyle(height: 1.5)),
                  const SizedBox(height: 12),
                ],
                const Text('Programme de la semaine',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...plan.weeklySchedule.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 70,
                          child: Text(
                            _capitalize(e.key),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary),
                          ),
                        ),
                        Expanded(
                          child: Text(e.value.isEmpty
                              ? 'Repos / libre'
                              : '${e.value.length} recette(s)'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
