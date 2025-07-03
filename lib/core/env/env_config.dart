import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Environment { dev, sta, prod }

class EnvConfig {
  static Environment _environment = Environment.dev;
  static bool _isInitialized = false;

  static Environment get environment => _environment;
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize({required Environment env}) async {
    _environment = env;
    print('🔧 Initializing EnvConfig with environment: $env');

    // Load environment-specific configuration
    await _loadEnvFile(env);
    _isInitialized = true;

    // Debug logging
    print('📋 Environment Configuration:');
    print('  - Environment: ${environmentName}');
    print('  - API Base URL: ${apiBaseUrl}');
    print('  - Enable Logging: ${enableLogging}');
    print('  - Debug Mode: ${debugMode}');
  }

  static Future<void> _loadEnvFile(Environment env) async {
    try {
      String fileName;
      switch (env) {
        case Environment.dev:
          fileName = 'assets/env/.env.dev';
          break;
        case Environment.sta:
          fileName = 'assets/env/.env.sta';
          break;
        case Environment.prod:
          fileName = 'assets/env/.env.prod';
          break;
      }
      print('📁 Attempting to load env file: $fileName');
      await dotenv.load(fileName: fileName);
      print('✅ Successfully loaded env file: $fileName');
    } catch (e) {
      print('❌ Failed to load env file: $e');
      print('🔄 Using fallback configuration...');
      // If loading env file fails, initialize with fallback configuration
      await _setFallbackConfig(env);
    }
  }

  static Future<void> _setFallbackConfig(Environment env) async {
    print('🛠️ Setting fallback configuration for environment: $env');
    // Create fallback configuration directly in dotenv
    Map<String, String> fallbackValues = {};

    switch (env) {
      case Environment.dev:
        fallbackValues = {
          'ENVIRONMENT': 'dev',
          'API_BASE_URL': 'https://api-dev.yourapp.com',
          'API_TIMEOUT': '30000',
          'ENABLE_LOGGING': 'true',
          'DEBUG_MODE': 'true',
        };
        break;
      case Environment.sta:
        fallbackValues = {
          'ENVIRONMENT': 'sta',
          'API_BASE_URL': 'https://api-staging.yourapp.com',
          'API_TIMEOUT': '30000',
          'ENABLE_LOGGING': 'true',
          'DEBUG_MODE': 'false',
        };
        break;
      case Environment.prod:
        fallbackValues = {
          'ENVIRONMENT': 'prod',
          'API_BASE_URL': 'https://api.yourapp.com',
          'API_TIMEOUT': '30000',
          'ENABLE_LOGGING': 'false',
          'DEBUG_MODE': 'false',
        };
        break;
    }

    // Set the fallback values directly to dotenv.env without file loading
    dotenv.env.clear();
    dotenv.env.addAll(fallbackValues);
    print('📝 Fallback values set: $fallbackValues');
  }

  // Configuration getters
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;
  static bool get enableLogging =>
      dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';
  static bool get debugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  static String get environmentName => dotenv.env['ENVIRONMENT'] ?? 'dev';
  static String get keyLogin => dotenv.env['KEY_LOGIN'] ?? '';

  // Environment checkers
  static bool get isDev => _environment == Environment.dev;
  static bool get isStaging => _environment == Environment.sta;
  static bool get isProd => _environment == Environment.prod;
}
