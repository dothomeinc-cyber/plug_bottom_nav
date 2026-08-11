# plug_commerce_ui

**Riverpod-first UI components for Blinkit/Uber/Instacart-style Flutter apps.**

Plug-and-play bottom navigation with **automatic `GoRouter` shell generation**, plus a complete set of **cart UI widgets** that work with your own data layer.

---

## 📦 What's Included

- **🔌 Auto Router** — `PlugBottomNavRouter.create()` returns a ready-to-use `GoRouter`. No manual `StatefulShellRoute` boilerplate.
- **🎨 Flexible Nav Bar** — `pinned`/`floating` (Uber pill), `hideOnScroll` (Instacart-style), `reverse`, custom colors, per-tab badges.
- **🧭 Selected Tab in Riverpod** — `plugSelectedIndexProvider` lets any page read the active tab.
- **🛒 Complete Cart UI** — `PlugAddToCartButton`, `PlugSellerCartSheet`, `PlugCartPopup`, `PlugSellerCartIndicator`, `PlugCartBadge`, `PlugEmptyCart`.
- **✨ Tab Transitions** — `fade`, `fadeThrough`, `slide`, `scale`, `none` via the `animations` package.
- **📱 Fully Responsive** — Adapts to different screen sizes with safe area handling.
- **♿ Accessibility Ready** — Semantics, screen reader labels, button roles.
- **🎯 Haptic Feedback** — Optional haptic ticks on add/increase/decrease (Blinkit-style).
- **📊 Live Badges** — Watch Riverpod providers for real-time badge counts.
- **🔀 Nested Routes** — Deep links keep the bottom bar visible.
- **🔄 Scroll-Aware** — Hide/show bar based on scroll direction.
- **🔐 Auth Ready** — Built-in redirect support for authentication flows.
- **🧩 ShellRoute Support** — Use `ShellRoute` in `extraRoutes` for shared layouts without bottom nav.

---

## 🚀 Quick Start

### 1. Add dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  plug_commerce_ui: ^1.0.0
  flutter_riverpod: ^3.3.2-dev.2
  go_router: ^17.3.0
  animations: ^2.0.11
```

`flutter_riverpod`, `go_router`, and `animations` are already required dependencies
of `plug_commerce_ui` — listing them explicitly here is only necessary because
your own app code (providers, `context.push`, etc.) imports them directly too.

### 2. Wrap your app with `ProviderScope`

```dart
void main() => runApp(const ProviderScope(child: MyApp()));
```

### 3. Create your router

```dart
final router = PlugBottomNavRouter.create(
  initialLocation: '/home',
  items: [
    PlugNavRoute(
      path: '/home',
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
      label: 'Shop',
      page: const HomeScreen(),
      routes: [
        // Nested routes keep bottom bar visible
        GoRoute(
          path: 'product/:id',
          builder: (c, s) => ProductDetailScreen(id: s.pathParameters['id']!),
        ),
      ],
    ),
    PlugNavRoute(
      path: '/cart',
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
      label: 'Cart',
      page: const CartScreen(),
      badgeProvider: cartCountProvider, // your Riverpod provider
    ),
    PlugNavRoute(
      path: '/orders',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'Orders',
      page: const OrdersScreen(),
      routes: [
        // /orders/:orderId — inside Orders tab, bar visible
        GoRoute(
          path: ':orderId',
          builder: (c, s) => OrderDetailScreen(
            orderId: s.pathParameters['orderId']!,
          ),
        ),
      ],
    ),
    PlugNavRoute(
      path: '/account',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Account',
      page: const AccountScreen(),
    ),
  ],
  extraRoutes: [
    // Full-screen routes WITHOUT bottom bar
    GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
    GoRoute(
      path: '/checkout/:sellerId',
      builder: (c, s) => CheckoutScreen(sellerId: s.pathParameters['sellerId']!),
    ),
    GoRoute(
      path: '/order-success',
      builder: (c, s) => OrderSuccessScreen(
        orderId: s.uri.queryParameters['orderId'] ?? '',
        paymentMethod: s.uri.queryParameters['method'] ?? '',
      ),
    ),
    // ShellRoute example — shared layout without bottom nav
    ShellRoute(
      builder: (context, state, child) => SettingsShell(child: child),
      routes: [
        GoRoute(
          path: '/settings',
          builder: (c, s) => const SettingsHomeScreen(),
        ),
        GoRoute(
          path: '/settings/notifications',
          builder: (c, s) => const NotificationSettingsScreen(),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    // Auth gating — applies to ALL routes
    const isLoggedIn = false;
    final loggingIn = state.matchedLocation == '/login';
    final onboarding = state.matchedLocation == '/onboarding';

    if (!isLoggedIn && !loggingIn && !onboarding) return '/login';
    if (isLoggedIn && loggingIn) return '/home';
    return null;
  },
  navConfig: const PlugBottomNavConfig(
    floating: true,              // Uber-style pill
    pinned: true,
    selectedColor: Colors.green,
    backgroundColor: Colors.white,
    animationType: PlugNavAnimationType.fadeThrough,
  ),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(routerConfig: router);
}
```

**That's it.** You now have a fully functional bottom navigation with tab switching, transitions, nested routes, and authentication.

---

## 🧭 Read the Selected Tab Anywhere

```dart
final currentTab = ref.watch(plugSelectedIndexProvider);
```

---

## 🛒 Complete Cart UI System

### `PlugCartItem` — Display Model

```dart
const PlugCartItem(
  productId: 'cement_001',
  sellerId: 'seller_001',
  productName: 'UltraTech Cement',
  subtitle: '50kg Bag',        // variant/pack info
  image: 'https://...',
  quantity: 2,
  maxQuantity: 10,             // UI-only cap
);

// Copy with new values
item.copyWith(quantity: 3);

// Seller info for display
const PlugSellerInfo(
  sellerId: 'seller_001',
  name: 'CSP Traders',
  image: 'https://...',
  location: 'Ponmanai, Kanyakumari',
);
```

### `PlugAddToCartButton` — Smart Add/Stepper Button

```dart
PlugAddToCartButton(
  state: myCartState,          // idle / loading / added
  quantity: myQty,
  maxQuantity: item.maxQuantity,
  addText: 'Add',
  addedText: 'Change',
  color: Colors.green,
  textColor: Colors.white,
  showStepperWhenAdded: true,  // shows − / qty / +
  height: 40,
  borderRadius: 10,
  enableHaptics: true,         // Blinkit-style haptic feedback
  onAdd: () => ref.read(cartRepo).add(item),
  onIncrease: () => ref.read(cartRepo).increase(item),
  onDecrease: () => ref.read(cartRepo).decrease(item),
  onChangePressed: () => showCartSheet(), // when stepper is disabled
);
```

**What you get for free:**
- ✅ Loading spinner during async operations
- ✅ Double-tap guard (ignores taps while loading)
- ✅ Optional quantity stepper with +/-
- ✅ Max quantity enforcement (UI-only)
- ✅ Haptic feedback on taps
- ✅ Automatic accessibility labels

### `PlugSellerCartSheet` — Full Cart Sheet

```dart
showModalBottomSheet(
  context: context,
  builder: (_) => PlugSellerCartSheet(
    seller: sellerInfo,
    items: myCartItems,
    footerTotal: '₹4,500',      // formatted by your app
    checkoutText: 'Checkout',
    emptyText: 'Your cart is empty',
    accentColor: Colors.green,

    // App-supplied per-line price info
    lineSubtitle: (item) => '₹450 x ${item.quantity}',

    // Callbacks
    onIncrease: (item) => myCartRepo.increase(item),
    onDecrease: (item) => myCartRepo.decrease(item),
    onRemove: (item) => myCartRepo.remove(item),
    onCheckout: () => context.push('/checkout'),
  ),
);
```

**Sheet Features:**
- ✅ Draggable scrollable sheet (0.3 - 0.9 of screen)
- ✅ Seller info header with location
- ✅ Product images with fallback
- ✅ Quantity steppers per item
- ✅ Remove button per item
- ✅ Footer total + checkout button
- ✅ Empty state handling
- ✅ Safe area aware

### `PlugCartPopup` — "Added to Cart" Confirmation

```dart
// Method 1: Show directly
PlugCartPopup.show(
  context: context,
  seller: seller,
  item: item,
  onViewCart: () => context.push('/cart'),
  unitLabel: 'Bags',
  addedToText: 'Added to:',
  viewCartText: 'View Cart',
  autoDismissAfter: const Duration(seconds: 3),
  animationDuration: const Duration(milliseconds: 250),
  backgroundColor: Colors.white,
  accentColor: Colors.green,
);

// Method 2: Show after async operation completes
await PlugCartPopup.showSuccess(
  context: context,
  seller: seller,
  item: item,
  onViewCart: () => context.push('/cart'),
  future: () => myCartRepo.add(item), // your API call
  unitLabel: 'Bags',
);
```

**Popup Features:**
- ✅ Blinkit-style slide-up animation
- ✅ Auto-dismiss after 3 seconds
- ✅ Shows seller + product info
- ✅ View Cart button
- ✅ Optional unit labels (e.g., "Bags", "kg")
- ✅ Product image with fallback
- ✅ Runs your async logic before showing

### `PlugSellerCartIndicator` — Floating Summary Bar

```dart
PlugSellerCartIndicator(
  itemCount: myCartCount,
  totalText: '₹4,500',           // formatted by your app
  viewCartText: 'View Cart',
  alwaysShow: false,             // show even when empty
  backgroundColor: Colors.green,
  foregroundColor: Colors.white,
  height: 56,
  borderRadius: 16,
  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
  onTap: () => showSellerCartSheet(),
);
```

**Indicator Features:**
- ✅ Shows item count badge
- ✅ Optional total price display
- ✅ Hides when cart is empty (unless alwaysShow)
- ✅ Floating over content
- ✅ Click to view cart

### `PlugCartBadge` — App Bar Badge

```dart
PlugCartBadge(
  icon: Icons.shopping_cart_outlined,
  countProvider: cartCountProvider, // your Riverpod provider
  onTap: () => context.push('/cart'),
  iconColor: Colors.black87,
  iconSize: 26,
  badgeColor: Colors.red,
  badgeTextColor: Colors.white,
);
```

**Badge Features:**
- ✅ Watches Riverpod provider for live count
- ✅ Shows '99+' for counts > 99
- ✅ Hides when count is 0
- ✅ Tappable with inkwell effect
- ✅ Semantic label for screen readers
- ✅ Accessible button role

### `PlugEmptyCart` — Empty State

```dart
items.isEmpty
  ? const PlugEmptyCart(
      title: 'Your cart is empty',
      subtitle: 'Items you add will show up here.',
      icon: Icons.shopping_cart_outlined,
      iconColor: Colors.grey,
      actionText: 'Browse Products',
      onAction: navigateToCatalog,
    )
  : PlugSellerCartSheet(...);
```

---

## 🎨 Navigation Configurations

### Style Comparison

| Style | Configuration | Visual |
|-------|--------------|--------|
| **Uber** | `floating: true` | Rounded pill overlaid above content |
| **Blinkit** | `floating: false` | Flat full-width bar at bottom |
| **Instacart** | `floating: false, pinned: false, hideOnScroll: true` | Edge-to-edge bar that hides on scroll |

### Configuration Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `pinned` | `bool` | `true` | Always visible. When `false` + `hideOnScroll`, slides away |
| `floating` | `bool` | `false` | Render as rounded pill vs. edge-to-edge |
| `hideOnScroll` | `bool` | `false` | Hide on scroll down, reveal on scroll up |
| `reverse` | `bool` | `false` | Reverse visual order (branch indexes unchanged) |
| `showLabels` | `bool` | `true` | Show text labels under icons |
| `backgroundColor` | `Color` | `Colors.white` | Bar background |
| `selectedColor` | `Color` | `Colors.green` | Selected icon/label color |
| `unselectedColor` | `Color` | `Colors.grey` | Unselected icon/label color |
| `selectedPillColor` | `Color?` | `null` | Selected item highlight (defaults to selectedColor at low opacity) |
| `height` | `double` | `76` | Bar height |
| `iconSize` | `double` | `24` | Unselected icon size |
| `selectedIconSize` | `double` | `28` | Selected icon size |
| `borderRadius` | `double` | `28` | Floating pill corner radius |
| `floatingMargin` | `EdgeInsets` | `EdgeInsets.fromLTRB(24, 0, 24, 16)` | Margin when floating |
| `elevation` | `double` | `12` | Drop shadow elevation |
| `animationType` | `PlugNavAnimationType` | `fadeThrough` | Page transition style |
| `animationDuration` | `Duration` | `300ms` | Transition duration |
| `labelStyle` | `TextStyle?` | `null` | Custom label font style |

### Animation Types

| Type | Description | Best For |
|------|-------------|----------|
| `none` | Instant switch | Performance-critical apps |
| `fade` | Simple opacity cross-fade | Minimal transitions |
| `fadeThrough` | Fade through black | Unrelated destinations |
| `slide` | Horizontal slide | Tab navigation |
| `scale` | Scale + fade combo | Modern, playful apps |

---

## 🔧 Manual Integration (Full Control)

For complete control (auth flows, full-screen routes without bottom bar, etc.):

```dart
final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    const isLoggedIn = false;
    final isGoingToLogin = state.matchedLocation == '/login';
    if (!isLoggedIn && !isGoingToLogin) return '/login';
    if (isLoggedIn && isGoingToLogin) return '/home';
    return null;
  },
  routes: [
    // ── Screens WITHOUT bottom bar ──
    GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
    GoRoute(
      path: '/product/:id',
      builder: (c, s) => ProductDetailScreen(id: s.pathParameters['id']!),
    ),

    // ── Screens WITH bottom bar ──
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => PlugBottomNavShell(
        navigationShell: navigationShell,
        items: [
          const PlugNavItem(
            icon: Icons.home,
            label: 'Home',
            badgeCount: 0,
          ),
          const PlugNavItem(
            icon: Icons.search,
            label: 'Search',
            activeIcon: Icons.search_rounded,
          ),
          PlugNavItem(
            icon: Icons.shopping_cart,
            label: 'Cart',
            badgeProvider: cartCountProvider,
          ),
          const PlugNavItem(
            icon: Icons.person,
            label: 'Account',
            semanticLabel: 'My Account',
          ),
        ],
        config: const PlugBottomNavConfig(
          floating: true,
          pinned: true,
          selectedColor: Colors.green,
          unselectedColor: Colors.grey,
          showLabels: true,
          animationType: PlugNavAnimationType.slide,
        ),
      ),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            builder: (c, s) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'category/:id',
                builder: (c, s) => CategoryScreen(id: s.pathParameters['id']!),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/search', builder: (c, s) => const SearchScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/cart', builder: (c, s) => const CartScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/account', builder: (c, s) => const AccountScreen()),
        ]),
      ],
    ),
  ],
);
```

Note: `PlugNavItem` instances that only use static fields (`icon`, `label`,
`activeIcon`, `badgeCount`, `semanticLabel`) can stay `const`. As soon as one
uses `badgeProvider: cartCountProvider` — a top-level provider reference, not
something built from `ref` — it's still a compile-time constant reference,
but the object itself has a non-const field type internally, so drop the
`const` keyword on that specific entry (as shown above).

### `PlugNavItem` vs `PlugNavRoute`

| `PlugNavItem` | `PlugNavRoute` |
|---------------|----------------|
| For manual GoRouter setups | For auto-router (recommended) |
| Icon + label only | Icon + label + page + path + routes |
| Used with `PlugBottomNavShell` | Used with `PlugBottomNavRouter.create()` |
| You define branches yourself | Branches auto-generated |

---

## 📊 Route Visualization

```
┌─────────────────────────────────────────────────────┐
│  FULL-SCREEN ROUTES (extraRoutes)                  │
│  /login, /onboarding, /checkout/:sellerId,         │
│  /order-success, /settings*, /kyc*                 │
│  → NO bottom bar                                   │
├─────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────┐│
│  │  MAIN TABS (items)                            ││
│  │  /home, /cart, /orders, /account              ││
│  │  → HAS bottom bar                             ││
│  ├─────────────────────────────────────────────────┤│
│  │  NESTED ROUTES (routes under tabs)            ││
│  │  /home/product/:id, /orders/:orderId          ││
│  │  → ALSO has bottom bar (stays in same branch) ││
│  └─────────────────────────────────────────────────┘│
│            [ Bottom Nav Bar ]                        │
└─────────────────────────────────────────────────────┘
```

---

## 🔄 Complete Cart State Example

Here's how to integrate the cart UI with your own Riverpod state:

```dart
// 1. Define your cart state
class CartItem {
  final String productId;
  final String sellerId;
  final String productName;
  final String subtitle;
  final String image;
  final int quantity;
  final double price;

  const CartItem({
    required this.productId,
    required this.sellerId,
    required this.productName,
    this.subtitle = '',
    this.image = '',
    this.quantity = 1,
    this.price = 0,
  });
}

class CartState {
  final Map<String, List<CartItem>> itemsBySeller;
  const CartState(this.itemsBySeller);
}

// 2. Create your cart notifier + provider
class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => const CartState({});

  void addItem(CartItem item) {
    // Your Firebase/API logic here, then update state.
  }

  void increaseQuantity(String sellerId, String productId) {
    // Update state.
  }

  void decreaseQuantity(String sellerId, String productId) {
    // Update state.
  }

  void removeItem(String sellerId, String productId) {
    // Update state.
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);

// 3. Derived providers — ONE canonical cartCountProvider used everywhere
// in this README (per-seller variants use .family instead of redefining
// the same top-level name).
final cartCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.itemsBySeller.values.fold(0, (sum, items) => sum + items.length);
});

final cartCountForSellerProvider = Provider.family<int, String>((ref, sellerId) {
  final cart = ref.watch(cartProvider);
  return cart.itemsBySeller[sellerId]?.length ?? 0;
});

final cartTotalForSellerProvider = Provider.family<String, String>((ref, sellerId) {
  final cart = ref.watch(cartProvider);
  final items = cart.itemsBySeller[sellerId] ?? [];
  final total = items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  return '₹${total.toStringAsFixed(0)}';
});

final cartItemsForSellerProvider =
    Provider.family<List<PlugCartItem>, String>((ref, sellerId) {
  final cart = ref.watch(cartProvider);
  return cart.itemsBySeller[sellerId]
          ?.map((item) => PlugCartItem(
                productId: item.productId,
                sellerId: item.sellerId,
                productName: item.productName,
                subtitle: item.subtitle,
                image: item.image,
                quantity: item.quantity,
              ))
          .toList() ??
      [];
});

// 4. Use in UI
class ProductCard extends ConsumerWidget {
  final String sellerId;
  final String productId;
  final CartItem item;

  const ProductCard({
    super.key,
    required this.sellerId,
    required this.productId,
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final sellerItems = cartState.itemsBySeller[sellerId];
    final matching = sellerItems?.where((e) => e.productId == productId);
    final isInCart = matching != null && matching.isNotEmpty;
    final quantity = isInCart ? matching.first.quantity : 0;

    return Column(
      children: [
        // Product info
        PlugAddToCartButton(
          state: isInCart ? PlugAddToCartState.added : PlugAddToCartState.idle,
          quantity: quantity,
          onAdd: () => ref.read(cartProvider.notifier).addItem(item),
          onIncrease: () =>
              ref.read(cartProvider.notifier).increaseQuantity(sellerId, productId),
          onDecrease: () =>
              ref.read(cartProvider.notifier).decreaseQuantity(sellerId, productId),
        ),
      ],
    );
  }
}
```

---

## 🔀 Advanced Routing Examples

### 1. Path Parameters + Query Parameters

```dart
// Full-screen route with path param
GoRoute(
  path: '/checkout/:sellerId',
  builder: (context, state) => CheckoutScreen(
    sellerId: state.pathParameters['sellerId']!,
  ),
)

// Full-screen route with query params
GoRoute(
  path: '/order-success',
  builder: (context, state) => OrderSuccessScreen(
    orderId: state.uri.queryParameters['orderId'] ?? '',
    paymentMethod: state.uri.queryParameters['method'] ?? '',
  ),
)

// Navigate with query params
context.push('/order-success?orderId=ORD123&method=upi');
```

### 2. Deep Nested Routes Under Extra Routes

```dart
// Multi-step KYC flow without bottom nav
GoRoute(
  path: '/kyc',
  builder: (context, state) => const KycStartScreen(),
  routes: [
    GoRoute(
      path: 'upload',
      builder: (context, state) => const KycUploadScreen(),
      routes: [
        GoRoute(
          path: 'pan',
          builder: (context, state) => const KycPanUploadScreen(),
        ),
        GoRoute(
          path: 'gst',
          builder: (context, state) => const KycGstUploadScreen(),
        ),
      ],
    ),
  ],
),

// Navigate: context.push('/kyc/upload/pan')
```

### 3. ShellRoute Without Bottom Nav

```dart
// Shared settings layout without bottom nav
ShellRoute(
  builder: (context, state, child) => SettingsShell(child: child),
  routes: [
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsHomeScreen(),
    ),
    GoRoute(
      path: '/settings/notifications',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
  ],
),

class SettingsShell extends StatelessWidget {
  final Widget child;
  const SettingsShell({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: child,
  );
}
```

### 4. Auth Redirect with Route Guarding

```dart
redirect: (context, state) {
  final isLoggedIn = ref.read(authProvider).isLoggedIn;
  final loggingIn = state.matchedLocation == '/login';
  final onboarding = state.matchedLocation == '/onboarding';

  // Not logged in → redirect to login
  if (!isLoggedIn && !loggingIn && !onboarding) {
    return '/login';
  }
  // Already logged in → skip login/onboarding
  if (isLoggedIn && loggingIn) {
    return '/home';
  }
  return null;
}
```

### 5. Navigation Methods

```dart
// Push/go to a tab (maintains back stack)
context.push('/cart');

// Go to a tab (replaces entire back stack)
context.go('/cart');

// Push a nested-under-tab route (bar stays visible)
context.push('/home/product/ultratech_ppc_50kg');
context.push('/home/product/ultratech_ppc_50kg/reviews');

// Push a full-screen extraRoute (bar hidden)
context.push('/checkout/csp_traders');

// With query params
context.push('/order-success?orderId=ORD123&method=upi');

// Pop back
context.pop();

// Replace instead of push (no back-stack entry)
context.replace('/login');

// Named routes (if you add `name:` to GoRoute)
context.pushNamed('productDetail', pathParameters: {'productId': '123'});
```

### 6. Navigator Observer & Error Builder

```dart
class MyRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    debugPrint('Pushed: ${route.settings.name}');
  }
}

PlugBottomNavRouter.create(
  // ...
  navigatorKey: rootNavigatorKey,
  debugLogDiagnostics: true,
  observers: [MyRouteObserver()],
  errorBuilder: (context, state) => NotFoundScreen(
    location: state.uri.toString(),
  ),
);
```

---

## ♿ Accessibility Features

The package is built with accessibility in mind:

- **Semantics** — All interactive elements have proper semantics
- **Screen Readers** — Descriptive labels for icons, badges, and buttons
- **Button Roles** — `Semantics(button: true)` for tappable elements
- **Selected State** — `Semantics(selected: true/false)` for nav items
- **Badge Labels** — "Cart, 3 items" for screen readers
- **Focusable** — All interactive elements are focusable
- **Color Contrast** — Customizable colors to meet contrast requirements

---

## 🎯 Haptic Feedback

Optional Blinkit-style haptic feedback:

```dart
PlugAddToCartButton(
  enableHaptics: true,  // default: true
  // ...
);
```

Disable for:
- Widget tests
- Apps that already trigger their own haptics
- Performance-sensitive screens

---

## 🏗️ Complete Router Example

Here's a production-ready router setup with all features:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plug_commerce_ui/plug_commerce_ui.dart';

// Auth state (in practice, use a Riverpod provider)
const isLoggedIn = false;
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final router = PlugBottomNavRouter.create(
  initialLocation: '/home',
  navConfig: const PlugBottomNavConfig(
    floating: true,
    pinned: true,
    selectedColor: Colors.green,
    unselectedColor: Colors.grey,
    backgroundColor: Colors.white,
    animationType: PlugNavAnimationType.fadeThrough,
    showLabels: true,
  ),

  items: [
    PlugNavRoute(
      path: '/home',
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
      label: 'Shop',
      page: const HomeScreen(),
      routes: [
        GoRoute(
          path: 'product/:productId',
          builder: (context, state) => ProductDetailScreen(
            productId: state.pathParameters['productId']!,
          ),
          routes: [
            GoRoute(
              path: 'reviews',
              builder: (context, state) => ReviewsScreen(
                productId: state.pathParameters['productId']!,
              ),
            ),
          ],
        ),
      ],
    ),
    PlugNavRoute(
      path: '/cart',
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
      label: 'Cart',
      page: const CartScreen(),
      badgeProvider: cartCountProvider,
    ),
    PlugNavRoute(
      path: '/orders',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'Orders',
      page: const OrdersScreen(),
      routes: [
        GoRoute(
          path: ':orderId',
          builder: (context, state) => OrderDetailScreen(
            orderId: state.pathParameters['orderId']!,
          ),
        ),
      ],
    ),
    PlugNavRoute(
      path: '/account',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Account',
      page: const AccountScreen(),
    ),
  ],

  extraRoutes: [
    // Full-screen routes WITHOUT bottom bar
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    GoRoute(
      path: '/checkout/:sellerId',
      builder: (context, state) => CheckoutScreen(
        sellerId: state.pathParameters['sellerId']!,
      ),
    ),
    GoRoute(
      path: '/order-success',
      builder: (context, state) => OrderSuccessScreen(
        orderId: state.uri.queryParameters['orderId'] ?? '',
        paymentMethod: state.uri.queryParameters['method'] ?? '',
      ),
    ),
    // Nested full-screen flow
    GoRoute(
      path: '/kyc',
      builder: (context, state) => const KycStartScreen(),
      routes: [
        GoRoute(
          path: 'upload',
          builder: (context, state) => const KycUploadScreen(),
          routes: [
            GoRoute(
              path: 'pan',
              builder: (context, state) => const KycPanUploadScreen(),
            ),
            GoRoute(
              path: 'gst',
              builder: (context, state) => const KycGstUploadScreen(),
            ),
          ],
        ),
      ],
    ),
    // ShellRoute without bottom nav
    ShellRoute(
      builder: (context, state, child) => SettingsShell(child: child),
      routes: [
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsHomeScreen(),
        ),
        GoRoute(
          path: '/settings/notifications',
          builder: (context, state) => const NotificationSettingsScreen(),
        ),
      ],
    ),
  ],

  // Auth gating
  redirect: (context, state) {
    final loggingIn = state.matchedLocation == '/login';
    final onboarding = state.matchedLocation == '/onboarding';

    if (!isLoggedIn && !loggingIn && !onboarding) {
      return '/login';
    }
    if (isLoggedIn && loggingIn) {
      return '/home';
    }
    return null;
  },

  // Standard GoRouter options
  navigatorKey: rootNavigatorKey,
  debugLogDiagnostics: true,
  observers: [MyRouteObserver()],
  errorBuilder: (context, state) => NotFoundScreen(
    location: state.uri.toString(),
  ),
);

// Usage in app
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(routerConfig: router);
}
```

---

## 📦 Package vs. Your App

| **Package** | **Your App** |
|-------------|--------------|
| Bottom nav UI + behaviour | Product/seller data |
| Auto `GoRouter` shell | Firestore / API calls |
| Selected-tab Riverpod state | Checkout / payment logic |
| Cart UI presentation | Cart data & business rules |
| Tab transitions & animations | Auth logic |
| Add-to-cart button UI | Async add/update operations |
| Cart badge display | Provider for badge count |
| Empty state UI | Navigation logic |
| Haptic feedback | Business validation |
| Accessibility semantics | Your data models |
| Route shell structure | Route redirect logic |

> **Philosophy:** The package owns **UI and state access patterns** only. No Firebase, no payment, no business logic — you own the data layer.

---

## 🐛 Common Issues & Solutions

### Issue: "No ProviderScope found"
```dart
// Make sure to wrap your app
void main() => runApp(const ProviderScope(child: MyApp()));
```

### Issue: "Could not find GoRouter"
```dart
// Make sure to use MaterialApp.router
MaterialApp.router(routerConfig: router);
```

### Issue: Cart badge not updating
```dart
// Make sure your provider is a ProviderListenable<int> — e.g. a
// Provider<int> derived from your cart Notifier, as shown in the
// "Complete Cart State Example" section above.
final cartCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.itemsBySeller.values.fold(0, (sum, items) => sum + items.length);
});
```

### Issue: Stepper not showing
```dart
// Set showStepperWhenAdded: true
PlugAddToCartButton(
  showStepperWhenAdded: true,
  // ...
);
```

### Issue: Max quantity not working
```dart
// Pass maxQuantity from your PlugCartItem
PlugAddToCartButton(
  maxQuantity: item.maxQuantity,
  // ...
);
```

### Issue: extraRoutes not working
```dart
// Make sure extraRoutes are siblings to the shell, not nested
// They must be top-level routes
extraRoutes: [
  GoRoute(path: '/login', builder: (c, s) => const LoginScreen()), // ✅ Works
  // GoRoute(path: '/settings', routes: [...]), // ✅ Works
  // GoRoute(path: '/home/login', builder: ...), // ❌ Nested under shell — won't work as intended
]
```

---

## Testing

```
test/
 ├── bottom_nav_test.dart          — badges (static + live), taps, reverse order, semantics
 ├── cart_popup_test.dart          — rendering, show()/showSuccess() flows
 ├── cart_sheet_test.dart          — quantity changes, maxQuantity cap, empty cart, remove
 ├── add_to_cart_button_test.dart  — idle/loading/added states, stepper, maxQuantity cap
 └── golden_test.dart              — pixel-comparison tests for key screens/states
```

```bash
flutter test
```

`golden_test.dart` compares against reference PNGs that aren't shipped in
this repo — generate them once locally with
`flutter test --update-goldens test/golden_test.dart`, review the images by
eye, then commit them. After that, `flutter test` catches visual
regressions alongside the behavior tests.

---

## Minimum versions

- Flutter `>=3.44.0` (for bottom-sheet entry-animation `curve` support)
- Dart `>=3.4.0`
- `flutter_riverpod ^3.3.2-dev.2`

---

## 📄 License

MIT