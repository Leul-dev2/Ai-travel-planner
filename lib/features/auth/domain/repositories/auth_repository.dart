// ─── Auth Repository Interface ──────────────────────────────────────
// Abstract contract for authentication operations.

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Check if user is currently authenticated.
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Login with email and password.
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  });

  /// Register with email and password.
  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  /// Sign in with Google.
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign in with Apple.
  Future<Either<Failure, UserEntity>> signInWithApple();

  /// Continue as guest.
  Future<Either<Failure, UserEntity>> signInAsGuest();

  /// Send password reset email.
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Send email verification.
  Future<Either<Failure, void>> sendEmailVerification();

  /// Logout.
  Future<Either<Failure, void>> logout();

  /// Stream of auth state changes.
  Stream<UserEntity?> get authStateChanges;
}
