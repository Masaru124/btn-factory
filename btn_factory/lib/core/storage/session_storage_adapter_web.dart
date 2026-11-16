import 'package:web/web.dart' as web;
import 'secure_storage.dart';

class WebSessionStorageAdapter implements SecureStorage {
  @override
  Future<void> delete(String key) async {
    web.window.sessionStorage.removeItem(key);
    web.window.localStorage.removeItem(key);
  }

  @override
  Future<void> deleteAll() async {
    web.window.sessionStorage.clear();
    web.window.localStorage.clear();
  }

  @override
  Future<String?> read(String key) async {
    return web.window.sessionStorage.getItem(key);
  }

  @override
  Future<void> write({required String key, required String value}) async {
    web.window.sessionStorage.setItem(key, value);
    // Purge from localStorage so it never persists across browser tab closures
    web.window.localStorage.removeItem(key);
  }
}

SecureStorage getWebSessionStorage() => WebSessionStorageAdapter();
