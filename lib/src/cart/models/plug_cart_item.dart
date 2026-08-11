import 'package:flutter/foundation.dart';

/// A cart line item, for DISPLAY ONLY.
///
/// This package never stores cart state — it has no provider, no
/// persistence, no Firestore writes. Your app owns the real cart (Firebase,
/// Riverpod, whatever) and passes instances of this model down into the
/// cart UI widgets so they know what to render.
///
/// Kept intentionally minimal. If your app needs price, MRP, units, variant
/// info, etc. for its own logic, keep that in your own cart model — hand
/// this UI layer only what it needs to draw the popup/sheet/badge.
@immutable
class PlugCartItem {
  final String productId;
  final String sellerId;
  final String productName;

  /// Optional second line under [productName] — variant/pack info, e.g.
  /// "50kg Bag" for a cement product with multiple pack sizes. NOT for
  /// price (that stays in your own cart model). Empty string omits it.
  final String subtitle;

  /// Image url/asset path shown in cart UI. Empty string omits the image.
  final String image;

  final int quantity;

  /// Optional UI-only cap. When set, [PlugAddToCartButton]'s stepper stops
  /// incrementing at this value — display/interaction guard only, not
  /// business validation (your app should still enforce this server-side
  /// wherever the real order is placed). Null means no cap.
  final int? maxQuantity;

  const PlugCartItem({
    required this.productId,
    required this.sellerId,
    required this.productName,
    this.subtitle = '',
    this.image = '',
    this.quantity = 1,
    this.maxQuantity,
  });

  /// Note: because [maxQuantity] is nullable, the standard `?? this.x`
  /// pattern here means you cannot use `copyWith` to explicitly clear an
  /// existing cap back to null — passing `null` for [maxQuantity] just
  /// keeps the current value. Construct a new [PlugCartItem] instead if you
  /// need to remove a cap.
  PlugCartItem copyWith({
    String? productId,
    String? sellerId,
    String? productName,
    String? subtitle,
    String? image,
    int? quantity,
    int? maxQuantity,
  }) {
    return PlugCartItem(
      productId: productId ?? this.productId,
      sellerId: sellerId ?? this.sellerId,
      productName: productName ?? this.productName,
      subtitle: subtitle ?? this.subtitle,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PlugCartItem &&
      other.productId == productId &&
      other.sellerId == sellerId &&
      other.productName == productName &&
      other.subtitle == subtitle &&
      other.image == image &&
      other.quantity == quantity &&
      other.maxQuantity == maxQuantity;

  @override
  int get hashCode => Object.hash(
        productId,
        sellerId,
        productName,
        subtitle,
        image,
        quantity,
        maxQuantity,
      );
}

/// Display info for the seller a [PlugCartItem] belongs to. Purely
/// cosmetic — your app's real seller/vendor record lives elsewhere.
@immutable
class PlugSellerInfo {
  final String sellerId;
  final String name;

  /// Optional logo/image url. Empty string shows a storefront icon instead.
  final String image;

  /// Optional short location label, e.g. "Ponmanai, Kanyakumari". Empty
  /// string omits it.
  final String location;

  const PlugSellerInfo({
    required this.sellerId,
    required this.name,
    this.image = '',
    this.location = '',
  });
}
