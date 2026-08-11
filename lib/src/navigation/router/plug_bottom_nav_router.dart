import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/plug_bottom_nav_config.dart';
import '../models/plug_nav_route.dart';
import '../widgets/plug_navigation_shell.dart';

/// Plug-and-play GoRouter factory.
///
/// You pass a flat list of tabs ([PlugNavRoute]) and config. This builds the
/// entire `StatefulShellRoute.indexedStack` for you — you never write shell
/// route boilerplate. The selected tab index is kept in
/// `plugSelectedIndexProvider` automatically — read it from anywhere with
/// `ref.watch(plugSelectedIndexProvider)`.
///
/// ```dart
/// final router = PlugBottomNavRouter.create(
///   initialLocation: '/home',
///   items: [...],
///   navConfig: const PlugBottomNavConfig(floating: true),
/// );
///
/// MaterialApp.router(routerConfig: router);
/// ```
class PlugBottomNavRouter {
  const PlugBottomNavRouter._();

  static GoRouter create({
    required String initialLocation,
    required List<PlugNavRoute> items,
    PlugBottomNavConfig navConfig = const PlugBottomNavConfig(),

    /// Top-level routes that live OUTSIDE the shell (no bottom bar), e.g.
    /// `/login`, `/onboarding`, full-screen flows.
    List<RouteBase> extraRoutes = const [],

    /// Optional global redirect (auth gating etc.).
    GoRouterRedirect? redirect,

    /// Passed straight through to [GoRouter].
    GlobalKey<NavigatorState>? navigatorKey,
    bool debugLogDiagnostics = false,
    List<NavigatorObserver>? observers,
    Widget Function(BuildContext, GoRouterState)? errorBuilder,
  }) {
    assert(items.isNotEmpty, 'PlugBottomNavRouter needs at least one item.');

    final shellRoute = StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return PlugNavigationShell(
          navigationShell: navigationShell,
          items: items.map((r) => r.toItem()).toList(),
          config: navConfig,
        );
      },
      branches: [
        for (final item in items)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: item.path,
                // Root tab pages use no route-level transition — the shell
                // (PlugNavigationShell) animates tab switches. This avoids a
                // double animation. Nested [item.routes] keep their own.
                pageBuilder: (context, state) =>
                    NoTransitionPage(key: state.pageKey, child: item.page),
                routes: item.routes,
              ),
            ],
          ),
      ],
    );

    return GoRouter(
      initialLocation: initialLocation,
      navigatorKey: navigatorKey,
      debugLogDiagnostics: debugLogDiagnostics,
      observers: observers,
      redirect: redirect,
      errorBuilder: errorBuilder,
      routes: [shellRoute, ...extraRoutes],
    );
  }
}
