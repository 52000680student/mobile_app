import 'package:equatable/equatable.dart';

class LoginRequest extends Equatable {
  final String username;
  final String password;
  final String grantType;

  const LoginRequest({
    required this.username,
    required this.password,
    this.grantType = 'password',
  });

  @override
  List<Object> get props => [username, password, grantType];
}
