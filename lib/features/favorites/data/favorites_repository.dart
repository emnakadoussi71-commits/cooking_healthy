import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firestore_paths.dart';

class FavoritesRepository {
  final FirebaseFirestore _db;

  FavoritesRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Stream<List<String>> watchFavoriteIds(String uid) {
    return _db
        .collection(FirestorePaths.favorites(uid))
        .snapshots()
        .map((s) => s.docs.map((d) => d.id).toList());
  }

  Future<void> addFavorite(String uid, String recipeId) async {
    await _db.doc(FirestorePaths.favoriteItem(uid, recipeId)).set({
      'savedAt': DateTime.now(),
    });
  }

  Future<void> removeFavorite(String uid, String recipeId) async {
    await _db.doc(FirestorePaths.favoriteItem(uid, recipeId)).delete();
  }
}
