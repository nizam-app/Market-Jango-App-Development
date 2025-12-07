// vendor_product_category_riverpod.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/utils/get_user_type.dart'; // sharedPreferencesProvider
import '../model/vendor_product_catagory_model.dart';

// ⬇️ String নেবে —> CategoryBar থেকে সরাসরি `endpoint` পাস করতে পারবে
final vendorCategoryProvider = FutureProvider.autoDispose
    .family<List<VendorCategoryModel>, String>((ref, endpoint) async {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('Token not found');

      final res = await http.get(
        Uri.parse(endpoint),
        headers: {'Accept': 'application/json', 'token': token},
      );
      if (res.statusCode != 200) {
        throw Exception('Failed: ${res.statusCode} -> ${res.body}');
      }

      final body = jsonDecode(res.body);
      final inner = body is Map ? body['data'] : body;
      final List list = inner is Map
          ? (inner['data'] ?? [])
          : (inner is List ? inner : []);

      return list
          .whereType<Map<String, dynamic>>()
          .map(VendorCategoryModel.fromJson)
          .toList();
    });
