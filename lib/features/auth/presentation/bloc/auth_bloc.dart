import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/login_request.dart';
import '../../domain/usecases/login_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;

  AuthBloc(this._loginUseCase) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      AppLogger.info('Login attempt for: ${event.email}');

      final loginRequest = LoginRequest(
        username: event.email,
        password: event.password,
      );

      final result = await _loginUseCase(loginRequest);

      result.fold(
        (failure) {
          AppLogger.error('Login failed: ${failure.message}');
          emit(AuthFailure(message: failure.message));
        },
        (authResponse) {
          AppLogger.info('Login successful for: ${event.email}');
          emit(AuthSuccess());
        },
      );
    } catch (e, stackTrace) {
      AppLogger.error('Login failed', e, stackTrace);
      emit(const AuthFailure(message: 'Login failed. Please try again.'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      AppLogger.info('Logout requested');

      // TODO: Implement actual logout logic here
      // - Clear tokens
      // - Clear user data
      // - Call logout API if needed

      emit(AuthInitial());
      AppLogger.info('Logout successful');
    } catch (e, stackTrace) {
      AppLogger.error('Logout failed', e, stackTrace);
      emit(const AuthFailure(message: 'Logout failed'));
    }
  }
}
