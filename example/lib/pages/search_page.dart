import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plug_bottom_nav/plug_bottom_nav.dart';

/// Shows reading the selected tab index from Riverpod anywhere in the app.
class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(plugSelectedIndexProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Center(
        child: Text('Selected tab index (from Riverpod): $selected'),
      ),
    );
  }
}
