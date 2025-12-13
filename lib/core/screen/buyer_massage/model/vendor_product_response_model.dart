import 'package:market_jango/features/vendor/screens/vendor_home/model/vendor_product_model.dart';

class VendorProductResponse {
  final List<VendorProduct> products;
  final int currentPage;
  final int lastPage;
  final int total;

  VendorProductResponse({
    required this.products,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory VendorProductResponse.fromJson(Map<String, dynamic> json) {
    return VendorProductResponse(
      products: (json['data'] as List? ?? json['products'] as List? ?? [])
          .map((e) => VendorProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: json['current_page'] ?? json['currentPage'] ?? 1,
      lastPage: json['last_page'] ?? json['lastPage'] ?? 1,
      total: json['total'] ?? 0,
    );
  }
}

