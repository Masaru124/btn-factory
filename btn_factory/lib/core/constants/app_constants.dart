class AppConstants {
  static const String appName = 'Button Factory MES';

  static String get apiBaseUrl {
    const dartDefineUrl = String.fromEnvironment('API_BASE_URL');
    if (dartDefineUrl.trim().isNotEmpty) {
      return dartDefineUrl.trim();
    }
    return 'http://127.0.0.1:8000/api';
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
