import 'package:plug_commerce_ui/plug_commerce_ui.dart';

/// A catalog product — NOT a cart item yet (no quantity chosen). Turned
/// into a [CartItem] (with price/GST) only when added to cart, in
/// `home_screen.dart`.
class DemoProduct {
  final String productId;
  final String sellerId;
  final String name;
  final String variant;
  final String image;
  final int? maxQuantity;
  final int priceInPaise;
  final double gstPercent;

  const DemoProduct({
    required this.productId,
    required this.sellerId,
    required this.name,
    this.variant = '',
    this.image = '',
    this.maxQuantity,
    this.priceInPaise = 0,
    this.gstPercent = 0,
  });
}

const cspTraders = PlugSellerInfo(
  sellerId: 'csp_traders',
  name: 'CSP Traders',
  location: 'Ponmanai, Kanyakumari',
);

const abcHardware = PlugSellerInfo(
  sellerId: 'abc_hardware',
  name: 'ABC Hardware',
  location: 'Nagercoil',
);

const demoSellers = [cspTraders, abcHardware];

const demoProducts = [
  DemoProduct(
    productId: 'ultratech_ppc_50kg',
    sellerId: 'csp_traders',
    name: 'UltraTech PPC Cement',
    variant: '50kg Bag',
    priceInPaise: 45000, // ₹450.00
    gstPercent: 28,
  ),
  DemoProduct(
    productId: 'tmt_bar_12mm',
    sellerId: 'csp_traders',
    name: 'TMT Bar 12mm',
    variant: 'Bundle of 10',
    priceInPaise: 320000, // ₹3,200.00
    gstPercent: 18,
  ),
  DemoProduct(
    productId: 'finolex_pvc_pipe',
    sellerId: 'abc_hardware',
    name: 'Finolex PVC Pipe',
    variant: '4 inch, 3m length',
    maxQuantity: 20,
    priceInPaise: 65000, // ₹650.00
    gstPercent: 18,
  ),
  DemoProduct(
    productId: 'cera_wc',
    sellerId: 'abc_hardware',
    name: 'CERA Wall-Mounted WC',
    maxQuantity: 5,
    priceInPaise: 850000, // ₹8,500.00
    gstPercent: 18,
  ),
];

PlugSellerInfo sellerFor(String sellerId) =>
    demoSellers.firstWhere((s) => s.sellerId == sellerId);
