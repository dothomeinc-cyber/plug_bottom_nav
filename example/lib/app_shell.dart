import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plug_commerce_ui/plug_commerce_ui.dart';

import 'features/cart/presentation/cart_controller.dart';
import 'screens/cart_screen.dart';
import 'screens/home_screen.dart';

/// Sets up the GoRouter + bottom nav. Riverpod-first: [cartTotalCountProvider]
/// is passed straight through as [PlugNavRoute.badgeProvider] — no adapter,
/// no manual wiring. The selected tab index syncs into
/// `plugSelectedIndexProvider` automatically.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final router = PlugBottomNavRouter.create(
      initialLocation: '/home',
      navConfig: const PlugBottomNavConfig(
        floating: true,
        selectedColor: Colors.green,
      ),
      items: [
        const PlugNavRoute(
          path: '/home',
          icon: Icons.storefront_outlined,
          activeIcon: Icons.storefront,
          label: 'Shop',
          page: HomeScreen(),
        ),
        PlugNavRoute(
          path: '/cart',
          icon: Icons.shopping_cart_outlined,
          activeIcon: Icons.shopping_cart,
          label: 'Cart',
          page: const CartScreen(),
          // The live badge — package never knows this counts Firestore
          // cart documents under the hood.
          badgeProvider: cartTotalCountProvider,
        ),
      ],
      extraRoutes: [
        GoRoute(
          path: '/cart/:sellerId',
          builder: (context, state) =>
              CartScreen(sellerId: state.pathParameters['sellerId']),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'plug_commerce_ui example',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      routerConfig: router,
    );
  }
}
