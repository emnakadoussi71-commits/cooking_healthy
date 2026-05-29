import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/nutrition_repository.dart';
import '../../domain/nutrition_log.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final nutritionRepositoryProvider = Provider<NutritionRepository>(
  (_) => NutritionRepository(),
);

final todayLogProvider = StreamProvider<NutritionLog?>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  return ref.watch(nutritionRepositoryProvider).watchLog(uid, today);
});

final weeklyLogsProvider = FutureProvider<List<NutritionLog>>((ref) async {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return [];
  return ref.watch(nutritionRepositoryProvider).getWeeklyLogs(uid);
});
