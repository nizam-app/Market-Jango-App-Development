// models/vendor_category_products.dart
import 'dart:convert';

VendorCategoryProductsResponse vendorCategoryProductsResponseFromJson(String s) =>
    VendorCategoryProductsResponse.fromJson(jsonDecode(s));

class VendorCategoryProductsResponse {
  final String status;
  final String? message;
  final VcpData data;

  VendorCategoryProductsResponse({
    required this.status,
    this.message,
    required this.data,
  });

  factory VendorCategoryProductsResponse.fromJson(Map<String, dynamic> j) =>
      VendorCategoryProductsResponse(
        status: (j['status'] ?? '').toString(),
        message: j['message']?.toString(),
        data: VcpData.fromJson(j['data'] as Map<String, dynamic>),
      );
}

class VcpData {
  final int all;
  final Page<CategoryNode> categories;
  final VcpVendor vendor;

  VcpData({required this.all, required this.categories, required this.vendor});

  factory VcpData.fromJson(Map<String, dynamic> j) => VcpData(
    all: _toInt(j['all']),
    categories: Page<CategoryNode>.fromJson(
      j['categories'] as Map<String, dynamic>,
          (e) => CategoryNode.fromJson(e as Map<String, dynamic>),
    ),
    vendor: VcpVendor.fromJson(j['vendor'] as Map<String, dynamic>),
  );
}

/// ---------- Generic Laravel pagination ----------
class Page<T> {
  final int currentPage;
  final List<T> data;
  final int lastPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  Page({
    required this.currentPage,
    required this.data,
    required this.lastPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory Page.fromJson(
      Map<String, dynamic> j,
      T Function(Object? json) itemFromJson,
      ) {
    final list = (j['data'] as List? ?? []).map(itemFromJson).toList();
    return Page(
      currentPage: _toInt(j['current_page']),
      data: list.cast<T>(),
      lastPage: _toInt(j['last_page']),
      nextPageUrl: j['next_page_url']?.toString(),
      prevPageUrl: j['prev_page_url']?.toString(),
    );
  }
}

/// ---------- Category ----------
class CategoryNode {
  final int id;
  final String name;
  final String description;
  final int vendorId;
  final List<VcpProduct> products;

  CategoryNode({
    required this.id,
    required this.name,
    required this.description,
    required this.vendorId,
    required this.products,
  });

  factory CategoryNode.fromJson(Map<String, dynamic> j) => CategoryNode(
    id: _toInt(j['id']),
    name: j['name']?.toString() ?? '',
    description: j['description']?.toString() ?? '',
    vendorId: _toInt(j['vendor_id']),
    products: ((j['products'] as List?) ?? [])
        .map((e) => VcpProduct.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// ---------- Product ----------
class VcpProduct {
  final int id;
  final String name;
  final String description;
  final double regularPrice;
  final double sellPrice;
  final int discount;
  final String image;
  final List<String> color;
  final List<String> size;
  final int vendorId;
  final int categoryId;

  VcpProduct({
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
    required this.categoryId,
  });

  factory VcpProduct.fromJson(Map<String, dynamic> j) => VcpProduct(
    id: _toInt(j['id']),
    name: j['name']?.toString() ?? '',
    description: j['description']?.toString() ?? '',
    regularPrice: _toDouble(j['regular_price']),
    sellPrice: _toDouble(j['sell_price']),
    discount: _toInt(j['discount']),
    image: j['image']?.toString() ?? '',
    color: _normalizeList(j['color']),
    size: _normalizeList(j['size']),
    vendorId: _toInt(j['vendor_id']),
    categoryId: _toInt(j['category_id']),
  );
}

/// ---------- Vendor (brief) ----------
class VcpVendor {
  final int id;
  final String businessName;
  final String country;

  VcpVendor({required this.id, required this.businessName, required this.country});

  factory VcpVendor.fromJson(Map<String, dynamic> j) => VcpVendor(
    id: _toInt(j['id']),
    businessName: (j['business_name'] ?? '').toString(),
    country: (j['country'] ?? '').toString(),
  );
}

/// ---------- helpers ----------
int _toInt(dynamic v) => v == null
    ? 0
    : v is int
    ? v
    : int.tryParse(v.toString()) ?? 0;

double _toDouble(dynamic v) => v == null
    ? 0.0
    : v is num
    ? v.toDouble()
    : double.tryParse(v.toString()) ?? 0.0;

/// color/size: ["yellow,blue"] বা ["L","XL"] — দুটোই হ্যান্ডেল
List<String> _normalizeList(dynamic v) {
  final out = <String>[];
  if (v == null) return out;
  if (v is List) {
    for (final e in v) {
      final s = e?.toString() ?? '';
      if (s.contains(',')) {
        out.addAll(s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
      } else if (s.trim().isNotEmpty) {
        out.add(s.trim());
      }
    }
  } else {
    final s = v.toString();
    out.addAll(s.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty));
  }
  return out;
}