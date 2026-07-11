class AppConstants {
  static const String appName = 'Button Factory MES';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://btn-factory.onrender.com/api',
  );
}

class AppStorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';
  static const String userRole = 'user_role';
  static const String userDepartment = 'user_department';
}
