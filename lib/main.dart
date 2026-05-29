import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'firebase_options.dart';

/// Creates admin@admin.com once on first launch if it doesn't exist.
Future<void> _seedAdmin() async {
  const email = 'admin@admin.com';
  const password = 'admin@admin.com';
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  try {
    UserCredential result;
    try {
      result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user!.updateDisplayName('Administrateur');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        result = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        return;
      }
    }

    final uid = result.user!.uid;
    await db.doc('users/$uid').set({
      'name': 'Administrateur',
      'email': email,
      'photoUrl': null,
      'role': 'admin',
      'dailyCalorieTarget': 2000,
    }, SetOptions(merge: true));

    await auth.signOut();
  } catch (_) {
    // Seeder is best-effort; never crash the app
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  await _seedAdmin();
  runApp(const ProviderScope(child: App()));
}
