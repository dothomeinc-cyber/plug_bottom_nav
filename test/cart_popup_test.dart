import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plug_commerce_ui/plug_commerce_ui.dart';

const _seller = PlugSellerInfo(
  sellerId: 'csp_traders',
  name: 'CSP Traders',
  location: 'Ponmanai, Kanyakumari',
);

const _item = PlugCartItem(
  productId: 'ultratech_ppc_50kg',
  sellerId: 'csp_traders',
  productName: 'UltraTech PPC Cement',
  subtitle: '50kg Bag',
  quantity: 10,
);

void main() {
  group('PlugCartPopup (inline widget)', () {
    testWidgets('renders seller name, location, item name, subtitle, and qty',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlugCartPopup(
              seller: _seller,
              item: _item,
              onViewCart: () {},
            ),
          ),
        ),
      );

      expect(find.text('CSP Traders'), findsOneWidget);
      expect(find.text('Ponmanai, Kanyakumari'), findsOneWidget);
      expect(find.text('UltraTech PPC Cement'), findsOneWidget);
      expect(find.text('50kg Bag'), findsOneWidget);
      expect(find.text('Qty: 10'), findsOneWidget);
    });

    testWidgets('unitLabel appends after quantity', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlugCartPopup(
              seller: _seller,
              item: _item,
              unitLabel: 'Bags',
              onViewCart: () {},
            ),
          ),
        ),
      );

      expect(find.text('Qty: 10 Bags'), findsOneWidget);
    });

    testWidgets('omits location row when seller.location is empty',
        (tester) async {
      const sellerNoLocation = PlugSellerInfo(
        sellerId: 'abc_hardware',
        name: 'ABC Hardware',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlugCartPopup(
              seller: sellerNoLocation,
              item: _item,
              onViewCart: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.location_on_outlined), findsNothing);
    });

    testWidgets('omits subtitle row when item.subtitle is empty',
        (tester) async {
      const itemNoSubtitle = PlugCartItem(
        productId: 'p1',
        sellerId: 'csp_traders',
        productName: 'Plain Product',
        quantity: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlugCartPopup(
              seller: _seller,
              item: itemNoSubtitle,
              onViewCart: () {},
            ),
          ),
        ),
      );

      expect(find.text('Plain Product'), findsOneWidget);
      expect(find.text('Qty: 1'), findsOneWidget);
    });

    testWidgets('tapping View Cart triggers onViewCart', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlugCartPopup(
              seller: _seller,
              item: _item,
              onViewCart: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('View Cart'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('custom viewCartText and addedToText are used', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlugCartPopup(
              seller: _seller,
              item: _item,
              onViewCart: () {},
              addedToText: 'Added to your order:',
              viewCartText: 'Go to cart',
            ),
          ),
        ),
      );

      expect(find.text('Added to your order:'), findsOneWidget);
      expect(find.text('Go to cart'), findsOneWidget);
    });
  });

  group('PlugCartPopup.show (bottom sheet flow)', () {
    testWidgets('shows the sheet and closes it on View Cart tap',
        (tester) async {
      var viewCartTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => PlugCartPopup.show(
                  context: context,
                  seller: _seller,
                  item: _item,
                  onViewCart: () => viewCartTapped = true,
                  autoDismissAfter: null, // don't race the auto-dismiss timer
                ),
                child: const Text('Add'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('CSP Traders'), findsOneWidget);

      await tester.tap(find.text('View Cart'));
      await tester.pumpAndSettle();

      expect(viewCartTapped, isTrue);
      expect(find.text('CSP Traders'), findsNothing);
    });
  });

  group('PlugCartPopup.showSuccess', () {
    testWidgets('shows the popup only after future completes', (tester) async {
      final completer = Completer<void>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => PlugCartPopup.showSuccess(
                  context: context,
                  seller: _seller,
                  item: _item,
                  onViewCart: () {},
                  autoDismissAfter: null,
                  future: () => completer.future,
                ),
                child: const Text('Add'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add'));
      await tester.pump();

      // Future hasn't resolved yet — popup must not be showing.
      expect(find.text('CSP Traders'), findsNothing);

      completer.complete();
      await tester.pumpAndSettle();

      expect(find.text('CSP Traders'), findsOneWidget);
    });

    testWidgets('does not show the popup if future throws', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  try {
                    await PlugCartPopup.showSuccess(
                      context: context,
                      seller: _seller,
                      item: _item,
                      onViewCart: () {},
                      autoDismissAfter: null,
                      future: () async => throw Exception('backend failed'),
                    );
                  } catch (_) {
                    // Expected — showSuccess propagates the error.
                  }
                },
                child: const Text('Add'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('CSP Traders'), findsNothing);
    });
  });
}
