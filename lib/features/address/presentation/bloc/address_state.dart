import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/address.dart';
import '../../domain/usecases/delete_address_uc.dart';
import '../../domain/usecases/save_address_uc.dart';

// State class
class AddressState extends Equatable {
  final AddressEntity? savedAddress;
  final bool isLoading;
  final Failure? error;
  final bool isSuccess;
  final bool isDeleted;

  const AddressState({
    this.savedAddress,
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.isDeleted = false,
  });

  AddressState copyWith({
    AddressEntity? savedAddress,
    bool? isLoading,
    Failure? error,
    bool? isSuccess,
    bool? isDeleted,
  }) {
    return AddressState(
      savedAddress: savedAddress ?? this.savedAddress,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props =>
      [savedAddress, isLoading, error, isSuccess, isDeleted];
}

// ChangeNotifier Provider
class AddressProvider extends ChangeNotifier {
  final SaveAddressUseCase saveAddressUsecase;
  final DeleteAddressUseCase deleteAddressUsecase;

  AddressState _state = const AddressState();

  AddressState get state => _state;

  AddressProvider({
    required this.saveAddressUsecase,
    required this.deleteAddressUsecase,
  });

  void _updateState(AddressState newState) {
    _state = newState;
    notifyListeners();
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
        _updateState(
          _state.copyWith(
            isLoading: false,
            savedAddress: address,
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

    final result = await deleteAddressUsecase.call(
      DeleteAddressParams(id: id),
    );

    result.fold(
      (failure) {
        _updateState(_state.copyWith(isLoading: false, error: failure));
      },
      (_) {
        _updateState(
          _state.copyWith(
            isLoading: false,
            savedAddress: null,
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
