import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/app_logger.dart';

part 'splash_event.dart';
part 'splash_state.dart';

@injectable
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial()) {
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

      // Add your initialization logic here:
      // - Check authentication status
      // - Load user preferences
      // - Initialize services
      // - Check app version

      AppLogger.info('App initialization completed');
      emit(SplashCompleted());
    } catch (e, stackTrace) {
      AppLogger.error('Error during app initialization', e, stackTrace);
      emit(SplashError(message: 'Failed to initialize app'));
    }
  }
}
