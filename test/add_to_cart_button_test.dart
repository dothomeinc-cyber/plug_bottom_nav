import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plug_commerce_ui/plug_commerce_ui.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('PlugAddToCartButton — states', () {
    testWidgets('idle shows addText and calls onAdd on tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        _wrap(
          PlugAddToCartButton(
            state: PlugAddToCartState.idle,
            onAdd: () => tapped = true,
            enableHaptics: false,
          ),
        ),
      );

      expect(find.text('Add'), findsOneWidget);

      await tester.tap(find.text('Add'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('loading shows a spinner and no tappable text', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const PlugAddToCartButton(state: PlugAddToCartState.loading),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Add'), findsNothing);
    });

    testWidgets(
        'added + showStepperWhenAdded: false shows addedText and calls onChangePressed',
        (tester) async {
      var changeTapped = false;

      await tester.pumpWidget(
        _wrap(
          PlugAddToCartButton(
            state: PlugAddToCartState.added,
            showStepperWhenAdded: false,
            onChangePressed: () => changeTapped = true,
          ),
        ),
      );

      expect(find.text('Change'), findsOneWidget);

      await tester.tap(find.text('Change'));
      await tester.pump();

      expect(changeTapped, isTrue);
    });

    testWidgets('custom addText/addedText are used', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlugAddToCartButton(
            state: PlugAddToCartState.idle,
            addText: 'Add to Cart',
            onAdd: () {},
          ),
        ),
      );

      expect(find.text('Add to Cart'), findsOneWidget);
    });
  });

  group('PlugAddToCartButton — quantity stepper', () {
    testWidgets('added + showStepperWhenAdded: true shows quantity and +/-',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          PlugAddToCartButton(
            state: PlugAddToCartState.added,
            quantity: 4,
            onIncrease: () {},
            onDecrease: () {},
            enableHaptics: false,
          ),
        ),
      );

      expect(find.text('4'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('tapping + calls onIncrease', (tester) async {
      var increased = 0;

      await tester.pumpWidget(
        _wrap(
          PlugAddToCartButton(
            state: PlugAddToCartState.added,
            quantity: 4,
            onIncrease: () => increased++,
            onDecrease: () {},
            enableHaptics: false,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(increased, 1);
    });

    testWidgets('tapping - calls onDecrease', (tester) async {
      var decreased = 0;

      await tester.pumpWidget(
        _wrap(
          PlugAddToCartButton(
            state: PlugAddToCartState.added,
            quantity: 4,
            onIncrease: () {},
            onDecrease: () => decreased++,
            enableHaptics: false,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(decreased, 1);
    });
  });

  group('PlugAddToCartButton — maxQuantity', () {
    testWidgets('+ is disabled once quantity reaches maxQuantity',
        (tester) async {
      var increaseCalls = 0;

      await tester.pumpWidget(
        _wrap(
          PlugAddToCartButton(
            state: PlugAddToCartState.added,
            quantity: 50,
            maxQuantity: 50,
            onIncrease: () => increaseCalls++,
            onDecrease: () {},
            enableHaptics: false,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(increaseCalls, 0);
    });

    testWidgets('+ remains enabled below maxQuantity', (tester) async {
      var increaseCalls = 0;

      await tester.pumpWidget(
        _wrap(
          PlugAddToCartButton(
            state: PlugAddToCartState.added,
            quantity: 49,
            maxQuantity: 50,
            onIncrease: () => increaseCalls++,
            onDecrease: () {},
            enableHaptics: false,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(increaseCalls, 1);
    });

    testWidgets('- remains enabled at maxQuantity', (tester) async {
      var decreaseCalls = 0;

      await tester.pumpWidget(
        _wrap(
          PlugAddToCartButton(
            state: PlugAddToCartState.added,
            quantity: 50,
            maxQuantity: 50,
            onIncrease: () {},
            onDecrease: () => decreaseCalls++,
            enableHaptics: false,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(decreaseCalls, 1);
    });

    testWidgets('quantity exceeding maxQuantity also disables + (defensive)',
        (tester) async {
      // Shouldn't normally happen (app's job to enforce), but the button
      // must not crash or allow further increment if it does.
      var increaseCalls = 0;

      await tester.pumpWidget(
        _wrap(
          PlugAddToCartButton(
            state: PlugAddToCartState.added,
            quantity: 55,
            maxQuantity: 50,
            onIncrease: () => increaseCalls++,
            onDecrease: () {},
            enableHaptics: false,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(increaseCalls, 0);
    });

    testWidgets('no maxQuantity set never disables +', (tester) async {
      var increaseCalls = 0;

      await tester.pumpWidget(
        _wrap(
          PlugAddToCartButton(
            state: PlugAddToCartState.added,
            quantity: 9999,
            onIncrease: () => increaseCalls++,
            onDecrease: () {},
            enableHaptics: false,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(increaseCalls, 1);
    });
  });
}
