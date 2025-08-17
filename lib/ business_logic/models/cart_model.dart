class CartItemModel {
  final String imageUrl;
  final String name;
  final String details; // e.g., "Pink, Size M"
  final double price;
  int quantity;

  CartItemModel({
    required this.imageUrl,
    required this.name,
    required this.details,
    required this.price,
    this.quantity = 1,
  });
}

