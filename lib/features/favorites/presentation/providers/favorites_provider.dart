import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/favorites_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (_) => FavoritesRepository(),
);

final favoriteIdsProvider = StreamProvider<List<String>>((ref) {
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(favoritesRepositoryProvider).watchFavoriteIds(uid);
});

final isFavoriteProvider = Provider.family<bool, String>((ref, recipeId) {
  return ref.watch(favoriteIdsProvider).valueOrNull?.contains(recipeId) ??
      false;
});
