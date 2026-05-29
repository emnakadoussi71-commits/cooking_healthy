import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/nutrition_provider.dart';
import '../../domain/nutrition_log.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayLogAsync = ref.watch(todayLogProvider);
    final weeklyAsync = ref.watch(weeklyLogsProvider);
    final appUserAsync = ref.watch(currentAppUserProvider);
    final dailyTarget = appUserAsync.valueOrNull?.dailyCalorieTarget ?? 2000;

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/home/nutrition/ajouter'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajouter un repas',
            style: TextStyle(color: Colors.white)),
      ),
      body: todayLogAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => const Center(child: Text('Erreur de chargement.')),
        data: (log) {
          final today =
              log ?? NutritionLog.empty(DateFormat('yyyy-MM-dd').format(DateTime.now()));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CalorieProgressCard(
                    consumed: today.totalCalories,
                    target: dailyTarget.toDouble()),
                const SizedBox(height: 16),
                _MacrosRow(log: today),
                const SizedBox(height: 24),
                weeklyAsync.when(
                  loading: () => const SizedBox(
                      height: 200, child: AppLoading()),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (logs) => _WeeklyChart(logs: logs),
                ),
                const SizedBox(height: 24),
                const Text('Repas d\'aujourd\'hui',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (today.meals.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Text('Aucun repas enregistré aujourd\'hui.',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  )
                else
                  ...today.meals.map((m) => _MealTile(
                        title: m.recipeTitle,
                        calories: m.calories,
                        servings: m.servings,
                        time: m.consumedAt,
                      )),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CalorieProgressCard extends StatelessWidget {
  final double consumed;
  final double target;

  const _CalorieProgressCard(
      {required this.consumed, required this.target});

  @override
  Widget build(BuildContext context) {
    final remaining = (target - consumed).clamp(0.0, target);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Calories du jour',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  startDegreeOffset: -90,
                  sections: [
                    PieChartSectionData(
                      value: consumed,
                      color: AppColors.secondary,
                      radius: 28,
                      title: '',
                    ),
                    PieChartSectionData(
                      value: remaining,
                      color: Colors.grey.shade200,
                      radius: 24,
                      title: '',
                    ),
                  ],
                  centerSpaceRadius: 52,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${consumed.toInt()} / ${target.toInt()} kcal',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${remaining.toInt()} kcal restantes',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacrosRow extends StatelessWidget {
  final NutritionLog log;

  const _MacrosRow({required this.log});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MacroCard(
            label: 'Protéines',
            value: log.totalProtein,
            color: AppColors.protein),
        _MacroCard(
            label: 'Glucides',
            value: log.totalCarbs,
            color: AppColors.carbs),
        _MacroCard(
            label: 'Lipides', value: log.totalFat, color: AppColors.fat),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MacroCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Text('${value.toStringAsFixed(1)}g',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<NutritionLog> logs;

  const _WeeklyChart({required this.logs});

  @override
  Widget build(BuildContext context) {
    final dayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final maxCal = logs.isEmpty
        ? 2000.0
        : (logs.map((l) => l.totalCalories).reduce((a, b) => a > b ? a : b))
            .clamp(100.0, double.infinity);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cette semaine',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: BarChart(
                BarChartData(
                  maxY: maxCal * 1.2,
                  barGroups: logs.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.totalCalories,
                          color: AppColors.primary,
                          width: 18,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxCal * 1.2,
                            color: Colors.grey.shade100,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) => Text(
                          dayLabels[v.toInt() % 7],
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  final String title;
  final double calories;
  final int servings;
  final DateTime time;

  const _MealTile({
    required this.title,
    required this.calories,
    required this.servings,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.restaurant,
              color: AppColors.primary, size: 22),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            '$servings portion(s) · ${DateFormat('HH:mm').format(time)}'),
        trailing: Text(
          '${calories.toInt()} kcal',
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.secondary),
        ),
      ),
    );
  }
}
