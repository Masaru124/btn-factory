import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppConstants {
  static const String appName = 'Fabricana Supreme';
  static const String logoAsset = 'assets/images/logo.jpeg';

  static String? _configuredApiBaseUrl;
  static String? _selectedBackendUrl;
  static List<String> backendUrls = [
    'https://aptly-nearly-footnote.ngrok-free.dev',
    'http://fasti2.duckdns.org',
    'http://fasti2.duckdns.org:8080',
    'http://fasti2.duckdns.org:8000',
    'http://testtt234e.duckdns.org',
    'http://127.0.0.1:8000',
    'http://localhost:8000',
  ];
  static String defaultDuckDnsDomain = 'fasti2.duckdns.org';

  /// Loads configuration from compile-time defines or optional local .env
  static Future<void> loadEnv() async {
    // 1. Check official Flutter compile-time defines (Vercel / CI)
    const dartDefineApi = String.fromEnvironment('API_BASE_URL');
    if (dartDefineApi.trim().isNotEmpty) {
      _configuredApiBaseUrl = dartDefineApi.trim();
    }
    const dartDefineBackends = String.fromEnvironment('BACKEND_URLS');
    if (dartDefineBackends.trim().isNotEmpty) {
      final list = dartDefineBackends.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (list.isNotEmpty) {
        backendUrls = list;
      }
    }

    // 2. Safe optional local .env reading (never crashes if .env is missing)
    try {
      final content = await rootBundle.loadString('.env');
      final lines = content.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final eqIdx = trimmed.indexOf('=');
        if (eqIdx == -1) continue;
        final key = trimmed.substring(0, eqIdx).trim();
        final value = trimmed.substring(eqIdx + 1).trim().replaceAll('"', '').replaceAll("'", '');

        if (key == 'API_BASE_URL' && value.isNotEmpty) {
          _configuredApiBaseUrl = value;
        } else if (key == 'BACKEND_URLS' && value.isNotEmpty) {
          final list = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          if (list.isNotEmpty) {
            backendUrls = list;
          }
        } else if (key == 'DEFAULT_DUCKDNS_DOMAIN' && value.isNotEmpty) {
          defaultDuckDnsDomain = value;
        }
      }
    } catch (_) {
      // Safely ignored on Vercel or any environment without a local .env file
    }
  }

  static void selectBackendUrl(String url) {
    var clean = url.trim();
    if (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    _selectedBackendUrl = clean;
  }

  static String get selectedBackendUrl => _selectedBackendUrl ?? '';

  static String get apiBaseUrl {
    // 1. User interactively selected backend URL
    if (_selectedBackendUrl != null && _selectedBackendUrl!.isNotEmpty) {
      var url = _selectedBackendUrl!;
      if (!url.endsWith('/api')) {
        url = '$url/api';
      }
      return url;
    }

    // 2. Compile-time or frontend .env defined URL
    const dartDefineUrl = String.fromEnvironment('API_BASE_URL');
    if (dartDefineUrl.trim().isNotEmpty) {
      return dartDefineUrl.trim();
    }
    if (_configuredApiBaseUrl != null && _configuredApiBaseUrl!.isNotEmpty) {
      var url = _configuredApiBaseUrl!;
      if (!url.endsWith('/api')) {
        url = '$url/api';
      }
      return url;
    }

    // 3. Dynamic origin detection for Web (supports LAN IP e.g. 192.168.1.50, DuckDNS, Cloudflare Tunnel, ngrok)
    if (kIsWeb) {
      final uri = Uri.base;

      // Query parameter override: ?server=http://... or ?backend=... or ?api=...
      final queryServer = uri.queryParameters['server'] ??
          uri.queryParameters['backend'] ??
          uri.queryParameters['api'];
      if (queryServer != null && queryServer.trim().isNotEmpty) {
        var clean = queryServer.trim();
        if (!clean.startsWith('http://') && !clean.startsWith('https://')) {
          clean = '${uri.scheme}://$clean';
        }
        if (clean.endsWith('/')) {
          clean = clean.substring(0, clean.length - 1);
        }
        if (!clean.endsWith('/api')) {
          clean = '$clean/api';
        }
        return clean;
      }

      final host = uri.host;
      final port = uri.port;
      final scheme = uri.scheme;

      // When running on frontend dev port (3000) or ephemeral debug port (10000+)
      if (port == 3000 || port > 10000) {
        if (host == 'localhost' || host == '127.0.0.1') {
          return 'http://127.0.0.1:8000/api';
        }
        return '$scheme://$host:8000/api';
      }

      // Normal reverse proxy origin (ports 80, 443, 8080, Cloudflare tunnel, ngrok)
      return '${uri.origin}/api';
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
