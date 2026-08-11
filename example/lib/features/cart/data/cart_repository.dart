import '../domain/cart_item.dart';

/// Stands in for Firestore. In Dot this would read/write
/// `users/{uid}/carts/{sellerId}/items/{productId}`, with the same
/// method surface — `presentation/cart_controller.dart` doesn't need to
/// change when you swap this in-memory map for real Firestore calls.
///
/// Notice this repository works entirely in terms of [CartItem] (the
/// app's domain model) — it has never heard of `PlugCartItem`. Mapping to
/// the package's UI model happens one layer up, in the controller/widgets.
class CartRepository {
  final Map<String, List<CartItem>> _bySeller = {};

  Future<Map<String, List<CartItem>>> loadAll() async {
    // Real implementation: fetch users/{uid}/carts/**/items and group by
    // sellerId.
    return Map.unmodifiable(_bySeller.map((k, v) => MapEntry(k, [...v])));
  }

  Future<void> add(CartItem item) async {
    final items = List<CartItem>.from(_bySeller[item.sellerId] ?? const []);
    final i = items.indexWhere((e) => e.productId == item.productId);
    if (i == -1) {
      items.add(item);
    } else {
      items[i] = items[i].copyWith(quantity: items[i].quantity + item.quantity);
    }
    _bySeller[item.sellerId] = items;
    // Real implementation: await Firestore write here.
  }

  Future<void> increase({required String sellerId, required String productId}) async {
    final items = List<CartItem>.from(_bySeller[sellerId] ?? const []);
    final i = items.indexWhere((e) => e.productId == productId);
    if (i == -1) return;
    items[i] = items[i].copyWith(quantity: items[i].quantity + 1);
    _bySeller[sellerId] = items;
  }

  Future<void> decrease({required String sellerId, required String productId}) async {
    final items = List<CartItem>.from(_bySeller[sellerId] ?? const []);
    final i = items.indexWhere((e) => e.productId == productId);
    if (i == -1) return;
    final q = items[i].quantity - 1;
    if (q <= 0) {
      items.removeAt(i);
    } else {
      items[i] = items[i].copyWith(quantity: q);
    }
    _bySeller[sellerId] = items;
  }

  Future<void> remove({required String sellerId, required String productId}) async {
    final items = List<CartItem>.from(_bySeller[sellerId] ?? const [])
      ..removeWhere((e) => e.productId == productId);
    _bySeller[sellerId] = items;
  }
}
