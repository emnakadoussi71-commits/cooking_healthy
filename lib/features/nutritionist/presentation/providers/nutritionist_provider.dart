import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/nutritionist_repository.dart';
import '../../domain/advice.dart';
import '../../domain/diet_plan.dart';

final nutritionistRepositoryProvider = Provider<NutritionistRepository>(
  (_) => NutritionistRepository(),
);

final adviceProvider = StreamProvider<List<Advice>>((ref) {
  return ref.watch(nutritionistRepositoryProvider).watchAdvice();
});

final dietPlansProvider = StreamProvider<List<DietPlan>>((ref) {
  return ref.watch(nutritionistRepositoryProvider).watchDietPlans();
});

final dietTypeFilterProvider = StateProvider<String?>((_) => null);

final filteredDietPlansProvider = Provider<AsyncValue<List<DietPlan>>>((ref) {
  final dietType = ref.watch(dietTypeFilterProvider);
  return ref
      .watch(nutritionistRepositoryProvider)
      .watchDietPlans(dietType: dietType)
      .map((plans) => plans) as AsyncValue<List<DietPlan>>;
});
