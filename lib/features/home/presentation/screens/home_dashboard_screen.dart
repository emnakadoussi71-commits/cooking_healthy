import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../nutrition/presentation/providers/nutrition_provider.dart';
import '../../../recommendations/presentation/providers/recommendations_provider.dart';
import '../../../recipes/presentation/widgets/recipe_card.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUserAsync = ref.watch(currentAppUserProvider);
    final todayLogAsync = ref.watch(todayLogProvider);
    final recsAsync = ref.watch(recommendationsProvider);

    final appUser = appUserAsync.valueOrNull;
    final todayLog = todayLogAsync.valueOrNull;
    final dailyTarget = (appUser?.dailyCalorieTarget ?? 2000).toDouble();

    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Bonjour' : 'Bonsoir';
    final firstName = appUser?.name.split(' ').first ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(todayLogProvider);
          ref.invalidate(recommendationsProvider);
          ref.invalidate(currentAppUserProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 100,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting${firstName.isNotEmpty ? ', $firstName' : ''} 👋',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text(
                      DateFormat('EEEE d MMMM yyyy').format(DateTime.now()),
                      style: const TextStyle(
                          fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: Colors.white, size: 26),
                  tooltip: 'Ajouter un repas',
                  onPressed: () => context.go('/home/nutrition/ajouter'),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  tooltip: 'Se déconnecter',
                  onPressed: () async {
                    await ref.read(authRepositoryProvider).signOut();
                  },
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Calorie summary card ──────────────────────────────
                    _CalorieSummaryCard(
                      consumed: todayLog?.totalCalories ?? 0,
                      target: dailyTarget,
                      protein: todayLog?.totalProtein ?? 0,
                      carbs: todayLog?.totalCarbs ?? 0,
                      fat: todayLog?.totalFat ?? 0,
                    ),
                    const SizedBox(height: 16),

                    // ── Quick actions ─────────────────────────────────────
                    _QuickActionsRow(),
                    const SizedBox(height: 20),

                    // ── Today's meals ─────────────────────────────────────
                    if (todayLog != null && todayLog.meals.isNotEmpty) ...[
                      _SectionHeader(
                        title: "Repas d'aujourd'hui",
                        actionLabel: 'Voir tout',
                        onAction: () => context.go('/home/nutrition'),
                      ),
                      const SizedBox(height: 8),
                      ...todayLog.meals.take(3).map(
                            (m) => _MealRow(
                              title: m.recipeTitle,
                              calories: m.calories,
                              time: m.consumedAt,
                            ),
                          ),
                      const SizedBox(height: 20),
                    ],

                    // ── Suggestions ───────────────────────────────────────
                    _SectionHeader(
                      title: 'Suggérées pour vous',
                      actionLabel: 'Tout voir',
                      onAction: () => context.go('/home/recettes'),
                    ),
                    const SizedBox(height: 10),
                    recsAsync.when(
                      loading: () =>
                          const SizedBox(height: 200, child: AppLoading()),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (recipes) {
                        if (recipes.isEmpty) {
                          return _EmptyHint(
                            icon: Icons.lightbulb_outline,
                            text:
                                'Complétez votre profil pour obtenir des recettes personnalisées.',
                          );
                        }
                        return SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: recipes.length,
                            itemBuilder: (_, i) => SizedBox(
                              width: 158,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: RecipeCard(recipe: recipes[i]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Calorie Summary ──────────────────────────────────────────────────────────

class _CalorieSummaryCard extends StatelessWidget {
  final double consumed;
  final double target;
  final double protein;
  final double carbs;
  final double fat;

  const _CalorieSummaryCard({
    required this.consumed,
    required this.target,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (target - consumed).clamp(0.0, target);
    final pct = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Pie chart
                SizedBox(
                  width: 110,
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          startDegreeOffset: -90,
                          sectionsSpace: 0,
                          sections: [
                            PieChartSectionData(
                              value: consumed > 0 ? consumed : 0.001,
                              color: AppColors.secondary,
                              radius: 22,
                              title: '',
                            ),
                            PieChartSectionData(
                              value: remaining > 0 ? remaining : 0.001,
                              color: Colors.grey.shade200,
                              radius: 18,
                              title: '',
                            ),
                          ],
                          centerSpaceRadius: 38,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${consumed.toInt()}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary),
                          ),
                          const Text('kcal',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Stats column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calories du jour',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      _StatLine(
                        label: 'Consommées',
                        value: '${consumed.toInt()} kcal',
                        color: AppColors.secondary,
                      ),
                      _StatLine(
                        label: 'Objectif',
                        value: '${target.toInt()} kcal',
                        color: AppColors.primary,
                      ),
                      _StatLine(
                        label: 'Restantes',
                        value: '${remaining.toInt()} kcal',
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(
                            pct >= 1.0 ? AppColors.error : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),
            // Macros row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MacroChip(label: 'Protéines', value: protein, color: AppColors.protein),
                _MacroChip(label: 'Glucides', value: carbs, color: AppColors.carbs),
                _MacroChip(label: 'Lipides', value: fat, color: AppColors.fat),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatLine(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          Text(value,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _MacroChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${value.toStringAsFixed(1)}g',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ── Quick actions ────────────────────────────────────────────────────────────

class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickAction(
          icon: Icons.add_circle,
          label: 'Ajouter\nun repas',
          color: AppColors.primary,
          onTap: () => context.go('/home/nutrition/ajouter'),
        ),
        const SizedBox(width: 10),
        _QuickAction(
          icon: Icons.bar_chart,
          label: 'Mon\nsuivi',
          color: AppColors.secondary,
          onTap: () => context.go('/home/nutrition'),
        ),
        const SizedBox(width: 10),
        _QuickAction(
          icon: Icons.search,
          label: 'Chercher\nune recette',
          color: Colors.blueGrey,
          onTap: () => context.go('/home/recettes'),
        ),
        const SizedBox(width: 10),
        _QuickAction(
          icon: Icons.health_and_safety_outlined,
          label: 'Conseils\nnutrition',
          color: AppColors.success,
          onTap: () => context.go('/home/conseils'),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w600,
                      height: 1.3)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  const _SectionHeader(
      {required this.title,
      required this.actionLabel,
      required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0)),
          child: Text(actionLabel,
              style: const TextStyle(
                  color: AppColors.primary, fontSize: 13)),
        ),
      ],
    );
  }
}

// ── Meal row ─────────────────────────────────────────────────────────────────

class _MealRow extends StatelessWidget {
  final String title;
  final double calories;
  final DateTime time;
  const _MealRow(
      {required this.title, required this.calories, required this.time});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.restaurant,
              size: 18, color: AppColors.primary),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        subtitle: Text(DateFormat('HH:mm').format(time),
            style: const TextStyle(fontSize: 11)),
        trailing: Text('${calories.toInt()} kcal',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
                fontSize: 13)),
      ),
    );
  }
}

// ── Empty hint ───────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyHint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
