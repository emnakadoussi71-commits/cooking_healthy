import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../domain/advice.dart';
import '../domain/diet_plan.dart';
import '../../../core/constants/firestore_paths.dart';

class NutritionistRepository {
  final FirebaseFirestore _db;

  NutritionistRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Stream<List<Advice>> watchAdvice() {
    return _db
        .collection(FirestorePaths.advice)
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Advice.fromMap(d.id, d.data())).toList());
  }

  Future<void> createAdvice(Advice advice) async {
    final id = const Uuid().v4();
    await _db.doc('${FirestorePaths.advice}/$id').set(advice.toMap());
  }

  Future<void> deleteAdvice(String id) async {
    await _db.doc('${FirestorePaths.advice}/$id').delete();
  }

  Stream<List<DietPlan>> watchDietPlans({String? dietType}) {
    Query<Map<String, dynamic>> query =
        _db.collection(FirestorePaths.dietPlans);

    if (dietType != null) {
      query = query.where('targetDiet', isEqualTo: dietType);
    }

    return query.snapshots().map(
          (s) => s.docs.map((d) => DietPlan.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> createDietPlan(DietPlan plan) async {
    final id = const Uuid().v4();
    await _db.doc('${FirestorePaths.dietPlans}/$id').set(plan.toMap());
  }

  Future<void> deleteDietPlan(String id) async {
    await _db.doc('${FirestorePaths.dietPlans}/$id').delete();
  }

  Future<void> validateRecipe(String recipeId, String nutritionistId) async {
    await _db.doc('${FirestorePaths.recipes}/$recipeId').update({
      'isValidated': true,
      'validatorId': nutritionistId,
    });
  }
}
