// ─── Auth Remote Datasource ─────────────────────────────────────────
// Firebase Auth + Firestore user profile management.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> registerWithEmail(
      String name, String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<UserModel> signInAsGuest();
  Future<UserModel?> getCurrentUser();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<void> logout();
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  GoogleSignIn? _googleSignIn;
  final GoogleSignIn? _injectedGoogleSignIn;

  AuthRemoteDatasourceImpl({
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _injectedGoogleSignIn = googleSignIn;

  /// Lazily initializes and returns GoogleSignIn instance
  GoogleSignIn _getGoogleSignIn() {
    _googleSignIn ??= _injectedGoogleSignIn ?? _createGoogleSignIn();
    return _googleSignIn!;
  }

  /// Creates GoogleSignIn instance with proper web configuration
  static GoogleSignIn _createGoogleSignIn() {
    if (kIsWeb) {
      final clientId = AppConfig.googleSignInClientId;
      if (clientId.isEmpty) {
        throw AuthException(
          message:
              'Google Sign-In is not configured for web. Set GOOGLE_SIGNIN_CLIENT_ID '
              'in .env or add the google-signin-client_id meta tag in web/index.html.',
        );
      }
      return GoogleSignIn(clientId: clientId);
    }
    return GoogleSignIn();
  }

  // ── Helpers ──
  DocumentReference _userDoc(String uid) =>
      _firestore.collection(FirestorePaths.users).doc(uid);

  Future<UserModel> _ensureUserDocument(fb.User user, {String? name}) async {
    final doc = await _userDoc(user.uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }

    // Create new user document
    final model = UserModel(
      id: user.uid,
      name: name ?? user.displayName ?? 'Traveler',
      email: user.email ?? '',
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _userDoc(user.uid).set(model.toFirestore());
    return model;
  }

  // ── Email Login ──
  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user == null) {
        throw AuthException(message: 'Login failed — no user returned');
      }
      return _ensureUserDocument(result.user!);
    } on fb.FirebaseAuthException catch (e) {
      AppLogger.error('Login failed', e);
      throw _mapFirebaseAuthError(e);
    }
  }

  // ── Email Register ──
  @override
  Future<UserModel> registerWithEmail(
      String name, String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user == null) {
        throw AuthException(message: 'Registration failed');
      }
      await result.user!.updateDisplayName(name);
      return _ensureUserDocument(result.user!, name: name);
    } on fb.FirebaseAuthException catch (e) {
      AppLogger.error('Registration failed', e);
      throw _mapFirebaseAuthError(e);
    }
  }

  // ── Google Sign In ──
  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final fb.UserCredential result;
      if (kIsWeb) {
        // Firebase popup flow — avoids google_sign_in_web popup/OAuth issues.
        final provider = fb.GoogleAuthProvider();
        result = await _auth.signInWithPopup(provider);
      } else {
        final googleSignIn = _getGoogleSignIn();
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          throw AuthException(message: 'Google sign-in cancelled');
        }
        final googleAuth = await googleUser.authentication;
        final credential = fb.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        result = await _auth.signInWithCredential(credential);
      }

      if (result.user == null) {
        throw AuthException(message: 'Google sign-in failed');
      }
      return _ensureUserDocument(result.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (e) {
      final message = e.toString();
      if (message.contains('popup_closed') ||
          message.contains('popup-closed-by-user')) {
        throw AuthException(message: 'Google sign-in cancelled');
      }
      throw AuthException(message: 'Google sign-in failed: $e');
    }
  }

  // ── Apple Sign In ──
  @override
  Future<UserModel> signInWithApple() async {
    try {
      final appleProvider = fb.AppleAuthProvider();
      final result = await _auth.signInWithProvider(appleProvider);
      if (result.user == null) {
        throw AuthException(message: 'Apple sign-in failed');
      }
      return _ensureUserDocument(result.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (e) {
      throw AuthException(message: 'Apple sign-in failed: $e');
    }
  }

  // ── Guest Login ──
  @override
  Future<UserModel> signInAsGuest() async {
    try {
      final result = await _auth.signInAnonymously();
      if (result.user == null) {
        throw AuthException(message: 'Guest login failed');
      }
      return _ensureUserDocument(result.user!, name: 'Guest Traveler');
    } on fb.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  // ── Get Current User ──
  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      final doc = await _userDoc(user.uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      AppLogger.error('Failed to get current user', e);
      return null;
    }
  }

  // ── Password Reset ──
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  // ── Email Verification ──
  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException(message: 'No user logged in');
    }
    await user.sendEmailVerification();
  }

  // ── Logout ──
  @override
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn?.signOut();
  }

  // ── Auth State Stream ──
  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        final doc = await _userDoc(user.uid).get();
        if (!doc.exists) return null;
        return UserModel.fromFirestore(doc);
      } catch (_) {
        return null;
      }
    });
  }

  // ── Error Mapping ──
  AuthException _mapFirebaseAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException(
            message: 'No account found with this email', code: e.code);
      case 'wrong-password':
        return AuthException(message: 'Incorrect password', code: e.code);
      case 'email-already-in-use':
        return AuthException(
            message: 'This email is already registered', code: e.code);
      case 'weak-password':
        return AuthException(message: 'Password is too weak', code: e.code);
      case 'invalid-email':
        return AuthException(message: 'Invalid email address', code: e.code);
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return AuthException(
          message: 'Invalid email or password',
          code: e.code,
        );
      case 'too-many-requests':
        return AuthException(
            message: 'Too many attempts. Try again later.', code: e.code);
      case 'user-disabled':
        return AuthException(
            message: 'This account has been disabled', code: e.code);
      case 'popup-closed-by-user':
        return AuthException(message: 'Google sign-in cancelled', code: e.code);
      case 'account-exists-with-different-credential':
        return AuthException(
          message:
              'An account already exists with this email using a different sign-in method',
          code: e.code,
        );
      case 'unauthorized-domain':
        return AuthException(
          message:
              'This domain is not authorized for sign-in. Add it in Firebase Console → Authentication → Settings → Authorized domains.',
          code: e.code,
        );
      default:
        return AuthException(
            message: e.message ?? 'Authentication error', code: e.code);
    }
  }
}
