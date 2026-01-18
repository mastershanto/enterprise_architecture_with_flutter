import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/address.dart';
import '../repositories/address_repository.dart';

class SaveAddressUseCase extends UseCase<AddressEntity, SaveAddressParams> {
  final AddressRepository repository;

  SaveAddressUseCase({required this.repository});

  @override
  Future<Either<Failure, AddressEntity>> call(SaveAddressParams params) =>
      repository.saveAddress(
        addressLine1: params.addressLine1,
        addressLine2: params.addressLine2,
        city: params.city,
        state: params.state,
        postalCode: params.postalCode,
        country: params.country,
        latitude: params.latitude,
        longitude: params.longitude,
        label: params.label,
      );
}

class SaveAddressParams extends Params {
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final String label;

  const SaveAddressParams({
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.latitude,
    this.longitude,
    required this.label,
  });
}
