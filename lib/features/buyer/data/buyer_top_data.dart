// buyer_top_data.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';
import 'package:market_jango/features/buyer/model/buyer_top_model.dart';

final topProductProvider =
    AsyncNotifierProvider<TopProductNotifier, List<TopProduct>>(
      TopProductNotifier.new,
    );

class TopProductNotifier extends AsyncNotifier<List<TopProduct>> {
  @override
  Future<List<TopProduct>> build() => fetchTopProducts();

  Future<List<TopProduct>> fetchTopProducts() async {
    try {
      final authStorage = AuthLocalStorage();
      final token = await authStorage.getToken();

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
      
      Logger().i(res.body);
      final parsed = TopProductsResponse.fromRawJson(res.body);

      // ✔️ data array contains TopProduct directly
      return parsed.data.data;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}