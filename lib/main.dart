import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection_container.dart';
import 'core/env/env_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_logger.dart';
import 'core/utils/locale_service.dart';
import 'l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const String envString = String.fromEnvironment('ENV', defaultValue: 'dev');
  Environment env;
  switch (envString.toLowerCase()) {
    case 'dev':
      env = Environment.dev;
      break;
    case 'sta':
    case 'staging':
      env = Environment.sta;
      break;
    case 'prod':
    case 'production':
    default:
      env = Environment.prod;
      break;
  }
  await EnvConfig.initialize(env: env);

  // Initialize logging
  AppLogger.initialize();

  // Configure dependencies
  await configureDependencies();

  AppLogger.info('App started successfully');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: getIt<LocaleService>(),
      builder: (context, child) {
        final localeService = getIt<LocaleService>();

        return MaterialApp.router(
          title: 'Lấy Mẫu TN',
          debugShowCheckedModeBanner: false,

          // Routing
          routerConfig: AppRouter.router,

          // Theming
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,

          // Localization
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: localeService.supportedLocales,
          locale: localeService.currentLocale, // Use dynamic locale

          // Error handling
          builder: (context, child) {
            // Global error handling for UI errors
            ErrorWidget.builder = (FlutterErrorDetails details) {
              AppLogger.error('UI Error', details.exception, details.stack);
              return _buildErrorWidget(context, details);
            };

            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, FlutterErrorDetails details) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.error,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.onError,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onError,
                    ),
                textAlign: TextAlign.center,
              ),
              if (EnvConfig.debugMode) ...[
                const SizedBox(height: 16),
                Text(
                  details.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onError,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
