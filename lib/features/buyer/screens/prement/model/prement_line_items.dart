class PaymentLineItem {
  final String title;
  final String imageUrl;
  final int qty;
  final double price;

  PaymentLineItem({
    required this.title,
    required this.imageUrl,
    required this.qty,
    required this.price,
  });
}

class ShippingOption {
  final String title;
  final double cost;
  ShippingOption({required this.title, required this.cost});
}
