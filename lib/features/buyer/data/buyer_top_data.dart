// buyer_top_data.dart
import 'dart:convert'; // <-- add this

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
        Logger().e('Top products failed: ${res.statusCode} ${res.body}');
        return []; // ❗ error holeo empty list
      }

      final body = res.body.trim();
      if (body.isEmpty || body == 'null' || body == '[]') {
        return [];
      }
      final decoded = jsonDecode(body);
      if (decoded is List) {
        if (decoded.isEmpty) return [];
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((e) => TopProduct.fromJson(e))
            .toList();
      }
      final parsed = TopProductsResponse.fromJson(
        decoded as Map<String, dynamic>,
      );
      final products = parsed.data.data;
      return products;
    } catch (e, st) {
      Logger().e('Top products error', error: e, stackTrace: st);
      // ❗ kono exception holeo empty list
      return [];
    }
  }
}
