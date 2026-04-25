import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier
 {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '419245381792-vmv6c2lk8v75if3q9s8avkfptukfhmdd.apps.googleusercontent.com'
        : null,
  );

  // 🔹 Current user
  User? get currentUser => _auth.currentUser;

  String? get currentUserName =>
      _auth.currentUser?.displayName ?? _auth.currentUser?.email;

  // 🔹 Auth state stream (VERY IMPORTANT)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==============================
  // 🔐 EMAIL AUTH
  // ==============================

  // Sign Up
  Future<UserCredential?> signUpWithEmail(
    String email,
    String password, {
    String? name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (name != null && name.isNotEmpty) {
      await credential.user?.updateDisplayName(name);
    }

    return credential;
  }

  // Sign In
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ==============================
  // 🔐 GOOGLE SIGN-IN
  // ==============================

  Future<UserCredential?> signInWithGoogle() async {
  final GoogleAuthProvider googleProvider = GoogleAuthProvider();
  return await FirebaseAuth.instance.signInWithPopup(googleProvider);
}
  // ==============================
  // 🔓 LOGOUT (FIXED)
  // ==============================
Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
}
}