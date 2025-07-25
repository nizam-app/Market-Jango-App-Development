class ProductModel {
  final String title;
  final String description;
  final double price;
  final List<String> size;
  final List<String> color;
  final String image;
  final String category;
  final String shop;
  final String vendor;
  final String buyerTips;
  final bool topProduct;
  final bool flashSale;
  final int discountPercent;
  final DateTime addedAt;

  ProductModel({
    required this.title,
    required this.description,
    required this.price,
    required this.size,
    required this.color,
    required this.image,
    required this.category,
    required this.shop,
    required this.vendor,
    required this.buyerTips,
    required this.topProduct,
    required this.flashSale,
    required this.discountPercent,
    required this.addedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      size: List<String>.from(json['size']),
      color: List<String>.from(json['color']),
      image: json['image'],
      category: json['category'],
      shop: json['shop'],
      vendor: json['vendor'],
      buyerTips: json['buyer_tips'],
      topProduct: json['top_product'],
      flashSale: json['flash_sale'],
      discountPercent: json['discount_percent'],
      addedAt: DateTime.parse(json['added_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'size': size,
      'color': color,
      'image': image,
      'category': category,
      'shop': shop,
      'vendor': vendor,
      'buyer_tips': buyerTips,
      'top_product': topProduct,
      'flash_sale': flashSale,
      'discount_percent': discountPercent,
      'added_at': addedAt.toIso8601String(),
    };
  }
}
