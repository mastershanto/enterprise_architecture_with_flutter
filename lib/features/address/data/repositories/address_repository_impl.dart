import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_local_datasource.dart';
import '../datasources/address_remote_datasource.dart';
import '../models/address_model.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;
  final AddressLocalDataSource localDataSource;

  AddressRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<AddressEntity>>> getAddresses() async {
    try {
      final models = await remoteDataSource.getAddresses();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to fetch addresses: $e'));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> saveAddress({
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    double? latitude,
    double? longitude,
    required String label,
  }) async {
    if (addressLine1.trim().isEmpty) {
      return const Left(
        ValidationFailure(
          message: 'Address line 1 cannot be empty',
          fieldErrors: {'address_line1': 'Required'},
        ),
      );
    }

    if (city.trim().isEmpty) {
      return const Left(
        ValidationFailure(
          message: 'City cannot be empty',
          fieldErrors: {'city': 'Required'},
        ),
      );
    }

    try {
      final model = await remoteDataSource.saveAddress(
        addressLine1: addressLine1.trim(),
        addressLine2: addressLine2?.trim(),
        city: city.trim(),
        state: state.trim(),
        postalCode: postalCode.trim(),
        country: country.trim(),
        latitude: latitude,
        longitude: longitude,
        label: label.trim(),
      );

      // Cache locally
      await localDataSource.cacheAddress(model);

      return Right(model.toEntity());
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to save address: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress({required int id}) async {
    try {
      await remoteDataSource.deleteAddress(id: id);
      await localDataSource.deleteAddressCache(id);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete address: $e'));
    }
  }
}
