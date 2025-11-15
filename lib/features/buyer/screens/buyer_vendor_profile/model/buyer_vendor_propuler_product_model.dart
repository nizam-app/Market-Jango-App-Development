import 'dart:convert';

PopularProductsResponse popularProductsResponseFromJson(String s) =>
    PopularProductsResponse.fromJson(jsonDecode(s));

class PopularProductsResponse {
  final String status;
  final String? message;
  final List<PopularItem> data;

  PopularProductsResponse({
    required this.status,
    this.message,
    required this.data,
  });

  factory PopularProductsResponse.fromJson(Map<String, dynamic> j) =>
      PopularProductsResponse(
        status: (j['status'] ?? '').toString(),
        message: j['message']?.toString(),
        data: ((j['data'] as List?) ?? [])
            .map((e) => PopularItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class PopularItem {
  final PProduct product;
  final int soldQty;

  PopularItem({required this.product, required this.soldQty});

  factory PopularItem.fromJson(Map<String, dynamic> j) => PopularItem(
    product: PProduct.fromJson(j['product'] as Map<String, dynamic>),
    soldQty: _toInt(j['sold_qty']),
  );
}

class PProduct {
  final int id;
  final String name;
  final String description;
  final double regularPrice;
  final double sellPrice;
  final int discount;
  final String publicId;
  final int star;
  final String image;
  final List<String> color; // normalized
  final List<String> size; // normalized
  final String remark;
  final int isActive;
  final int vendorId;
  final int categoryId;
  final String? createdAt;
  final String? updatedAt;

  PProduct({
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
    this.createdAt,
    this.updatedAt,
  });

  factory PProduct.fromJson(Map<String, dynamic> j) => PProduct(
    id: _toInt(j['id']),
    name: (j['name'] ?? '').toString(),
    description: (j['description'] ?? '').toString(),
    regularPrice: _toDouble(j['regular_price']),
    sellPrice: _toDouble(j['sell_price']),
    discount: _toInt(j['discount']),
    publicId: (j['public_id'] ?? '').toString(),
    star: _toInt(j['star']),
    image: (j['image'] ?? '').toString(),
    color: _normalizeList(j['color']),
    size: _normalizeList(j['size']),
    remark: (j['remark'] ?? '').toString(),
    isActive: _toInt(j['is_active']),
    vendorId: _toInt(j['vendor_id']),
    categoryId: _toInt(j['category_id']),
    createdAt: j['created_at']?.toString(),
    updatedAt: j['updated_at']?.toString(),
  );
}

int _toInt(dynamic v) =>
    v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);

double _toDouble(dynamic v) => v == null
    ? 0.0
    : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);

/// Accepts ["a,b,c"] or ["a","b","c"] or null -> always List<String>
List<String> _normalizeList(dynamic v) {
  final out = <String>[];
  if (v == null) return out;
  if (v is List) {
    for (final e in v) {
      final s = (e ?? '').toString();
      if (s.contains(',')) {
        out.addAll(
          s.split(',').map((x) => x.trim()).where((x) => x.isNotEmpty),
        );
      } else if (s.trim().isNotEmpty) {
        out.add(s.trim());
      }
    }
  } else {
    final s = v.toString();
    out.addAll(s.split(',').map((x) => x.trim()).where((x) => x.isNotEmpty));
  }
  return out;
}
