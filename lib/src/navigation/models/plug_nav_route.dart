import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
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

  /// Optional static per-tab badge count. Ignored when [badgeProvider] is
  /// set.
  final int badgeCount;

  /// A Riverpod provider watched for a live badge count on this tab, e.g.
  /// `badgeProvider: cartCountProvider` where `cartCountProvider` is
  /// defined in your own app. See [PlugNavItem.badgeProvider].
  final ProviderListenable<int>? badgeProvider;

  /// Accessibility label read by screen readers. Falls back to [label].
  final String? semanticLabel;

  const PlugNavRoute({
    required this.path,
    required this.icon,
    required this.label,
    required this.page,
    this.activeIcon,
    this.routes = const [],
    this.badgeCount = 0,
    this.badgeProvider,
    this.semanticLabel,
  });

  /// The bar-only view of this route (icon + label + badge).
  PlugNavItem toItem() => PlugNavItem(
        icon: icon,
        activeIcon: activeIcon,
        label: label,
        badgeCount: badgeCount,
        badgeProvider: badgeProvider,
        semanticLabel: semanticLabel,
      );
}
