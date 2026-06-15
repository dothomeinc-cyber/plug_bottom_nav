import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/plug_cart_item.dart';
import '../providers/plug_cart_provider.dart';
import '../providers/plug_nav_provider.dart';

/// Instacart-style add-to-cart button.
///
/// Handles everything automatically:
///  * shows [addText] when the item is not in the cart,
///  * runs [onPressed] (your Firestore/API logic) with a spinner,
///  * flips to [addedText] once the item is in the cart,
///  * prevents double-taps while loading,
///  * optionally shows a quantity stepper (− qty +) once added.
///
/// You only style colors and text. State lives in [plugCartProvider].
class PlugAddToCartButton extends ConsumerWidget {
  final String sellerId;
  final PlugCartItem item;

  final String addText;
  final String addedText;

  final Color color;
  final Color textColor;

  /// Show a − / qty / + stepper instead of the "Change" label once in cart.
  final bool showStepperWhenAdded;

  final double height;
  final double borderRadius;
  final TextStyle? textStyle;

  /// Optional async side-effect (Firestore write, analytics, API call).
  /// Runs after the local cart is updated. Loading covers its full duration.
  final Future<void> Function()? onPressed;

  /// Called when the user taps while already added (only when stepper is off).
  final VoidCallback? onChangePressed;

  const PlugAddToCartButton({
    super.key,
    required this.sellerId,
    required this.item,
    this.addText = 'Add',
    this.addedText = 'Change',
    this.color = Colors.green,
    this.textColor = Colors.white,
    this.showStepperWhenAdded = true,
    this.height = 40,
    this.borderRadius = 10,
    this.textStyle,
    this.onPressed,
    this.onChangePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(plugCartProvider);
    final sellerItems = cart[sellerId];
    final inCart = sellerItems?.any((e) => e.id == item.id) ?? false;
    final qty = sellerItems
            ?.where((e) => e.id == item.id)
            .fold<int>(0, (s, e) => s + e.quantity) ??
        0;

    final loadingSet = ref.watch(plugAddToCartLoadingProvider);
    final loading = loadingSet.contains('$sellerId::${item.id}');

    Future<void> handleAdd() async {
      if (loading) return; // double-tap guard
      final loadingNotifier =
          ref.read(plugAddToCartLoadingProvider.notifier);
      loadingNotifier.start(sellerId, item.id);
      try {
        ref.read(plugCartProvider.notifier).addItem(
              sellerId: sellerId,
              item: item,
            );
        if (onPressed != null) await onPressed!();
      } finally {
        loadingNotifier.stop(sellerId, item.id);
      }
    }

    final radius = BorderRadius.circular(borderRadius);

    // 1) Loading spinner.
    if (loading) {
      return SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(color: color, borderRadius: radius),
          child: Center(
            child: SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(textColor),
              ),
            ),
          ),
        ),
      );
    }

    // 2) In cart + stepper mode → show − qty + control.
    if (inCart && showStepperWhenAdded) {
      return _Stepper(
        quantity: qty,
        color: color,
        textColor: textColor,
        height: height,
        borderRadius: borderRadius,
        onIncrease: () => ref
            .read(plugCartProvider.notifier)
            .increaseQty(sellerId: sellerId, itemId: item.id),
        onDecrease: () => ref
            .read(plugCartProvider.notifier)
            .decreaseQty(sellerId: sellerId, itemId: item.id),
      );
    }

    // 3) Plain button (Add / Change).
    return SizedBox(
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        onPressed: inCart ? (onChangePressed ?? () {}) : handleAdd,
        child: Text(
          inCart ? addedText : addText,
          style: textStyle ?? const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int quantity;
  final Color color;
  final Color textColor;
  final double height;
  final double borderRadius;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _Stepper({
    required this.quantity,
    required this.color,
    required this.textColor,
    required this.height,
    required this.borderRadius,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StepBtn(icon: Icons.remove, color: textColor, onTap: onDecrease),
          Text(
            '$quantity',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          _StepBtn(icon: Icons.add, color: textColor, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StepBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
