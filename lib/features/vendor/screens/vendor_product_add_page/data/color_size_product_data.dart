// import 'dart:convert';
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as http;
// import 'package:market_jango/core/constants/api_control/vendor_api.dart';
//
// import '../../../../../core/utils/get_token_sharedpefarens.dart';
// import '../model/color_and_size_model.dart';
//
// final productAttributesProvider = FutureProvider<List<ProductAttribute>>((
//   ref,
// ) async {
//   final token = ref.watch(authTokenProvider);
//   if (token == null) throw Exception("token not found");
//   final response = await http.get(
//     Uri.parse(VendorAPIController.product_attribute_vendor),
//     headers: {'token': 'Bearer $token'},
//   );
//
//   if (response.statusCode != 200) {
//     throw Exception('Failed to fetch product attributes');
//   }
//
//   final data = json.decode(response.body)['data'] as List;
//   return data.map((e) => ProductAttribute.fromJson(e)).toList();
// });