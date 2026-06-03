// ─── Auth Repository Implementation ─────────────────────────────────
// Bridges datasources to domain layer with error handling.

import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl({
    required AuthRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = await _remoteDatasource.getCurrentUser();
      if (user == null) {
        return const Left(UnauthorizedFailure());
      }
      return Right(user.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      AppLogger.error('getCurrentUser failed', e);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final user = await _remoteDatasource.loginWithEmail(email, password);
      return Right(user.toEntity());
    } on AuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'user-not-found') {
        return Left(InvalidCredentialsFailure(message: e.message));
      }
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      AppLogger.error('loginWithEmail failed', e);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final user =
          await _remoteDatasource.registerWithEmail(name, email, password);
      return Right(user.toEntity());
    } on AuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return Left(EmailAlreadyInUseFailure(message: e.message));
      }
      if (e.code == 'weak-password') {
        return Left(WeakPasswordFailure(message: e.message));
      }
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      AppLogger.error('registerWithEmail failed', e);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final user = await _remoteDatasource.signInWithGoogle();
      return Right(user.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      AppLogger.error('signInWithGoogle failed', e);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithApple() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final user = await _remoteDatasource.signInWithApple();
      return Right(user.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      AppLogger.error('signInWithApple failed', e);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInAsGuest() async {
    try {
      final user = await _remoteDatasource.signInAsGuest();
      return Right(user.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      AppLogger.error('signInAsGuest failed', e);
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      await _remoteDatasource.sendPasswordResetEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      await _remoteDatasource.sendEmailVerification();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDatasource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _remoteDatasource.authStateChanges
        .map((model) => model?.toEntity());
  }
}
