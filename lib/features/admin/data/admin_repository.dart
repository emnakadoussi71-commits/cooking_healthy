import 'package:cloud_firestore/cloud_firestore.dart';
import '../../auth/domain/app_user.dart';
import '../../../core/constants/firestore_paths.dart';

class AdminRepository {
  final FirebaseFirestore _db;

  AdminRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Stream<List<AppUser>> watchAllUsers() {
    return _db.collection(FirestorePaths.users).snapshots().map(
          (s) => s.docs
              .map((d) => AppUser.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<void> updateUserRole(String uid, String role) async {
    await _db.doc(FirestorePaths.user(uid)).update({'role': role});
  }
}
