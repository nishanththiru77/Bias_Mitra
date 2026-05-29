import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import '../models/government_profile.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '419245381792-vmv6c2lk8v75if3q9s8avkfptukfhmdd.apps.googleusercontent.com'
        : null,
  );

  GovernmentProfile? _currentProfile;

  // Constructor listening to auth states to fetch user profiles dynamically
  AuthService() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await fetchUserProfile();
      } else {
        _currentProfile = null;
        notifyListeners();
      }
    });
  }

  // 🔹 Current profile getter
  GovernmentProfile? get currentProfile => _currentProfile;

  // 🔹 Current user
  User? get currentUser => _auth.currentUser;

  String? get currentUserName =>
      _currentProfile?.name ??
      _auth.currentUser?.displayName ??
      _auth.currentUser?.email;

  // 🔹 Auth state stream (VERY IMPORTANT)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==============================
  // 📁 FIRESTORE PROFILE ACTIONS
  // ==============================

  /// Load user profile details from Firestore
  Future<void> fetchUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _db.collection('users').doc(user.uid).get().timeout(
            const Duration(seconds: 8),
            onTimeout: () => throw TimeoutException('Firestore read timed out'),
          );
      if (doc.exists && doc.data() != null) {
        _currentProfile = GovernmentProfile.fromMap(
          doc.data()!,
          user.uid,
          user.email ?? '',
          user.displayName ?? 'Officer',
        );
      } else {
        // Create initial incomplete profile
        _currentProfile = GovernmentProfile.initial(
          user.uid,
          user.email ?? '',
          user.displayName ?? 'Officer',
        );
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      // Always create initial profile on error to prevent infinite loading
      if (_currentProfile == null) {
        _currentProfile = GovernmentProfile.initial(
          user.uid,
          user.email ?? '',
          user.displayName ?? 'Officer',
        );
      }
    } finally {
      notifyListeners();
    }
  }

  /// Update and save the profile in Firestore and state
  Future<void> saveUserProfile(GovernmentProfile profile) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db
          .collection('users')
          .doc(user.uid)
          .set(profile.toMap(), SetOptions(merge: true));
      _currentProfile = profile;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      rethrow;
    }
  }

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

    // Initialize profile in Firestore instantly
    if (credential.user != null) {
      final initialProfile = GovernmentProfile.initial(
        credential.user!.uid,
        email,
        name ?? 'Officer',
      );
      await saveUserProfile(initialProfile);
    }

    return credential;
  }

  // Sign In
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await fetchUserProfile();
    return cred;
  }

  // ==============================
  // 🔐 GOOGLE SIGN-IN
  // ==============================

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();
    final cred = await FirebaseAuth.instance.signInWithPopup(googleProvider);

    // Automatically load/create profile on Google login
    if (cred.user != null) {
      await fetchUserProfile();
    }
    return cred;
  }

  // ==============================
  // 🔓 LOGOUT
  // ==============================
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _currentProfile = null;
    notifyListeners();
  }
}
