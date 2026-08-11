import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';

/// A bottom-bar tab when you write your OWN GoRouter.
///
/// Unlike [PlugNavRoute], this holds no page/path — your `StatefulShellRoute`
/// already defines those. You only describe how the tab looks.
///
/// This package is Riverpod-first: give it a [badgeProvider] —
/// `ProviderListenable<int>` — from your own app (backed by Firebase or
/// anything else) and the nav bar watches it directly:
///
/// ```dart
/// PlugNavItem(
///   icon: Icons.shopping_cart,
///   label: 'Cart',
///   badgeProvider: cartCountProvider, // defined in YOUR app
/// )
/// ```
class PlugNavItem {
  final IconData icon;

  /// Optional icon shown when selected. Falls back to [icon].
  final IconData? activeIcon;

  final String label;

  /// Static badge count (e.g. a fixed "new" indicator). 0 hides the badge.
  /// Ignored when [badgeProvider] is set.
  final int badgeCount;

  /// A Riverpod provider the nav bar watches for a live badge count. Takes
  /// priority over [badgeCount] when set. The package doesn't care what
  /// backs it — Firebase, local state, anything — only that it resolves
  /// to an `int`.
  final ProviderListenable<int>? badgeProvider;

  /// Accessibility label read by screen readers, e.g. "Home navigation".
  /// Falls back to [label] when omitted.
  final String? semanticLabel;

  const PlugNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.badgeCount = 0,
    this.badgeProvider,
    this.semanticLabel,
  });
}
