import 'package:flutter/foundation.dart';

class AppConstants {
  static const String appName = 'Button Factory MES';

  static String get apiBaseUrl {
    const dartDefineUrl = String.fromEnvironment('API_BASE_URL');
    if (dartDefineUrl.trim().isNotEmpty) {
      return dartDefineUrl.trim();
    }
    // Dynamic origin detection for Web (supports LAN IP e.g. 192.168.1.50, Caddy port 80, or ngrok)
    if (kIsWeb) {
      final origin = Uri.base.origin;
      // When running Flutter web debug on ephemeral port (e.g. 50000+), connect to local backend port 8000
      final port = Uri.base.port;
      if (port > 10000) {
        return 'http://127.0.0.1:8000/api';
      }
      return '$origin/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  static String get mediaBaseUrl {
    const dartDefineUrl = String.fromEnvironment('MEDIA_BASE_URL');
    if (dartDefineUrl.trim().isNotEmpty) {
      return dartDefineUrl.trim();
    }
    // Automatically derive from apiBaseUrl so media requests route to backend host
    final apiUrl = apiBaseUrl;
    if (apiUrl.endsWith('/api')) {
      return apiUrl.substring(0, apiUrl.length - 4);
    } else if (apiUrl.endsWith('/api/')) {
      return apiUrl.substring(0, apiUrl.length - 5);
    }
    if (kIsWeb) {
      final origin = Uri.base.origin;
      final port = Uri.base.port;
      if (port > 10000) {
        return 'http://127.0.0.1:8000';
      }
      return origin;
    }
    return 'http://127.0.0.1:8000';
  }
}

class AppStorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';
  static const String userRole = 'user_role';
  static const String userDepartment = 'user_department';
}
