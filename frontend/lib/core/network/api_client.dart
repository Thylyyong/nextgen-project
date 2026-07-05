import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:nextgen/core/storage/secure_storage_service.dart';

/// Centralized HTTP client — adapted from storex_customer's ApiClient pattern.
///
/// Key behaviours:
/// - All requests include `Content-Type: application/json`
/// - The JWT is automatically injected via [InterceptorsWrapper.onRequest]
/// - 401 responses automatically clear the stored token
/// - Timeouts are enforced at both connect and receive phases
class ApiClient {
  ApiClient({required SecureStorageService storageService})
      : _storage = storageService {
    _dio = Dio(
      BaseOptions(
        // Change this to your server's host before deploying:
        // Android emulator: http://10.0.2.2:8080/api
        // iOS simulator / macOS desktop: http://localhost:8080/api
        baseUrl: 'http://localhost:8080/api',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        // ── Inject Bearer token on every request ──────────────────────
        onRequest: (options, handler) async {
          final token = await _storage.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          _log.d('[API] ${options.method} ${options.uri}');
          return handler.next(options);
        },
        // ── Log responses in debug mode ───────────────────────────────
        onResponse: (response, handler) {
          _log.d('[API] ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
        // ── Handle global errors ──────────────────────────────────────
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Token expired or invalid — clear local storage
            await _storage.clearToken();
            _log.w('[API] 401 — token cleared. Redirect to login.');
          }
          _log.e(
            '[API] Error: ${e.message}',
            error: e,
            stackTrace: e.stackTrace,
          );
          return handler.next(e);
        },
      ),
    );
  }

  late final Dio _dio;
  final SecureStorageService _storage;
  final _log = Logger();

  // ── Convenience wrappers (matches storex_customer ApiClient signature) ─────

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) async {
    return _dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) async {
    return _dio.put<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path, {dynamic data}) async {
    return _dio.delete<T>(path, data: data);
  }
}
