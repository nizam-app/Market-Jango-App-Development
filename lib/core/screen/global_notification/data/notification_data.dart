import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/notification_api.dart';
import 'dart:convert';

import 'package:market_jango/core/screen/global_notification/model/all_notification_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
  final String? token = _sharedPreferences.getString("auth_token");
  if (token == null) throw Exception('Token not found');

  final response = await http.get(
    Uri.parse(NotificationAPIController.notification),
    headers: {
        'token': token,
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    // Handle cases where 'data' might be null
    final notificationsJson = data['data'] as List? ?? [];
    return notificationsJson.map((json) => NotificationModel.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load notifications');
  }
});