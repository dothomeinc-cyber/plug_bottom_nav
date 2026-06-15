import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the currently selected tab index.
///
/// The shell keeps this in sync with `navigationShell.currentIndex`, so any
/// page anywhere in the app can read the active tab with:
///
/// ```dart
/// final index = ref.watch(plugSelectedIndexProvider);
/// ```
class PlugSelectedIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// Set the selected index. Called by the shell on branch changes.
  void set(int index) {
    if (state != index) state = index;
  }
}

/// Selected-tab index, synced from the GoRouter navigation shell.
final plugSelectedIndexProvider =
    NotifierProvider<PlugSelectedIndexNotifier, int>(
  PlugSelectedIndexNotifier.new,
);

/// Per-(seller,item) loading flags for add-to-cart buttons.
///
/// Keyed as `"<sellerId>::<itemId>"`. Lets multiple buttons show independent
/// spinners without local widget state leaking across rebuilds.
class PlugAddToCartLoadingNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  String _key(String sellerId, String itemId) => '$sellerId::$itemId';

  bool isLoading(String sellerId, String itemId) =>
      state.contains(_key(sellerId, itemId));

  void start(String sellerId, String itemId) {
    state = {...state, _key(sellerId, itemId)};
  }

  void stop(String sellerId, String itemId) {
    final next = {...state}..remove(_key(sellerId, itemId));
    state = next;
  }
}

/// Tracks which add-to-cart buttons are currently in their async phase.
final plugAddToCartLoadingProvider =
    NotifierProvider<PlugAddToCartLoadingNotifier, Set<String>>(
  PlugAddToCartLoadingNotifier.new,
);
