import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/plug_cart_provider.dart';

/// Floating green cart bar (Blinkit / Instacart style).
///
/// Watches one seller's cart and shows item count + total + a "view cart"
/// affordance. Auto-hides (returns an empty box) when that seller's cart is
/// empty, unless [alwaysShow] is true.
class PlugCartBar extends ConsumerWidget {
  final String sellerId;

  final Color backgroundColor;
  final Color foregroundColor;
  final String viewCartText;

  /// Optional currency prefix used when formatting the total (e.g. '₹', '\$').
  final String currencySymbol;

  /// Keep showing even when empty. Default false (hidden when empty).
  final bool alwaysShow;

  final EdgeInsets margin;
  final double height;
  final double borderRadius;

  final VoidCallback onTap;

  const PlugCartBar({
    super.key,
    required this.sellerId,
    required this.onTap,
    this.backgroundColor = Colors.green,
    this.foregroundColor = Colors.white,
    this.viewCartText = 'View Cart',
    this.currencySymbol = '\$',
    this.alwaysShow = false,
    this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 16),
    this.height = 56,
    this.borderRadius = 16,
  });

  String _money(double v) => '$currencySymbol${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(plugCartCountProvider(sellerId));
    final total = ref.watch(plugCartTotalProvider(sellerId));

    if (count == 0 && !alwaysShow) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: margin,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        elevation: 6,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _CountBadge(count: count, color: foregroundColor),
                  const SizedBox(width: 12),
                  Text(
                    _money(total),
                    style: TextStyle(
                      color: foregroundColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    viewCartText,
                    style: TextStyle(
                      color: foregroundColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_ios,
                      size: 14, color: foregroundColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final Color color;

  const _CountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count item${count == 1 ? '' : 's'}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
