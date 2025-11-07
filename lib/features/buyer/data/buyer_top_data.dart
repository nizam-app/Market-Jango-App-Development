// buyer_top_data.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/features/buyer/model/buyer_top_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final topProductProvider =
    AsyncNotifierProvider<TopProductNotifier, List<TopProduct>>(
      TopProductNotifier.new,
    );

class TopProductNotifier extends AsyncNotifier<List<TopProduct>> {
  @override
  Future<List<TopProduct>> build() => fetchTopProducts();

  Future<List<TopProduct>> fetchTopProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final res = await http.get(
        Uri.parse(BuyerAPIController.top_products),
        headers: {
          if (token != null) 'token': token,
          'Accept': 'application/json',
        },
      );

      if (res.statusCode != 200) {
        throw Exception('Failed: ${res.statusCode} ${res.reasonPhrase}');
      }

      // ✔️ পুরো রেসপন্স মডেলে পার্স করি
      Logger().i(res.body);
      final parsed = TopProductsResponse.fromRawJson(res.body);

      // ✔️ প্রতিটি item থেকে শুধুই product নাও
      final products = parsed.data.data.map((it) => it.product).toList();
      return products;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
