import 'package:dartz/dartz.dart';
import 'package:enterprise_architecture_with_flutter/features/address/data/datasources/address_remote_datasource.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Cache the user data
      await localDataSource.cacheUser(userModel);

      return Right(userModel.toEntity());
    } on ApiException catch (e) {
      return Left(
        ServerFailure(
          message: e.message ?? e.toString(),
          statusCode: e.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<User?> getCachedUser() async {
    try {
      final userModel = await localDataSource.getCachedUser();
      return userModel?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCachedUser() async {
    await localDataSource.clearCache();
  }
}
