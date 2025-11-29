import 'dart:convert';

/// ---------- Pagination link ----------
class PageLink {
  final String? url;
  final String label;
  final int? page;
  final bool active;

  const PageLink({
    required this.url,
    required this.label,
    required this.page,
    required this.active,
  });

  factory PageLink.fromJson(Map<String, dynamic> json) => PageLink(
    url: json['url'],
    label: json['label']?.toString() ?? '',
    page: json['page'] is int ? json['page'] as int : int.tryParse('${json['page'] ?? ''}'),
    active: json['active'] == true,
  );
}

/// ---------- Top-level response (status + message + paginated data) ----------
class GlobalSearchResponse {
  final String status;
  final String message;

  // Pagination meta
  final int currentPage;
  final String? firstPageUrl;
  final int? from;
  final int lastPage;
  final String? lastPageUrl;
  final List<PageLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  // Actual items
  final List<GlobalSearchProduct> products;

  GlobalSearchResponse({
    required this.status,
    required this.message,
    required this.currentPage,
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
    required this.products,
  });

  factory GlobalSearchResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] ?? {}) as Map<String, dynamic>;
    final list = (data['data'] is List) ? data['data'] as List : const [];

    // per_page কখনো string হতে পারে
    int _parsePerPage(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return GlobalSearchResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      currentPage: data['current_page'] ?? 1,
      firstPageUrl: data['first_page_url'],
      from: data['from'],
      lastPage: data['last_page'] ?? 1,
      lastPageUrl: data['last_page_url'],
      links: (data['links'] is List)
          ? (data['links'] as List).map((e) => PageLink.fromJson(e)).toList()
          : const [],
      nextPageUrl: data['next_page_url'],
      path: data['path']?.toString() ?? '',
      perPage: _parsePerPage(data['per_page']),
      prevPageUrl: data['prev_page_url'],
      to: data['to'],
      total: data['total'] ?? 0,
      products: List<GlobalSearchProduct>.from(
        list.map((x) => GlobalSearchProduct.fromJson(x as Map<String, dynamic>)),
      ),
    );
  }
  // GlobalSearchResponse ক্লাসের ভিতরে যোগ করুন:
  factory GlobalSearchResponse.empty() => GlobalSearchResponse(
    status: 'success',
    message: '',
    currentPage: 1,
    firstPageUrl: null,
    from: 0,
    lastPage: 1,
    lastPageUrl: null,
    links: const [],
    nextPageUrl: null,
    path: '',
    perPage: 0,
    prevPageUrl: null,
    to: 0,
    total: 0,
    products: const [],
  );

}

/// ---------- Product + nested objects ----------
class GlobalSearchProduct {
  final int id;
  final String name;
  final String description;
  final String image;
  final String regularPrice;
  final String sellPrice;

  // Newly added (from sample JSON)
  final List<String> size;     // ["L,XL"] → normalize করে ["L","XL"]
  final List<String> color;    // ["yellow,blue"] → ["yellow","blue"]
  final int? vendorId;
  final int? categoryId;
  final SearchCategory? category;
  final SearchVendor? vendor;
  final List<SearchProductImage> images;

  GlobalSearchProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.regularPrice,
    required this.sellPrice,
    this.size = const [],
    this.color = const [],
    this.vendorId,
    this.categoryId,
    this.category,
    this.vendor,
    this.images = const [],
  });

  factory GlobalSearchProduct.fromJson(Map<String, dynamic> json) => GlobalSearchProduct(
    id: json['id'] ?? 0,
    name: json['name']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    image: json['image']?.toString() ?? '',
    regularPrice: json['regular_price']?.toString() ?? '',
    // sell_price না থাকলে regular_price fallback
    sellPrice: (json['sell_price'] ?? json['regular_price'] ?? '').toString(),
    size: _parseFlexibleStringList(json['size']),
    color: _parseFlexibleStringList(json['color']),
    vendorId: json['vendor_id'],
    categoryId: json['category_id'],
    category: (json['category'] is Map) ? SearchCategory.fromJson(json['category']) : null,
    vendor: (json['vendor'] is Map) ? SearchVendor.fromJson(json['vendor']) : null,
    images: (json['images'] is List)
        ? (json['images'] as List).map((e) => SearchProductImage.fromJson(e)).toList()
        : const [],
  );
}

class SearchCategory {
  final int id;
  final String name;

  const SearchCategory({required this.id, required this.name});

  factory SearchCategory.fromJson(Map<String, dynamic> json) => SearchCategory(
    id: json['id'] ?? 0,
    name: json['name']?.toString() ?? '',
  );
}

class SearchProductImage {
  final int id;
  final String imagePath;
  final String? publicId;
  final int? productId;

  const SearchProductImage({
    required this.id,
    required this.imagePath,
    this.publicId,
    this.productId,
  });

  factory SearchProductImage.fromJson(Map<String, dynamic> json) => SearchProductImage(
    id: json['id'] ?? 0,
    imagePath: json['image_path']?.toString() ?? '',
    publicId: json['public_id']?.toString(),
    productId: json['product_id'],
  );
}

class SearchVendor {
  final int id;
  final int? userId;
  final SearchVendorUser? user;
  final List<SearchVendorReview> reviews;

  const SearchVendor({
    required this.id,
    this.userId,
    this.user,
    this.reviews = const [],
  });

  factory SearchVendor.fromJson(Map<String, dynamic> json) => SearchVendor(
    id: json['id'] ?? 0,
    userId: json['user_id'],
    user: (json['user'] is Map) ? SearchVendorUser.fromJson(json['user']) : null,
    reviews: (json['reviews'] is List)
        ? (json['reviews'] as List).map((e) => SearchVendorReview.fromJson(e)).toList()
        : const [],
  );
}

class SearchVendorUser {
  final int id;
  final String name;

  const SearchVendorUser({required this.id, required this.name});

  factory SearchVendorUser.fromJson(Map<String, dynamic> json) => SearchVendorUser(
    id: json['id'] ?? 0,
    name: json['name']?.toString() ?? '',
  );
}

class SearchVendorReview {
  final int id;
  final int? vendorId;
  final String? description;
  final num? rating;

  const SearchVendorReview({
    required this.id,
    this.vendorId,
    this.description,
    this.rating,
  });

  factory SearchVendorReview.fromJson(Map<String, dynamic> json) => SearchVendorReview(
    id: json['id'] ?? 0,
    vendorId: json['vendor_id'],
    description: json['description']?.toString(),
    rating: (json['rating'] is num) ? json['rating'] as num : num.tryParse('${json['rating'] ?? ''}'),
  );
}

/// --- helper: ["L,XL"] / "L,XL" / ["L","XL"] / '["L","XL"]' → ["L","XL"]
List<String> _parseFlexibleStringList(dynamic raw) {
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
      final j = jsonDecode(raw);
      if (j is List) return j.map((e) => e.toString()).toList();
    } catch (_) {
      // not JSON → CSV fallback
    }
    return raw
        .split(',')
        .map((e) => e.replaceAll(RegExp(r'[\[\]\"]'), '').trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  return const [];
}