import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/constants/patient_states.dart';
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
      // Simulate app initialization (e.g., loading user data, checking auth)
      await Future.delayed(const Duration(seconds: 2));

      // Check authentication status
      final isLoggedIn = await _authLocalDataSource.isLoggedIn();

      if (isLoggedIn) {
        emit(SplashAuthenticated());
      } else {
        emit(SplashCompleted());
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error during app initialization', e, stackTrace);
      emit(const SplashError(message: ErrorMessages.initializationFailedError));
    }
  }
}
