// models/top_products_response.dart
import 'dart:convert';

class TopProductsResponse {
  final String status;
  final String message;
  final TopProductsData data;

  TopProductsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TopProductsResponse.fromJson(Map<String, dynamic> json) {
    return TopProductsResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: TopProductsData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.toJson(),
  };

  static TopProductsResponse fromRawJson(String str) =>
      TopProductsResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}

class TopProductsData {
  final int currentPage;
  final List<TopProductItem> data;
  final String firstPageUrl;
  final int? from;
  final int lastPage;
  final String lastPageUrl;
  final List<PageLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  TopProductsData({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory TopProductsData.fromJson(Map<String, dynamic> json) {
    return TopProductsData(
      currentPage: json['current_page'] ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => TopProductItem.fromJson(e))
          .toList(),
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'],
      lastPage: json['last_page'] ?? 0,
      lastPageUrl: json['last_page_url'] ?? '',
      links: (json['links'] as List<dynamic>? ?? [])
          .map((e) => PageLink.fromJson(e))
          .toList(),
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 0,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'data': data.map((d) => d.toJson()).toList(),
    'first_page_url': firstPageUrl,
    'from': from,
    'last_page': lastPage,
    'last_page_url': lastPageUrl,
    'links': links.map((l) => l.toJson()).toList(),
    'next_page_url': nextPageUrl,
    'path': path,
    'per_page': perPage,
    'prev_page_url': prevPageUrl,
    'to': to,
    'total': total,
  };
}

class TopProductItem {
  final int id;
  final String key;
  final int productId;
  final Product product;

  TopProductItem({
    required this.id,
    required this.key,
    required this.productId,
    required this.product,
  });

  factory TopProductItem.fromJson(Map<String, dynamic> json) {
    return TopProductItem(
      id: json['id'] ?? 0,
      key: json['key'] ?? '',
      productId: json['product_id'] ?? 0,
      product: Product.fromJson(json['product'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'key': key,
    'product_id': productId,
    'product': product.toJson(),
  };
}

class Product {
  final int id;
  final String name;
  final String regularPrice;
  final String sellPrice;
  final String image;
  final int categoryId;
  final int vendorId;
  final List<ProductImage> images;
  final Vendor vendor;
  final Category category;

  Product({
    required this.id,
    required this.name,
    required this.regularPrice,
    required this.sellPrice,
    required this.image,
    required this.categoryId,
    required this.vendorId,
    required this.images,
    required this.vendor,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      regularPrice: json['regular_price']?.toString() ?? '',
      sellPrice: json['sell_price']?.toString() ?? '',
      image: json['image'] ?? '',
      categoryId: json['category_id'] ?? 0,
      vendorId: json['vendor_id'] ?? 0,
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => ProductImage.fromJson(e))
          .toList(),
      vendor: Vendor.fromJson(json['vendor'] ?? {}),
      category: Category.fromJson(json['category'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'regular_price': regularPrice,
    'sell_price': sellPrice,
    'image': image,
    'category_id': categoryId,
    'vendor_id': vendorId,
    'images': images.map((i) => i.toJson()).toList(),
    'vendor': vendor.toJson(),
    'category': category.toJson(),
  };
}

class ProductImage {
  final int id;
  final int productId;
  final String imagePath;
  final String publicId;

  ProductImage({
    required this.id,
    required this.productId,
    required this.imagePath,
    required this.publicId,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      imagePath: json['image_path'] ?? '',
      publicId: json['public_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'image_path': imagePath,
    'public_id': publicId,
  };
}

class Vendor {
  final int id;
  final int userId;
  final User user;
  final List<Review> reviews;

  Vendor({
    required this.id,
    required this.userId,
    required this.user,
    required this.reviews,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      user: User.fromJson(json['user'] ?? {}),
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((e) => Review.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'user': user.toJson(),
    'reviews': reviews.map((r) => r.toJson()).toList(),
  };
}

class User {
  final int id;
  final String name;

  User({
    required this.id,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class Review {
  final int id;
  final int vendorId;
  final String description;
  final int rating;

  Review({
    required this.id,
    required this.vendorId,
    required this.description,
    required this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? 0,
      vendorId: json['vendor_id'] ?? 0,
      description: json['description'] ?? '',
      rating: json['rating'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vendor_id': vendorId,
    'description': description,
    'rating': rating,
  };
}

class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class PageLink {
  final String? url;
  final String label;
  final int? page;
  final bool active;

  PageLink({
    required this.url,
    required this.label,
    required this.page,
    required this.active,
  });

  factory PageLink.fromJson(Map<String, dynamic> json) {
    return PageLink(
      url: json['url'],
      label: json['label'] ?? '',
      page: json['page'],
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'label': label,
    'page': page,
    'active': active,
  };
}