import 'package:logger/logger.dart';
import '../env/env_config.dart';

class AppLogger {
  static late Logger _logger;
  static bool _isInitialized = false;

  static void initialize() {
    if (_isInitialized) return;

    _logger = Logger(
      filter: _LogFilter(),
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      output: _LogOutput(),
    );

    _isInitialized = true;

    // Test log to verify logger is working
    _logger.i('🚀 AppLogger initialized successfully');
  }

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_isInitialized) initialize();
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_isInitialized) initialize();
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_isInitialized) initialize();
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_isInitialized) initialize();
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_isInitialized) initialize();
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}

class _LogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // Always log in debug mode (when assertions are enabled)
    bool isDebugMode = false;
    assert(() {
      isDebugMode = true;
      return true;
    }());

    if (isDebugMode) {
      return true; // Always log in debug builds
    }

    // In release mode, only log if logging is enabled in the environment
    return EnvConfig.isInitialized ? EnvConfig.enableLogging : false;
  }
}

class _LogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    // In production, you might want to send logs to a remote service
    for (final line in event.lines) {
      print(line);
    }
  }
}
