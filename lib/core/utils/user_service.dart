import 'package:injectable/injectable.dart';
import '../di/injection_container.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import 'jwt_service.dart';
import 'app_logger.dart';

@injectable
class UserService {
  final JwtService _jwtService;
  final AuthLocalDataSource _authLocalDataSource;

  UserService(this._jwtService, this._authLocalDataSource);

  /// Get current logged-in user ID
  Future<String?> getCurrentUserId() async {
    try {
      final token = await _authLocalDataSource.getAccessToken();
      if (token == null) {
        return null;
      }

      final userId = _jwtService.getUserId(token);
      if (userId == null) {
        return null;
      }

      return userId;
    } catch (e) {
      AppLogger.error('Error getting current user ID: $e');
      return null;
    }
  }

  /// Get current logged-in username
  Future<String?> getCurrentUsername() async {
    try {
      final token = await _authLocalDataSource.getAccessToken();
      if (token == null) {
        return null;
      }

      final username = _jwtService.getUsername(token);
      if (username == null) {
        return null;
      }

      return username;
    } catch (e) {
      AppLogger.error('Error getting current username: $e');
      return null;
    }
  }

  /// Get all current user information
  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      final token = await _authLocalDataSource.getAccessToken();
      if (token == null) {
        return null;
      }

      final userInfo = _jwtService.getUserInfo(token);
      if (userInfo == null) {
        return null;
      }

      return userInfo;
    } catch (e) {
      AppLogger.error('Error getting current user info: $e');
      return null;
    }
  }

  /// Check if user is currently logged in and token is valid
  Future<bool> isUserLoggedIn() async {
    try {
      final token = await _authLocalDataSource.getAccessToken();
      if (token == null) return false;

      final isExpired = _jwtService.isTokenExpired(token);
      return !isExpired;
    } catch (e) {
      AppLogger.error('Error checking user login status: $e');
      return false;
    }
  }

  /// Get current user ID with fallback
  /// Returns hardcoded fallback if no user ID is found (for backward compatibility)
  Future<String> getCurrentUserIdWithFallback(
      {String fallback = "1000004"}) async {
    final userId = await getCurrentUserId();
    if (userId != null && userId.isNotEmpty) {
      return userId;
    }

    return fallback;
  }
}
