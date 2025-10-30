import 'dart:convert';

class BuyerNewItemsModel {
  final String status;
  final String message;
  final BuyerNewItems data;

  BuyerNewItemsModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BuyerNewItemsModel.fromJson(Map<String, dynamic> json) {
    return BuyerNewItemsModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: BuyerNewItems.fromJson(json['data']),
    );
  }
}

class BuyerNewItems {
  final int currentPage;
  final List<NewItemsProduct> data;
  final String? nextPageUrl;
  final int lastPage;

  BuyerNewItems({
    required this.currentPage,
    required this.data,
    required this.nextPageUrl,
    required this.lastPage,
  });

  factory BuyerNewItems.fromJson(Map<String, dynamic> json) {
    return BuyerNewItems(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List)
          .map((e) => NewItemsProduct.fromJson(e))
          .toList(),
      nextPageUrl: json['next_page_url'],
      lastPage: json['last_page'] ?? 1,
    );
  }
}

class NewItemsProduct {
  final int id;
  final String name;
  final String description;
  final String regularPrice;
  final String sellPrice;
  final String image;
  final int vendorId;
  final int categoryId;
  final List<String> color;
  final List<String> size;
  final Category category;
  final List<ProductImage> images;

  NewItemsProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.regularPrice,
    required this.sellPrice,
    required this.image,
    required this.vendorId,
    required this.categoryId,
    required this.color,
    required this.size,
    required this.category,
    required this.images,
  });

  factory NewItemsProduct.fromJson(Map<String, dynamic> json) {
    // normalize color
    List<String> parsedColors = [];
    if (json['color'] is List) {
      parsedColors = (json['color'] as List)
          .expand((e) => e.toString().split(','))
          .map((e) => e.replaceAll(RegExp(r'[\[\]\"]'), '').trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (json['color'] is String) {
      try {
        parsedColors = List<String>.from(jsonDecode(json['color']));
      } catch (_) {
        parsedColors = json['color']
            .toString()
            .split(',')
            .map((e) => e.replaceAll(RegExp(r'[\[\]\"]'), '').trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    // normalize size
    List<String> parsedSizes = [];
    if (json['size'] is List) {
      parsedSizes = (json['size'] as List)
          .expand((e) => e.toString().split(','))
          .map((e) => e.replaceAll(RegExp(r'[\[\]\"]'), '').trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (json['size'] is String) {
      try {
        parsedSizes = List<String>.from(jsonDecode(json['size']));
      } catch (_) {
        parsedSizes = json['size']
            .toString()
            .split(',')
            .map((e) => e.replaceAll(RegExp(r'[\[\]\"]'), '').trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    return NewItemsProduct(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      regularPrice: json['regular_price'] ?? '0.00',
      sellPrice: json['sell_price'] ?? '0.00',
      image: json['image'] ?? '',
      vendorId: json['vendor_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      color: parsedColors,
      size: parsedSizes,
      category: Category.fromJson(json['category']),
      images: (json['images'] as List)
          .map((e) => ProductImage.fromJson(e))
          .toList(),
    );
  }
}

class Category {
  final int id;
  final String name;
  final String description;

  Category({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

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
    return ProductImage(
      id: json['id'] ?? 0,
      imagePath: json['image_path'] ?? '',
      productId: json['product_id'] ?? 0,
    );
  }
}