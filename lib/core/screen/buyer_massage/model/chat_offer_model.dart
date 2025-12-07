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
    // Handle nested product data if present
    final product = json['product'] as Map<String, dynamic>?;
    
    // Extract product name - try multiple possible field names
    String? productName = json['product_name']?.toString() ?? 
                         json['productName']?.toString() ??
                         product?['name']?.toString();
    
    // Extract product image - try multiple possible field names and paths
    String? productImage = json['product_image']?.toString() ?? 
                          json['productImage']?.toString() ??
                          product?['image']?.toString();
    
    // If image is still null, try to get from product.images array
    if (productImage == null && product != null) {
      final images = product['images'] as List?;
      if (images != null && images.isNotEmpty) {
        final firstImage = images[0] as Map<String, dynamic>?;
        productImage = firstImage?['image_path']?.toString() ?? 
                      firstImage?['imagePath']?.toString();
      }
    }
    
    return ChatOffer(
      id: json['id'] ?? 0,
      productName: productName,
      productImage: productImage,
      salePrice: (json['sale_price'] ?? json['salePrice'] ?? '0').toString(),
      quantity: json['quantity'] ?? 0,
      deliveryCharge: (json['delivery_charge'] ?? json['deliveryCharge'] ?? '0').toString(),
      color: json['color']?.toString(),
      size: json['size']?.toString(),
      isAccepted: json['is_accepted'] ?? json['isAccepted'] ?? 0,
    );
  }
}

