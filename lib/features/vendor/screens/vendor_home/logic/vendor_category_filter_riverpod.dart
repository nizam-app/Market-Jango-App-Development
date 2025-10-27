import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:market_jango/core/constants/api_control/vendor_api.dart';

import '../model/vendor_category_filter_model.dart';

class ProductService {
  final String baseUrl =
      '${VendorAPIController.vendor_category_product_filter}';

  Future<ProductResponse> fetchProductsByCategory(int categoryId) async {
    final response = await http.get(Uri.parse('$baseUrl/$categoryId'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      Logger().d(json);
      return ProductResponse.fromJson(json);
    } else {
      throw Exception('Failed to load products');
    }
  }
}

final productServiceProvider = Provider<ProductService>(
  (ref) => ProductService(),
);

final productsByCategoryProvider =
    FutureProvider.family<ProductResponse, Map<String, int>>((
      ref,
      params,
    ) async {
      final service = ref.read(productServiceProvider);
      return service.fetchProductsByCategory(params['categoryId']!);
    });
