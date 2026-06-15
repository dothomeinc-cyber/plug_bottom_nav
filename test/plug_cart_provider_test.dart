import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plug_bottom_nav/plug_bottom_nav.dart';

void main() {
  late ProviderContainer container;
  PlugCartNotifier cart() =>
      container.read(plugCartProvider.notifier);

  const sellerA = 'seller_a';
  const sellerB = 'seller_b';

  const cement = PlugCartItem(
    id: 'cement',
    title: 'Cement',
    sellerId: sellerA,
    price: 10,
  );
  const paint = PlugCartItem(
    id: 'paint',
    title: 'Paint',
    sellerId: sellerA,
    price: 25,
    quantity: 2,
  );
  const milk = PlugCartItem(
    id: 'milk',
    title: 'Milk',
    sellerId: sellerB,
    price: 3,
  );

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  group('initial state', () {
    test('starts empty', () {
      expect(container.read(plugCartProvider), isEmpty);
    });

    test('count/total are zero for unknown seller', () {
      expect(cart().cartCount(sellerA), 0);
      expect(cart().cartTotal(sellerA), 0);
      expect(
          cart().isInCart(
              sellerId: sellerA, itemId: 'cement'),
          isFalse);
      expect(
          cart().quantityOf(
              sellerId: sellerA, itemId: 'cement'),
          0);
    });
  });

  group('addItem', () {
    test('adds a new item', () {
      cart().addItem(sellerId: sellerA, item: cement);

      expect(
          cart().isInCart(
              sellerId: sellerA, itemId: 'cement'),
          isTrue);
      expect(cart().cartCount(sellerA), 1);
      expect(cart().cartTotal(sellerA), 10);
    });

    test(
        'adding same id increases quantity by item.quantity',
        () {
      cart().addItem(
          sellerId: sellerA, item: cement); // qty 1
      cart()
          .addItem(sellerId: sellerA, item: paint); // qty 2

      expect(cart().cartCount(sellerA), 3); // 1 + 2
      expect(cart().cartTotal(sellerA), 10 + 25 * 2);

      cart().addItem(
          sellerId: sellerA, item: cement); // +1 -> qty 2
      expect(
          cart().quantityOf(
              sellerId: sellerA, itemId: 'cement'),
          2);
      expect(cart().cartCount(sellerA), 4);
    });

    test('carts are isolated per seller', () {
      cart().addItem(sellerId: sellerA, item: cement);
      cart().addItem(sellerId: sellerB, item: milk);

      expect(cart().cartCount(sellerA), 1);
      expect(cart().cartCount(sellerB), 1);
      expect(
          cart()
              .isInCart(sellerId: sellerA, itemId: 'milk'),
          isFalse);
      expect(
          cart()
              .isInCart(sellerId: sellerB, itemId: 'milk'),
          isTrue);
    });
  });

  group('increaseQty / decreaseQty', () {
    test('increaseQty bumps quantity', () {
      cart().addItem(sellerId: sellerA, item: cement);
      cart()
          .increaseQty(sellerId: sellerA, itemId: 'cement');

      expect(
          cart().quantityOf(
              sellerId: sellerA, itemId: 'cement'),
          2);
    });

    test('decreaseQty lowers quantity', () {
      cart()
          .addItem(sellerId: sellerA, item: paint); // qty 2
      cart()
          .decreaseQty(sellerId: sellerA, itemId: 'paint');

      expect(
          cart().quantityOf(
              sellerId: sellerA, itemId: 'paint'),
          1);
    });

    test('decreaseQty to zero removes the line', () {
      cart().addItem(
          sellerId: sellerA, item: cement); // qty 1
      cart()
          .decreaseQty(sellerId: sellerA, itemId: 'cement');

      expect(
          cart().isInCart(
              sellerId: sellerA, itemId: 'cement'),
          isFalse);
      // Seller key dropped entirely once its cart is empty.
      expect(
          container
              .read(plugCartProvider)
              .containsKey(sellerA),
          isFalse);
    });

    test('mutating unknown item is a no-op', () {
      cart()
          .increaseQty(sellerId: sellerA, itemId: 'ghost');
      cart()
          .decreaseQty(sellerId: sellerA, itemId: 'ghost');
      expect(container.read(plugCartProvider), isEmpty);
    });
  });

  group('removeItem / clear', () {
    test('removeItem removes a single line', () {
      cart().addItem(sellerId: sellerA, item: cement);
      cart().addItem(sellerId: sellerA, item: paint);
      cart()
          .removeItem(sellerId: sellerA, itemId: 'cement');

      expect(
          cart().isInCart(
              sellerId: sellerA, itemId: 'cement'),
          isFalse);
      expect(
          cart()
              .isInCart(sellerId: sellerA, itemId: 'paint'),
          isTrue);
    });

    test('clearSellerCart empties only that seller', () {
      cart().addItem(sellerId: sellerA, item: cement);
      cart().addItem(sellerId: sellerB, item: milk);
      cart().clearSellerCart(sellerA);

      expect(cart().cartCount(sellerA), 0);
      expect(cart().cartCount(sellerB), 1);
    });

    test('clearAll empties everything', () {
      cart().addItem(sellerId: sellerA, item: cement);
      cart().addItem(sellerId: sellerB, item: milk);
      cart().clearAll();

      expect(container.read(plugCartProvider), isEmpty);
    });
  });

  group('convenience providers', () {
    test('plugCartCountProvider reflects live count', () {
      expect(container.read(plugCartCountProvider(sellerA)),
          0);

      cart()
          .addItem(sellerId: sellerA, item: paint); // qty 2
      expect(container.read(plugCartCountProvider(sellerA)),
          2);
    });

    test('plugCartTotalProvider reflects live total', () {
      cart().addItem(sellerId: sellerA, item: cement); // 10
      cart().addItem(
          sellerId: sellerA, item: paint); // 25 * 2

      expect(container.read(plugCartTotalProvider(sellerA)),
          60);
    });
  });

  test('PlugCartItem.lineTotal = price * quantity', () {
    expect(paint.lineTotal, 50);
    expect(cement.lineTotal, 10);
  });
}
