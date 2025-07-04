import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_response_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveAuthResponse(AuthResponseModel authResponse);
  Future<AuthResponseModel?> getAuthResponse();
  Future<void> clearAuthData();
  Future<bool> isLoggedIn();
  Future<String?> getAccessToken();

  // Remember Me functionality
  Future<void> saveLoginCredentials(String username, String password);
  Future<Map<String, String?>> getLoginCredentials();
  Future<void> clearLoginCredentials();
  Future<void> setRememberMe(bool remember);
  Future<bool> getRememberMe();
}

@Injectable(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;

  const AuthLocalDataSourceImpl(this._prefs);

  @override
  Future<void> saveAuthResponse(AuthResponseModel authResponse) async {
    try {
      final authJson = json.encode(authResponse.toJson());
      await _prefs.setString(AppConstants.tokenKey, authResponse.accessToken);

      if (authResponse.refreshToken != null) {
        await _prefs.setString(
            AppConstants.refreshTokenKey, authResponse.refreshToken!);
      }

      // Save the full auth response for future use
      await _prefs.setString('auth_response', authJson);

      // Save login timestamp
      await _prefs.setInt(
          'login_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      throw const CacheException(message: 'Failed to save auth data');
    }
  }

  @override
  Future<AuthResponseModel?> getAuthResponse() async {
    try {
      final authResponseJson = _prefs.getString('auth_response');
      if (authResponseJson != null) {
        final authResponseMap =
            json.decode(authResponseJson) as Map<String, dynamic>;
        return AuthResponseModel.fromJson(authResponseMap);
      }
      return null;
    } catch (e) {
      throw const CacheException(message: 'Failed to retrieve auth data');
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await Future.wait([
        _prefs.remove(AppConstants.tokenKey),
        _prefs.remove(AppConstants.refreshTokenKey),
        _prefs.remove('auth_response'),
        _prefs.remove('login_timestamp'),
        // Also clear login credentials if remember me is not enabled
        _clearLoginCredentialsIfNeeded(),
      ]);
    } catch (e) {
      throw const CacheException(message: 'Failed to clear auth data');
    }
  }

  Future<void> _clearLoginCredentialsIfNeeded() async {
    final rememberMe = await getRememberMe();
    if (!rememberMe) {
      await clearLoginCredentials();
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = _prefs.getString(AppConstants.tokenKey);
      if (token == null) return false;

      // Check if token is expired
      final authResponse = await getAuthResponse();
      if (authResponse == null) return false;

      final loginTimestamp = _prefs.getInt('login_timestamp') ?? 0;
      final loginTime = DateTime.fromMillisecondsSinceEpoch(loginTimestamp);
      final expirationTime =
          loginTime.add(Duration(seconds: authResponse.expiresIn));

      return DateTime.now().isBefore(expirationTime);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final isLoggedInResult = await isLoggedIn();
      if (!isLoggedInResult) return null;

      return _prefs.getString(AppConstants.tokenKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveLoginCredentials(String username, String password) async {
    try {
      await Future.wait([
        _prefs.setString(AppConstants.savedUsernameKey, username),
        _prefs.setString(AppConstants.savedPasswordKey, password),
      ]);
    } catch (e) {
      throw const CacheException(message: 'Failed to save login credentials');
    }
  }

  @override
  Future<Map<String, String?>> getLoginCredentials() async {
    try {
      final username = _prefs.getString(AppConstants.savedUsernameKey);
      final password = _prefs.getString(AppConstants.savedPasswordKey);
      return {
        'username': username,
        'password': password,
      };
    } catch (e) {
      throw const CacheException(message: 'Failed to retrieve login credentials');
    }
  }

  @override
  Future<void> clearLoginCredentials() async {
    try {
      await Future.wait([
        _prefs.remove(AppConstants.savedUsernameKey),
        _prefs.remove(AppConstants.savedPasswordKey),
        _prefs.remove(AppConstants.rememberMeKey),
      ]);
    } catch (e) {
      throw const CacheException(message: 'Failed to clear login credentials');
    }
  }

  @override
  Future<void> setRememberMe(bool remember) async {
    try {
      await _prefs.setBool(AppConstants.rememberMeKey, remember);
    } catch (e) {
      throw const CacheException(message: 'Failed to save remember me preference');
    }
  }

  @override
  Future<bool> getRememberMe() async {
    try {
      return _prefs.getBool(AppConstants.rememberMeKey) ?? false;
    } catch (e) {
      return false;
    }
  }
}
