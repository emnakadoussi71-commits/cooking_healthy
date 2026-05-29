import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../domain/recipe.dart';
import '../../../core/constants/firestore_paths.dart';

class RecipeRepository {
  final FirebaseFirestore _db;

  RecipeRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Stream<List<Recipe>> watchPublishedRecipes({String? dietTag}) {
    Query<Map<String, dynamic>> query = _db
        .collection(FirestorePaths.recipes)
        .where('status', isEqualTo: 'published');

    if (dietTag != null) {
      query = query.where('dietTags', arrayContains: dietTag);
    }

    return query.snapshots().map(
          (s) => s.docs.map((d) => Recipe.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<List<Recipe>> watchAllRecipes() {
    return _db.collection(FirestorePaths.recipes).snapshots().map(
          (s) => s.docs.map((d) => Recipe.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<Recipe?> getRecipe(String id) async {
    final doc = await _db.doc(FirestorePaths.recipe(id)).get();
    if (!doc.exists) return null;
    return Recipe.fromMap(doc.id, doc.data()!);
  }

  Future<String> createRecipe(Recipe recipe) async {
    final id = const Uuid().v4();
    await _db.doc(FirestorePaths.recipe(id)).set(recipe.toMap());
    return id;
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _db.doc(FirestorePaths.recipe(recipe.id)).update(recipe.toMap());
  }

  Future<void> deleteRecipe(String id) async {
    await _db.doc(FirestorePaths.recipe(id)).delete();
  }

  Future<void> togglePublish(String id, bool publish) async {
    await _db.doc(FirestorePaths.recipe(id)).update({
      'status': publish ? 'published' : 'draft',
    });
  }
}
