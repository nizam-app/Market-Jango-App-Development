// vendor_top_products_model.dart
import 'dart:convert';

VendorTopProductsResponse vendorTopProductsResponseFromJson(String s) =>
    VendorTopProductsResponse.fromJson(jsonDecode(s) as Map<String, dynamic>);

class VendorTopProductsResponse {
  final String status;
  final String? message;
  final VendorTopSelleData data;

  VendorTopProductsResponse({
    required this.status,
    this.message,
    required this.data,
  });

  factory VendorTopProductsResponse.fromJson(Map<String, dynamic> j) {
    // API: { status, message, data: { products: [ ... ] } }
    final dataMap = j['data'] as Map<String, dynamic>? ?? {};
    return VendorTopProductsResponse(
      status: (j['status'] ?? '').toString(),
      message: j['message']?.toString(),
      data: VendorTopSelleData.fromJson(dataMap),
    );
  }
}

class VendorTopSelleData {
  final List<TopProductItem> products;

  VendorTopSelleData({required this.products});

  factory VendorTopSelleData.fromJson(Map<String, dynamic> j) {
    final list = (j['products'] as List? ?? [])
        .map((e) => TopProductItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return VendorTopSelleData(products: list);
  }
}

class TopProductItem {
  final int? productId;
  final String name;
  final int totalQuantity;
  final double totalRevenue;

  TopProductItem({
    required this.productId,
    required this.name,
    required this.totalQuantity,
    required this.totalRevenue,
  });

  factory TopProductItem.fromJson(Map<String, dynamic> j) {
    return TopProductItem(
      productId: j['product_id'] == null ? null : _toInt(j['product_id']),
      name: (j['name'] ?? '').toString(),
      totalQuantity: _toInt(j['total_quantity']),
      totalRevenue: _toDouble(j['total_revenue']),
    );
  }
}

int _toInt(dynamic v) =>
    v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);

double _toDouble(dynamic v) => v == null
    ? 0.0
    : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);
