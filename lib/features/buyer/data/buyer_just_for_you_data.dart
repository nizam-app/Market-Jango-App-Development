import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';
import 'package:market_jango/features/buyer/model/buyer_top_model.dart';

/// family: এখন স্ক্রিন থেকে url পাঠানো যাবে
final justForYouProvider =
    AsyncNotifierProvider.family<
      JustForYouNotifier,
      TopProductsResponse?,
      String
    >(JustForYouNotifier.new);

class JustForYouNotifier
    extends FamilyAsyncNotifier<TopProductsResponse?, String> {
  int _page = 1;
  late String _baseUrl;

  int get currentPage => _page;

  @override
  Future<TopProductsResponse?> build(String baseUrl) async {
    _baseUrl = baseUrl; // স্ক্রিন থেকে আসা URL ধরে রাখছি
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

    final base = Uri.parse(_baseUrl);
    final qp = Map<String, String>.from(base.queryParameters);
    qp['page'] = '$_page';
    final uri = base.replace(queryParameters: qp);

    Logger().d('Just for you: GET $uri (token: ${token != null ? "yes" : "no"})');

    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null) 'token': token,
      },
    );

    Logger().d('Just for you: status=${res.statusCode} bodyLen=${res.body.length}');

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final jsonData = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{
              'status': 'success',
              'message': '',
              'data': decoded is List ? decoded : [],
            };
      final result = TopProductsResponse.fromJson(jsonData);
      Logger().i('Just for you: loaded ${result.data.data.length} items');
      return result;
    } else {
      Logger().e('Just for you failed: ${res.statusCode} ${res.body.length > 200 ? res.body.substring(0, 200) + "..." : res.body}');
      throw Exception('Failed: ${res.statusCode} ${res.reasonPhrase}');
    }
  }
}
