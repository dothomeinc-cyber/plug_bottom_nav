// Golden (pixel-comparison) tests, as opposed to the behavior-focused
// widget tests in bottom_nav_test.dart / cart_popup_test.dart /
// cart_sheet_test.dart / add_to_cart_button_test.dart.
//
// These render each widget to a fixed-size surface and compare against a
// reference PNG under test/goldens/. Golden tests catch *visual*
// regressions (spacing, color, layout shifts) that behavior tests can't —
// but they're inherently fragile across Flutter/font-rendering versions,
// so keep this file small and focused on a few key screens rather than
// every widget/state combination (that's what the other test files cover).
//
// Generate/update the reference images with:
//   flutter test --update-goldens test/golden_test.dart
//
// Then review the diffs in test/goldens/ before committing them — an
// updated golden is only correct if a human confirmed the new rendering
// is actually right, not just different.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

void _noop() {}

/// Golden tests are sensitive to the test device's pixel ratio/size —
/// pinning both keeps the reference images stable across machines.
///
/// [settle] controls whether we wait for animations to finish
/// (`pumpAndSettle`) or just advance one frame (`pump`). Widgets with a
/// perpetual animation — e.g. [CircularProgressIndicator] in
/// [PlugAddToCartState.loading] — never "settle", so `pumpAndSettle` times
/// out on them; pass `settle: false` for those and capture a single frame
/// instead.
Future<void> _pumpGolden(
  WidgetTester tester,
  Widget child, {
  Size surfaceSize = const Size(400, 400),
  bool settle = true,
}) async {
  tester.view.physicalSize = surfaceSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(body: child),
      ),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('Golden — PlugCartPopup', () {
    testWidgets('default state', (tester) async {
      await _pumpGolden(
        tester,
        PlugCartPopup(seller: _seller, item: _item, onViewCart: () {}),
        surfaceSize: const Size(400, 320),
      );

      await expectLater(
        find.byType(PlugCartPopup),
        matchesGoldenFile('goldens/cart_popup_default.png'),
      );
    });

    testWidgets('no seller location, no item subtitle', (tester) async {
      const plainSeller = PlugSellerInfo(sellerId: 'abc', name: 'ABC Hardware');
      const plainItem = PlugCartItem(
        productId: 'p1',
        sellerId: 'abc',
        productName: 'CERA Wall-Mounted WC',
        quantity: 2,
      );

      await _pumpGolden(
        tester,
        PlugCartPopup(
          seller: plainSeller,
          item: plainItem,
          onViewCart: _noop,
        ),
        surfaceSize: const Size(400, 280),
      );

      await expectLater(
        find.byType(PlugCartPopup),
        matchesGoldenFile('goldens/cart_popup_minimal.png'),
      );
    });
  });

  group('Golden — PlugAddToCartButton', () {
    testWidgets('idle', (tester) async {
      await _pumpGolden(
        tester,
        const SizedBox(
          width: 120,
          child: PlugAddToCartButton(state: PlugAddToCartState.idle),
        ),
        surfaceSize: const Size(160, 80),
      );

      await expectLater(
        find.byType(PlugAddToCartButton),
        matchesGoldenFile('goldens/add_to_cart_idle.png'),
      );
    });

    testWidgets('added, stepper, mid-range quantity', (tester) async {
      await _pumpGolden(
        tester,
        const SizedBox(
          width: 120,
          child: PlugAddToCartButton(
            state: PlugAddToCartState.added,
            quantity: 4,
          ),
        ),
        surfaceSize: const Size(160, 80),
      );

      await expectLater(
        find.byType(PlugAddToCartButton),
        matchesGoldenFile('goldens/add_to_cart_stepper.png'),
      );
    });

    testWidgets('added, stepper, at maxQuantity (+ dimmed)', (tester) async {
      await _pumpGolden(
        tester,
        const SizedBox(
          width: 120,
          child: PlugAddToCartButton(
            state: PlugAddToCartState.added,
            quantity: 50,
            maxQuantity: 50,
          ),
        ),
        surfaceSize: const Size(160, 80),
      );

      await expectLater(
        find.byType(PlugAddToCartButton),
        matchesGoldenFile('goldens/add_to_cart_stepper_at_max.png'),
      );
    });

    testWidgets('loading', (tester) async {
      await _pumpGolden(
        tester,
        const SizedBox(
          width: 120,
          child: PlugAddToCartButton(state: PlugAddToCartState.loading),
        ),
        surfaceSize: const Size(160, 80),
        // CircularProgressIndicator animates forever — pumpAndSettle would
        // never return. Capture a single frame instead.
        settle: false,
      );

      await expectLater(
        find.byType(PlugAddToCartButton),
        matchesGoldenFile('goldens/add_to_cart_loading.png'),
      );
    });
  });

  group('Golden — PlugEmptyCart', () {
    testWidgets('default', (tester) async {
      await _pumpGolden(
        tester,
        const PlugEmptyCart(),
        surfaceSize: const Size(400, 300),
      );

      await expectLater(
        find.byType(PlugEmptyCart),
        matchesGoldenFile('goldens/empty_cart_default.png'),
      );
    });

    testWidgets('with action button', (tester) async {
      await _pumpGolden(
        tester,
        PlugEmptyCart(actionText: 'Browse Products', onAction: () {}),
        surfaceSize: const Size(400, 320),
      );

      await expectLater(
        find.byType(PlugEmptyCart),
        matchesGoldenFile('goldens/empty_cart_with_action.png'),
      );
    });
  });

  group('Golden — PlugBottomNavBar', () {
    testWidgets('with static badge', (tester) async {
      await _pumpGolden(
        tester,
        PlugBottomNavBar(
          currentIndex: 0,
          items: const [
            PlugNavItem(icon: Icons.storefront, label: 'Shop'),
            PlugNavItem(icon: Icons.shopping_cart, label: 'Cart', badgeCount: 3),
          ],
          onTap: (_) {},
          config: const PlugBottomNavConfig(),
        ),
        surfaceSize: const Size(400, 90),
      );

      await expectLater(
        find.byType(PlugBottomNavBar),
        matchesGoldenFile('goldens/bottom_nav_with_badge.png'),
      );
    });

    testWidgets('floating pill style', (tester) async {
      await _pumpGolden(
        tester,
        PlugBottomNavBar(
          currentIndex: 1,
          items: const [
            PlugNavItem(icon: Icons.storefront, label: 'Shop'),
            PlugNavItem(icon: Icons.shopping_cart, label: 'Cart'),
          ],
          onTap: (_) {},
          config: const PlugBottomNavConfig(floating: true),
        ),
        surfaceSize: const Size(400, 100),
      );

      await expectLater(
        find.byType(PlugBottomNavBar),
        matchesGoldenFile('goldens/bottom_nav_floating.png'),
      );
    });
  });
}
