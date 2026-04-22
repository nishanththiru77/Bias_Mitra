import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '419245381792-vmv6c2lk8v75if3q9s8avkfptukfhmdd.apps.googleusercontent.com'
        : null,
  );

  User? get currentUser => _auth.currentUser;
  String? get currentUserName =>
      _auth.currentUser?.displayName ?? _auth.currentUser?.email;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email/Password Sign Up
  Future<UserCredential?> signUpWithEmail(String email, String password,
      {String? name}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (name != null && name.isNotEmpty) {
      await credential.user?.updateDisplayName(name);
    }

    notifyListeners();
    return credential;
  }

  // Email/Password Sign In (alias for loginWithEmail)
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return loginWithEmail(email, password);
  }

  // Email Login
  Future<UserCredential?> loginWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    notifyListeners();
    return credential;
  }

  // Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    notifyListeners();
    return userCredential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    notifyListeners();
  }
}
