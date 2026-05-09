import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/main_layout/presentation/screens/main_layout_screen.dart';
import '../../features/moderation/presentation/screens/moderation_screen.dart';
import '../../features/users/presentation/screens/profile_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: ValueNotifier(ref.watch(authControllerProvider)),
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isLoggingIn = state.uri.path == '/login';
      final isSplashScreen = state.uri.path == '/splash';

      return authState.when(
        data: (profile) {
          if (profile == null || !profile.isAdmin) {
            return isLoggingIn ? null : '/login';
          }
          // If we are on login or splash and authenticated, go to dashboard
          if (isLoggingIn || isSplashScreen) return '/';
          return null;
        },
        loading: () => isSplashScreen ? null : '/splash',
        error: (err, stack) => '/login',
      );
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayoutScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/users/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ProfileDetailScreen(userId: id);
            },
          ),
          GoRoute(
            path: '/moderation',
            builder: (context, state) => const ModerationScreen(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Users Management'))),
          ),
          GoRoute(
            path: '/chats',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Chat Management'))),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Settings'))),
          ),
        ],
      ),
    ],
  );
});
