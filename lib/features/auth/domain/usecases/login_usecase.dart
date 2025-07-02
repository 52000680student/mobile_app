import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_response.dart';
import '../entities/login_request.dart';
import '../repositories/auth_repository.dart';

@injectable
class LoginUseCase {
  final AuthRepository _authRepository;

  const LoginUseCase(this._authRepository);

  Future<Either<Failure, AuthResponse>> call(LoginRequest loginRequest) async {
    return await _authRepository.login(loginRequest);
  }
}
