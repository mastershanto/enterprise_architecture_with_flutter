import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/usecases/get_equipments_uc.dart';

class EquipmentState {
  final List<Equipment> equipments;
  final bool isLoading;
  final Failure? error;

  const EquipmentState({
    this.equipments = const [],
    this.isLoading = false,
    this.error,
  });

  EquipmentState copyWith({
    List<Equipment>? equipments,
    bool? isLoading,
    Failure? error,
    bool clearError = false,
  }) {
    return EquipmentState(
      equipments: equipments ?? this.equipments,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class EquipmentProvider extends ChangeNotifier {
  final GetEquipmentsUseCase getEquipmentsUsecase;

  EquipmentState _state = const EquipmentState();
  EquipmentState get state => _state;

  EquipmentProvider({required this.getEquipmentsUsecase});

  List<Equipment> get equipments => _state.equipments;
  bool get isLoading => _state.isLoading;
  Failure? get error => _state.error;

  Future<void> getEquipments() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    final result = await getEquipmentsUsecase(NoParams());

    result.fold(
      (failure) {
        _state = _state.copyWith(error: failure, isLoading: false);
        notifyListeners();
      },
      (equipments) {
        _state = _state.copyWith(equipments: equipments, isLoading: false);
        notifyListeners();
      },
    );
  }

  void clearError() {
    _state = _state.copyWith(clearError: true);
    notifyListeners();
  }
}
