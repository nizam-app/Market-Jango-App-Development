import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/features/vendor/screens/vendor_home/model/vendor_serach_model.dart';
import '../../../../../core/utils/get_token_sharedpefarens.dart';


final searchProvider =
FutureProvider.autoDispose.family<SearchResponse, String>((ref, query) async {
  if (query.isEmpty) return SearchResponse(products: []);
  final token = await ref.read(authTokenProvider.future);
  if (token == null) throw Exception('Token not found');

  final url = 'http://103.208.183.253:8000/api/vendor/search-by-vendor?query=$query';
  final response = await http.get(Uri.parse(url), headers: {'token': token});

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    return SearchResponse.fromJson(body);
  } else {
    throw Exception('Search failed: ${response.statusCode}');
  }
});