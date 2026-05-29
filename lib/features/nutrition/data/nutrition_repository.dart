import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../domain/meal_entry.dart';
import '../domain/nutrition_log.dart';
import '../../../core/constants/firestore_paths.dart';

class NutritionRepository {
  final FirebaseFirestore _db;

  NutritionRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Stream<NutritionLog?> watchLog(String uid, String date) {
    return _db.doc(FirestorePaths.nutritionEntry(uid, date)).snapshots().map(
          (doc) => doc.exists
              ? NutritionLog.fromMap(date, doc.data()!)
              : NutritionLog.empty(date),
        );
  }

  Future<void> addMealEntry(String uid, MealEntry entry) async {
    final date = DateFormat('yyyy-MM-dd').format(entry.consumedAt);
    final docRef = _db.doc(FirestorePaths.nutritionEntry(uid, date));

    await _db.runTransaction((tx) async {
      final doc = await tx.get(docRef);
      final meals = doc.exists
          ? (doc.data()?['meals'] as List<dynamic>? ?? [])
              .map((e) => MealEntry.fromMap(e as Map<String, dynamic>))
              .toList()
          : <MealEntry>[];

      meals.add(entry);

      tx.set(
        docRef,
        NutritionLog(
          date: date,
          meals: meals,
          totalCalories: meals.fold(0, (s, m) => s + m.calories),
          totalProtein: meals.fold(0, (s, m) => s + m.protein),
          totalCarbs: meals.fold(0, (s, m) => s + m.carbs),
          totalFat: meals.fold(0, (s, m) => s + m.fat),
        ).toMap(),
      );
    });
  }

  Future<List<NutritionLog>> getWeeklyLogs(String uid) async {
    final today = DateTime.now();
    final logs = <NutritionLog>[];

    for (var i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final date = DateFormat('yyyy-MM-dd').format(day);
      final doc =
          await _db.doc(FirestorePaths.nutritionEntry(uid, date)).get();
      logs.add(
        doc.exists
            ? NutritionLog.fromMap(date, doc.data()!)
            : NutritionLog.empty(date),
      );
    }
    return logs;
  }
}
