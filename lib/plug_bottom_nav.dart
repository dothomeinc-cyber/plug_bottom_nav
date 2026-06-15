/// Plug-and-play Blinkit / Uber / Instacart-style bottom navigation.
///
/// Auto-generates the GoRouter `StatefulShellRoute.indexedStack`, syncs the
/// selected tab into Riverpod, and ships a per-seller cart + automatic
/// add-to-cart button. The host app writes no shell-route boilerplate.
library plug_bottom_nav;

export 'src/router/plug_bottom_nav_router.dart';

export 'src/models/plug_nav_route.dart';
export 'src/models/plug_nav_item.dart';
export 'src/models/plug_bottom_nav_config.dart';
export 'src/models/plug_cart_item.dart';

export 'src/enums/plug_nav_animation_type.dart';

export 'src/providers/plug_nav_provider.dart';
export 'src/providers/plug_cart_provider.dart';

export 'src/widgets/plug_navigation_shell.dart';
export 'src/widgets/plug_bottom_nav_shell.dart';
export 'src/widgets/plug_bottom_nav_bar.dart';
export 'src/widgets/plug_cart_bar.dart';
export 'src/widgets/plug_add_to_cart_button.dart';
