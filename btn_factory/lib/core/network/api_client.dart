import 'dart:async';
import 'package:btn_factory/core/constants/app_constants.dart';
import 'package:btn_factory/core/storage/secure_storage.dart';
import 'package:btn_factory/features/auth/application/auth_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: <String, dynamic>{
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
        'X-Client-Platform': kIsWeb ? 'web' : 'native',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(AppStorageKeys.accessToken);
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        // Handle 401 Unauthorized
        if (e.response?.statusCode == 401 && e.requestOptions.path != '/auth/login') {
          ref.read(authControllerProvider.notifier).logout();
          return handler.next(e);
        }

        // Retry network timeout on idempotent GET requests (up to 2 attempts for factory Wi-Fi blips)
        final bool isGet = e.requestOptions.method.toUpperCase() == 'GET';
        final bool isNetworkError = e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.receiveTimeout;

        final int retryCount = (e.requestOptions.extra['retry_count'] as int?) ?? 0;
        if (isGet && isNetworkError && retryCount < 2) {
          e.requestOptions.extra['retry_count'] = retryCount + 1;
          await Future<void>.delayed(Duration(milliseconds: 1000 * (retryCount + 1)));
          try {
            final response = await dio.fetch(e.requestOptions);
            return handler.resolve(response);
          } catch (retryError) {
            if (retryError is DioException) {
              return handler.next(retryError);
            }
          }
        }

        handler.next(e);
      },
    ),
  );

  return dio;
});
