class AppConstants {
  // App Information
  static const String appName = 'Mobile App';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const int apiTimeout = 30000; // 30 seconds
  static const int maxRetries = 3;
  static const int retryDelay = 1000; // 1 second

  // Validation Constants
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int maxEmailLength = 254;
  static const int maxNameLength = 50;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Cache
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String languageKey = 'selected_language';
  static const String themeKey = 'selected_theme';

  // Environment Keys
  static const String environmentKey = 'ENVIRONMENT';
  static const String apiBaseUrlKey = 'API_BASE_URL';
  static const String apiTimeoutKey = 'API_TIMEOUT';
  static const String enableLoggingKey = 'ENABLE_LOGGING';
  static const String debugModeKey = 'DEBUG_MODE';

  // Error Messages
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'An unknown error occurred';
  static const String timeoutError = 'Request timeout';
  static const String unauthorizedError = 'Unauthorized access';
  static const String forbiddenError = 'Access forbidden';
  static const String notFoundError = 'Resource not found';

  // Toast Duration
  static const Duration toastDuration = Duration(seconds: 3);
  static const Duration errorToastDuration = Duration(seconds: 4);
  static const Duration warningToastDuration = Duration(seconds: 3);
  static const Duration successToastDuration = Duration(seconds: 2);
}

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String about = '/about';
}

class AppAssets {
  // Images
  static const String _imagePath = 'assets/images';
  static const String logo = '$_imagePath/logo.png';
  static const String placeholder = '$_imagePath/placeholder.png';
  static const String noData = '$_imagePath/no_data.png';
  static const String error = '$_imagePath/error.png';

  // Icons
  static const String _iconPath = 'assets/icons';
  static const String appIcon = '$_iconPath/app_icon.png';

  // Fonts
  static const String primaryFont = 'Roboto';
}
