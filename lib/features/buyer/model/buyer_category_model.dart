// category_response.dart
import 'dart:convert';

class CategoryResponse {
  final String status;
  final String message;
  final CategoryPage data;

  CategoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CategoryResponse.fromRawJson(String str) =>
      CategoryResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CategoryResponse.fromJson(Map<String, dynamic> json) =>
      CategoryResponse(
        status: json['status'] ?? '',
        message: json['message'] ?? '',
        data: CategoryPage.fromJson(json['data'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.toJson(),
  };
}

class CategoryPage {
  final int currentPage;
  final List<CategoryItem> data;
  final String firstPageUrl;
  final int? from;
  final int lastPage;
  final String lastPageUrl;
  final List<PageLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  CategoryPage({
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

  factory CategoryPage.fromJson(Map<String, dynamic> json) => CategoryPage(
    currentPage: json['current_page'] ?? 0,
    data: (json['data'] as List<dynamic>? ?? [])
        .map((e) => CategoryItem.fromJson(e))
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
    perPage: _toInt(json['per_page']),
    prevPageUrl: json['prev_page_url'],
    to: json['to'],
    total: _toInt(json['total']),
  );

  Map<String, dynamic> toJson() => {
    'current_page': currentPage,
    'data': data.map((e) => e.toJson()).toList(),
    'first_page_url': firstPageUrl,
    'from': from,
    'last_page': lastPage,
    'last_page_url': lastPageUrl,
    'links': links.map((e) => e.toJson()).toList(),
    'next_page_url': nextPageUrl,
    'path': path,
    'per_page': perPage,
    'prev_page_url': prevPageUrl,
    'to': to,
    'total': total,
  };
}

class CategoryItem {
  final int id;
  final String name;
  final String status;
  final int vendorId;
  final List<Product> products;
  final List<dynamic> categoryImages;
  final VendorSummary vendor; // only { "id": 1 } in list payload

  CategoryItem({
    required this.id,
    required this.name,
    required this.status,
    required this.vendorId,
    required this.products,
    required this.categoryImages,
    required this.vendor,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) => CategoryItem(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    status: json['status'] ?? '',
    vendorId: json['vendor_id'] ?? 0,
    products: (json['products'] as List<dynamic>? ?? [])
        .map((e) => Product.fromJson(e))
        .toList(),
    categoryImages: (json['category_images'] as List<dynamic>? ?? []),
    vendor: VendorSummary.fromJson(json['vendor'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'status': status,
    'vendor_id': vendorId,
    'products': products.map((e) => e.toJson()).toList(),
    'category_images': categoryImages,
    'vendor': vendor.toJson(),
  };
}

class VendorSummary {
  final int id;

  VendorSummary({required this.id});

  factory VendorSummary.fromJson(Map<String, dynamic> json) =>
      VendorSummary(id: json['id'] ?? 0);

  Map<String, dynamic> toJson() => {'id': id};
}

class Product {
  final int id;
  final String name;
  final String description;
  final String regularPrice;
  final String sellPrice;
  final num discount;
  final String image;
  final List<String> color;
  final List<String> size;
  final int vendorId;
  final String remark;
  final int categoryId;
  final List<ProductImage> images;
  final Vendor? vendor;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.regularPrice,
    required this.sellPrice,
    required this.discount,
    required this.image,
    required this.color,
    required this.size,
    required this.vendorId,
    required this.remark,
    required this.categoryId,
    required this.images,
    required this.vendor,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    regularPrice: json['regular_price']?.toString() ?? '',
    sellPrice: json['sell_price']?.toString() ?? '',
    discount: json['discount'] ?? 0,
    image: json['image'] ?? '',
    color: _normalizeStrList(json['color']),
    size: _normalizeStrList(json['size']),
    vendorId: json['vendor_id'] ?? 0,
    remark: json['remark'] ?? '',
    categoryId: json['category_id'] ?? 0,
    images: (json['images'] as List<dynamic>? ?? [])
        .map((e) => ProductImage.fromJson(e))
        .toList(),
    vendor: json['vendor'] == null ? null : Vendor.fromJson(json['vendor']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'regular_price': regularPrice,
    'sell_price': sellPrice,
    'discount': discount,
    'image': image,
    'color': color,
    'size': size,
    'vendor_id': vendorId,
    'remark': remark,
    'category_id': categoryId,
    'images': images.map((e) => e.toJson()).toList(),
    'vendor': vendor?.toJson(),
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

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
    id: json['id'] ?? 0,
    productId: json['product_id'] ?? 0,
    imagePath: json['image_path'] ?? '',
    publicId: json['public_id'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'image_path': imagePath,
    'public_id': publicId,
  };
}

class Vendor {
  final int id;
  final String? country;
  final String? address;
  final String? businessName;
  final String? businessType;
  final int? userId;
  final VendorUser? user;

  Vendor({
    required this.id,
    this.country,
    this.address,
    this.businessName,
    this.businessType,
    this.userId,
    this.user,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
    id: json['id'] ?? 0,
    country: json['country'],
    address: json['address'],
    businessName: json['business_name'],
    businessType: json['business_type'],
    userId: json['user_id'],
    user: json['user'] == null ? null : VendorUser.fromJson(json['user']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'country': country,
    'address': address,
    'business_name': businessName,
    'business_type': businessType,
    'user_id': userId,
    'user': user?.toJson(),
  };
}

class VendorUser {
  final int id;
  final String name;
  final String? image;
  final String? email;
  final String? phone;
  final String? language;

  VendorUser({
    required this.id,
    required this.name,
    this.image,
    this.email,
    this.phone,
    this.language,
  });

  factory VendorUser.fromJson(Map<String, dynamic> json) => VendorUser(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    image: json['image'],
    email: json['email'],
    phone: json['phone'],
    language: json['language'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'email': email,
    'phone': phone,
    'language': language,
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

  factory PageLink.fromJson(Map<String, dynamic> json) => PageLink(
    url: json['url'],
    label: json['label'] ?? '',
    page: json['page'],
    active: json['active'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'url': url,
    'label': label,
    'page': page,
    'active': active,
  };
}

// ---------- helpers ----------
int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

/// Handles cases like:
/// ["yellow,blue"], ["L,XL"], "M", "\"x\"", or ["blue"]
List<String> _normalizeStrList(dynamic raw) {
  if (raw == null) return [];
  if (raw is List) {
    final joined = raw.map((e) => e?.toString() ?? '').join(',');
    return joined
        .replaceAll('"', '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
  if (raw is String) {
    return raw
        .replaceAll('"', '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
  return [];
}
