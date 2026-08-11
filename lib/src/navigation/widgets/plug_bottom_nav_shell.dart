import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/plug_bottom_nav_config.dart';
import '../models/plug_nav_item.dart';
import 'plug_navigation_shell.dart';

/// Drop-in bottom-navigation shell for when you write your OWN GoRouter.
///
/// Put it inside your `StatefulShellRoute.indexedStack` builder. You pass the
/// `navigationShell` GoRouter gives you plus a list of [PlugNavItem]s (icon +
/// label only — your router already owns the pages/paths).
///
/// ```dart
/// StatefulShellRoute.indexedStack(
///   builder: (context, state, navigationShell) => PlugBottomNavShell(
///     navigationShell: navigationShell,
///     items: const [
///       PlugNavItem(icon: Icons.home,   label: 'Home'),
///       PlugNavItem(icon: Icons.person, label: 'Account'),
///     ],
///     config: const PlugBottomNavConfig(floating: true),
///   ),
///   branches: [...],
/// );
/// ```
///
/// It handles: pinned / floating / reverse / hide-on-scroll, selected &
/// unselected colors, background, badges, and tab transitions. The
/// selected tab index is synced automatically into
/// `plugSelectedIndexProvider` — read it from anywhere with
/// `ref.watch(plugSelectedIndexProvider)`.
class PlugBottomNavShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<PlugNavItem> items;
  final PlugBottomNavConfig config;

  const PlugBottomNavShell({
    super.key,
    required this.navigationShell,
    required this.items,
    this.config = const PlugBottomNavConfig(),
  });

  @override
  Widget build(BuildContext context) {
    return PlugNavigationShell(
      navigationShell: navigationShell,
      items: items,
      config: config,
    );
  }
}
