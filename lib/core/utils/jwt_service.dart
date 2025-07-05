import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:injectable/injectable.dart';
import '../error/exceptions.dart';
import 'app_logger.dart';

@injectable
class JwtService {
  /// Decode JWT token and extract user information
  Map<String, dynamic>? decodeToken(String token) {
    try {
      // Remove 'Bearer ' prefix if present
      final cleanToken = token.replaceFirst('Bearer ', '');

      // Split token into parts
      final parts = cleanToken.split('.');
      if (parts.length != 3) {
        AppLogger.error('Invalid JWT token format');
        return null;
      }

      // Decode the payload (second part)
      final payload = parts[1];

      // Add padding if needed
      final normalizedPayload = base64Url.normalize(payload);

      // Decode base64
      final decoded = utf8.decode(base64Url.decode(normalizedPayload));

      // Parse JSON
      final Map<String, dynamic> payloadMap = json.decode(decoded);

      return payloadMap;
    } catch (e) {
      AppLogger.error('Error decoding JWT token: $e');
      return null;
    }
  }

  /// Extract user ID from JWT token
  String? getUserId(String token) {
    try {
      final payload = decodeToken(token);
      if (payload == null) return null;

      // Try different possible user ID field names
      final possibleUserIdFields = [
        'sub',
        'userId',
        'user_id',
        'id',
        'uid',
        'unique_name',
      ];

      for (final field in possibleUserIdFields) {
        if (payload.containsKey(field)) {
          final value = payload[field];
          if (value != null) {
            return value.toString();
          }
        }
      }

      return null;
    } catch (e) {
      AppLogger.error('Error extracting user ID from token: $e');
      return null;
    }
  }

  /// Extract username from JWT token
  String? getUsername(String token) {
    try {
      final payload = decodeToken(token);
      if (payload == null) return null;

      // Try different possible username field names
      final possibleUsernameFields = [
        'username',
        'user_name',
        'name',
        'preferred_username',
        'email',
        'unique_name',
      ];

      for (final field in possibleUsernameFields) {
        if (payload.containsKey(field)) {
          final value = payload[field];
          if (value != null) {
            return value.toString();
          }
        }
      }

      return null;
    } catch (e) {
      AppLogger.error('Error extracting username from token: $e');
      return null;
    }
  }

  /// Check if token is expired
  bool isTokenExpired(String token) {
    try {
      final payload = decodeToken(token);
      if (payload == null) return true;

      if (payload.containsKey('exp')) {
        final exp = payload['exp'] as int?;
        if (exp != null) {
          final expirationDate =
              DateTime.fromMillisecondsSinceEpoch(exp * 1000);
          final isExpired = DateTime.now().isAfter(expirationDate);
          return isExpired;
        }
      }

      return false; // If no exp field, assume it's valid
    } catch (e) {
      AppLogger.error('Error checking token expiration: $e');
      return true; // If error, assume expired for safety
    }
  }

  /// Get all user information from token
  Map<String, dynamic>? getUserInfo(String token) {
    try {
      final payload = decodeToken(token);
      if (payload == null) return null;

      return {
        'userId': getUserId(token),
        'username': getUsername(token),
        'isExpired': isTokenExpired(token),
        'rawPayload': payload,
      };
    } catch (e) {
      AppLogger.error('Error getting user info from token: $e');
      return null;
    }
  }
}
