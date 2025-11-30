// buyer_top_data.dart
import 'dart:convert'; // <-- add this

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
        Logger().e('Top products failed: ${res.statusCode} ${res.body}');
        return []; // ❗ error holeo empty list
      }

      final body = res.body.trim();
      Logger().i(body);

      // ✅ null / empty / [] hole empty list return
      if (body.isEmpty || body == 'null' || body == '[]') {
        return [];
      }

      // ekhane ashle body ekta Map expected
      // (jodi ekhaneo List ashe, shekhetreo handle korchi)
      final decoded = jsonDecode(body);

      // jodi backend sudhu list of products dei
      if (decoded is List) {
        if (decoded.isEmpty) return [];
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((e) => TopProduct.fromJson(e))
            .toList();
      }

      // normal case: object => model
      final parsed = TopProductsResponse.fromJson(
        decoded as Map<String, dynamic>,
      );

      final products = parsed.data.data
          .map((it) => it.product)
          .toList(); // tomar ager line
      return products;
    } catch (e, st) {
      Logger().e('Top products error', error: e, stackTrace: st);
      // ❗ kono exception holeo empty list
      return [];
    }
  }
}
