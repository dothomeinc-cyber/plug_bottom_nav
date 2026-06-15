import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'plug_nav_item.dart';

/// A single tab/branch in the bottom navigation.
///
/// Each [PlugNavRoute] becomes one [StatefulShellBranch] with a root
/// [GoRoute] at [path]. Optional nested [routes] (sub-pages, details, etc.)
/// are attached under that branch so deep links keep the bottom bar visible.
class PlugNavRoute {
  /// Root location for this tab, e.g. `/home`. Must be unique and start `/`.
  final String path;

  /// Icon shown in the bottom bar.
  final IconData icon;

  /// Optional icon shown when this tab is selected. Falls back to [icon].
  final IconData? activeIcon;

  /// Label shown under the icon.
  final String label;

  /// Root page for this tab.
  final Widget page;

  /// Optional nested routes living under this branch (kept inside the shell).
  final List<RouteBase> routes;

  /// Optional per-tab badge count (e.g. cart items). 0 hides the badge.
  final int badgeCount;

  const PlugNavRoute({
    required this.path,
    required this.icon,
    required this.label,
    required this.page,
    this.activeIcon,
    this.routes = const [],
    this.badgeCount = 0,
  });

  /// The bar-only view of this route (icon + label + badge).
  PlugNavItem toItem() => PlugNavItem(
        icon: icon,
        activeIcon: activeIcon,
        label: label,
        badgeCount: badgeCount,
      );
}
