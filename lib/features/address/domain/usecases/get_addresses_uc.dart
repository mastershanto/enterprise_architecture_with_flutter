import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/address.dart';
import '../repositories/address_repository.dart';

class GetAddressesUseCase extends UseCase<List<AddressEntity>, NoParams> {
  final AddressRepository repository;

  GetAddressesUseCase({required this.repository});

  @override
  Future<Either<Failure, List<AddressEntity>>> call(NoParams params) =>
      repository.getAddresses();
}
