import 'package:flutter/foundation.dart';

/// The app's OWN cart line model — carries whatever business fields Dot
/// actually needs (price, GST, unit, discount...). This is deliberately
/// separate from `package:plug_commerce_ui`'s `PlugCartItem`, which is
/// intentionally UI-only (no price, no tax, no business logic).
///
/// [presentation/cart_controller.dart] maps this down to a `PlugCartItem`
/// only at the point where it's handed to a Plug widget — the package
/// itself never sees or needs to know about [priceInPaise], [gstPercent],
/// etc. This keeps `plug_commerce_ui` reusable across apps with completely
/// different pricing/tax models, and keeps Dot's real business data out of
/// a general-purpose UI package's release cycle.
@immutable
class CartItem {
  final String productId;
  final String sellerId;
  final String productName;
  final String variant; // e.g. "50kg Bag" — maps to PlugCartItem.subtitle
  final String image;
  final int quantity;
  final int? maxQuantity;

  /// Price fields plug_commerce_ui deliberately has no concept of.
  final int priceInPaise;
  final double gstPercent;

  const CartItem({
    required this.productId,
    required this.sellerId,
    required this.productName,
    this.variant = '',
    this.image = '',
    this.quantity = 1,
    this.maxQuantity,
    this.priceInPaise = 0,
    this.gstPercent = 0,
  });

  double get lineTotalRupees =>
      (priceInPaise * quantity * (1 + gstPercent / 100)) / 100;

  CartItem copyWith({
    String? productId,
    String? sellerId,
    String? productName,
    String? variant,
    String? image,
    int? quantity,
    int? maxQuantity,
    int? priceInPaise,
    double? gstPercent,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      sellerId: sellerId ?? this.sellerId,
      productName: productName ?? this.productName,
      variant: variant ?? this.variant,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      priceInPaise: priceInPaise ?? this.priceInPaise,
      gstPercent: gstPercent ?? this.gstPercent,
    );
  }
}
