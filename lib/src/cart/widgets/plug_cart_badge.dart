import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// A small numeric badge over an icon — e.g. a cart icon in an app bar.
///
/// Purely presentational. Watches a Riverpod `ProviderListenable<int>`
/// your app provides and shows nothing when the count is 0.
///
/// ```dart
/// PlugCartBadge(
///   icon: Icons.shopping_cart_outlined,
///   countProvider: cartCountProvider, // defined in YOUR app
///   onTap: () => context.push('/cart'),
/// )
/// ```
class PlugCartBadge extends ConsumerWidget {
  final IconData icon;
  final ProviderListenable<int> countProvider;
  final VoidCallback? onTap;

  final Color iconColor;
  final double iconSize;
  final Color badgeColor;
  final Color badgeTextColor;

  const PlugCartBadge({
    super.key,
    required this.icon,
    required this.countProvider,
    this.onTap,
    this.iconColor = Colors.black87,
    this.iconSize = 26,
    this.badgeColor = Colors.red,
    this.badgeTextColor = Colors.white,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(countProvider);

    final iconWidget =
        Icon(icon, size: iconSize, color: iconColor);

    final content = count <= 0
        ? iconWidget
        : Stack(
            clipBehavior: Clip.none,
            children: [
              iconWidget,
              Positioned(
                right: -6,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 16),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );

    if (onTap == null) return content;

    return Semantics(
      button: true,
      label: count > 0
          ? 'Cart, $count ${count == 1 ? 'item' : 'items'}'
          : 'Cart',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: content,
        ),
      ),
    );
  }
}
