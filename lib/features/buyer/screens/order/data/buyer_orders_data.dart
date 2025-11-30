// lib/features/buyer/screens/order/data/buyer_orders_data.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/features/buyer/screens/order/model/order_summary.dart';
import 'package:shared_preferences/shared_preferences.dart';

final buyerOrdersProvider =
    AsyncNotifierProvider<BuyerOrdersNotifier, OrdersPageData?>(
      BuyerOrdersNotifier.new,
    );

class BuyerOrdersNotifier extends AsyncNotifier<OrdersPageData?> {
  int _page = 1;

  @override
  Future<OrdersPageData?> build() async => _fetch();

  Future<void> changePage(int newPage) async {
    if (newPage == _page) return;
    _page = newPage;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<OrdersPageData?> _fetch() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final uri = Uri.parse('${BuyerAPIController.all_order}?page=$_page');
    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'token': token,
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch orders: ${res.statusCode}');
    }

    final parsed = OrdersResponse.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
    return parsed.data; // OrdersPageData?
  }
}
