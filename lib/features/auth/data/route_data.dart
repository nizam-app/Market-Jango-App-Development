import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/auth_api.dart';

import '../model/route_model.dart';

final routeListProvider = FutureProvider<List<RouteModel>>((ref) async {
  final response = await http.get(Uri.parse(AuthAPIController.route));

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    final List list = decoded['data'];
    return list.map((e) => RouteModel.fromJson(e)).toList();
  } else {
    throw Exception("Failed to load routes");
  }
});
