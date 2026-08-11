import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plug_commerce_ui/plug_commerce_ui.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(body: Align(alignment: Alignment.bottomCenter, child: child)),
    ),
  );
}

void main() {
  group('PlugBottomNavBar', () {
    testWidgets('renders a tile per item with labels', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlugBottomNavBar(
            currentIndex: 0,
            items: const [
              PlugNavItem(icon: Icons.home, label: 'Home'),
              PlugNavItem(icon: Icons.shopping_cart, label: 'Cart'),
            ],
            onTap: (_) {},
            config: const PlugBottomNavConfig(),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Cart'), findsOneWidget);
    });

    testWidgets('tapping a tile reports its real index, honouring reverse',
        (tester) async {
      final tapped = <int>[];

      await tester.pumpWidget(
        _wrap(
          PlugBottomNavBar(
            currentIndex: 0,
            items: const [
              PlugNavItem(icon: Icons.home, label: 'Home'),
              PlugNavItem(icon: Icons.shopping_cart, label: 'Cart'),
            ],
            onTap: tapped.add,
            config: const PlugBottomNavConfig(reverse: true),
          ),
        ),
      );

      // Visually, 'Cart' is now first (reverse: true), but tapping it must
      // still report its real branch index (1), not its visual slot (0).
      await tester.tap(find.text('Cart'));
      await tester.pump();

      expect(tapped, [1]);
    });

    testWidgets('static badgeCount shows and hides at 0', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlugBottomNavBar(
            currentIndex: 0,
            items: const [
              PlugNavItem(icon: Icons.shopping_cart, label: 'Cart', badgeCount: 3),
              PlugNavItem(icon: Icons.home, label: 'Home', badgeCount: 0),
            ],
            onTap: (_) {},
            config: const PlugBottomNavConfig(),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
      // badgeCount: 0 must render no badge at all for that tile.
      expect(find.text('0'), findsNothing);
    });

    testWidgets('badgeCount caps display at 99+', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlugBottomNavBar(
            currentIndex: 0,
            items: const [
              PlugNavItem(icon: Icons.shopping_cart, label: 'Cart', badgeCount: 250),
            ],
            onTap: (_) {},
            config: const PlugBottomNavConfig(),
          ),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
      expect(find.text('250'), findsNothing);
    });

    testWidgets('badgeProvider drives a live badge and updates on change',
        (tester) async {
      final countProvider =
          NotifierProvider<_CountNotifier, int>(_CountNotifier.new);

      await tester.pumpWidget(
        _wrap(
          PlugBottomNavBar(
            currentIndex: 0,
            items: [
              PlugNavItem(
                icon: Icons.shopping_cart,
                label: 'Cart',
                badgeProvider: countProvider,
              ),
            ],
            onTap: (_) {},
            config: const PlugBottomNavConfig(),
          ),
        ),
      );

      // 0 -> no badge.
      expect(find.text('0'), findsNothing);

      final element = tester.element(find.byType(PlugBottomNavBar));
      final container = ProviderScope.containerOf(element);

      container.read(countProvider.notifier).set(5);
      await tester.pump();
      expect(find.text('5'), findsOneWidget);

      container.read(countProvider.notifier).set(12);
      await tester.pump();
      expect(find.text('5'), findsNothing);
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('badgeProvider takes priority over static badgeCount',
        (tester) async {
      final countProvider =
          NotifierProvider<_CountNotifier, int>(() => _CountNotifier(7));

      await tester.pumpWidget(
        _wrap(
          PlugBottomNavBar(
            currentIndex: 0,
            items: [
              PlugNavItem(
                icon: Icons.shopping_cart,
                label: 'Cart',
                badgeCount: 99, // should be ignored
                badgeProvider: countProvider,
              ),
            ],
            onTap: (_) {},
            config: const PlugBottomNavConfig(),
          ),
        ),
      );

      expect(find.text('7'), findsOneWidget);
      expect(find.text('99'), findsNothing);
    });

    testWidgets('semantics label includes badge count when present',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrap(
          PlugBottomNavBar(
            currentIndex: 0,
            items: const [
              PlugNavItem(icon: Icons.shopping_cart, label: 'Cart', badgeCount: 4),
            ],
            onTap: (_) {},
            config: const PlugBottomNavConfig(),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Cart navigation, 4 items'),
        findsOneWidget,
      );

      handle.dispose();
    });

    testWidgets('custom semanticLabel overrides the default', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrap(
          PlugBottomNavBar(
            currentIndex: 0,
            items: const [
              PlugNavItem(
                icon: Icons.shopping_cart,
                label: 'Cart',
                semanticLabel: 'Shopping cart tab',
              ),
            ],
            onTap: (_) {},
            config: const PlugBottomNavConfig(),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Shopping cart tab'), findsOneWidget);

      handle.dispose();
    });
  });
}

/// Minimal mutable-count Notifier for testing live badge updates — mirrors
/// the shape a real app's cart-count provider would have, without needing
/// a full cart model for these tests.
class _CountNotifier extends Notifier<int> {
  final int _initial;

  _CountNotifier([this._initial = 0]);

  @override
  int build() => _initial;

  void set(int value) => state = value;
}
