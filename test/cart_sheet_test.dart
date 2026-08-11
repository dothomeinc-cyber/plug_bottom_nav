import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plug_commerce_ui/plug_commerce_ui.dart';

const _seller = PlugSellerInfo(
  sellerId: 'csp_traders',
  name: 'CSP Traders',
  location: 'Ponmanai, Kanyakumari',
);

const _cement = PlugCartItem(
  productId: 'ultratech_ppc_50kg',
  sellerId: 'csp_traders',
  productName: 'UltraTech PPC Cement',
  subtitle: '50kg Bag',
  quantity: 10,
);

const _cappedItem = PlugCartItem(
  productId: 'finolex_pvc_pipe',
  sellerId: 'abc_hardware',
  productName: 'Finolex PVC Pipe',
  quantity: 20,
  maxQuantity: 20,
);

/// [PlugSellerCartSheet] is built on [DraggableScrollableSheet] (needs an
/// unconstrained-height ancestor, which `home:` provides) and uses
/// [InkWell] internally (needs a [Material] ancestor, which `MaterialApp`
/// alone does NOT provide — only `Scaffold`/`Material` do). Both are
/// covered by wrapping in a bare `Scaffold`.
Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('PlugSellerCartSheet — empty cart', () {
    testWidgets('shows emptyText and no line items when items is empty',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlugSellerCartSheet(seller: _seller, items: const []),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.text('UltraTech PPC Cement'), findsNothing);
    });

    testWidgets('custom emptyText is used', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlugSellerCartSheet(
            seller: _seller,
            items: const [],
            emptyText: 'Nothing here yet',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nothing here yet'), findsOneWidget);
    });

    testWidgets('checkout button and footer are hidden when empty',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlugSellerCartSheet(
            seller: _seller,
            items: const [],
            footerTotal: '₹0',
            onCheckout: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Checkout'), findsNothing);
      expect(find.text('₹0'), findsNothing);
    });
  });

  group('PlugSellerCartSheet — rendering', () {
    testWidgets('renders seller name, location, and item lines',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlugSellerCartSheet(seller: _seller, items: const [_cement]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CSP Traders'), findsOneWidget);
      expect(find.text('Ponmanai, Kanyakumari'), findsOneWidget);
      expect(find.text('UltraTech PPC Cement'), findsOneWidget);
      expect(find.text('50kg Bag'), findsOneWidget);
      // No onIncrease/onDecrease passed here, so the line falls back to
      // the plain 'xN' quantity text (see the dedicated stepper-fallback
      // test below) rather than the stepper's bare '10'.
      expect(find.text('x10'), findsOneWidget);
    });

    testWidgets('lineSubtitle and item.subtitle are both shown, independently',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlugSellerCartSheet(
            seller: _seller,
            items: const [_cement],
            lineSubtitle: (item) => '₹450 x ${item.quantity}',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // item.subtitle (variant label)
      expect(find.text('50kg Bag'), findsOneWidget);
      // app-supplied lineSubtitle (price text)
      expect(find.text('₹450 x 10'), findsOneWidget);
    });

    testWidgets('footerTotal renders when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlugSellerCartSheet(
            seller: _seller,
            items: const [_cement],
            footerTotal: '₹4,500',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('₹4,500'), findsOneWidget);
    });
  });

  group('PlugSellerCartSheet — quantity changes', () {
    testWidgets('tapping + calls onIncrease with the item', (tester) async {
      PlugCartItem? increased;

      await tester.pumpWidget(
        _wrap(
          PlugSellerCartSheet(
            seller: _seller,
            items: const [_cement],
            onIncrease: (item) => increased = item,
            onDecrease: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(increased, _cement);
    });

    testWidgets('tapping - calls onDecrease with the item', (tester) async {
      PlugCartItem? decreased;

      await tester.pumpWidget(
        _wrap(
          PlugSellerCartSheet(
            seller: _seller,
            items: const [_cement],
            onIncrease: (_) {},
            onDecrease: (item) => decreased = item,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(decreased, _cement);
    });

    testWidgets('falls back to plain "xN" text when steppers are not wired',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlugSellerCartSheet(seller: _seller, items: const [_cement]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('x10'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byIcon(Icons.remove), findsNothing);
    });

    testWidgets('tapping the remove (x) icon calls onRemove with the item',
        (tester) async {
      PlugCartItem? removed;

      await tester.pumpWidget(
        _wrap(
          PlugSellerCartSheet(
            seller: _seller,
            items: const [_cement],
            onRemove: (item) => removed = item,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(removed, _cement);
    });
  });

  group('PlugSellerCartSheet — max quantity', () {
    testWidgets('+ is disabled once quantity reaches maxQuantity',
        (tester) async {
      var increaseCalls = 0;

      await tester.pumpWidget(
        _wrap(
          PlugSellerCartSheet(
            seller: _seller,
            items: const [_cappedItem], // quantity == maxQuantity == 20
            onIncrease: (_) => increaseCalls++,
            onDecrease: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // The tap must be swallowed — onIncrease should never fire past the cap.
      expect(increaseCalls, 0);
    });

    testWidgets('+ remains enabled below maxQuantity', (tester) async {
      var increaseCalls = 0;
      const belowCap = PlugCartItem(
        productId: 'finolex_pvc_pipe',
        sellerId: 'abc_hardware',
        productName: 'Finolex PVC Pipe',
        quantity: 19,
        maxQuantity: 20,
      );

      await tester.pumpWidget(
        _wrap(
          PlugSellerCartSheet(
            seller: _seller,
            items: const [belowCap],
            onIncrease: (_) => increaseCalls++,
            onDecrease: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(increaseCalls, 1);
    });

    testWidgets('- remains enabled at maxQuantity (only + is capped)',
        (tester) async {
      var decreaseCalls = 0;

      await tester.pumpWidget(
        _wrap(
          PlugSellerCartSheet(
            seller: _seller,
            items: const [_cappedItem],
            onIncrease: (_) {},
            onDecrease: (_) => decreaseCalls++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(decreaseCalls, 1);
    });

    testWidgets('no cap (maxQuantity null) never disables +', (tester) async {
      var increaseCalls = 0;

      await tester.pumpWidget(
        _wrap(
          PlugSellerCartSheet(
            seller: _seller,
            items: const [_cement], // maxQuantity is null
            onIncrease: (_) => increaseCalls++,
            onDecrease: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(increaseCalls, 1);
    });
  });

  group('PlugSellerCartSheet — checkout', () {
    testWidgets('tapping Checkout calls onCheckout', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        _wrap(
          PlugSellerCartSheet(
            seller: _seller,
            items: const [_cement],
            onCheckout: () => tapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Checkout'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('custom checkoutText is used', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlugSellerCartSheet(
            seller: _seller,
            items: const [_cement],
            checkoutText: 'Place Order',
            onCheckout: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Place Order'), findsOneWidget);
    });
  });
}
