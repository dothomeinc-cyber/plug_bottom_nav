import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plug_commerce_ui/plug_commerce_ui.dart';

import '../data/cart_repository.dart';
import '../domain/cart_item.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) => CartRepository());

/// The single Riverpod entry point widgets talk to. Holds [CartItem]s (the
/// app's domain model, with price/GST) — `plug_commerce_ui` widgets never
/// see this directly.
class CartController extends AsyncNotifier<Map<String, List<CartItem>>> {
  @override
  Future<Map<String, List<CartItem>>> build() {
    return ref.read(cartRepositoryProvider).loadAll();
  }

  Future<void> add(CartItem item) async {
    await ref.read(cartRepositoryProvider).add(item);
    state = AsyncData(await ref.read(cartRepositoryProvider).loadAll());
  }

  Future<void> increase({required String sellerId, required String productId}) async {
    await ref
        .read(cartRepositoryProvider)
        .increase(sellerId: sellerId, productId: productId);
    state = AsyncData(await ref.read(cartRepositoryProvider).loadAll());
  }

  Future<void> decrease({required String sellerId, required String productId}) async {
    await ref
        .read(cartRepositoryProvider)
        .decrease(sellerId: sellerId, productId: productId);
    state = AsyncData(await ref.read(cartRepositoryProvider).loadAll());
  }

  Future<void> remove({required String sellerId, required String productId}) async {
    await ref
        .read(cartRepositoryProvider)
        .remove(sellerId: sellerId, productId: productId);
    state = AsyncData(await ref.read(cartRepositoryProvider).loadAll());
  }
}

final cartControllerProvider =
    AsyncNotifierProvider<CartController, Map<String, List<CartItem>>>(
  CartController.new,
);

/// Total item count across all sellers — passed straight to
/// `PlugNavRoute.badgeProvider`/`PlugCartBadge.countProvider` (Riverpod
/// `ProviderListenable<int>`, no adapter needed). Still a
/// [CartItem]-typed read; no `PlugCartItem` anywhere in this file except
/// the mapper below.
final cartTotalCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartControllerProvider).value ?? const {};
  return cart.values.fold<int>(
    0,
    (sum, items) => sum + items.fold<int>(0, (s, e) => s + e.quantity),
  );
});

final cartCountForSellerProvider = Provider.family<int, String>((ref, sellerId) {
  final cart = ref.watch(cartControllerProvider).value ?? const {};
  return cart[sellerId]?.fold<int>(0, (s, e) => s + e.quantity) ?? 0;
});

/// The ONLY place `CartItem` (domain) becomes `PlugCartItem` (UI). Keeping
/// this mapping in one small function is what lets the package stay
/// ignorant of price/GST/whatever Dot adds next — widgets call this right
/// before handing data to a Plug widget, nothing upstream needs to change.
PlugCartItem toPlugCartItem(CartItem item) => PlugCartItem(
      productId: item.productId,
      sellerId: item.sellerId,
      productName: item.productName,
      subtitle: item.variant,
      image: item.image,
      quantity: item.quantity,
      maxQuantity: item.maxQuantity,
    );
