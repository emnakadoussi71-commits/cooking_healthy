import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../recipes/domain/recipe.dart';
import '../../../core/constants/firestore_paths.dart';

class RecommendationsRepository {
  final FirebaseFirestore _db;

  RecommendationsRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<List<Recipe>> getRecommendations(String uid) async {
    final userDoc = await _db.doc(FirestorePaths.user(uid)).get();
    if (!userDoc.exists) return [];

    final data = userDoc.data()!;
    final profile = data['profile'] as Map<String, dynamic>?;
    final dietType = profile?['dietType'] as String?;
    final dailyTarget = (data['dailyCalorieTarget'] as num?)?.toInt() ?? 2000;

    // Fetch recipes logged today to exclude them
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final logDoc =
        await _db.doc(FirestorePaths.nutritionEntry(uid, today)).get();
    final loggedIds = <String>{};
    if (logDoc.exists) {
      final meals = logDoc.data()?['meals'] as List<dynamic>? ?? [];
      for (final m in meals) {
        loggedIds.add((m as Map<String, dynamic>)['recipeId'] as String? ?? '');
      }
    }

    Query<Map<String, dynamic>> query = _db
        .collection(FirestorePaths.recipes)
        .where('status', isEqualTo: 'published');

    if (dietType != null && dietType != 'standard') {
      query = query.where('dietTags', arrayContains: dietType);
    }

    final snapshot = await query.limit(20).get();
    final perMeal = dailyTarget ~/ 3;

    return snapshot.docs
        .map((d) => Recipe.fromMap(d.id, d.data()))
        .where((r) => !loggedIds.contains(r.id))
        .where((r) =>
            r.calories >= perMeal - 200 && r.calories <= perMeal + 200)
        .take(5)
        .toList();
  }
}
