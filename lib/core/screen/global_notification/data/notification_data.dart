import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/notification_api.dart';
import 'package:market_jango/core/screen/global_notification/model/all_notification_model.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';

Future<Map<String, String>> _authHeaders() async {
  final authStorage = AuthLocalStorage();
  final token = await authStorage.getToken();
  if (token == null || token.isEmpty) {
    throw Exception('Not logged in');
  }
  return {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
    'token': token,
  };
}

List<dynamic> _extractNotificationList(Map<String, dynamic> top) {
  final data = top['data'];
  if (data is List) return data;
  if (data is Map<String, dynamic>) {
    final inner = data['data'];
    if (inner is List) return inner;
  }
  return [];
}

/// `GET /api/notification/` — Bearer + legacy `token` header.
Future<List<NotificationModel>> fetchNotifications() async {
  final headers = await _authHeaders();
  final response = await http.get(
    Uri.parse(NotificationAPIController.notificationList),
    headers: headers,
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Failed to load notifications (${response.statusCode})',
    );
  }

  final raw = jsonDecode(response.body) as Map<String, dynamic>;
  final list = _extractNotificationList(raw);
  return list
      .whereType<Map<String, dynamic>>()
      .map(NotificationModel.fromJson)
      .toList();
}

/// `PUT /api/notification/read/{id}`
Future<void> markNotificationRead(int id) async {
  final headers = await _authHeaders();
  final uri = Uri.parse(NotificationAPIController.notificationRead(id));
  final response = await http.put(uri, headers: headers);
  if (response.statusCode < 200 || response.statusCode >= 300) {
    debugPrint('mark read failed: ${response.statusCode} ${response.body}');
    throw Exception('Failed to mark notification read');
  }
}

final notificationProvider =
    FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  return fetchNotifications();
});

/// Unread count for bell badge (derived from last list fetch).
final notificationUnreadCountProvider = Provider<int>((ref) {
  final async = ref.watch(notificationProvider);
  return async.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
