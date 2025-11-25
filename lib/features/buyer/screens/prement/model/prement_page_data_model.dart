import 'package:market_jango/features/buyer/screens/cart/model/cart_model.dart';

class PaymentPageData {
  final Buyer buyer;
  final List<CartItem> items; // API model
  final double subtotal;
  final double deliveryTotal;
  final double grandTotal;

  PaymentPageData({
    required this.buyer,
    required this.items,
    required this.subtotal,
    required this.deliveryTotal,
    required this.grandTotal,
  });
}