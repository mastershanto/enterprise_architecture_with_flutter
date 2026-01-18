import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/equipment.dart';
import '../repositories/equipment_repository.dart';

class GetEquipmentsUseCase implements UseCase<List<Equipment>, NoParams> {
  final EquipmentRepository repository;

  GetEquipmentsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<Equipment>>> call(NoParams params) async {
    return await repository.getEquipments();
  }
}
