// lib/features/buyer/screens/review/data/vendor_review_data.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/features/buyer/screens/review/model/buyer_review_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<VendorReviewsPage> fetchVendorReviews({
  required int vendorId,
  int page = 1,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  final uri = Uri.parse(
    '${BuyerAPIController.review_vendor(vendorId)}?page=$page',
  );

  final res = await http.get(
    uri,
    headers: {'Accept': 'application/json', if (token != null) 'token': token},
  );

  if (res.statusCode != 200) {
    throw Exception('Failed to load reviews (${res.statusCode})');
  }

  final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
  final parsed = VendorReviewsResponse.fromJson(jsonMap);

  final pageData = parsed.data;
  if (pageData == null) {
    throw Exception('No page data in response');
  }
  return pageData;
}
