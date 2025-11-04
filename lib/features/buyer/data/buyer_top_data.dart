import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/features/buyer/model/buyer_top_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

final topProductProvider =
AsyncNotifierProvider<TopProductNotifier, List<Product>>(TopProductNotifier.new);

class TopProductNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async {
    return await fetchTopProducts();
  }

  Future<List<Product>> fetchTopProducts() async {
    try {
      // 1️⃣ Token load from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // 2️⃣ API call
      final response = await http.get(
        Uri.parse(BuyerAPIController.top_products),
        headers: {
         if (token != null)   'token': token,
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List products = jsonData['data']['data'];

        Logger().e(jsonData);
        return products.map((e) => Product.fromJson(e)).toList();
   
      } else {
        throw Exception('Failed to fetch products');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}