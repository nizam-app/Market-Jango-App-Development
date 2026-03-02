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
      final url = BuyerAPIController.top_products;
      Logger().d('Top products: GET $url (token: ${token != null ? "yes" : "no"})');

      final res = await http.get(
        Uri.parse(url),
        headers: {
          if (token != null) 'token': token,
          'Accept': 'application/json',
        },
      );

      Logger().d('Top products: status=${res.statusCode} bodyLen=${res.body.length}');

      if (res.statusCode != 200) {
        Logger().e('Top products failed: ${res.statusCode} body=${res.body.length > 200 ? res.body.substring(0, 200) + "..." : res.body}');
        return [];
      }

      final body = res.body.trim();
      if (body.isEmpty || body == 'null' || body == '[]') {
        Logger().w('Top products: empty body');
        return [];
      }
      final decoded = jsonDecode(body);
      List<TopProduct> products;
      if (decoded is List) {
        if (decoded.isEmpty) return [];
        products = decoded
            .whereType<Map<String, dynamic>>()
            .map((e) => TopProduct.fromJson(e))
            .toList();
      } else {
        final parsed = TopProductsResponse.fromJson(
          decoded as Map<String, dynamic>,
        );
        products = parsed.data.data;
      }
      Logger().i('Top products: loaded ${products.length} items');
      return products;
    } catch (e, st) {
      Logger().e('Top products parse error', error: e, stackTrace: st);
      return [];
    }
  }
}
