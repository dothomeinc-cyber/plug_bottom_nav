import 'package:flutter/material.dart';

/// Empty-state placeholder for cart screens/sheets. Purely presentational.
///
/// ```dart
/// items.isEmpty
///   ? const PlugEmptyCart()
///   : PlugSellerCartSheet(...)
/// ```
class PlugEmptyCart extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  /// Optional call-to-action, e.g. "Browse Products".
  final String? actionText;
  final VoidCallback? onAction;

  const PlugEmptyCart({
    super.key,
    this.title = 'Your cart is empty',
    this.subtitle = 'Items you add will show up here.',
    this.icon = Icons.shopping_cart_outlined,
    this.iconColor = Colors.grey,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: iconColor.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
