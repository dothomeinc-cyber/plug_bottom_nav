import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the currently selected bottom-nav tab index.
///
/// [PlugNavigationShell] keeps this in sync with
/// `navigationShell.currentIndex` automatically — no wiring required. Any
/// page in the app can read the active tab with:
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

/// Selected-tab index, synced automatically from the GoRouter navigation
/// shell.
final plugSelectedIndexProvider =
    NotifierProvider<PlugSelectedIndexNotifier, int>(
  PlugSelectedIndexNotifier.new,
);
