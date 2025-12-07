import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/get_user_type.dart';
import 'package:market_jango/core/models/global_search_model.dart';
import '../../../../../core/utils/get_token_sharedpefarens.dart';


final searchProvider =
FutureProvider.autoDispose.family<GlobalSearchResponse, String>((ref, query) async {
  // 1) খালি কুয়েরি: সোজা empty() রেসপন্স দিন
  if (query.trim().isEmpty) return GlobalSearchResponse.empty();

  // 2) টোকেন/ইউজার টাইপ
  final token = await ref.read(authTokenProvider.future);
  if (token == null) throw Exception('Token not found');

  final userType = await ref.read(getUserTypeProvider.future);

  final vendorUrl = VendorAPIController.search_by_vendor(query);
  final buyerUrl  = BuyerAPIController.buyer_search_product(query);
  final url = (userType == 'vendor') ? vendorUrl : buyerUrl;

  // 3) API কল
  final resp = await http.get(Uri.parse(url), headers: {'token': token});

  // 4) রেসপন্স
  if (resp.statusCode == 200) {
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    return GlobalSearchResponse.fromJson(body);
  } else {
    throw Exception('Search failed: ${resp.statusCode} ${resp.body}');
  }
});