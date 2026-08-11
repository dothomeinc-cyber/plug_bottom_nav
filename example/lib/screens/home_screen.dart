import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plug_commerce_ui/plug_commerce_ui.dart';

import '../features/cart/domain/cart_item.dart';
import '../features/cart/domain/demo_catalog.dart';
import '../features/cart/presentation/cart_controller.dart';

/// Demonstrates: [PlugAddToCartButton] driven by the app's own
/// [CartController], and [PlugCartPopup.show] as the "Added to cart"
/// confirmation. Note this widget never constructs a `PlugCartItem`
/// directly from a [DemoProduct] — it goes through [CartItem] first
/// (the domain model, with price/GST) and only maps to `PlugCartItem` via
/// [toPlugCartItem] right at the point of handing data to a Plug widget.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartControllerProvider);
    final cart = cartAsync.value ?? const {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('CSP Traders'),
        actions: const [
          _CartBadgeAction(),
          SizedBox(width: 8),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: demoProducts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = demoProducts[index];
          final sellerItems = cart[product.sellerId];
          final line = sellerItems?.where(
            (e) => e.productId == product.productId,
          );
          final inCart = line != null && line.isNotEmpty;
          final qty = inCart ? line.first.quantity : 0;

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (product.variant.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              product.variant,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          sellerFor(product.sellerId).name,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: PlugAddToCartButton(
                      state: inCart
                          ? PlugAddToCartState.added
                          : PlugAddToCartState.idle,
                      quantity: qty,
                      maxQuantity: product.maxQuantity,
                      onAdd: () => _addToCart(context, ref, product),
                      onIncrease: () => ref.read(cartControllerProvider.notifier).increase(
                            sellerId: product.sellerId,
                            productId: product.productId,
                          ),
                      onDecrease: () => ref.read(cartControllerProvider.notifier).decrease(
                            sellerId: product.sellerId,
                            productId: product.productId,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addToCart(
    BuildContext context,
    WidgetRef ref,
    DemoProduct product,
  ) async {
    // The app's OWN domain model — carries price/GST, which
    // plug_commerce_ui never sees.
    final cartItem = CartItem(
      productId: product.productId,
      sellerId: product.sellerId,
      productName: product.name,
      variant: product.variant,
      quantity: 1,
      maxQuantity: product.maxQuantity,
      priceInPaise: product.priceInPaise,
      gstPercent: product.gstPercent,
    );

    // Real Firebase write happens inside the controller/repository.
    await ref.read(cartControllerProvider.notifier).add(cartItem);

    if (!context.mounted) return;

    // Mapped to PlugCartItem ONLY here, right before handing it to the
    // package's popup widget.
    PlugCartPopup.show(
      context: context,
      seller: sellerFor(product.sellerId),
      item: toPlugCartItem(cartItem),
      onViewCart: () => context.push('/cart/${product.sellerId}'),
    );
  }
}

/// Trivial wrapper — `PlugCartBadge` watches `cartTotalCountProvider`
/// directly (Riverpod-first: no adapter, no `ValueListenable` bridge).
/// Kept as its own widget purely for readability alongside the product
/// list, not because it's required for correctness.
class _CartBadgeAction extends StatelessWidget {
  const _CartBadgeAction();

  @override
  Widget build(BuildContext context) {
    return PlugCartBadge(
      icon: Icons.shopping_cart_outlined,
      countProvider: cartTotalCountProvider,
      onTap: () => context.push('/cart'),
    );
  }
}
