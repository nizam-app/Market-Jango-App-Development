// lib/features/vendor_first_product/data/vendor_first_product_provider.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/features/buyer/screens/all_categori/model/vendor_first_product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final vendorFirstProductProvider =
    AsyncNotifierProvider<VendorFirstProductNotifier, List<VendorFirstProduct>>(
      VendorFirstProductNotifier.new,
    );

class VendorFirstProductNotifier
    extends AsyncNotifier<List<VendorFirstProduct>> {
  @override
  Future<List<VendorFirstProduct>> build() async => _fetch();

  Future<List<VendorFirstProduct>> _fetch() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final uri = Uri.parse(BuyerAPIController.vendor_first_product);

    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'token': token,
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed: ${res.statusCode}');
    }

    final parsed = VendorFirstProductResponse.fromJson(jsonDecode(res.body));
    // keep only those with a product present
    return parsed.data.where((e) => e.product != null).toList();
  }

  Future<void> refreshNow() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
