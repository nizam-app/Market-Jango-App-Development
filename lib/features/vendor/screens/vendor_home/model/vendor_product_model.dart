class Product {
  final int id;
  final String name;
  final String description;
  final String regularPrice;
  final String sellPrice;
  final String image;
  final int vendorId;
  final int categoryId;

  final String categoryName; // optional category object, optional images list
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.regularPrice,
    required this.sellPrice,
    required this.image,
    required this.vendorId,
    required this.categoryId,
    required this.categoryName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      regularPrice: json['regular_price'] ?? '',
      sellPrice: json['sell_price'] ?? '',
      image: json['image'] ?? '',
      vendorId: json['vendor_id'],
      categoryId: json['category_id'],
      categoryName: json['category']?['name'] ?? '',
    );
  }
}

class PaginatedProducts {
  final int currentPage;
  final int lastPage;
  final int total;
  final List<Product> products;

  PaginatedProducts({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.products,
  });

  factory PaginatedProducts.fromJson(Map<String, dynamic> json) {
    final data = json['products'];
    return PaginatedProducts(
      currentPage: data['current_page'],
      lastPage: data['last_page'],
      total: data['total'],
      products: (data['data'] as List<dynamic>)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
