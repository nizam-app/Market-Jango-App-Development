// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:logger/logger.dart';
// import 'package:market_jango/core/constants/api_control/vendor_api.dart';
// import 'package:market_jango/core/utils/get_user_type.dart';
// import 'package:market_jango/features/vendor/screens/vendor_home/model/vendor_category_filter_model.dart';
//
// class ProductService {
//   static final String baseUrl =
//       '${VendorAPIController.vendor_category_product_filter}';
//
//   static Future<ProductResponse> fetchProductsByCategory({
//     required int categoryId,
//     required ref
//    
//   }) async {
//     final prefs = await ref.watch(sharedPreferencesProvider.future);
//
//     String? token = prefs.getString('auth_token');
//     if (token == null) throw Exception("Token not found");
//
//     final url = Uri.parse('$baseUrl/$categoryId');
//     final response = await http.get(
//       url,
//       headers: {
//         'token':  token,
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final jsonBody = jsonDecode(response.body);
//       Logger().d(jsonBody);
//       return ProductResponse.fromJson(jsonBody);
//     } else {
//       throw Exception('Failed to load products: ${response.statusCode}');
//     }
//   }
// }