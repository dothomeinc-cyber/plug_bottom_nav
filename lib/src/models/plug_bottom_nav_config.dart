import 'package:flutter/material.dart';

import '../enums/plug_nav_animation_type.dart';

/// Visual + behavioural configuration for the bottom navigation bar.
class PlugBottomNavConfig {
  /// Keep the bar always visible. When true the bar never hides on scroll.
  /// When false and [hideOnScroll] is true, the bar slides away on scroll-down
  /// and returns on scroll-up. Independent of [floating]. Default true.
  final bool pinned;

  /// Render as a rounded floating pill (Uber-style), inset with [floatingMargin]
  /// and overlaid above the body. When false the bar is edge-to-edge at the
  /// bottom. Independent of [pinned]. Default false.
  final bool floating;

  /// Reverse the visual order of the items (last item shown first).
  /// Note: this does NOT change branch indexes, only the on-screen order.
  final bool reverse;

  /// Hide the bar while scrolling down and reveal it when scrolling up.
  /// Requires wiring [PlugNavScrollController]/`PlugNavScrollHider`
  /// (see README). Defaults to false.
  final bool hideOnScroll;

  /// Show text labels under icons.
  final bool showLabels;

  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;

  /// Background of the selected item's pill highlight (floating style).
  /// Defaults to [selectedColor] at low opacity when null.
  final Color? selectedPillColor;

  final double height;
  final double iconSize;
  final double selectedIconSize;
  final double borderRadius;

  /// Outer margin used only when [floating] is true.
  final EdgeInsets floatingMargin;

  /// Drop shadow elevation of the bar.
  final double elevation;

  final PlugNavAnimationType animationType;
  final Duration animationDuration;

  /// Optional font family for labels (e.g. GoogleFonts family name).
  final TextStyle? labelStyle;

  const PlugBottomNavConfig({
    this.pinned = true,
    this.floating = false,
    this.reverse = false,
    this.hideOnScroll = false,
    this.showLabels = true,
    this.backgroundColor = Colors.white,
    this.selectedColor = Colors.green,
    this.unselectedColor = Colors.grey,
    this.selectedPillColor,
    this.height = 72,
    this.iconSize = 24,
    this.selectedIconSize = 28,
    this.borderRadius = 28,
    this.floatingMargin = const EdgeInsets.fromLTRB(24, 0, 24, 16),
    this.elevation = 12,
    this.animationType = PlugNavAnimationType.fadeThrough,
    this.animationDuration = const Duration(milliseconds: 300),
    this.labelStyle,
  });

  PlugBottomNavConfig copyWith({
    bool? pinned,
    bool? floating,
    bool? reverse,
    bool? hideOnScroll,
    bool? showLabels,
    Color? backgroundColor,
    Color? selectedColor,
    Color? unselectedColor,
    Color? selectedPillColor,
    double? height,
    double? iconSize,
    double? selectedIconSize,
    double? borderRadius,
    EdgeInsets? floatingMargin,
    double? elevation,
    PlugNavAnimationType? animationType,
    Duration? animationDuration,
    TextStyle? labelStyle,
  }) {
    return PlugBottomNavConfig(
      pinned: pinned ?? this.pinned,
      floating: floating ?? this.floating,
      reverse: reverse ?? this.reverse,
      hideOnScroll: hideOnScroll ?? this.hideOnScroll,
      showLabels: showLabels ?? this.showLabels,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedColor: selectedColor ?? this.selectedColor,
      unselectedColor: unselectedColor ?? this.unselectedColor,
      selectedPillColor: selectedPillColor ?? this.selectedPillColor,
      height: height ?? this.height,
      iconSize: iconSize ?? this.iconSize,
      selectedIconSize: selectedIconSize ?? this.selectedIconSize,
      borderRadius: borderRadius ?? this.borderRadius,
      floatingMargin: floatingMargin ?? this.floatingMargin,
      elevation: elevation ?? this.elevation,
      animationType: animationType ?? this.animationType,
      animationDuration: animationDuration ?? this.animationDuration,
      labelStyle: labelStyle ?? this.labelStyle,
    );
  }
}
