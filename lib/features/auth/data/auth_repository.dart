import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/app_user.dart';
import '../../../core/constants/firestore_paths.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> register(
      String name, String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await result.user!.updateDisplayName(name);
    await _db.doc(FirestorePaths.user(result.user!.uid)).set({
      'name': name,
      'email': email,
      'photoUrl': null,
      'role': 'user',
      'dailyCalorieTarget': 2000,
    });
    return result;
  }

  Future<void> signOut() => _auth.signOut();

  Future<AppUser?> getAppUser(String uid) async {
    final doc = await _db.doc(FirestorePaths.user(uid)).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(uid, doc.data()!);
  }

  Future<void> saveUserProfile(String uid, UserProfile profile) async {
    await _db.doc(FirestorePaths.user(uid)).update({
      'profile': profile.toMap(),
    });
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }
}
