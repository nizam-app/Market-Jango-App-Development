// category_provider.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';

import '../../../../../core/utils/get_token_sharedpefarens.dart';
import '../model/vendor_product_catagory_model.dart';
import '../model/vendor_product_model.dart';

final categoriesProvider = FutureProvider.family<PaginatedCategories, int>((
  ref,
  page,
) async {
  final uri = Uri.parse('${VendorAPIController.vendor_product}?page=$page');
  final response = await http.get(
    uri,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      // add token header if needed
    },
  );
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return PaginatedCategories.fromJson(json['data']);
  } else {
    throw Exception('Failed to load categories');
  }
});

final productsByCategoryProvider =
    FutureProvider.family<PaginatedProducts, Map<String, int>>((
      ref,
      params,
    ) async {
      final int categoryId = params['categoryId']!;
      final int page = params['page']!;
      String urlString;
      if (categoryId == 0) {
        urlString = '${VendorAPIController.vendor_product}?page=$page';
      } else {
        urlString =
            '${VendorAPIController.vendor_product}?category_id=$categoryId&page=$page';
      }
      final uri = Uri.parse(urlString);
      final token = await ref.watch(authTokenProvider.future);
      if (token == null) throw Exception('Token not found');
      final response = await http.get(
        uri,
        headers: {
          // 'Accept': 'application/json',
          // 'Content-Type': 'application/json',
          // add token header if needed
          'token': token,
        },
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return PaginatedProducts.fromJson(json['data']);
      } else {
        throw Exception('Failed to load products by category');
      }
    });
