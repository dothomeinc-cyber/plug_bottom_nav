/// Page transition styles used when switching between tabs.
enum PlugNavAnimationType {
  /// No transition. The new page appears instantly.
  none,

  /// Simple opacity cross-fade.
  fade,

  /// Material "fade through" (recommended for unrelated destinations).
  fadeThrough,

  /// Horizontal slide.
  slide,

  /// Scale + fade.
  scale,
}
