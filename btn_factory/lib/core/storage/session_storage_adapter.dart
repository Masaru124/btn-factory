import 'secure_storage.dart';
import 'session_storage_adapter_stub.dart'
    if (dart.library.js_interop) 'session_storage_adapter_web.dart';

SecureStorage createWebSessionStorage() => getWebSessionStorage();
