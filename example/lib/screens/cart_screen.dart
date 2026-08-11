import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plug_commerce_ui/plug_commerce_ui.dart';

import '../features/cart/domain/demo_catalog.dart';
import '../features/cart/presentation/cart_controller.dart';

/// Demonstrates: [PlugSellerCartSheet] and [PlugEmptyCart], both driven by
/// the app's own [cartControllerProvider] — the package renders, the app
/// decides. `CartItem` (domain) is mapped to `PlugCartItem` (UI) via
/// [toPlugCartItem] right before being handed to a Plug widget.
class CartScreen extends ConsumerWidget {
  /// Optional — when set, shows only this seller's cart (as if opened from
  /// [PlugCartPopup]'s "View Cart" button). When null, shows all sellers.
  final String? sellerId;

  const CartScreen({super.key, this.sellerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider).value ?? const {};
    final sellerIds = sellerId != null ? [sellerId!] : cart.keys.toList();

    if (cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cart')),
        body: PlugEmptyCart(
          actionText: 'Browse Products',
          onAction: () => context.go('/home'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final id in sellerIds)
            if ((cart[id] ?? const []).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _SellerCartCard(sellerId: id),
              ),
        ],
      ),
    );
  }
}

class _SellerCartCard extends ConsumerWidget {
  final String sellerId;

  const _SellerCartCard({required this.sellerId});

  String _rupees(double v) => '₹${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items =
        ref.watch(cartControllerProvider).value?[sellerId] ?? const [];
    final seller = sellerFor(sellerId);
    final controller = ref.read(cartControllerProvider.notifier);

    final total = items.fold<double>(0, (s, e) => s + e.lineTotalRupees);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storefront, size: 18),
                const SizedBox(width: 6),
                Text(seller.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const Divider(),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.productName}${item.variant.isEmpty ? '' : ' — ${item.variant}'}',
                      ),
                    ),
                    Text('x${item.quantity}'),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => PlugSellerCartSheet(
                    seller: seller,
                    // Mapped to PlugCartItem right at the widget boundary —
                    // price/GST (from CartItem) stay in this screen's own
                    // lineSubtitle/footerTotal formatting, never inside the
                    // package.
                    items: items.map(toPlugCartItem).toList(),
                    lineSubtitle: (plugItem) {
                      final item = items.firstWhere(
                        (e) => e.productId == plugItem.productId,
                      );
                      return '${_rupees(item.priceInPaise / 100)} x ${item.quantity} '
                          '(incl. ${item.gstPercent.toStringAsFixed(0)}% GST)';
                    },
                    footerTotal: _rupees(total),
                    onIncrease: (plugItem) => controller.increase(
                      sellerId: sellerId,
                      productId: plugItem.productId,
                    ),
                    onDecrease: (plugItem) => controller.decrease(
                      sellerId: sellerId,
                      productId: plugItem.productId,
                    ),
                    onRemove: (plugItem) => controller.remove(
                      sellerId: sellerId,
                      productId: plugItem.productId,
                    ),
                    onCheckout: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Checkout for ${seller.name} — your app '
                            'implements this (Firebase order write, '
                            'PayU/Razorpay, etc.)',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                child: Text('View cart (${_rupees(total)})'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
