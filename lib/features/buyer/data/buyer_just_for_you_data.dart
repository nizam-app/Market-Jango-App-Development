import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/features/buyer/model/buyer_top_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for paginated "Just For You" products
final justForYouProvider =
    AsyncNotifierProvider<JustForYouNotifier, TopProductsResponse?>(
      JustForYouNotifier.new,
    );

class JustForYouNotifier extends AsyncNotifier<TopProductsResponse?> {
  int _page = 1;

  int get currentPage => _page;

  @override
  Future<TopProductsResponse?> build() async {
    return _fetchJustForYou();
  }

  /// Move to a different page and reload
  Future<void> changePage(int newPage) async {
    _page = newPage;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchJustForYou);
  }

  /// Core network call
  Future<TopProductsResponse> _fetchJustForYou() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final uri = Uri.parse('${BuyerAPIController.just_for_you}?page=$_page');

    final res = await http.get(
      uri,
      headers: {if (token != null) 'token': token},
    );

    if (res.statusCode == 200) {
      return TopProductsResponse.fromJson(jsonDecode(res.body));
    } else {
      throw Exception(
        'Failed to fetch Just For You items: ${res.statusCode} ${res.reasonPhrase}',
      );
    }
  }
}
