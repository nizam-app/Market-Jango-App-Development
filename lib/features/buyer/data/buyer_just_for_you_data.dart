import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/utils/auth_local_storage.dart';
import 'package:market_jango/features/buyer/model/buyer_top_model.dart';

/// family: এখন স্ক্রিন থেকে url পাঠানো যাবে
final justForYouProvider = AsyncNotifierProvider.family<
    JustForYouNotifier, TopProductsResponse?, String>(
  JustForYouNotifier.new,
);

class JustForYouNotifier
    extends FamilyAsyncNotifier<TopProductsResponse?, String> {
  int _page = 1;
  late String _baseUrl;

  int get currentPage => _page;

  @override
  Future<TopProductsResponse?> build(String baseUrl) async {
    _baseUrl = baseUrl;             // স্ক্রিন থেকে আসা URL ধরে রাখছি
    return _fetch();
  }

  Future<void> changePage(int newPage) async {
    _page = newPage;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<TopProductsResponse> _fetch() async {
    final authStorage = AuthLocalStorage();
    final token = await authStorage.getToken();

    // baseUrl-এ আগেই query থাকলে মর্জ করে page বসাচ্ছি
    final base = Uri.parse(_baseUrl);
    final qp = Map<String, String>.from(base.queryParameters);
    qp['page'] = '$_page';
    final uri = base.replace(queryParameters: qp);

    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'token': token,
      },
    );

    if (res.statusCode == 200) {
      return TopProductsResponse.fromJson(jsonDecode(res.body));
    } else {
      throw Exception(
        'Failed: ${res.statusCode} ${res.reasonPhrase}',
      );
    }
  }
}