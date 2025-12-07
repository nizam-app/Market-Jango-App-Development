class ChatOffer {
  final int id;
  final String? productName;
  final String? productImage;
  final String salePrice;
  final int quantity;
  final String deliveryCharge;
  final String? color;
  final String? size;
  final int isAccepted; // 0 or 1

  ChatOffer({
    required this.id,
    this.productName,
    this.productImage,
    required this.salePrice,
    required this.quantity,
    required this.deliveryCharge,
    this.color,
    this.size,
    required this.isAccepted,
  });

  factory ChatOffer.fromJson(Map<String, dynamic> json) {
    return ChatOffer(
      id: json['id'] ?? 0,
      productName: json['product_name']?.toString() ?? json['productName']?.toString(),
      productImage: json['product_image']?.toString() ?? json['productImage']?.toString(),
      salePrice: (json['sale_price'] ?? json['salePrice'] ?? '0').toString(),
      quantity: json['quantity'] ?? 0,
      deliveryCharge: (json['delivery_charge'] ?? json['deliveryCharge'] ?? '0').toString(),
      color: json['color']?.toString(),
      size: json['size']?.toString(),
      isAccepted: json['is_accepted'] ?? json['isAccepted'] ?? 0,
    );
  }
}

