// product_all_details_model.dart

class DetailItem {
  final int id;
  final String name;
  final String description;
  final double regularPrice;
  final double sellPrice;
  final int discount;
  final String publicId;
  final double star;
  final String image;
  final List<String> color;
  final List<String> size;
  final String remark;
  final bool isActive;
  final int vendorId;
  final int categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Vendor vendor;
  final Category category;
  final List<DetailImage> images;

  DetailItem({
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
    required this.vendor,
    required this.category,
    required this.images,
  });

  factory DetailItem.fromJson(Map<String, dynamic> json) {
    final data = json;

    return DetailItem(
      id: (data['id'] as num?)?.toInt() ?? 0,
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      regularPrice: _toDouble(data['regular_price']),
      sellPrice: _toDouble(data['sell_price']),
      discount: (data['discount'] as num?)?.toInt() ?? 0,
      publicId: data['public_id']?.toString() ?? '',
      star: (data['star'] is num) ? (data['star'] as num).toDouble() : 0.0,
      image: data['image']?.toString() ?? '',
      color: _parseColors(data['color']),
      size: _parseStringList(data['size']),
      remark: data['remark']?.toString() ?? '',
      isActive: data['is_active'] is bool
          ? data['is_active'] as bool
          : (data['is_active'] as num?)?.toInt() == 1,
      vendorId: (data['vendor_id'] as num?)?.toInt() ?? 0,
      categoryId: (data['category_id'] as num?)?.toInt() ?? 0,
      createdAt: _parseDate(data['created_at']),
      updatedAt: _parseDate(data['updated_at']),
      vendor: Vendor.fromJson((data['vendor'] as Map?)?.cast<String, dynamic>() ?? const {}),
      category: Category.fromJson((data['category'] as Map?)?.cast<String, dynamic>() ?? const {}),
      images: ((data['images'] as List?) ?? const [])
          .whereType<Map>()
          .map((m) => DetailImage.fromJson(m.cast<String, dynamic>()))
          .toList(),
    );
  }

  // -------- helpers ----------
  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw == null) return <String>[];
    if (raw is List) {
      return raw
          .where((e) => e != null)
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (raw is String) {
      return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return <String>[];
  }

  static List<String> _parseColors(dynamic raw) {
    // Accept: ["d926cd,3B82F6,..."] OR ["d926cd","3B82F6"] OR "d926cd,3B82F6"
    if (raw == null) return <String>[];
    if (raw is List) {
      return raw
          .where((e) => e != null)
          .expand<String>((e) => e.toString().split(','))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (raw is String) {
      return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return <String>[];
  }
}

// ---------------- Vendor ----------------

class Vendor {
  final int id;
  final String country;
  final String address;
  final String businessName;
  final String businessType;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;
  final List<dynamic> reviews;

  Vendor({
    required this.id,
    required this.country,
    required this.address,
    required this.businessName,
    required this.businessType,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.reviews,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    final j = json;
    return Vendor(
      id: (j['id'] as num?)?.toInt() ?? 0,
      country: j['country']?.toString() ?? '',
      address: j['address']?.toString() ?? '',
      businessName: j['business_name']?.toString() ?? '',
      businessType: j['business_type']?.toString() ?? '',
      userId: (j['user_id'] as num?)?.toInt() ?? 0,
      createdAt: DetailItem._parseDate(j['created_at']),
      updatedAt: DetailItem._parseDate(j['updated_at']),
      user: User.fromJson((j['user'] as Map?)?.cast<String, dynamic>() ?? const {}),
      reviews: (j['reviews'] as List?)?.toList() ?? const [],
    );
  }
}

// ---------------- User ----------------

class User {
  final int id;
  final String userType;
  final String name;
  final String email;
  final String phone;
  final String? otp;
  final DateTime? phoneVerifiedAt;
  final String language;
  final String image;
  final String publicId;
  final String status;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.userType,
    required this.name,
    required this.email,
    required this.phone,
    this.otp,
    this.phoneVerifiedAt,
    required this.language,
    required this.image,
    required this.publicId,
    required this.status,
    required this.isActive,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final j = json;
    return User(
      id: (j['id'] as num?)?.toInt() ?? 0,
      userType: j['user_type']?.toString() ?? '',
      name: j['name']?.toString() ?? '',
      email: j['email']?.toString() ?? '',
      phone: j['phone']?.toString() ?? '',
      otp: j['otp']?.toString(),
      phoneVerifiedAt:
      j['phone_verified_at'] != null ? DateTime.tryParse(j['phone_verified_at'].toString()) : null,
      language: j['language']?.toString() ?? '',
      image: j['image']?.toString() ?? '',
      publicId: j['public_id']?.toString() ?? '',
      status: j['status']?.toString() ?? '',
      isActive: j['is_active'] is bool ? j['is_active'] as bool : ((j['is_active'] as num?)?.toInt() == 1),
      expiresAt: j['expires_at'] != null ? DateTime.tryParse(j['expires_at'].toString()) : null,
      createdAt: DetailItem._parseDate(j['created_at']),
      updatedAt: DetailItem._parseDate(j['updated_at']),
    );
  }
}

// --------------- Category ---------------

class Category {
  final int id;
  final String name;
  final String description;
  final String status;
  final int vendorId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.vendorId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final j = json;
    return Category(
      id: (j['id'] as num?)?.toInt() ?? 0,
      name: j['name']?.toString() ?? '',
      description: j['description']?.toString() ?? '',
      status: j['status']?.toString() ?? '',
      vendorId: (j['vendor_id'] as num?)?.toInt() ?? 0,
      createdAt: DetailItem._parseDate(j['created_at']),
      updatedAt: DetailItem._parseDate(j['updated_at']),
    );
  }
}

// --------------- DetailImage ---------------

class DetailImage {
  final int id;
  final String imagePath;
  final String publicId;
  final int productId;

  DetailImage({
    required this.id,
    required this.imagePath,
    required this.publicId,
    required this.productId,
  });

  factory DetailImage.fromJson(Map<String, dynamic> json) {
    final j = json;
    return DetailImage(
      id: (j['id'] as num?)?.toInt() ?? 0,
      imagePath: j['image_path']?.toString() ?? '',
      publicId: j['public_id']?.toString() ?? '',
      productId: (j['product_id'] as num?)?.toInt() ?? 0,
    );
  }
}