import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plug_bottom_nav/plug_bottom_nav.dart';

/// Lists every seller's cart separately (Instacart-style).
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(plugCartProvider);
    final notifier = ref.read(plugCartProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.isEmpty
          ? const Center(child: Text('Your carts are empty'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final entry in cart.entries) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () =>
                            notifier.clearSellerCart(entry.key),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  for (final item in entry.value)
                    ListTile(
                      title: Text(item.title),
                      subtitle: Text(
                          '\$${item.price.toStringAsFixed(2)} x ${item.quantity}'),
                      trailing: Text(
                        '\$${item.lineTotal.toStringAsFixed(2)}',
                        style:
                            const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  const Divider(),
                ],
              ],
            ),
    );
  }
}
