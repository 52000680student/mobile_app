import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_response.dart';
import '../entities/login_request.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> login(LoginRequest loginRequest);
  Future<Either<Failure, void>> logout();
  Future<bool> isLoggedIn();
  Future<String?> getAccessToken();
}
