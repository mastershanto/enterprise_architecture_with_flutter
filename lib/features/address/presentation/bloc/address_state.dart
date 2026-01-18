import 'package:enterprise_architecture_with_flutter/core/usecases/usecase.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/address.dart';
import '../../domain/usecases/delete_address_uc.dart';
import '../../domain/usecases/get_addresses_uc.dart';
import '../../domain/usecases/save_address_uc.dart';

// State class
class AddressState extends Equatable {
  final List<AddressEntity> addresses;
  final AddressEntity? savedAddress;
  final bool isLoading;
  final Failure? error;
  final bool isSuccess;
  final bool isDeleted;

  const AddressState({
    this.addresses = const [],
    this.savedAddress,
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.isDeleted = false,
  });

  AddressState copyWith({
    List<AddressEntity>? addresses,
    AddressEntity? savedAddress,
    bool? isLoading,
    Failure? error,
    bool? isSuccess,
    bool? isDeleted,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      savedAddress: savedAddress ?? this.savedAddress,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
    addresses,
    savedAddress,
    isLoading,
    error,
    isSuccess,
    isDeleted,
  ];
}

// ChangeNotifier Provider
class AddressProvider extends ChangeNotifier {
  final GetAddressesUseCase getAddressesUsecase;
  final SaveAddressUseCase saveAddressUsecase;
  final DeleteAddressUseCase deleteAddressUsecase;

  AddressState _state = const AddressState();

  AddressState get state => _state;

  AddressProvider({
    required this.getAddressesUsecase,
    required this.saveAddressUsecase,
    required this.deleteAddressUsecase,
  });

  void _updateState(AddressState newState) {
    _state = newState;
    notifyListeners();
  }

  // Get all addresses
  Future<void> getAddresses() async {
    _updateState(_state.copyWith(isLoading: true, error: null));

    final result = await getAddressesUsecase.call(const NoParams());

    result.fold(
      (failure) {
        _updateState(_state.copyWith(isLoading: false, error: failure));
      },
      (addresses) {
        _updateState(
          _state.copyWith(
            isLoading: false,
            addresses: addresses,
            isSuccess: true,
          ),
        );
      },
    );
  }

  // Save address
  Future<void> saveAddress({
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
    _updateState(_state.copyWith(isLoading: true, error: null));

    final result = await saveAddressUsecase.call(
      SaveAddressParams(
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        latitude: latitude,
        longitude: longitude,
        label: label,
      ),
    );

    result.fold(
      (failure) {
        _updateState(_state.copyWith(isLoading: false, error: failure));
      },
      (address) {
        final updatedAddresses = [..._state.addresses, address];
        _updateState(
          _state.copyWith(
            isLoading: false,
            savedAddress: address,
            addresses: updatedAddresses,
            isSuccess: true,
            isDeleted: false,
          ),
        );
      },
    );
  }

  // Delete address
  Future<void> deleteAddress({required int id}) async {
    _updateState(_state.copyWith(isLoading: true, error: null));

    final result = await deleteAddressUsecase.call(DeleteAddressParams(id: id));

    result.fold(
      (failure) {
        _updateState(_state.copyWith(isLoading: false, error: failure));
      },
      (_) {
        final updatedAddresses = _state.addresses
            .where((addr) => addr.id != id)
            .toList();
        _updateState(
          _state.copyWith(
            isLoading: false,
            savedAddress: null,
            addresses: updatedAddresses,
            isSuccess: true,
            isDeleted: true,
          ),
        );
      },
    );
  }

  // Reset state
  void resetState() {
    _updateState(const AddressState());
  }

  // Clear error
  void clearError() {
    _updateState(_state.copyWith(error: null));
  }
}
