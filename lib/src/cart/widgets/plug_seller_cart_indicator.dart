import 'package:flutter/material.dart';

/// Floating summary bar shown while browsing a seller's catalog — "3 items
/// — View Cart". Pure UI: you pass in the item count and a pre-formatted
/// total string (this widget has no idea about currency/pricing).
///
/// ```dart
/// PlugSellerCartIndicator(
///   itemCount: myCartCount,       // from YOUR provider
///   totalText: '₹4,500',          // formatted by your app
///   onTap: () => showSellerCartSheet(...),
/// )
/// ```
class PlugSellerCartIndicator extends StatelessWidget {
  final int itemCount;

  /// Pre-formatted total, e.g. '₹4,500' or '\$45.00'. Omit to hide the
  /// total and only show the item count.
  final String? totalText;

  final String viewCartText;

  /// Hide entirely when [itemCount] is 0, unless [alwaysShow] is true.
  final bool alwaysShow;

  final VoidCallback onTap;

  final Color backgroundColor;
  final Color foregroundColor;
  final EdgeInsets margin;
  final double height;
  final double borderRadius;

  const PlugSellerCartIndicator({
    super.key,
    required this.itemCount,
    required this.onTap,
    this.totalText,
    this.viewCartText = 'View Cart',
    this.alwaysShow = false,
    this.backgroundColor = Colors.green,
    this.foregroundColor = Colors.white,
    this.margin = const EdgeInsets.fromLTRB(16, 0, 16, 16),
    this.height = 56,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0 && !alwaysShow) return const SizedBox.shrink();

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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: foregroundColor.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$itemCount item${itemCount == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: foregroundColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (totalText != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      totalText!,
                      style: TextStyle(
                        color: foregroundColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
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
