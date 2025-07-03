import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';

part 'splash_event.dart';
part 'splash_state.dart';

@injectable
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthLocalDataSource _authLocalDataSource;

  SplashBloc(this._authLocalDataSource) : super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    try {
      AppLogger.info('Splash screen started');

      // Simulate app initialization (e.g., loading user data, checking auth)
      await Future.delayed(const Duration(seconds: 2));

      // Check authentication status
      final isLoggedIn = await _authLocalDataSource.isLoggedIn();

      if (isLoggedIn) {
        AppLogger.info('User is already authenticated, redirecting to home');
        emit(SplashAuthenticated());
      } else {
        AppLogger.info('User is not authenticated, redirecting to login');
        emit(SplashCompleted());
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error during app initialization', e, stackTrace);
      emit(SplashError(message: 'Failed to initialize app'));
    }
  }
}
