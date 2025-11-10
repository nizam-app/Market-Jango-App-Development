// lib/features/vendor_first_product/model/vendor_first_product.dart
import 'dart:convert';

class VendorFirstProductResponse {
  final String? status;
  final String? message;
  final List<VendorFirstProduct> data;

  VendorFirstProductResponse({this.status, this.message, required this.data});

  factory VendorFirstProductResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List?) ?? const [];
    return VendorFirstProductResponse(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      data: list
          .map((e) => VendorFirstProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static VendorFirstProductResponse fromJsonString(String body) =>
      VendorFirstProductResponse.fromJson(jsonDecode(body));
}

class VendorFirstProduct {
  final int vendorId;
  final String businessName;
  final String vendorName;
  final String? vendorImage;
  final CategoryRef? category;
  final ProductLite? product;

  VendorFirstProduct({
    required this.vendorId,
    required this.businessName,
    required this.vendorName,
    required this.vendorImage,
    required this.category,
    required this.product,
  });

  factory VendorFirstProduct.fromJson(Map<String, dynamic> json) {
    return VendorFirstProduct(
      vendorId: _toInt(json['vendor_id']),
      businessName: json['business_name']?.toString() ?? '',
      vendorName: json['vendor_name']?.toString() ?? '',
      vendorImage: json['vendor_image']?.toString(),
      category: (json['category'] is Map<String, dynamic>)
          ? CategoryRef.fromJson(json['category'])
          : null,
      product: (json['product'] is Map<String, dynamic>)
          ? ProductLite.fromJson(json['product'])
          : null,
    );
  }
}

class CategoryRef {
  final int id;
  final String name;
  CategoryRef({required this.id, required this.name});
  factory CategoryRef.fromJson(Map<String, dynamic> json) =>
      CategoryRef(id: _toInt(json['id']), name: json['name']?.toString() ?? '');
}

class ProductLite {
  final int id;
  final int discount;
  final String name;
  final double regularPrice; // "233.00" -> 233.0
  final double sellPrice; // "761.00" -> 761.0
  final String image;

  ProductLite({
    required this.id,
    required this.discount,
    required this.name,
    required this.regularPrice,
    required this.sellPrice,
    required this.image,
  });

  factory ProductLite.fromJson(Map<String, dynamic> json) => ProductLite(
    id: _toInt(json['id']),
    discount: _toInt(json['discount']),
    name: json['name']?.toString() ?? '',
    regularPrice: _toDouble(json['regular_price']),
    sellPrice: _toDouble(json['sell_price']),
    image: json['image']?.toString() ?? '',
  );
}

/* helpers */
int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}
