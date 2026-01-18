import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/address_repository.dart';

class DeleteAddressUseCase extends UseCase<void, DeleteAddressParams> {
  final AddressRepository repository;

  DeleteAddressUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(DeleteAddressParams params) =>
      repository.deleteAddress(id: params.id);
}

class DeleteAddressParams extends Params {
  final int id;

  const DeleteAddressParams({required this.id});
}
