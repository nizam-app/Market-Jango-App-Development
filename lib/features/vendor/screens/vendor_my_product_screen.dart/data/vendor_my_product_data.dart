// import 'dart:convert';
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as http;
// import 'package:market_jango/core/constants/api_control/vendor_api.dart';
// import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
//
// import '../model/vendor_my_product_attribute_model.dart';
//
// final vendorAttributesProvider =
// FutureProvider<List<MyProductAttribute>>((ref) async {
//   final token = await ref.read(authTokenProvider.future);
//   if (token == null) {
//     throw Exception('Token not found');
//   }
//
//   // <- এখানে তোমার endpoint constant use করবে
//   final url = VendorAPIController.productAttributeVendor;
//   final res = await http.get(
//     Uri.parse(url),
//     headers: {
//       'Accept': 'application/json',
//       'token': token,
//     },
//   );
//
//   if (res.statusCode != 200) {
//     throw Exception('Fetch failed: ${res.statusCode} ${res.body}');
//   }
//
//   final decoded = jsonDecode(res.body) as Map<String, dynamic>;
//   final apiRes = ProductAttributeResponse.fromJson(decoded);
//
//   if (apiRes.status.toLowerCase() != 'success') {
//     throw Exception(apiRes.message);
//   }
//
//   return apiRes.data; // List<ProductAttribute>
// });