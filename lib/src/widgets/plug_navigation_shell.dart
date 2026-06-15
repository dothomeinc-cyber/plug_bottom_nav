import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../enums/plug_nav_animation_type.dart';
import '../models/plug_bottom_nav_config.dart';
import '../models/plug_nav_item.dart';
import '../providers/plug_nav_provider.dart';
import 'plug_bottom_nav_bar.dart';

/// Wraps the [StatefulNavigationShell] with a [Scaffold] + bottom bar.
///
/// You normally never build this yourself — `PlugBottomNavRouter.create`
/// supplies it inside the generated shell route. It:
///  * renders the active branch,
///  * keeps [plugSelectedIndexProvider] in sync,
///  * applies the configured page transition,
///  * supports pinned / floating / reverse / hide-on-scroll.
class PlugNavigationShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<PlugNavItem> items;
  final PlugBottomNavConfig config;

  const PlugNavigationShell({
    super.key,
    required this.navigationShell,
    required this.items,
    required this.config,
  });

  @override
  ConsumerState<PlugNavigationShell> createState() =>
      _PlugNavigationShellState();
}

class _PlugNavigationShellState extends ConsumerState<PlugNavigationShell> {
  /// 0..1 visibility used for hide-on-scroll. 1 = fully shown.
  double _barVisible = 1;

  void _syncIndex() {
    // Defer to after build to avoid mutating provider during widget build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(plugSelectedIndexProvider.notifier)
          .set(widget.navigationShell.currentIndex);
    });
  }

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  bool _onScroll(ScrollNotification n) {
    // Only react when the bar is actually allowed to hide.
    if (!widget.config.hideOnScroll || widget.config.pinned) return false;
    if (n is ScrollUpdateNotification && n.scrollDelta != null) {
      final delta = n.scrollDelta!;
      final next = (_barVisible - delta / 80).clamp(0.0, 1.0);
      if ((next - _barVisible).abs() > 0.01) {
        setState(() => _barVisible = next);
      }
    }
    return false;
  }

  Widget _transition(Widget child) {
    final cfg = widget.config;
    switch (cfg.animationType) {
      case PlugNavAnimationType.none:
        return child;
      case PlugNavAnimationType.fade:
      case PlugNavAnimationType.slide:
      case PlugNavAnimationType.scale:
      case PlugNavAnimationType.fadeThrough:
        // PageTransitionSwitcher animates when the keyed child changes.
        return PageTransitionSwitcher(
          duration: cfg.animationDuration,
          transitionBuilder: (c, anim, sec) =>
              _builderFor(cfg.animationType, c, anim, sec),
          child: KeyedSubtree(
            key: ValueKey<int>(widget.navigationShell.currentIndex),
            child: child,
          ),
        );
    }
  }

  Widget _builderFor(
    PlugNavAnimationType type,
    Widget child,
    Animation<double> animation,
    Animation<double> secondary,
  ) {
    switch (type) {
      case PlugNavAnimationType.fadeThrough:
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondary,
          child: child,
        );
      case PlugNavAnimationType.scale:
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondary,
          transitionType: SharedAxisTransitionType.scaled,
          child: child,
        );
      case PlugNavAnimationType.slide:
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondary,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      case PlugNavAnimationType.fade:
      case PlugNavAnimationType.none:
        return FadeTransition(opacity: animation, child: child);
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncIndex();

    final cfg = widget.config;

    final body = NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: _transition(widget.navigationShell),
    );

    final navBar = PlugBottomNavBar(
      currentIndex: widget.navigationShell.currentIndex,
      items: widget.items,
      config: cfg,
      onTap: _goBranch,
    );

    // Two independent switches:
    //   floating  -> pill shape (overlaid) vs. edge-to-edge bar
    //   pinned    -> always visible vs. allowed to hide on scroll
    //
    // hideOnScroll only takes effect when pinned == false.
    final canHide = cfg.hideOnScroll && !cfg.pinned;

    final maybeHidingBar = canHide
        ? AnimatedSlide(
            duration: const Duration(milliseconds: 200),
            offset: Offset(0, 1 - _barVisible),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _barVisible,
              child: navBar,
            ),
          )
        : navBar;

    if (cfg.floating) {
      // Floating pill: overlay the bar above the body so it "floats".
      // Pinned vs. hide-on-scroll both supported via [maybeHidingBar].
      return Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            Positioned.fill(child: body),
            Align(
              alignment: Alignment.bottomCenter,
              child: maybeHidingBar,
            ),
          ],
        ),
      );
    }

    // Edge-to-edge bar. Pinned -> fixed bottomNavigationBar.
    // Not pinned + hideOnScroll -> overlaid so it can slide away.
    if (cfg.pinned) {
      return Scaffold(
        body: body,
        bottomNavigationBar: maybeHidingBar,
      );
    }

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(child: body),
          Align(
            alignment: Alignment.bottomCenter,
            child: maybeHidingBar,
          ),
        ],
      ),
    );
  }
}
