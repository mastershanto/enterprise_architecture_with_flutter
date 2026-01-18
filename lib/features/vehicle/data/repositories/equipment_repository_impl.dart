import 'package:dartz/dartz.dart';
import 'package:enterprise_architecture_with_flutter/core/errors/failures.dart';
import 'package:enterprise_architecture_with_flutter/features/address/data/datasources/address_remote_datasource.dart';

import '../../domain/entities/equipment.dart';
import '../../domain/repositories/equipment_repository.dart';
import '../datasources/equipment_local_datasource.dart';
import '../datasources/equipment_remote_datasource.dart';

class EquipmentRepositoryImpl implements EquipmentRepository {
  final EquipmentRemoteDataSource remoteDataSource;
  final EquipmentLocalDataSource localDataSource;

  EquipmentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Equipment>>> getEquipments() async {
    try {
      final equipmentModels = await remoteDataSource.getEquipments();
      final equipments = equipmentModels
          .map((model) => model.toEntity())
          .toList();
      return Right(equipments);
    } on ApiException catch (e) {
      return Left(
        ServerFailure(statusCode: e.statusCode, message: 'No equipments found'),
      );
    } catch (e) {
      return const Left(ServerFailure(message: 'No equipments found'));
    }
  }
}
