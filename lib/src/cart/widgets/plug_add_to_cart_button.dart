import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

/// Visual state the button should render. Your app decides this (from its
/// own Firebase-backed cart state) — this widget never owns cart data.
enum PlugAddToCartState {
  /// Not in cart yet — show [addText].
  idle,

  /// Async add in progress — show a spinner, ignore taps.
  loading,

  /// Already in cart — show [addedText] or the quantity stepper.
  added,
}

/// A stateless add-to-cart button. All state (idle/loading/added, current
/// quantity) is passed in by your app — this widget just renders it and
/// reports taps via callbacks.
///
/// ```dart
/// PlugAddToCartButton(
///   state: myCartState, // derived from YOUR cart provider
///   quantity: myQty,
///   onAdd: () => ref.read(cartRepo).add(item),       // your Firebase call
///   onIncrease: () => ref.read(cartRepo).increase(item),
///   onDecrease: () => ref.read(cartRepo).decrease(item),
/// )
/// ```
class PlugAddToCartButton extends StatelessWidget {
  final PlugAddToCartState state;

  /// Current quantity in cart. Only used when [state] is
  /// [PlugAddToCartState.added] and [showStepperWhenAdded] is true.
  final int quantity;

  /// Optional UI-only cap on quantity. When set and [quantity] has reached
  /// it, the stepper's "+" is disabled (dimmed, ignores taps) instead of
  /// calling [onIncrease]. Display/interaction guard only — enforce the
  /// real limit server-side wherever the order is actually placed. Null
  /// means no cap. If you're passing a [PlugCartItem], this is typically
  /// `item.maxQuantity`.
  final int? maxQuantity;

  final String addText;
  final String addedText;

  final Color color;
  final Color textColor;

  /// Show a − / qty / + stepper instead of the "Change" label once added.
  final bool showStepperWhenAdded;

  final double height;
  final double borderRadius;
  final TextStyle? textStyle;

  /// Tapped when [state] is idle.
  final VoidCallback? onAdd;

  /// Tapped when [state] is added and [showStepperWhenAdded] is false.
  final VoidCallback? onChangePressed;

  /// Tapped on the stepper's "+" when [state] is added and
  /// [showStepperWhenAdded] is true.
  final VoidCallback? onIncrease;

  /// Tapped on the stepper's "−" when [state] is added and
  /// [showStepperWhenAdded] is true.
  final VoidCallback? onDecrease;

  /// Play a light haptic tick on add/increase/decrease taps (Blinkit-style
  /// feel). Set false to disable — e.g. if your app already triggers its
  /// own haptics, or during widget tests.
  final bool enableHaptics;

  const PlugAddToCartButton({
    super.key,
    required this.state,
    this.quantity = 0,
    this.maxQuantity,
    this.addText = 'Add',
    this.addedText = 'Change',
    this.color = Colors.green,
    this.textColor = Colors.white,
    this.showStepperWhenAdded = true,
    this.height = 40,
    this.borderRadius = 10,
    this.textStyle,
    this.onAdd,
    this.onChangePressed,
    this.onIncrease,
    this.onDecrease,
    this.enableHaptics = true,
  });

  void _haptic() {
    if (enableHaptics) HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    if (state == PlugAddToCartState.loading) {
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

    if (state == PlugAddToCartState.added && showStepperWhenAdded) {
      final atMax = maxQuantity != null && quantity >= maxQuantity!;
      return _Stepper(
        quantity: quantity,
        color: color,
        textColor: textColor,
        height: height,
        borderRadius: borderRadius,
        onIncrease: atMax
            ? null
            : () {
                _haptic();
                (onIncrease ?? () {})();
              },
        onDecrease: () {
          _haptic();
          (onDecrease ?? () {})();
        },
      );
    }

    final added = state == PlugAddToCartState.added;

    return SizedBox(
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
        onPressed: added
            ? onChangePressed
            : (onAdd == null
                ? null
                : () {
                    _haptic();
                    onAdd!();
                  }),
        child: Text(
          added ? addedText : addText,
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
  final VoidCallback? onIncrease;
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
          _StepBtn(
            icon: Icons.add,
            color: onIncrease == null
                ? textColor.withValues(alpha: 0.4)
                : textColor,
            onTap: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

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
