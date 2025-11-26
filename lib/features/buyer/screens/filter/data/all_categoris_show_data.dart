// file: lib/features/buyer/data/location_category_provider.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_user_type.dart';
import 'package:market_jango/features/buyer/screens/filter/model/all_categoris_show_model.dart';



/// GET {{baseurl}}/api/category
final locationCategoriesProvider =
FutureProvider<LocationCategoryPage>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final token = prefs.getString('auth_token');

  final uri = Uri.parse(BuyerAPIController.category); // <-- api/category
  final res = await http.get(
    uri,
    headers: {
      'Accept': 'application/json',
      if (token != null) 'token': token,
    },
  );

  if (res.statusCode != 200) {
    throw Exception('Failed to fetch categories (${res.statusCode})');
  }

  final json = jsonDecode(res.body) as Map<String, dynamic>;
  final response = LocationCategoryResponse.fromJson(json);
  return response.data; // LocationCategoryPage
});