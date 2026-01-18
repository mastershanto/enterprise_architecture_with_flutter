import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/equipment.dart';

abstract class EquipmentRepository {
  Future<Either<Failure, List<Equipment>>> getEquipments();
}
