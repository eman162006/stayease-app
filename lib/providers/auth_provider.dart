import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? _user;
  bool _loading = false;

  User? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((u) {
      _user = u;
      notifyListeners();
    });
  }

  // =========================
  // ✅ SIGN UP WITH NAME
  // =========================
  Future<void> signupWithDetails(
      String email, String password, String fullName) async {
    try {
      _loading = true;
      notifyListeners();

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // ✅ Save display name inside Firebase Auth
      await cred.user!.updateDisplayName(fullName.trim());
      await cred.user!.reload();

      // ✅ Save user document in Firestore
      await _db.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'fullName': fullName.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _user = _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Signup failed");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // =========================
  // ✅ LOGIN
  // =========================
  Future<void> login(String email, String password) async {
    try {
      _loading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      _user = _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Login failed");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // =========================
  // ✅ LOGOUT
  // =========================
  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
  Future<void> resetPassword(String email) async {
  try {
    await _auth.sendPasswordResetEmail(email: email.trim());
  } on FirebaseAuthException catch (e) {
    throw Exception(e.message ?? "Reset failed");
  }
}
}