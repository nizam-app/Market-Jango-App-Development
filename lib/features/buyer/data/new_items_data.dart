import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';
import 'package:market_jango/features/buyer/model/buyer_top_model.dart';

final buyerNewItemsProvider =
    AsyncNotifierProvider<BuyerNewItemsNotifier, TopProductsResponse?>(
      BuyerNewItemsNotifier.new,
    );

class BuyerNewItemsNotifier extends AsyncNotifier<TopProductsResponse?> {
  int _page = 1;

  int get currentPage => _page;

  @override
  Future<TopProductsResponse?> build() async {
    return _fetchNewItems();
  }

  /// Change current page & reload data
  Future<void> changePage(int newPage) async {
    _page = newPage;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchNewItems);
  }

  /// Core data fetch (token optional - matches top_products & just_for_you)
  /// API: GET /api/admin-selects/new-items?page=1
  /// Response: { status, message, data: { current_page, data: [...products] } }
  Future<TopProductsResponse> _fetchNewItems() async {
    final authStorage = AuthLocalStorage();
    final token = await authStorage.getToken();
    final uri = Uri.parse('${BuyerAPIController.new_items}?page=$_page');

    Logger().d('New items: GET $uri (token: ${token != null && token.isNotEmpty ? "yes" : "no"})');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'token': token,
      },
    );

    Logger().d('New items: status=${response.statusCode} bodyLen=${response.body.length}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final jsonData = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{
              'status': 'success',
              'message': '',
              'data': decoded is List ? decoded : [],
            };
      final result = TopProductsResponse.fromJson(jsonData);
      Logger().i('New items: loaded ${result.data.data.length} items');
      return result;
    } else {
      Logger().e('New items failed: ${response.statusCode} ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');
      throw Exception(
        'Failed to load new items: ${response.statusCode} ${response.reasonPhrase}',
      );
    }
  }
}
