import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code});
}

// HTTP-specific failures
class BadRequestFailure extends ServerFailure {
  const BadRequestFailure({required super.message}) : super(code: 400);
}

class UnauthorizedFailure extends ServerFailure {
  const UnauthorizedFailure({required super.message}) : super(code: 401);
}

class ForbiddenFailure extends ServerFailure {
  const ForbiddenFailure({required super.message}) : super(code: 403);
}

class NotFoundFailure extends ServerFailure {
  const NotFoundFailure({required super.message}) : super(code: 404);
}

class InternalServerFailure extends ServerFailure {
  const InternalServerFailure({required super.message}) : super(code: 500);
}
