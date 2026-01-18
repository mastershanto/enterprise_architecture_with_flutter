import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCachedUserUseCase {
  final AuthRepository repository;

  GetCachedUserUseCase({required this.repository});

  Future<User?> call() async {
    return await repository.getCachedUser();
  }
}
