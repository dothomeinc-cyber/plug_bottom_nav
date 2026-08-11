import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_shell.dart';

/// plug_commerce_ui example app.
///
/// Shows the four things the package cares about:
///   1. Bottom navigation (GoRouter shell, floating pill, live badge) —
///      see app_shell.dart.
///   2. Add-to-cart popup flow ("Added to: 🏪 CSP Traders / ... / View
///      Cart") — see screens/home_screen.dart.
///   3. Seller cart sheet — see screens/cart_screen.dart.
///   4. Feature-first cart architecture, keeping the package UI-only —
///      see features/cart/. The layering is:
///
///      features/cart/
///        data/cart_repository.dart          — stands in for Firestore
///        domain/cart_item.dart              — app's own model (has price/GST)
///        domain/demo_catalog.dart           — sample product data
///        presentation/cart_controller.dart  — Riverpod AsyncNotifier +
///                                              the ONE mapping function
///                                              (toPlugCartItem) from the
///                                              domain model to the
///                                              package's UI-only model
///
///      plug_commerce_ui never sees `CartItem`, price, or GST — only the
///      `PlugCartItem`/`PlugSellerInfo` produced at that single mapping
///      point. Swapping the in-memory `CartRepository` for real Firestore
///      calls touches only data/cart_repository.dart.
void main() {
  runApp(const ProviderScope(child: AppShell()));
}
