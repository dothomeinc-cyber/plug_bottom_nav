import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plug_bottom_nav/plug_bottom_nav.dart';

/// Demonstrates two different sellers, each with its own independent cart,
/// the auto add-to-cart button, and a floating cart bar per seller.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _sellerA = 'seller_hardware';
  static const _sellerB = 'seller_grocery';

  @override
  Widget build(BuildContext context) {
    final hardware = [
      const PlugCartItem(
        id: 'cement_001',
        title: 'UltraTech Cement 50kg',
        sellerId: _sellerA,
        price: 8.50,
      ),
      const PlugCartItem(
        id: 'paint_002',
        title: 'Wall Paint 4L',
        sellerId: _sellerA,
        price: 22.00,
      ),
    ];
    final grocery = [
      const PlugCartItem(
        id: 'milk_001',
        title: 'Almond Milk 1L',
        sellerId: _sellerB,
        price: 3.20,
      ),
      const PlugCartItem(
        id: 'eggs_002',
        title: 'Free-range Eggs (12)',
        sellerId: _sellerB,
        price: 4.99,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 160),
        children: [
          const _SellerHeader(name: 'BuildMart (Hardware)'),
          for (final item in hardware)
            _ProductCard(sellerId: _sellerA, item: item),
          // Floating cart bar for seller A.
          PlugCartBar(
            sellerId: _sellerA,
            onTap: () => context.go('/cart'),
            backgroundColor: const Color(0xFF0A8754),
          ),
          const SizedBox(height: 24),
          const _SellerHeader(name: 'FreshGo (Grocery)'),
          for (final item in grocery)
            _ProductCard(sellerId: _sellerB, item: item),
          PlugCartBar(
            sellerId: _sellerB,
            onTap: () => context.go('/cart'),
            backgroundColor: const Color(0xFFEA580C),
          ),
        ],
      ),
    );
  }
}

class _SellerHeader extends StatelessWidget {
  final String name;
  const _SellerHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        name,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String sellerId;
  final PlugCartItem item;

  const _ProductCard({required this.sellerId, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory_2_outlined),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style:
                          const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('\$${item.price.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
            SizedBox(
              width: 110,
              child: PlugAddToCartButton(
                sellerId: sellerId,
                item: item,
                color: const Color(0xFF0A8754),
                addText: 'Add',
                addedText: 'Added',
                // Your async logic (Firestore/API). Loading is automatic.
                onPressed: () async {
                  await Future<void>.delayed(
                      const Duration(milliseconds: 400));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
