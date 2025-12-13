// buyer_top_categories_data.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';
import 'package:market_jango/features/buyer/model/buyer_category_model.dart';

final topCategoriesProvider =
    AsyncNotifierProvider<TopCategoriesNotifier, CategoryResponse?>(
      TopCategoriesNotifier.new,
    );

class TopCategoriesNotifier extends AsyncNotifier<CategoryResponse?> {
  @override
  Future<CategoryResponse?> build() => fetchTopCategories();

  Future<CategoryResponse?> fetchTopCategories() async {
    try {
      final authStorage = AuthLocalStorage();
      final token = await authStorage.getToken();

      final res = await http.get(
        Uri.parse(BuyerAPIController.top_categories),
        headers: {
          if (token != null) 'token': token,
          'Accept': 'application/json',
        },
      );

      if (res.statusCode != 200) {
        throw Exception('Failed: ${res.statusCode} ${res.reasonPhrase}');
      }

      final decoded = jsonDecode(res.body);
      // Handle case where response might be a List or Map
      final jsonData = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{
              'status': 'success',
              'message': '',
              'data': decoded is List ? decoded : [],
            };
      
      return CategoryResponse.fromJson(jsonData);
    } catch (e) {
      throw Exception('Error loading top categories: $e');
    }
  }
}

