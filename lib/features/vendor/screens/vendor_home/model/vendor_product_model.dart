class VendorProduct {
  final int id;
  final String name;
  final String description;
  final String regularPrice;
  final String sellPrice;
  final String image;
  final int vendorId;
  final int categoryId;
  final String categoryName;

  final List<String> sizes;
  final List<String> colors;
  final List<ProductImage> images;

  VendorProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.regularPrice,
    required this.sellPrice,
    required this.image,
    required this.vendorId,
    required this.categoryId,
    required this.categoryName,
    required this.sizes,
    required this.colors,
    required this.images,
  });

  factory VendorProduct.fromJson(Map<String, dynamic> json) {
    final rawSize = json['size'];
    final rawColor = json['color'];

    // Helper to safely convert to int
    int _toInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is num) return value.toInt();
      return defaultValue;
    }

    return VendorProduct(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      regularPrice: json['regular_price']?.toString() ?? '',
      sellPrice: json['sell_price']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      vendorId: _toInt(json['vendor_id']),
      categoryId: _toInt(json['category_id']),
      categoryName: json['category']?['name']?.toString() ?? '',

      /// ✅ Safe list conversion
      sizes: rawSize is List
          ? rawSize.map((e) => e.toString()).toList()
          : rawSize is String
          ? [rawSize]
          : [],

      colors: rawColor is List
          ? rawColor.map((e) => e.toString()).toList()
          : rawColor is String
          ? [rawColor]
          : [],

      /// ✅ images mapping - ensure it's a List, not a Map
      images: () {
        final imagesField = json['images'];
        if (imagesField is List) {
          return imagesField
              .whereType<Map>()
              .map((e) => ProductImage.fromJson(e.cast<String, dynamic>()))
              .toList();
        }
        return <ProductImage>[];
      }(),
    );
  }
}

class PaginatedProducts {
  final int currentPage;
  final int lastPage;
  final int total;
  final List<VendorProduct> products;

  PaginatedProducts({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.products,
  });

  factory PaginatedProducts.fromJson(Map<String, dynamic> json) {
    // Helper to safely convert to int
    int _toInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is num) return value.toInt();
      return defaultValue;
    }

    // Safely extract products list
    List<VendorProduct> productsList = [];
    final dataField = json['data'];
    
    if (dataField is List) {
      // If 'data' is a List, map it directly
      productsList = dataField
          .whereType<Map>()
          .map((e) => VendorProduct.fromJson(e.cast<String, dynamic>()))
          .toList();
    } else if (dataField is Map) {
      // If 'data' is a Map, it might contain nested data
      // This shouldn't happen in normal cases, but handle it safely
      productsList = [];
    }

    return PaginatedProducts(
      currentPage: _toInt(json['current_page'], defaultValue: 1),
      lastPage: _toInt(json['last_page'], defaultValue: 1),
      total: _toInt(json['total']),
      products: productsList,
    );
  }
}

//
// class PaginatedProducts {
//   final int currentPage;
//   final int lastPage;
//   final int total;
//   final List<Product> products;
//
//   PaginatedProducts({
//     required this.currentPage,
//     required this.lastPage,
//     required this.total,
//     required this.products,
//   });
//
//   factory PaginatedProducts.fromJson(Map<String, dynamic> json) {
//     final data = json['products'];
//     return PaginatedProducts(
//       currentPage: data['current_page'],
//       lastPage: data['last_page'],
//       total: data['total'],
//       products: (data['data'] as List<dynamic>)
//           .map((e) => Product.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
// }
class ProductImage {
  final int id;
  final String imagePath;
  final int productId;

  ProductImage({
    required this.id,
    required this.imagePath,
    required this.productId,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    // Helper to safely convert to int
    int _toInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is num) return value.toInt();
      return defaultValue;
    }

    return ProductImage(
      id: _toInt(json['id']),
      imagePath: json['image_path']?.toString() ?? '',
      productId: _toInt(json['product_id']),
    );
  }
}