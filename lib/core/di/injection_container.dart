import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'injection_container.config.dart';
import '../utils/connectivity_service.dart';
import '../utils/app_logger.dart';
import '../utils/toast_service.dart';
import '../utils/loading_service.dart';
import '../utils/dialog_service.dart';
import '../network/api_client.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // Register SharedPreferences first
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register core services
  getIt.registerSingleton<ConnectivityService>(ConnectivityService());
  getIt.registerSingleton<AppLogger>(AppLogger());
  getIt.registerSingleton<ToastService>(ToastService());
  getIt.registerSingleton<LoadingService>(LoadingService());
  getIt.registerSingleton<DialogService>(DialogService());

  // Register API client
  getIt.registerSingleton<ApiClient>(ApiClient());

  // Register auth data sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Register auth repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<AuthLocalDataSource>(),
    ),
  );

  // Register auth use cases
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );

  // Register auth bloc
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(getIt<LoginUseCase>()),
  );

  // Initialize services that need initialization
  await getIt<ConnectivityService>().initialize();
}

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
