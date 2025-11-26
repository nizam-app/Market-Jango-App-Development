// lib/features/buyer/model/new_items_model.dart
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
      data: BuyerNewItems.fromJson(
        Map<String, dynamic>.from(json['data'] as Map),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.toJson(),
  };
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
    final list = (json['data'] as List? ?? const []);
    return BuyerNewItems(
      currentPage: _toInt(json['current_page'], fallback: 1),
      data: list
          .where((e) => e != null)
          .map(
            (e) =>
                NewItemsProduct.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      nextPageUrl: _toStrN(json['next_page_url']),
      lastPage: _toInt(json['last_page'], fallback: 1),
    );
  }

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'data': data.map((e) => e.toJson()).toList(),
    'next_page_url': nextPageUrl,
    'last_page': lastPage,
  };
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
  final Vendor vendor;

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
    required this.vendor,
  });

  /// API কখনো wrapper দেয়:
  /// { id,key,product_id, product:{ ... actual product ... } }
  /// অথবা সরাসরি product object।
  factory NewItemsProduct.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> src = (json['product'] is Map)
        ? Map<String, dynamic>.from(json['product'] as Map)
        : Map<String, dynamic>.from(json);

    final List<String> parsedColors = _normalizeStringOrList(src['color']);
    final List<String> parsedSizes = _normalizeStringOrList(src['size']);

    final Map<String, dynamic> categoryMap = (src['category'] is Map)
        ? Map<String, dynamic>.from(src['category'] as Map)
        : const <String, dynamic>{};

    final Map<String, dynamic> vendorMap = (src['vendor'] is Map)
        ? Map<String, dynamic>.from(src['vendor'] as Map)
        : const <String, dynamic>{};

    final List<ProductImage> imageList = ((src['images'] as List?) ?? const [])
        .where((e) => e is Map)
        .map((e) => ProductImage.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return NewItemsProduct(
      id: _toInt(src['id']),
      name: _toStr(src['name']),
      description: _toStr(src['description']),
      regularPrice: _toStr(src['regular_price'], fallback: '0.00'),
      sellPrice: _toStr(src['sell_price'], fallback: '0.00'),
      image: _toStr(src['image']),
      vendorId: _toInt(src['vendor_id']),
      categoryId: _toInt(src['category_id']),
      color: parsedColors,
      size: parsedSizes,
      category: Category.fromJson(categoryMap),
      images: imageList,
      vendor: vendorMap.isNotEmpty
          ? Vendor.fromJson(vendorMap)
          : Vendor.empty(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'regular_price': regularPrice,
    'sell_price': sellPrice,
    'image': image,
    'vendor_id': vendorId,
    'category_id': categoryId,
    'color': color,
    'size': size,
    'category': category.toJson(),
    'images': images.map((e) => e.toJson()).toList(),
    'vendor': vendor.toJson(),
  };
}

class Category {
  final int id;
  final String name;
  final String description;

  Category({required this.id, required this.name, required this.description});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: _toInt(json['id']),
      name: _toStr(json['name']),
      description: _toStr(json['description']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
  };
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
      id: _toInt(json['id']),
      imagePath: _toStr(json['image_path']),
      productId: _toInt(json['product_id']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'image_path': imagePath,
    'product_id': productId,
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
      id: _toInt(json['id']),
      vendorId: _toInt(json['vendor_id']),
      description: _toStr(json['description']),
      rating: _toInt(json['rating']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vendor_id': vendorId,
    'description': description,
    'rating': rating,
  };
}

class Vendor {
  final int id;
  final String? country;
  final String? address;
  final String? businessName;
  final String? businessType;
  final int userId;
  final String? createdAt;
  final String? updatedAt;

  final User user; // nested user
  final List<Review> reviews; // nested reviews

  const Vendor({
    required this.id,
    required this.userId,
    required this.user,
    required this.reviews,
    this.country,
    this.address,
    this.businessName,
    this.businessType,
    this.createdAt,
    this.updatedAt,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> userMap = (json['user'] is Map)
        ? Map<String, dynamic>.from(json['user'] as Map)
        : const <String, dynamic>{}; // ✅ typed empty map

    final List reviewsList = (json['reviews'] as List?) ?? const [];

    return Vendor(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      user: userMap.isNotEmpty ? User.fromJson(userMap) : User.empty(),
      reviews: reviewsList
          .where((e) => e is Map)
          .map((e) => Review.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      country: _toStrN(json['country']),
      address: _toStrN(json['address']),
      businessName: _toStrN(json['business_name']),
      businessType: _toStrN(json['business_type']),
      createdAt: _toStrN(json['created_at']),
      updatedAt: _toStrN(json['updated_at']),
    );
  }

  factory Vendor.empty() => Vendor(
    id: 0,
    userId: 0,
    user: User.empty(),
    reviews: const [],
    country: null,
    address: null,
    businessName: null,
    businessType: null,
    createdAt: null,
    updatedAt: null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'country': country,
    'address': address,
    'business_name': businessName,
    'business_type': businessType,
    'user_id': userId,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'user': user.toJson(),
    'reviews': reviews.map((r) => r.toJson()).toList(),
  };
}

class User {
  final int id;
  final String name;

  // extra (API-তে থাকে)
  final String? userType;
  final String? email;
  final String? phone;
  final String? otp;
  final String? phoneVerifiedAt;
  final String? language;
  final String? image;
  final String? publicId;
  final String? status;
  final int? isActive;
  final String? expiresAt;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.name,
    this.userType,
    this.email,
    this.phone,
    this.otp,
    this.phoneVerifiedAt,
    this.language,
    this.image,
    this.publicId,
    this.status,
    this.isActive,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _toInt(json['id']),
      name: _toStr(json['name']),
      userType: _toStrN(json['user_type']),
      email: _toStrN(json['email']),
      phone: _toStrN(json['phone']),
      otp: _toStrN(json['otp']),
      phoneVerifiedAt: _toStrN(json['phone_verified_at']),
      language: _toStrN(json['language']),
      image: _toStrN(json['image']),
      publicId: _toStrN(json['public_id']),
      status: _toStrN(json['status']),
      isActive: _toIntN(json['is_active']),
      expiresAt: _toStrN(json['expires_at']),
      createdAt: _toStrN(json['created_at']),
      updatedAt: _toStrN(json['updated_at']),
    );
  }

  factory User.empty() => User(id: 0, name: '');

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'user_type': userType,
    'email': email,
    'phone': phone,
    'otp': otp,
    'phone_verified_at': phoneVerifiedAt,
    'language': language,
    'image': image,
    'public_id': publicId,
    'status': status,
    'is_active': isActive,
    'expires_at': expiresAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

/// -------------------- helpers --------------------

int _toInt(dynamic v, {int fallback = 0}) {
  if (v is int) return v;
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

int? _toIntN(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is String) return int.tryParse(v);
  return null;
}

String _toStr(dynamic v, {String fallback = ''}) {
  if (v == null) return fallback;
  final s = v.toString();
  return s.isEmpty ? fallback : s;
}

String? _toStrN(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

/// color/size normalize: List | "['x','xl']" | "x,XL"
List<String> _normalizeStringOrList(dynamic raw) {
  if (raw == null) return const [];

  if (raw is List) {
    return raw
        .expand((e) => e.toString().split(','))
        .map((e) => e.replaceAll(RegExp(r'[\[\]\"]'), '').trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  if (raw is String) {
    try {
      final d = jsonDecode(raw);
      if (d is List) {
        return d
            .expand((e) => e.toString().split(','))
            .map((e) => e.replaceAll(RegExp(r'[\[\]\"]'), '').trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (_) {}
    return raw
        .toString()
        .split(',')
        .map((e) => e.replaceAll(RegExp(r'[\[\]\"]'), '').trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  return const [];
}
