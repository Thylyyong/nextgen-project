import 'package:dio/dio.dart';
import 'package:nextgen/auth/model/auth_model.dart';
import 'package:nextgen/core/network/api_client.dart';
import 'package:nextgen/core/storage/secure_storage_service.dart';

/// AuthService coordinates registration, login, and logout operations.
///
/// On a successful login/register, the JWT is automatically persisted
/// to [SecureStorageService] so [ApiClient]'s interceptor picks it up
/// for all subsequent requests.
class AuthService {
  AuthService({
    required ApiClient apiClient,
    required SecureStorageService storageService,
  })  : _api = apiClient,
        _storage = storageService;

  final ApiClient _api;
  final SecureStorageService _storage;

  // ── Register ────────────────────────────────────────────────────────────────
  /// Creates a new account.
  /// Throws [DioException] on network/server errors.
  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/register',
      data: request.toJson(),
    );
    final auth = AuthResponse.fromJson(response.data!);
    await _storage.saveToken(auth.token); // Persist token immediately
    return auth;
  }

  // ── Login ───────────────────────────────────────────────────────────────────
  /// Authenticates an existing user.
  /// Throws [DioException] on network/server errors.
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/auth/login',
      data: request.toJson(),
    );
    final auth = AuthResponse.fromJson(response.data!);
    await _storage.saveToken(auth.token); // Persist token
    return auth;
  }

  // ── Logout ──────────────────────────────────────────────────────────────────
  /// Clears the stored JWT. The interceptor will stop sending auth headers.
  Future<void> logout() async {
    await _storage.clearToken();
  }
}
