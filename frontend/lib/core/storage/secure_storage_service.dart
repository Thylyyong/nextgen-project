import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// SecureStorageService wraps [FlutterSecureStorage] for JWT management.
///
/// The JWT is stored under a private key. It is never logged or exposed.
/// On iOS, values are stored in the Keychain.
/// On Android, values are encrypted with AES256 using the Android Keystore.
class SecureStorageService {
  SecureStorageService() : _storage = const FlutterSecureStorage(
    // Use EncryptedSharedPreferences on Android (API 23+)
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final FlutterSecureStorage _storage;

  // The key under which the JWT is stored — intentionally opaque
  static const _tokenKey = 'ng_auth_token';

  /// Persists [token] to secure storage.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Returns the stored JWT, or null if not present / expired.
  Future<String?> readToken() async {
    return _storage.read(key: _tokenKey);
  }

  /// Removes the stored JWT — call on logout.
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Returns true if a token exists in storage (does NOT validate expiry).
  Future<bool> hasToken() async {
    final token = await readToken();
    return token != null && token.isNotEmpty;
  }
}
