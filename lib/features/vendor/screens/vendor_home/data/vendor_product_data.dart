import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';

import '../../../../../core/utils/get_token_sharedpefarens.dart';
import '../model/vendor_product_model.dart';

final String _baseUrl = VendorAPIController.vendor_product;

final productsProvider = FutureProvider.family<PaginatedProducts, int>((
  ref,
  page,
) async {
  // read token from shared preferences or wherever you store it
  final token = await ref.read(authTokenProvider.future);
  final uri = Uri.parse('$_baseUrl?page=$page');

  if (token == null) throw Exception('Token not found');
  final response = await http.get(
    uri,
    headers: {
      // 'Accept': 'application/json',
      // 'Content‑Type': 'application/json',
      'token': token,
    },
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    return PaginatedProducts.fromJson(body['data']);
  } else {
    throw Exception('Failed to fetch products. Status: ${response.statusCode}');
  }
});
