
## 0.7.0

- package name changed


## 0.2.0

- updated to latest version

## 0.1.0

Initial release.

### Added
- `PlugBottomNavRouter.create` auto-generates the `StatefulShellRoute.indexedStack`
  GoRouter — no manual shell-route boilerplate.
- `PlugBottomNavShell` drop-in widget for use inside your own GoRouter.
- Blinkit / Uber / Instacart-style bottom bar with `pinned`, `floating`,
  `reverse`, `hideOnScroll`, `showLabels`, selected/unselected colors,
  background color, and per-tab badge counts.
- `PlugBottomNavConfig` for styling (sizes, radius, elevation, margins,
  animation type/duration, label style). `pinned` and `floating` are
  independent switches.
- `PlugNavRoute` (icon + label + page + nested routes) for the auto router and
  `PlugNavItem` (icon + label only) for manual shell use.
- Riverpod 3.x state:
  - `plugSelectedIndexProvider` — selected tab, synced from the navigation shell.
  - `plugCartProvider` — Instacart-style per-seller carts.
  - `plugCartCountProvider` / `plugCartTotalProvider` — live per-seller helpers.
  - `plugAddToCartLoadingProvider` — independent per-button loading flags.
- `PlugAddToCartButton` — automatic loading spinner, `Add` → `Added`/`Change`,
  double-tap guard, and optional quantity stepper.
- `PlugCartBar` — floating per-seller cart bar with live count + total.
- Tab transitions via the `animations` package: `fade`, `fadeThrough`,
  `slide`, `scale`, `none`.
- Support for nested routes (bar stays visible) and `extraRoutes` (full-screen,
  no bar), plus optional auth `redirect`.
- Example app and provider unit tests.