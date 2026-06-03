// ─── Failure Classes ────────────────────────────────────────────────
// Typed failure objects used across the domain layer.
// Uses dartz Either<Failure, T> pattern for error handling.

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

// ── Server Failures ──
class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred', super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure(
      {super.message = 'No internet connection. Please check your network.',
      super.code});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure(
      {super.message = 'Request timed out. Please try again.', super.code});
}

// ── Auth Failures ──
class AuthFailure extends Failure {
  const AuthFailure(
      {super.message = 'Authentication failed', super.code});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(
      {super.message = 'Session expired. Please log in again.', super.code});
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure(
      {super.message = 'Invalid email or password', super.code});
}

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure(
      {super.message = 'This email is already registered', super.code});
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure(
      {super.message = 'Password is too weak. Use at least 8 characters.',
      super.code});
}

// ── Data Failures ──
class CacheFailure extends Failure {
  const CacheFailure(
      {super.message = 'Failed to load cached data', super.code});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(
      {super.message = 'Requested resource not found', super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure(
      {super.message = 'Invalid input data', super.code});
}

// ── AI Failures ──
class AIFailure extends Failure {
  const AIFailure(
      {super.message = 'AI service is temporarily unavailable', super.code});
}

class AIRateLimitFailure extends Failure {
  const AIRateLimitFailure(
      {super.message =
          'AI request limit reached. Please wait before trying again.',
      super.code});
}

class AIExhaustedFailure extends Failure {
  const AIExhaustedFailure(
      {super.message =
          'All AI providers are currently unavailable. Using cached data.',
      super.code});
}

// ── Payment Failures ──
class PaymentFailure extends Failure {
  const PaymentFailure(
      {super.message = 'Payment processing failed', super.code});
}

class PaymentCancelledFailure extends Failure {
  const PaymentCancelledFailure(
      {super.message = 'Payment was cancelled', super.code});
}

// ── Permission Failures ──
class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure(
      {super.message = 'Permission denied', super.code});
}

// ── Generic ──
class UnknownFailure extends Failure {
  const UnknownFailure(
      {super.message = 'An unexpected error occurred', super.code});
}
