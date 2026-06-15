import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/plug_cart_item.dart';

/// Instacart-style multi-seller cart.
///
/// State is a map of `sellerId -> List<PlugCartItem>`, so every shop/seller
/// keeps its own independent cart. All mutations are immutable (Riverpod 3.x
/// [Notifier]) so widgets watching the provider rebuild correctly.
class PlugCartNotifier extends Notifier<Map<String, List<PlugCartItem>>> {
  @override
  Map<String, List<PlugCartItem>> build() => const {};

  List<PlugCartItem> _seller(String sellerId) =>
      List<PlugCartItem>.from(state[sellerId] ?? const []);

  void _commit(String sellerId, List<PlugCartItem> items) {
    final next = {...state};
    if (items.isEmpty) {
      next.remove(sellerId);
    } else {
      next[sellerId] = items;
    }
    state = next;
  }

  /// Add an item. If it already exists, its quantity is increased by
  /// [item.quantity].
  void addItem({required String sellerId, required PlugCartItem item}) {
    final items = _seller(sellerId);
    final i = items.indexWhere((e) => e.id == item.id);
    if (i == -1) {
      items.add(item.copyWith(sellerId: sellerId));
    } else {
      items[i] = items[i].copyWith(
        quantity: items[i].quantity + item.quantity,
      );
    }
    _commit(sellerId, items);
  }

  void removeItem({required String sellerId, required String itemId}) {
    final items = _seller(sellerId)..removeWhere((e) => e.id == itemId);
    _commit(sellerId, items);
  }

  void increaseQty({required String sellerId, required String itemId}) {
    final items = _seller(sellerId);
    final i = items.indexWhere((e) => e.id == itemId);
    if (i == -1) return;
    items[i] = items[i].copyWith(quantity: items[i].quantity + 1);
    _commit(sellerId, items);
  }

  /// Decrease quantity by one. Removes the line when it reaches zero.
  void decreaseQty({required String sellerId, required String itemId}) {
    final items = _seller(sellerId);
    final i = items.indexWhere((e) => e.id == itemId);
    if (i == -1) return;
    final q = items[i].quantity - 1;
    if (q <= 0) {
      items.removeAt(i);
    } else {
      items[i] = items[i].copyWith(quantity: q);
    }
    _commit(sellerId, items);
  }

  void clearSellerCart(String sellerId) => _commit(sellerId, const []);

  void clearAll() => state = const {};

  // ---- Read helpers (pure, safe to call in build) -------------------------

  bool isInCart({required String sellerId, required String itemId}) =>
      state[sellerId]?.any((e) => e.id == itemId) ?? false;

  int quantityOf({required String sellerId, required String itemId}) {
    final items = state[sellerId];
    if (items == null) return 0;
    for (final e in items) {
      if (e.id == itemId) return e.quantity;
    }
    return 0;
  }

  int cartCount(String sellerId) =>
      state[sellerId]?.fold<int>(0, (s, e) => s + e.quantity) ?? 0;

  double cartTotal(String sellerId) =>
      state[sellerId]?.fold<double>(0, (s, e) => s + e.lineTotal) ?? 0;
}

/// The per-seller cart provider.
final plugCartProvider =
    NotifierProvider<PlugCartNotifier, Map<String, List<PlugCartItem>>>(
  PlugCartNotifier.new,
);

/// Convenience: live item count for one seller. Rebuilds only on count change.
final plugCartCountProvider = Provider.family<int, String>((ref, sellerId) {
  final cart = ref.watch(plugCartProvider);
  return cart[sellerId]?.fold<int>(0, (s, e) => s + e.quantity) ?? 0;
});

/// Convenience: live total for one seller.
final plugCartTotalProvider = Provider.family<double, String>((ref, sellerId) {
  final cart = ref.watch(plugCartProvider);
  return cart[sellerId]?.fold<double>(0, (s, e) => s + e.lineTotal) ?? 0;
});
