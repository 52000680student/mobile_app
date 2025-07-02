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
      throw CacheException(message: 'Failed to save auth data');
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
      throw CacheException(message: 'Failed to retrieve auth data');
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
      ]);
    } catch (e) {
      throw CacheException(message: 'Failed to clear auth data');
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
}
