import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/auth_api.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';

import '../model/route_model.dart';

final routeListProvider = FutureProvider<List<RouteModel>>((ref) async {
  final authStorage = AuthLocalStorage();
  final token = await authStorage.getToken();

  final response = await http.get(
    Uri.parse(AuthAPIController.route),
    headers: {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'token': token,
    },
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    
    // Handle paginated response structure: { "status": "...", "data": { "data": [...] } }
    // or simple response: { "status": "...", "data": [...] }
    dynamic dataField = decoded['data'];
    List list;
    
    if (dataField is List) {
      // Simple list structure
      list = dataField;
    } else if (dataField is Map && dataField.containsKey('data')) {
      // Paginated structure with nested data
      list = dataField['data'] ?? [];
    } else {
      list = [];
    }
    
    return list.map((e) => RouteModel.fromJson(e as Map<String, dynamic>)).toList();
  } else {
    throw Exception("Failed to load routes: ${response.statusCode} ${response.body}");
  }
});
