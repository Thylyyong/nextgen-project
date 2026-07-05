import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:nextgen/app/theme/app_theme.dart';
import 'package:nextgen/auth/service/auth_service.dart';
import 'package:nextgen/auth/view/login_page.dart';
import 'package:nextgen/auth/view/register_page.dart';
import 'package:nextgen/core/network/api_client.dart';
import 'package:nextgen/core/storage/secure_storage_service.dart';
import 'package:nextgen/product/service/product_service.dart';
import 'package:nextgen/product/view/product_page.dart';

// ─────────────────────────────────────────────
// Dependency Injection Setup
// ─────────────────────────────────────────────

/// Registers all singletons into GetIt's service locator.
/// Called once at startup before [runApp].
void _setupDependencies() {
  final getIt = GetIt.instance;

  // ── Core services ─────────────────────────────────────────────────────────
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(storageService: getIt<SecureStorageService>()),
  );

  // ── Feature services ──────────────────────────────────────────────────────
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(
      apiClient: getIt<ApiClient>(),
      storageService: getIt<SecureStorageService>(),
    ),
  );

  getIt.registerLazySingleton<ProductService>(
    () => ProductService(apiClient: getIt<ApiClient>()),
  );
}

// ─────────────────────────────────────────────
// Router
// ─────────────────────────────────────────────

/// GoRouter handles all navigation.
/// Redirect logic: if no token is stored → send to /login.
GoRouter _buildRouter() {
  final storageService = GetIt.I<SecureStorageService>();

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) async {
      final hasToken = await storageService.hasToken();
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!hasToken && !isAuthRoute) return '/login';
      if (hasToken && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const ProductPage(),
      ),
    ],
  );
}

// ─────────────────────────────────────────────
// Entry Point
// ─────────────────────────────────────────────

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _setupDependencies();
  runApp(NextGenApp());
}

class NextGenApp extends StatelessWidget {
  NextGenApp({super.key});

  // Router is built once and stored — GoRouter must be stable across rebuilds
  final _router = _buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NextGen Shop',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
    );
  }
}
