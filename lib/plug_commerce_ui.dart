/// Riverpod-first UI for Blinkit / Uber / Instacart-style commerce apps.
///
/// This package owns UI ONLY — bottom navigation and cart *presentation*.
/// It never stores cart data, never talks to Firebase, and never decides
/// checkout/order logic. Your app supplies:
///   * cart state (a Riverpod provider backed by Firebase or anything else)
///   * badge counts, as `ProviderListenable<int>`
///   * callbacks for add/increase/decrease/remove/checkout/view-cart
///
/// and this package renders it.
library;

// ---- Navigation -----------------------------------------------------------

export 'src/navigation/router/plug_bottom_nav_router.dart';

export 'src/navigation/models/plug_nav_route.dart';
export 'src/navigation/models/plug_nav_item.dart';
export 'src/navigation/models/plug_bottom_nav_config.dart';

export 'src/navigation/enums/plug_nav_animation_type.dart';

export 'src/navigation/providers/plug_selected_index_provider.dart';

export 'src/navigation/widgets/plug_navigation_shell.dart';
export 'src/navigation/widgets/plug_bottom_nav_shell.dart';
export 'src/navigation/widgets/plug_bottom_nav_bar.dart';

// ---- Cart UI ----------------------------------------------------------------

export 'src/cart/models/plug_cart_item.dart';

export 'src/cart/widgets/plug_cart_popup.dart';
export 'src/cart/widgets/plug_cart_badge.dart';
export 'src/cart/widgets/plug_add_to_cart_button.dart';
export 'src/cart/widgets/plug_seller_cart_sheet.dart';
export 'src/cart/widgets/plug_seller_cart_indicator.dart';
export 'src/cart/widgets/plug_empty_cart.dart';
