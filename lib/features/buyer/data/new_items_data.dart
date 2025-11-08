import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/buyer/model/buyer_top_model.dart';

/// 🔹 Provider for paginated "Buyer New Items"
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

  /// Core data fetch (with token and pagination)
  Future<TopProductsResponse> _fetchNewItems() async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final uri = Uri.parse('${BuyerAPIController.new_items}?page=$_page');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'token': token},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return TopProductsResponse.fromJson(jsonData);
    } else {
      throw Exception(
        'Failed to load new items: ${response.statusCode} ${response.reasonPhrase}',
      );
    }
  }
}
