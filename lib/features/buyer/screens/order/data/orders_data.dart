import 'package:market_jango/features/buyer/screens/order/model/order_summary.dart';

final List<OrderSummary> ordersData = [
  OrderSummary(
    orderId: "#92287157",
    deliveryType: "Standard Delivery",
    status: "Shipped",
    itemCount: 4,
    imageUrls: [
      "https://images.unsplash.com/photo-1542291026-7eec264c27ff",
      "https://images.unsplash.com/photo-1512436991641-6745cdb1723f",
      "https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb",
      "https://images.unsplash.com/photo-1517841905240-472988babdf9",
    ],
    onTrack: () {},
  ),
  OrderSummary(
    orderId: "#92287158",
    deliveryType: "Express Delivery",
    status: "Processing",
    itemCount: 3,
    imageUrls: [
      "https://images.unsplash.com/photo-1520975732099-628ae3f8c7e3",
      "https://images.unsplash.com/photo-1514996937319-344454492b37",
      "https://images.unsplash.com/photo-1526178617633-048a2c1d6687",
    ],
    onTrack: () {},
  ),
  OrderSummary(
    orderId: "#92287159",
    deliveryType: "Standard Delivery",
    status: "Delivered",
    itemCount: 2,
    imageUrls: [
      "https://images.unsplash.com/photo-1475180098004-ca77a66827be",
      "https://images.unsplash.com/photo-1520975682035-6532b97f3152",
    ],
    onTrack: () {},
  ),
  OrderSummary(
    orderId: "#92287160",
    deliveryType: "Economy",
    status: "Shipped",
    itemCount: 5,
    imageUrls: [
      "https://images.unsplash.com/photo-1512436991641-6745cdb1723f",
      "https://images.unsplash.com/photo-1517841905240-472988babdf9",
      "https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb",
      "https://images.unsplash.com/photo-1542291026-7eec264c27ff",
    ],
    onTrack: () {},
  ),
  OrderSummary(
    orderId: "#92287161",
    deliveryType: "Standard Delivery",
    status: "Pending",
    itemCount: 1,
    imageUrls: [
      "https://images.unsplash.com/photo-1520975732099-628ae3f8c7e3",
    ],
    onTrack: () {},
  ),
];