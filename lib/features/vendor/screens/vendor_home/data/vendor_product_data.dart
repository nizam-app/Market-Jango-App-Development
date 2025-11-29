// import 'dart:convert';
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as http;
// import 'package:logger/logger.dart';
// import 'package:market_jango/core/constants/api_control/vendor_api.dart';
//
// import '../../../../../core/utils/get_token_sharedpefarens.dart';
// import '../model/vendor_product_model.dart';
//
// final String _baseUrl = VendorAPIController.vendor_product;
// final String _baseUrlCategory = VendorAPIController.vendor_category_product_filter;
//
//
// // final productsProvider = FutureProvider.family<PaginatedProducts, int>((
// //   ref,
// //   page,
// // ) async {
// //   // read token from shared preferences or wherever you store it
// //   final token = await ref.read(authTokenProvider.future);
// //   final uri = Uri.parse('$_baseUrl?page=$page');
// //
// //   if (token == null) throw Exception('Token not found');
// //   final response = await http.get(
// //     uri,
// //     headers: {
// //       // 'Accept': 'application/json',
// //       // 'Content‑Type': 'application/json',
// //       'token': token,
// //     },
// //   );
// //
// //   if (response.statusCode == 200) {
// //     final body = jsonDecode(response.body);
// //     return PaginatedProducts.fromJson(body['data']);
// //   } else {
// //     throw Exception('Failed to fetch products. Status: ${response.statusCode}');
// //   }
// // });
// final productsProvider = FutureProvider.family
//     .autoDispose<PaginatedProducts, Map<String, int>>((ref, params) async {
//   final page = params['page'] ?? 1;
//   final categoryId = params['categoryId'] ?? 0;
//
//   final token = await ref.read(authTokenProvider.future);
//   if (token == null) throw Exception('Token not found');
//
//   // যদি categoryId = 0 হয় (মানে All), তাহলে base URL-এ কোনো filter না পাঠাও
//   final uri = categoryId == 0
//       ? Uri.parse('$_baseUrl?page=$page')
//       : Uri.parse('$_baseUrlCategory/$categoryId?page=$page');
//
//   final response = await http.get(uri, headers: {'token': token});
//
//   if (response.statusCode == 200) {
//     final body = jsonDecode(response.body);
//     Logger().d(body);
//     return PaginatedProducts.fromJson(body['data']);
//   } else {
//     throw Exception('Failed to fetch products: ${response.statusCode}');
//   }
// });

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../../../../../core/constants/api_control/vendor_api.dart';
import '../../../../../core/utils/get_token_sharedpefarens.dart';
import '../model/vendor_product_model.dart';

final productNotifierProvider =
AsyncNotifierProvider<ProductNotifier, PaginatedProducts?>(ProductNotifier.new);

class ProductNotifier extends AsyncNotifier<PaginatedProducts?> {
  int _categoryId = 0;
  int _page = 1;

  int get categoryId => _categoryId;
  int get currentPage => _page;

  @override
  Future<PaginatedProducts?> build() async {
    return _fetchProducts();
  }

  Future<void> changeCategory(int newCategoryId) async {
    _categoryId = newCategoryId;
    _page = 1;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchProducts());
  }

  Future<void> changePage(int newPage) async {
    _page = newPage;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchProducts());
  }

  Future<PaginatedProducts> _fetchProducts() async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null) throw Exception('Token not found');

    final baseUrl = VendorAPIController.vendor_product;
    final categoryUrl = VendorAPIController.vendor_category_product_filter;

    final uri = _categoryId == 0
        ? Uri.parse('$baseUrl?page=$_page')
        : Uri.parse('$categoryUrl/$_categoryId?page=$_page');

    final response = await http.get(uri, headers: {'token': token});
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data'];
      
      if (data == null) {
        return PaginatedProducts(
          currentPage: 1,
          lastPage: 1,
          products: [],
          total: 0
        );
      }
      // ✅ Only use products block now
      final productBlock = data['products'];

      if (productBlock == null) {
        return PaginatedProducts(
          currentPage: 1,
          lastPage: 1,
          products: [],
          total: 0
        );
      }
      
      return    PaginatedProducts.fromJson(productBlock);
        // PaginatedProducts.fromJson(body['data']);
    } else {
      throw Exception('Failed to fetch products: ${response.statusCode}');
    }
  }
}