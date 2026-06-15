import 'package:flutter/foundation.dart';

/// A single line item inside a per-seller cart.
@immutable
class PlugCartItem {
  final String id;
  final String title;
  final String sellerId;
  final int quantity;
  final double price;

  /// Free-form extra data (image url, options, etc.) the host app may need.
  final Map<String, dynamic> meta;

  const PlugCartItem({
    required this.id,
    required this.title,
    required this.sellerId,
    this.quantity = 1,
    this.price = 0,
    this.meta = const {},
  });

  /// Line total = price * quantity.
  double get lineTotal => price * quantity;

  PlugCartItem copyWith({
    String? id,
    String? title,
    String? sellerId,
    int? quantity,
    double? price,
    Map<String, dynamic>? meta,
  }) {
    return PlugCartItem(
      id: id ?? this.id,
      title: title ?? this.title,
      sellerId: sellerId ?? this.sellerId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      meta: meta ?? this.meta,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PlugCartItem &&
      other.id == id &&
      other.sellerId == sellerId &&
      other.quantity == quantity &&
      other.price == price &&
      other.title == title;

  @override
  int get hashCode => Object.hash(id, sellerId, quantity, price, title);
}
