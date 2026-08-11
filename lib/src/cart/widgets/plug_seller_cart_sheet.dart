import 'package:flutter/material.dart';

import '../models/plug_cart_item.dart';

/// Renders one seller's cart contents as a scrollable sheet. Pure UI — you
/// pass in the list of items (from your own Firebase-backed cart) and
/// callbacks for quantity changes; this widget owns no state.
///
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (_) => PlugSellerCartSheet(
///     seller: sellerInfo,
///     items: myCartRepo.itemsFor(sellerId), // your data
///     onIncrease: (item) => myCartRepo.increase(item),
///     onDecrease: (item) => myCartRepo.decrease(item),
///     onRemove: (item) => myCartRepo.remove(item),
///     onCheckout: () => context.push('/checkout/$sellerId'),
///   ),
/// );
/// ```
class PlugSellerCartSheet extends StatelessWidget {
  final PlugSellerInfo seller;
  final List<PlugCartItem> items;

  /// Optional app-supplied per-line text — typically price/unit info, since
  /// this UI layer has no price field: `lineSubtitle: (item) => '₹450 x
  /// ${item.quantity}'`. Shown under [PlugCartItem.subtitle] (a variant
  /// label like "50kg Bag") when both are present — they're independent,
  /// not alternatives.
  final String Function(PlugCartItem item)? lineSubtitle;

  /// Optional footer total text, fully formatted by your app (this widget
  /// doesn't know about prices): `footerTotal: '₹4,500'`.
  final String? footerTotal;

  final void Function(PlugCartItem item)? onIncrease;
  final void Function(PlugCartItem item)? onDecrease;
  final void Function(PlugCartItem item)? onRemove;
  final VoidCallback? onCheckout;

  final String checkoutText;
  final String emptyText;
  final Color accentColor;

  const PlugSellerCartSheet({
    super.key,
    required this.seller,
    required this.items,
    this.lineSubtitle,
    this.footerTotal,
    this.onIncrease,
    this.onDecrease,
    this.onRemove,
    this.onCheckout,
    this.checkoutText = 'Checkout',
    this.emptyText = 'Your cart is empty',
    this.accentColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.storefront, size: 20, color: accentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            seller.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (seller.location.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      seller.location,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          emptyText,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _CartLine(
                            item: item,
                            subtitle: lineSubtitle?.call(item),
                            accentColor: accentColor,
                            onIncrease: onIncrease == null
                                ? null
                                : () => onIncrease!(item),
                            onDecrease: onDecrease == null
                                ? null
                                : () => onDecrease!(item),
                            onRemove:
                                onRemove == null ? null : () => onRemove!(item),
                          );
                        },
                      ),
              ),
              if (items.isNotEmpty)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Row(
                      children: [
                        if (footerTotal != null) ...[
                          Text(
                            footerTotal!,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: onCheckout,
                              child: Text(
                                checkoutText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CartLine extends StatelessWidget {
  final PlugCartItem item;

  /// App-supplied line text (typically price/unit info), distinct from
  /// [PlugCartItem.subtitle] (a variant label like "50kg Bag") — both are
  /// shown when present.
  final String? subtitle;
  final Color accentColor;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback? onRemove;

  const _CartLine({
    required this.item,
    required this.subtitle,
    required this.accentColor,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final atMax = item.maxQuantity != null && item.quantity >= item.maxQuantity!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          if (item.image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.image,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackIcon(),
              ),
            )
          else
            _fallbackIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    item.subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (onIncrease != null && onDecrease != null)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: onDecrease,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.remove, size: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  InkWell(
                    onTap: atMax ? null : onIncrease,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.add,
                        size: 16,
                        color: atMax ? Colors.grey.shade400 : null,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              'x${item.quantity}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              color: Colors.grey.shade500,
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }

  Widget _fallbackIcon() => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.inventory_2_outlined, color: accentColor, size: 20),
      );
}
