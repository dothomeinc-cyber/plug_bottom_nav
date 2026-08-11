import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/plug_bottom_nav_config.dart';
import '../models/plug_nav_item.dart';

/// The visual bottom navigation bar (Blinkit / Uber / Instacart style).
///
/// Renders [items] for the given [currentIndex] and reports taps via [onTap]
/// using the *real* branch index (independent of `reverse` visual ordering).
/// A live badge comes from [PlugNavItem.badgeProvider] — a Riverpod
/// `ProviderListenable<int>` — watched directly by each tile.
class PlugBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<PlugNavItem> items;
  final ValueChanged<int> onTap;
  final PlugBottomNavConfig config;

  const PlugBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    // Build (visualIndex -> realIndex) ordering, honouring `reverse`.
    final order = List<int>.generate(items.length, (i) => i);
    final ordered = config.reverse ? order.reversed.toList() : order;

    final bar = Container(
      height: config.height,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: config.floating
            ? BorderRadius.circular(config.borderRadius)
            : BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: config.elevation,
            offset: Offset(0, config.floating ? 4 : -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final realIndex in ordered)
            Expanded(
              child: _PlugNavTile(
                item: items[realIndex],
                selected: realIndex == currentIndex,
                config: config,
                onTap: () => onTap(realIndex),
              ),
            ),
        ],
      ),
    );

    if (!config.floating) {
      // Edge-to-edge bar: respect bottom safe area.
      return SafeArea(top: false, child: bar);
    }

    // Floating pill: inset with margins and clip the shadow nicely.
    return SafeArea(
      top: false,
      child: Padding(
        padding: config.floatingMargin,
        child: bar,
      ),
    );
  }
}

class _PlugNavTile extends ConsumerWidget {
  final PlugNavItem item;
  final bool selected;
  final PlugBottomNavConfig config;
  final VoidCallback onTap;

  const _PlugNavTile({
    required this.item,
    required this.selected,
    required this.config,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = selected ? config.selectedColor : config.unselectedColor;
    final iconData =
        selected ? (item.activeIcon ?? item.icon) : item.icon;

    final pillColor = config.selectedPillColor ??
        config.selectedColor.withValues(alpha: 0.12);

    final semanticLabelBase = item.semanticLabel ?? '${item.label} navigation';

    final badgeCount = item.badgeProvider != null
        ? ref.watch(item.badgeProvider!)
        : item.badgeCount;

    final semanticLabel = badgeCount > 0
        ? '$semanticLabelBase, $badgeCount ${badgeCount == 1 ? 'item' : 'items'}'
        : semanticLabelBase;

    return Semantics(
      selected: selected,
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(config.borderRadius),
        child: AnimatedContainer(
          duration: config.animationDuration,
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 14 : 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: selected && config.floating
                ? pillColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(config.borderRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: _IconWithBadge(
                  icon: iconData,
                  size: selected
                      ? config.selectedIconSize
                      : config.iconSize,
                  color: color,
                  badgeCount: badgeCount,
                  duration: config.animationDuration,
                ),
              ),
              if (config.showLabels) ...[
                const SizedBox(height: 4),
                ExcludeSemantics(
                  child: AnimatedDefaultTextStyle(
                    duration: config.animationDuration,
                    style: (config.labelStyle ?? const TextStyle()).copyWith(
                      color: color,
                      fontSize: 12,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    child: Text(item.label, maxLines: 1),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IconWithBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final int badgeCount;
  final Duration duration;

  const _IconWithBadge({
    required this.icon,
    required this.size,
    required this.color,
    required this.badgeCount,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = AnimatedSize(
      duration: duration,
      curve: Curves.easeOut,
      child: Icon(icon, size: size, color: color),
    );

    if (badgeCount <= 0) return iconWidget;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        Positioned(
          right: -8,
          top: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            constraints: const BoxConstraints(minWidth: 16),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badgeCount > 99 ? '99+' : '$badgeCount',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
