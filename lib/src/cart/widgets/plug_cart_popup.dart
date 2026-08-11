import 'package:flutter/material.dart';

import '../models/plug_cart_item.dart';

/// The "Added to cart" confirmation popup shown right after a user taps
/// add-to-cart. Purely presentational — call [show] with the item that was
/// just added; your app decides *when* to call it (after your own Firebase
/// write succeeds, or optimistically — your choice).
///
/// ```
/// --------------------------------
/// Added to:
///
/// 🏪 CSP Traders
///
/// UltraTech Cement
/// Qty: 10 Bags
///
/// [View Cart]
/// --------------------------------
/// ```
class PlugCartPopup extends StatelessWidget {
  final PlugSellerInfo seller;
  final PlugCartItem item;

  /// Optional unit label appended after quantity, e.g. "Bags", "kg".
  /// Left empty to just show the raw quantity.
  final String unitLabel;

  final String addedToText;
  final String viewCartText;
  final VoidCallback onViewCart;
  final VoidCallback? onDismiss;

  final Color backgroundColor;
  final Color accentColor;

  const PlugCartPopup({
    super.key,
    required this.seller,
    required this.item,
    required this.onViewCart,
    this.unitLabel = '',
    this.addedToText = 'Added to:',
    this.viewCartText = 'View Cart',
    this.onDismiss,
    this.backgroundColor = Colors.white,
    this.accentColor = Colors.green,
  });

  /// Shows this popup as a bottom sheet. Auto-dismisses after
  /// [autoDismissAfter] unless the user interacts with it first (standard
  /// modal bottom sheet behavior — tapping outside also dismisses).
  ///
  /// [animationDuration] and [animationCurve] control the slide-up entry
  /// animation (Blinkit-style pop). Defaults to a quick 250ms ease-out.
  static Future<void> show({
    required BuildContext context,
    required PlugSellerInfo seller,
    required PlugCartItem item,
    required VoidCallback onViewCart,
    String unitLabel = '',
    Duration? autoDismissAfter = const Duration(seconds: 3),
    Duration animationDuration = const Duration(milliseconds: 250),
    Curve animationCurve = Curves.easeOut,
    Color backgroundColor = Colors.white,
    Color accentColor = Colors.green,
  }) async {
    final navigator = Navigator.of(context);
    if (autoDismissAfter != null) {
      Future.delayed(autoDismissAfter, () {
        if (navigator.canPop()) navigator.pop();
      });
    }
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: AnimationStyle(
        duration: animationDuration,
        curve: animationCurve,
      ),
      builder: (ctx) => PlugCartPopup(
        seller: seller,
        item: item,
        unitLabel: unitLabel,
        backgroundColor: backgroundColor,
        accentColor: accentColor,
        onViewCart: () {
          Navigator.of(ctx).pop();
          onViewCart();
        },
      ),
    );
  }

  /// Convenience wrapper for the common "await the backend call, then show
  /// the confirmation" flow. Runs [future] (typically your Firebase/API
  /// add-to-cart call) and only calls [show] once it completes
  /// successfully. If [future] throws, [show] is skipped and the error
  /// propagates to the caller — pair this with your own loading indicator
  /// (e.g. [PlugAddToCartState.loading] on `PlugAddToCartButton`) so the
  /// user sees a spinner during [future] rather than nothing.
  ///
  /// ```dart
  /// await PlugCartPopup.showSuccess(
  ///   context: context,
  ///   seller: seller,
  ///   item: item,
  ///   onViewCart: () => context.push('/cart/${seller.sellerId}'),
  ///   future: () => myCartRepo.add(item), // your Firebase call
  /// );
  /// ```
  static Future<void> showSuccess({
    required BuildContext context,
    required PlugSellerInfo seller,
    required PlugCartItem item,
    required VoidCallback onViewCart,
    required Future<void> Function() future,
    String unitLabel = '',
    Duration? autoDismissAfter = const Duration(seconds: 3),
    Duration animationDuration = const Duration(milliseconds: 250),
    Curve animationCurve = Curves.easeOut,
    Color backgroundColor = Colors.white,
    Color accentColor = Colors.green,
  }) async {
    await future();
    if (!context.mounted) return;
    return show(
      context: context,
      seller: seller,
      item: item,
      onViewCart: onViewCart,
      unitLabel: unitLabel,
      autoDismissAfter: autoDismissAfter,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      backgroundColor: backgroundColor,
      accentColor: accentColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addedToText,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _SellerIcon(seller: seller, accentColor: accentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            seller.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (seller.location.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      seller.location,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (item.image.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.image,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _ImageFallback(
                            accentColor: accentColor,
                          ),
                        ),
                      )
                    else
                      _ImageFallback(accentColor: accentColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.subtitle.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              item.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 2),
                          Text(
                            unitLabel.isEmpty
                                ? 'Qty: ${item.quantity}'
                                : 'Qty: ${item.quantity} $unitLabel',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onViewCart,
                    child: Text(
                      viewCartText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SellerIcon extends StatelessWidget {
  final PlugSellerInfo seller;
  final Color accentColor;

  const _SellerIcon({required this.seller, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    if (seller.image.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          seller.image,
          width: 22,
          height: 22,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.storefront, size: 20, color: accentColor),
        ),
      );
    }
    return Icon(Icons.storefront, size: 20, color: accentColor);
  }
}

class _ImageFallback extends StatelessWidget {
  final Color accentColor;

  const _ImageFallback({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.inventory_2_outlined, color: accentColor, size: 22),
    );
  }
}
