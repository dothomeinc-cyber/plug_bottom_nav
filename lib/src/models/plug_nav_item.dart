import 'package:flutter/material.dart';

/// A bottom-bar tab when you write your OWN GoRouter.
///
/// Unlike [PlugNavRoute], this holds no page/path — your `StatefulShellRoute`
/// already defines those. You only describe how the tab looks.
class PlugNavItem {
  final IconData icon;

  /// Optional icon shown when selected. Falls back to [icon].
  final IconData? activeIcon;

  final String label;

  /// Optional badge count (e.g. cart items). 0 hides the badge.
  final int badgeCount;

  const PlugNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.badgeCount = 0,
  });
}
