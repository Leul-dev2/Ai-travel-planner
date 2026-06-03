// ─── Auth Riverpod Providers ────────────────────────────────────────
// Reactive auth state management using Riverpod.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// ── Dependency Providers ──

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  try {
    return AuthRemoteDatasourceImpl();
  } catch (e) {
    throw Exception('Failed to initialize auth datasource: $e');
  }
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDatasource: ref.watch(authRemoteDatasourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// ── Auth State ──

/// Listenable auth state for GoRouter refresh
class AuthStateNotifier extends ChangeNotifier {
  UserEntity? _user;
  bool _isLoading = true;
  String? _error;

  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  void setUser(UserEntity? user) {
    _user = user;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

final authStateProvider = ChangeNotifierProvider<AuthStateNotifier>((ref) {
  return AuthStateNotifier();
});

// ── Auth Actions ──

final loginProvider = FutureProvider.family
    .autoDispose<bool, ({String email, String password})>((ref, creds) async {
  final repo = ref.read(authRepositoryProvider);
  final authState = ref.read(authStateProvider);

  authState.setLoading(true);
  authState.clearError();

  final result = await repo.loginWithEmail(
    email: creds.email,
    password: creds.password,
  );

  return result.fold(
    (failure) {
      authState.setError(failure.message);
      return false;
    },
    (user) {
      authState.setUser(user);
      return true;
    },
  );
});

final registerProvider = FutureProvider.family
    .autoDispose<bool, ({String name, String email, String password})>(
        (ref, creds) async {
  final repo = ref.read(authRepositoryProvider);
  final authState = ref.read(authStateProvider);

  authState.setLoading(true);
  authState.clearError();

  final result = await repo.registerWithEmail(
    name: creds.name,
    email: creds.email,
    password: creds.password,
  );

  return result.fold(
    (failure) {
      authState.setError(failure.message);
      return false;
    },
    (user) {
      authState.setUser(user);
      return true;
    },
  );
});

final googleSignInProvider = FutureProvider.autoDispose<bool>((ref) async {
  final repo = ref.read(authRepositoryProvider);
  final authState = ref.read(authStateProvider);

  authState.setLoading(true);
  authState.clearError();

  final result = await repo.signInWithGoogle();
  return result.fold(
    (failure) {
      authState.setError(failure.message);
      return false;
    },
    (user) {
      authState.setUser(user);
      return true;
    },
  );
});

final logoutProvider = FutureProvider.autoDispose<void>((ref) async {
  final repo = ref.read(authRepositoryProvider);
  final authState = ref.read(authStateProvider);

  await repo.logout();
  authState.setUser(null);
});

final checkAuthProvider = FutureProvider<bool>((ref) async {
  final repo = ref.read(authRepositoryProvider);
  final authState = ref.read(authStateProvider);

  final result = await repo.getCurrentUser();
  return result.fold(
    (failure) {
      authState.setUser(null);
      return false;
    },
    (user) {
      authState.setUser(user);
      return true;
    },
  );
});

final passwordResetProvider =
    FutureProvider.family.autoDispose<bool, String>((ref, email) async {
  final repo = ref.read(authRepositoryProvider);
  final result = await repo.sendPasswordResetEmail(email);
  return result.isRight();
});
