// vendor_product_category_riverpod.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/utils/auth_local_storage.dart';
import '../model/vendor_product_catagory_model.dart';

// ⬇️ String নেবে —> CategoryBar থেকে সরাসরি `endpoint` পাস করতে পারবে
final vendorCategoryProvider = FutureProvider.autoDispose
    .family<List<VendorCategoryModel>, String>((ref, endpoint) async {
      final authStorage = AuthLocalStorage();
      final token = await authStorage.getToken();
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
      
      // Safely extract list - ensure we never use a Map as a List
      List<dynamic> list = [];
      if (inner is Map) {
        final dataField = inner['data'];
        if (dataField is List) {
          list = dataField;
        }
      } else if (inner is List) {
        list = inner;
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map(VendorCategoryModel.fromJson)
          .toList();
    });
