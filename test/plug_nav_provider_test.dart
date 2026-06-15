import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plug_bottom_nav/plug_bottom_nav.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  group('plugSelectedIndexProvider', () {
    PlugSelectedIndexNotifier index() =>
        container.read(plugSelectedIndexProvider.notifier);

    test('defaults to 0', () {
      expect(container.read(plugSelectedIndexProvider), 0);
    });

    test('set updates the index', () {
      index().set(2);
      expect(container.read(plugSelectedIndexProvider), 2);

      index().set(1);
      expect(container.read(plugSelectedIndexProvider), 1);
    });

    test('setting same index does not emit a new state',
        () {
      var rebuilds = 0;
      container.listen(
        plugSelectedIndexProvider,
        (_, __) => rebuilds++,
        fireImmediately: false,
      );

      index().set(0); // already 0 -> no change
      expect(rebuilds, 0);

      index().set(3); // change
      expect(rebuilds, 1);

      index().set(3); // same again -> no change
      expect(rebuilds, 1);
    });
  });

  group('plugAddToCartLoadingProvider', () {
    PlugAddToCartLoadingNotifier loading() => container
        .read(plugAddToCartLoadingProvider.notifier);

    const seller = 'seller_1';
    const itemA = 'item_a';
    const itemB = 'item_b';

    test('starts with nothing loading', () {
      expect(container.read(plugAddToCartLoadingProvider),
          isEmpty);
      expect(loading().isLoading(seller, itemA), isFalse);
    });

    test('start marks a single item as loading', () {
      loading().start(seller, itemA);

      expect(loading().isLoading(seller, itemA), isTrue);
      expect(loading().isLoading(seller, itemB), isFalse);
    });

    test('multiple items load independently', () {
      loading().start(seller, itemA);
      loading().start(seller, itemB);

      expect(loading().isLoading(seller, itemA), isTrue);
      expect(loading().isLoading(seller, itemB), isTrue);

      loading().stop(seller, itemA);

      expect(loading().isLoading(seller, itemA), isFalse);
      expect(loading().isLoading(seller, itemB), isTrue);
    });

    test(
        'same item under different sellers is keyed separately',
        () {
      loading().start('seller_x', itemA);

      expect(
          loading().isLoading('seller_x', itemA), isTrue);
      expect(
          loading().isLoading('seller_y', itemA), isFalse);
    });

    test('stop on a non-loading item is a no-op', () {
      loading().stop(seller, itemA);
      expect(container.read(plugAddToCartLoadingProvider),
          isEmpty);
    });
  });
}
