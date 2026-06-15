
```markdown
# plug_bottom_nav

Plug-and-play **Blinkit / Uber / Instacart-style** bottom navigation for Flutter.

You pass a flat list of tabs. The package builds the entire
`StatefulShellRoute.indexedStack` for you — **you never write shell-route
boilerplate**. Selected-tab state lives in Riverpod, and a per-seller cart +
automatic add-to-cart button come included.

## Features

- 🔌 **Auto router** — `PlugBottomNavRouter.create(...)` returns a ready
  `GoRouter`. No manual `StatefulShellRoute`.
- 🎨 Bar styles: `pinned`, `floating` (Uber pill), `reverse`, `hideOnScroll`,
  selected/unselected colors, background color, per-tab badge counts.
- 🧭 Selected index synced into Riverpod (`plugSelectedIndexProvider`) — read
  the active tab from any page.
- 🛒 **Per-seller carts** (Instacart-style): each seller has its own cart.
- ➕ `PlugAddToCartButton` — automatic loading spinner, `Add` → `Added`/`Change`,
  double-tap guard, optional quantity stepper. You only set colors + text and
  your async `onPressed` logic.
- 🟩 `PlugCartBar` — floating per-seller cart bar with live count + total.
- ✨ Fade-through tab transitions via the `animations` package
  (`fade`, `fadeThrough`, `slide`, `scale`, `none`).

## Requirements

- Wrap your app in a `ProviderScope` (Riverpod).
- Uses Riverpod 3.x APIs (`Notifier` / `NotifierProvider`).

## Quick start

### Option 1: Auto-router (Recommended for most apps)

```dart
void main() => runApp(const ProviderScope(child: MyApp()));

final router = PlugBottomNavRouter.create(
  initialLocation: '/home',
  items: const [
    PlugNavRoute(path: '/home',    icon: Icons.home,          label: 'Home',    page: HomePage()),
    PlugNavRoute(path: '/search',  icon: Icons.search,        label: 'Search',  page: SearchPage()),
    PlugNavRoute(path: '/cart',    icon: Icons.shopping_cart, label: 'Cart',    page: CartPage()),
    PlugNavRoute(path: '/account', icon: Icons.person,        label: 'Account', page: AccountPage()),
  ],
  navConfig: const PlugBottomNavConfig(
    pinned: true,
    floating: true,
    reverse: false,
    backgroundColor: Colors.white,
    selectedColor: Colors.green,
    unselectedColor: Colors.grey,
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

That's the entire navigation setup. No `StatefulShellRoute.indexedStack`,
no `MainNavigationShell`.

### Option 2: Manual integration (For complete control)

Perfect when you need full-screen routes WITHOUT the bottom bar (login, onboarding, etc.) alongside tabbed screens WITH the bottom bar.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plug_bottom_nav/plug_bottom_nav.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    // ── Screens WITHOUT the bottom bar (outside the shell) ──
    GoRoute(path: '/login',     builder: (c, s) => const LoginPage()),
    GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingPage()),
    GoRoute(
      path: '/product/:id',
      builder: (c, s) => ProductPage(id: s.pathParameters['id']!),
    ),

    // ── Screens WITH the bottom bar (inside the shell) ──
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => PlugBottomNavShell(
        navigationShell: navigationShell,
        items: const [
          PlugNavItem(icon: Icons.home,          label: 'Home'),
          PlugNavItem(icon: Icons.search,        label: 'Search'),
          PlugNavItem(icon: Icons.shopping_cart, label: 'Cart'),
          PlugNavItem(icon: Icons.person,        label: 'Account'),
        ],
        config: const PlugBottomNavConfig(floating: true),
      ),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (c, s) => const HomePage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/search', builder: (c, s) => const SearchPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/cart', builder: (c, s) => const CartPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/account', builder: (c, s) => const AccountPage()),
        ]),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) =>
      MaterialApp.router(routerConfig: router);
}

// Example pages
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Home')),
    body: const Center(child: Text('Home Page')),
  );
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Search')),
    body: const Center(child: Text('Search Page')),
  );
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cart')),
    body: const Center(child: Text('Cart Page')),
  );
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Account')),
    body: const Center(child: Text('Account Page')),
  );
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Login')),
    body: Center(
      child: ElevatedButton(
        onPressed: () => context.go('/home'),
        child: const Text('Login → Go to Home'),
      ),
    ),
  );
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Onboarding')),
    body: const Center(child: Text('Welcome!')),
  );
}

class ProductPage extends StatelessWidget {
  final String id;
  const ProductPage({super.key, required this.id});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Product $id')),
    body: Center(child: Text('Showing product $id')),
  );
}
```

## Read the selected tab anywhere

```dart
final index = ref.watch(plugSelectedIndexProvider);
```

## Per-seller cart + add-to-cart button

Each seller/shop keeps its own cart. Drop the button into any product card:

```dart
PlugAddToCartButton(
  sellerId: 'seller_001',
  item: const PlugCartItem(
    id: 'cement_001',
    title: 'UltraTech Cement',
    sellerId: 'seller_001',
    price: 8.50,
  ),
  color: Colors.green,
  addText: 'Add',
  addedText: 'Added',
  onPressed: () async {
    // your Firestore / API logic — the spinner is automatic
  },
)
```

Behaviour you get for free: shows **Add** → runs your async logic with a
spinner → flips to a **quantity stepper** (or `Added`/`Change` text if
`showStepperWhenAdded: false`). Double-taps are ignored while loading.

Floating cart bar for a seller:

```dart
PlugCartBar(
  sellerId: 'blinkit_store',
  backgroundColor: const Color(0xFF0C831F),
  onTap: () => context.go('/cart'),
)
```

Cart reads/writes are plain Riverpod:

```dart
final notifier = ref.read(plugCartProvider.notifier);
notifier.increaseQty(sellerId: 'seller_001', itemId: 'cement_001');
final count = ref.watch(plugCartCountProvider('seller_001'));
final total = ref.watch(plugCartTotalProvider('seller_001'));
```

## Using PlugBottomNavShell (for custom GoRouter setups)

If you already have your own GoRouter setup with `StatefulShellRoute`, you can
use `PlugBottomNavShell` directly instead of the full `PlugBottomNavRouter`:

### Uber-style floating pill

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) => PlugBottomNavShell(
    navigationShell: navigationShell,
    items: const [
      PlugNavItem(icon: Icons.home,        label: 'Home'),
      PlugNavItem(icon: Icons.apps,        label: 'Services'),
      PlugNavItem(icon: Icons.receipt_long, label: 'Activity'),
      PlugNavItem(icon: Icons.person,      label: 'Account'),
    ],
    config: const PlugBottomNavConfig(
      floating: true,            // 👈 the pill
      pinned: true,              // always visible
      backgroundColor: Colors.white,
      selectedColor: Colors.black,     // Uber: black selected
      unselectedColor: Colors.grey,
      borderRadius: 32,                // very round pill
      height: 64,
      animationType: PlugNavAnimationType.fadeThrough,
    ),
  ),
  branches: [...],
);
```

### Blinkit-style edge-to-edge bar

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) => PlugBottomNavShell(
    navigationShell: navigationShell,
    items: const [
      PlugNavItem(icon: Icons.home,          label: 'Home'),
      PlugNavItem(icon: Icons.grid_view,     label: 'Categories'),
      PlugNavItem(icon: Icons.shopping_cart, label: 'Cart'),
      PlugNavItem(icon: Icons.person,        label: 'Account'),
    ],
    config: const PlugBottomNavConfig(
      floating: false,           // 👈 edge-to-edge, not a pill
      pinned: true,              // fixed at bottom
      backgroundColor: Colors.white,
      selectedColor: Color(0xFF0C831F),  // Blinkit green
      unselectedColor: Colors.grey,
      height: 64,
    ),
  ),
  branches: [...],
);
```

### Complete manual integration with auth flow

Here's a production-ready example showing login flow, protected routes, and nested navigation:

```dart
final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    // Your auth logic
    final isLoggedIn = false;
    final isGoingToLogin = state.matchedLocation == '/login';
    
    if (!isLoggedIn && !isGoingToLogin) {
      return '/login';
    }
    if (isLoggedIn && isGoingToLogin) {
      return '/home';
    }
    return null;
  },
  routes: [
    // Public routes (no bottom bar)
    GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
    GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingPage()),
    
    // Shared routes that can be accessed from anywhere
    GoRoute(
      path: '/product/:id',
      builder: (c, s) => ProductPage(id: s.pathParameters['id']!),
    ),
    
    // Protected shell with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => PlugBottomNavShell(
        navigationShell: navigationShell,
        items: const [
          PlugNavItem(icon: Icons.home, label: 'Home'),
          PlugNavItem(icon: Icons.search, label: 'Search'),
          PlugNavItem(icon: Icons.shopping_cart, label: 'Cart', badgeCount: 3),
          PlugNavItem(icon: Icons.person, label: 'Account'),
        ],
        config: const PlugBottomNavConfig(
          floating: true,
          pinned: true,
          selectedColor: Colors.green,
          unselectedColor: Colors.grey,
        ),
      ),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            builder: (c, s) => const HomePage(),
            routes: [
              // Nested route keeps bottom bar visible
              GoRoute(
                path: 'category/:id',
                builder: (c, s) => CategoryPage(id: s.pathParameters['id']!),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/search', builder: (c, s) => const SearchPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/cart', builder: (c, s) => const CartPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/account', builder: (c, s) => const AccountPage()),
        ]),
      ],
    ),
  ],
);
```

### Style comparison

| Style | Configuration | Visual |
|-------|--------------|--------|
| **Uber** | `floating: true` | Rounded pill, overlaid above content |
| **Blinkit** | `floating: false` | Flat full-width bar at bottom |
| **Instacart** | `floating: false, pinned: false, hideOnScroll: true` | Edge-to-edge bar that hides on scroll |

## Bottom navigation configurations

The `PlugBottomNavConfig` offers flexible styling options for different use cases:

### Floating pill (Uber-style) — always visible
```dart
PlugBottomNavConfig(
  floating: true,   // rounded pill shape
  pinned: true,     // always visible
)
```

### Classic fixed bar (Blinkit-style)
```dart
PlugBottomNavConfig(
  floating: false,  // edge-to-edge
  pinned: true,     // fixed at bottom
)
```

### Edge-to-edge bar that hides on scroll (Instacart-style)
```dart
PlugBottomNavConfig(
  floating: false,      // edge-to-edge
  pinned: false,        // allowed to hide
  hideOnScroll: true,   // slides away on scroll down
)
```

### Floating pill that hides on scroll
```dart
PlugBottomNavConfig(
  floating: true,       // rounded pill
  pinned: false,        // allowed to hide
  hideOnScroll: true,   // slides away on scroll down
)
```

### Configuration properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `pinned` | `bool` | `true` | Keep bar always visible. When `false` and `hideOnScroll` is `true`, bar slides away |
| `floating` | `bool` | `false` | Render as rounded pill (Uber-style) vs. edge-to-edge bar |
| `reverse` | `bool` | `false` | Reverse visual order of items (doesn't affect branch indexes) |
| `hideOnScroll` | `bool` | `false` | Hide bar while scrolling down, reveal on scroll up |
| `showLabels` | `bool` | `true` | Show text labels under icons |
| `backgroundColor` | `Color` | `Colors.white` | Background color of the navigation bar |
| `selectedColor` | `Color` | `Colors.green` | Color for selected icon and label |
| `unselectedColor` | `Color` | `Colors.grey` | Color for unselected icons and labels |
| `selectedPillColor` | `Color?` | `null` | Background of selected item's pill (defaults to `selectedColor` at low opacity) |
| `height` | `double` | `72` | Height of the navigation bar |
| `iconSize` | `double` | `24` | Size of unselected icons |
| `selectedIconSize` | `double` | `28` | Size of selected icons |
| `borderRadius` | `double` | `28` | Border radius for floating pill |
| `floatingMargin` | `EdgeInsets` | `EdgeInsets.fromLTRB(24, 0, 24, 16)` | Outer margin when `floating` is `true` |
| `elevation` | `double` | `12` | Drop shadow elevation |
| `animationType` | `PlugNavAnimationType` | `fadeThrough` | Page transition style |
| `animationDuration` | `Duration` | `300ms` | Duration of page transitions |
| `labelStyle` | `TextStyle?` | `null` | Optional custom font style for labels |

## Nested routes, extra routes, auth redirect

### With auto-router (Option 1)
```dart
PlugBottomNavRouter.create(
  initialLocation: '/home',
  items: [
    PlugNavRoute(
      path: '/home',
      icon: Icons.home,
      label: 'Home',
      page: const HomePage(),
      routes: [ // nested pages keep the bottom bar visible
        GoRoute(
          path: 'product/:id',
          builder: (c, s) => ProductPage(id: s.pathParameters['id']!),
        ),
      ],
    ),
    // ...
  ],
  extraRoutes: [ // full-screen routes WITHOUT the bottom bar
    GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
  ],
  redirect: (context, state) {
    // return '/login' when unauthenticated, else null
    return null;
  },
);
```

### With manual integration (Option 2)
```dart
final router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final isLoggedIn = false;
    final isGoingToLogin = state.matchedLocation == '/login';
    
    if (!isLoggedIn && !isGoingToLogin) return '/login';
    if (isLoggedIn && isGoingToLogin) return '/home';
    return null;
  },
  routes: [
    // Full-screen routes without bottom bar
    GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
    GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingPage()),
    
    // Shared routes
    GoRoute(
      path: '/product/:id',
      builder: (c, s) => ProductPage(id: s.pathParameters['id']!),
    ),
    
    // Main shell with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => PlugBottomNavShell(
        navigationShell: navigationShell,
        items: const [
          PlugNavItem(icon: Icons.home,          label: 'Home'),
          PlugNavItem(icon: Icons.search,        label: 'Search'),
          PlugNavItem(icon: Icons.shopping_cart, label: 'Cart'),
          PlugNavItem(icon: Icons.person,        label: 'Account'),
        ],,
        config: const PlugBottomNavConfig(...),
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (c, s) => const HomePage(),
              routes: [
                GoRoute(
                  path: 'category/:id',
                  builder: (c, s) => CategoryPage(id: s.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
        // ... other branches
      ],
    ),
  ],
);
```

## Route visualization

Here's how different route types behave with the bottom bar:

```
┌─────────────────────────────────────────┐
│  /login, /onboarding, /product/:id      │  ← NO bottom bar
│  (full-screen, outside shell)           │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────────┐│
│  │  /home, /search, /cart, /account    ││  ← HAS bottom bar
│  │  (main tab screens)                 ││
│  ├─────────────────────────────────────┤│
│  │  /home/category/:id                 ││  ← ALSO has bottom bar
│  │  (nested routes keep the bar)       ││     (stays in same branch)
│  └─────────────────────────────────────┘│
│            [ Bottom Nav Bar ]            │
└─────────────────────────────────────────┘
```

## What the package owns vs. your app

| Package | Your app |
|---|---|
| Bottom nav UI + behaviour | Product/seller data |
| Auto `GoRouter` shell | Firestore / API calls |
| Selected-tab Riverpod state | Checkout / payment |
| Per-seller cart state + UI | Auth logic |
| Tab transitions & animations | Business logic |

The package is UI + state only. No Firebase, no payment, no forced app
structure.
```

## Key additions made:

1. **Clear separation** - Screens WITH vs WITHOUT bottom bar clearly labeled
2. **Complete working example** - Includes LoginPage, OnboardingPage, ProductPage with full implementations
3. **Auth flow example** - Shows redirect logic for protected routes
4. **Nested routes example** - Shows `/home/category/:id` keeping bottom bar
5. **Route visualization diagram** - Visual representation of how routes work
6. **Production-ready structure** - Real-world example with auth, shared routes, and nested navigation

Your documentation now shows developers exactly how to:
- Have screens WITHOUT bottom bar (login, onboarding)
- Have screens WITH bottom bar (main tabs)
- Share routes across both (product details)
- Handle authentication redirects
- Nest routes within tabs

This is production-grade documentation! 🎉