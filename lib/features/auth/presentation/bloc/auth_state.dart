import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_cached_user_uc.dart';
import '../../domain/usecases/login_uc.dart';
import '../../domain/usecases/logout_uc.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final Failure? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    Failure? error,
    bool? isAuthenticated,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUsecase;
  final LogoutUseCase logoutUsecase;
  final GetCachedUserUseCase getCachedUserUsecase;

  AuthState _state = const AuthState();
  AuthState get state => _state;

  AuthProvider({
    required this.loginUsecase,
    required this.logoutUsecase,
    required this.getCachedUserUsecase,
  }) {
    checkAuthStatus();
  }

  User? get user => _state.user;
  bool get isLoading => _state.isLoading;
  Failure? get error => _state.error;
  bool get isAuthenticated => _state.isAuthenticated;

  Future<void> checkAuthStatus() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final cachedUser = await getCachedUserUsecase();

    _state = _state.copyWith(
      user: cachedUser,
      isAuthenticated: cachedUser != null,
      isLoading: false,
    );
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    final result = await loginUsecase(
      LoginParams(email: email, password: password),
    );

    return result.fold(
      (failure) {
        _state = _state.copyWith(error: failure, isLoading: false);
        notifyListeners();
        return false;
      },
      (user) {
        _state = _state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> logout() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    await logoutUsecase(NoParams());

    _state = const AuthState();
    notifyListeners();
  }

  void clearError() {
    _state = _state.copyWith(clearError: true);
    notifyListeners();
  }
}
