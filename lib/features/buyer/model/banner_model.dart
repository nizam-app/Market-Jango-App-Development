class PaginatedBanners {
  final int currentPage;
  final int lastPage;
  final int total;
  final List<BannerItem> banners;

  PaginatedBanners({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.banners,
  });

  factory PaginatedBanners.fromJson(Map<String, dynamic> json) {
    return PaginatedBanners(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
      banners: (json['data'] as List<dynamic>?)
          ?.map((e) => BannerItem.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class BannerItem {
  final int id;
  final String name;
  final String description;
  final String discount;
  final String image;
  final String publicId;
  final int productId;
  final String createdAt;
  final String updatedAt;
  final Product? product;

  BannerItem({
    required this.id,
    required this.name,
    required this.description,
    required this.discount,
    required this.image,
    required this.publicId,
    required this.productId,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      discount: json['discount'] ?? '',
      image: json['image'] ?? '',
      publicId: json['public_id'] ?? '',
      productId: json['product_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      product: json['product'] != null
          ? Product.fromJson(json['product'])
          : null,
    );
  }
}

class Product {
  final int id;
  final String name;
  final String description;
  final String regularPrice;
  final String sellPrice;
  final int discount;
  final String publicId;
  final int star;
  final String image;
  final List<String> color;
  final List<String> size;
  final String remark;
  final int isActive;
  final int vendorId;
  final int categoryId;
  final String createdAt;
  final String updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.regularPrice,
    required this.sellPrice,
    required this.discount,
    required this.publicId,
    required this.star,
    required this.image,
    required this.color,
    required this.size,
    required this.remark,
    required this.isActive,
    required this.vendorId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // color এবং size কখনো array, কখনো string — তাই normalize করা হয়েছে
    List<String> parseDynamicList(dynamic data) {
      if (data == null) return [];
      if (data is List) {
        return data
            .expand((e) => e.toString().split(','))
            .map((e) => e.trim())
            .toList();
      }
      if (data is String) {
        return data
            .replaceAll('"', '')
            .split(',')
            .map((e) => e.trim())
            .toList();
      }
      return [];
    }

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      regularPrice: json['regular_price'] ?? '',
      sellPrice: json['sell_price'] ?? '',
      discount: json['discount'] ?? 0,
      publicId: json['public_id'] ?? '',
      star: json['star'] ?? 0,
      image: json['image'] ?? '',
      color: parseDynamicList(json['color']),
      size: parseDynamicList(json['size']),
      remark: json['remark'] ?? '',
      isActive: json['is_active'] ?? 0,
      vendorId: json['vendor_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}