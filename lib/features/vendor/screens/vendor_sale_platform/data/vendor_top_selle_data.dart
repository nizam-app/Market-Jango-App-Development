// vendor_top_products_data.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

import '../model/vendor_top_selle_model.dart';

/// GET {{baseurl}}/api/vendor/sell-top-product
final vendorTopProductsProvider = FutureProvider<VendorTopSelleData>((
  ref,
) async {
  final token = await ref.read(authTokenProvider.future);
  if (token == null) throw Exception('Auth token not found');

  final uri = Uri.parse(VendorAPIController.sell_top_product);
  // e.g. static String get sellTopProduct => '${BaseURL.baseUrl}/api/vendor/sell-top-product';

  final res = await http.get(
    uri,
    headers: {'Accept': 'application/json', 'token': token},
  );

  if (res.statusCode != 200) {
    throw Exception('Top products fetch failed: ${res.statusCode} ${res.body}');
  }

  final parsed = vendorTopProductsResponseFromJson(res.body);
  return parsed.data;
});
