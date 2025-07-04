import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/constants/patient_states.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../domain/entities/login_request.dart';
import '../../domain/usecases/login_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final AuthLocalDataSource _authLocalDataSource;

  AuthBloc(this._loginUseCase, this._authLocalDataSource)
      : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final loginRequest = LoginRequest(
        username: event.email,
        password: event.password,
      );

      final result = await _loginUseCase(loginRequest);

      if (result.isLeft()) {
        // Handle failure
        final failure = result.fold((l) => l, (r) => null)!;
        AppLogger.error('Login failed: ${failure.message}');
        emit(AuthFailure(message: failure.message));
      } else {
        // Handle success
        // Handle remember me functionality
        if (event.rememberMe) {
          await _authLocalDataSource.setRememberMe(true);
          await _authLocalDataSource.saveLoginCredentials(
            event.email,
            event.password,
          );
        } else {
          await _authLocalDataSource.setRememberMe(false);
          await _authLocalDataSource.clearLoginCredentials();
        }

        emit(AuthSuccess());
      }
    } catch (e, stackTrace) {
      AppLogger.error('Login failed', e, stackTrace);
      emit(const AuthFailure(message: ErrorMessages.authenticationFailed));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Clear all auth data (this will preserve remember me if enabled)
      await _authLocalDataSource.clearAuthData();

      emit(AuthInitial());
    } catch (e, stackTrace) {
      AppLogger.error('Logout failed', e, stackTrace);
      emit(const AuthFailure(message: ErrorMessages.unexpectedError));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isLoggedIn = await _authLocalDataSource.isLoggedIn();

      if (isLoggedIn) {
        emit(AuthAlreadyAuthenticated());
      } else {
        emit(AuthInitial());
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error checking auth status', e, stackTrace);
      emit(AuthInitial());
    }
  }
}
