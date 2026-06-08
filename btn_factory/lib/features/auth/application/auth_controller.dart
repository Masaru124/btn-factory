import 'package:btn_factory/core/constants/app_constants.dart';
import 'package:btn_factory/core/network/api_client.dart';
import 'package:btn_factory/core/storage/secure_storage.dart';
import 'package:btn_factory/features/auth/application/auth_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(AppStorageKeys.accessToken);

    if (token == null || token.isEmpty) {
      return AuthState.unauthenticated();
    }

    return AuthState.authenticated(
      accessToken: token,
      userName: await storage.read(AppStorageKeys.userName) ?? 'Super Admin',
      userEmail: await storage.read(AppStorageKeys.userEmail) ?? 'admin@factory.local',
      userRole: await storage.read(AppStorageKeys.userRole) ?? 'super_admin',
      userDepartment: await storage.read(AppStorageKeys.userDepartment) ?? 'admin',
    );
  }

  Future<bool> login({required String email, required String password}) async {
    state = const AsyncLoading();
    final dio = ref.read(dioProvider);
    final storage = ref.read(secureStorageProvider);

    try {
      final Response<dynamic> response = await dio.post<dynamic>(
        '/auth/login',
        data: <String, dynamic>{'email': email, 'password': password},
      );

      final Map<String, dynamic> data = Map<String, dynamic>.from(response.data as Map<dynamic, dynamic>);
      final String accessToken = data['access_token'] as String;
      final Map<String, dynamic> user = Map<String, dynamic>.from(data['user'] as Map<dynamic, dynamic>);

      await storage.write(key: AppStorageKeys.accessToken, value: accessToken);
      await storage.write(key: AppStorageKeys.userName, value: (user['name'] ?? 'Super Admin') as String);
      await storage.write(key: AppStorageKeys.userEmail, value: (user['email'] ?? email) as String);
      await storage.write(key: AppStorageKeys.userRole, value: (user['role'] ?? 'super_admin') as String);
      await storage.write(key: AppStorageKeys.userDepartment, value: (user['department'] ?? 'admin') as String);

      state = AsyncData(
        AuthState.authenticated(
          accessToken: accessToken,
          userName: (user['name'] ?? 'Super Admin') as String,
          userEmail: (user['email'] ?? email) as String,
          userRole: (user['role'] ?? 'super_admin') as String,
          userDepartment: (user['department'] ?? 'admin') as String,
        ),
      );
      return true;
    } on DioException catch (error, stackTrace) {
      final message = _extractMessage(error);
      state = AsyncError(message, stackTrace);
      return false;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    await storage.deleteAll();
    state = AsyncData(AuthState.unauthenticated());
  }

  String _extractMessage(DioException error) {
    final dynamic data = error.response?.data;
    if (data is Map && data['detail'] != null) {
      return data['detail'].toString();
    }
    return 'Unable to sign in right now. Check the backend connection and try again.';
  }
}
