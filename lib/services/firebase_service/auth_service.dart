import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/constants/app_constants.dart';

class AuthService {
  AuthService(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    await _firestore.collection(AppConstants.usersCollection).doc(uid).set({
      'name': name,
      'email': email,
      'profilePhoto': null,
      'age': 0,
      'height': 0,
      'weight': 0,
      'fitnessGoal': 'Maintain weight',
      'gender': 'Male',
      'activityLevel': 'Moderate',
      'dietPreference': 'Balanced',
      'createdAt': Timestamp.now(),
      'onboardingCompleted': false,
    }, SetOptions(merge: true));
  }

  Future<void> signInWithGoogle() async {
    final google = GoogleSignIn();
    final account = await google.signIn();
    if (account == null) return;
    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) return;

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set({
          'name': user.displayName ?? 'User',
          'email': user.email ?? '',
          'profilePhoto': user.photoURL,
          'age': 0,
          'height': 0,
          'weight': 0,
          'fitnessGoal': 'Maintain weight',
          'gender': 'Male',
          'activityLevel': 'Moderate',
          'dietPreference': 'Balanced',
          'createdAt': Timestamp.now(),
          'onboardingCompleted': false,
        }, SetOptions(merge: true));
  }

  Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => _auth.signOut();
}
