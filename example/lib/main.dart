import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plug_bottom_nav/plug_bottom_nav.dart';

import 'pages/account_page.dart';
import 'pages/cart_page.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';

void main() {
  // ProviderScope is required for Riverpod.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // === The ONLY navigation setup you write. No shell route boilerplate. ===
  static final router = PlugBottomNavRouter.create(
    initialLocation: '/home',
    items: const [
      PlugNavRoute(
        path: '/home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        page: HomePage(),
      ),
      PlugNavRoute(
        path: '/search',
        icon: Icons.search,
        label: 'Search',
        page: SearchPage(),
      ),
      PlugNavRoute(
        path: '/cart',
        icon: Icons.shopping_cart_outlined,
        activeIcon: Icons.shopping_cart,
        label: 'Cart',
        page: CartPage(),
      ),
      PlugNavRoute(
        path: '/account',
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Account',
        page: AccountPage(),
      ),
    ],
    navConfig: const PlugBottomNavConfig(
      pinned: true,
      floating: true, // Uber-style floating pill
      reverse: false,
      backgroundColor: Colors.white,
      selectedColor: Color(0xFF0A8754), // green
      unselectedColor: Colors.grey,
      animationType: PlugNavAnimationType.fadeThrough,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'plug_bottom_nav demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      routerConfig: router,
    );
  }
}
