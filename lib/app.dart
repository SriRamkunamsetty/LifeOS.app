import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/dashboard/presentation/dashboard_shell.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'providers/app_providers.dart';

class LifeOsApp extends ConsumerWidget {
  const LifeOsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'LifeOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      ref.read(authServiceProvider).authStateChanges(),
    ),
    redirect: (context, state) {
      final firebaseReady = ref.read(firebaseReadyProvider);
      if (!firebaseReady) {
        return state.uri.path == '/auth' ? null : '/auth';
      }

      final authState = ref.read(authStateChangesProvider).valueOrNull;
      final profile = ref.read(userProfileStreamProvider).valueOrNull;
      final isAuthRoute = state.uri.path == '/auth';
      final isOnboarding = state.uri.path == '/onboarding';

      if (authState == null) {
        return isAuthRoute ? null : '/auth';
      }

      final doneOnboarding = profile?.onboardingCompleted ?? false;
      if (!doneOnboarding) {
        return isOnboarding ? null : '/onboarding';
      }

      if (isAuthRoute || isOnboarding) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/', builder: (context, state) => const DashboardShell()),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
