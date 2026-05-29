import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/recommendations_repository.dart';
import '../../../recipes/domain/recipe.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final recommendationsRepositoryProvider =
    Provider<RecommendationsRepository>((_) => RecommendationsRepository());

final recommendationsProvider = FutureProvider<List<Recipe>>((ref) async {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return [];
  return ref
      .watch(recommendationsRepositoryProvider)
      .getRecommendations(uid);
});
