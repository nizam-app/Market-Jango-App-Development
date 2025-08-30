import 'dart:ui';

class OrderSummary {
  final String orderId;            // e.g. #92287157
  final String deliveryType;       // e.g. Standard Delivery
  final String status;             // e.g. Shipped
  final int itemCount;             // e.g. 4
  final List<String> imageUrls;    // up to 4
  final VoidCallback? onTrack;

  OrderSummary({
    required this.orderId,
    required this.deliveryType,
    required this.status,
    required this.itemCount,
    required this.imageUrls,
    this.onTrack,
  });
}