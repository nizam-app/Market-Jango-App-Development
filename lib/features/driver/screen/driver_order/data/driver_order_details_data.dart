// driver_tracking_provider.dart

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/driver_api.dart';
import 'package:market_jango/features/driver/screen/driver_order/model/driver_order_details_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// GET {{baseurl}}/api/driver/invoice/tracking/{id}
final driverTrackingProvider = FutureProvider.family<DriverTrackingData, int>((
  ref,
  int trackingId,
) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token == null) {
    throw Exception('auth token not found');
  }

  final url = Uri.parse("${DriverAPIController.invoiceTracking}/$trackingId");

  final response = await http.get(
    url,
    headers: {'Accept': 'application/json', 'token': token},
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final dataJson = decoded['data'] as Map<String, dynamic>?;

    if (dataJson == null) {
      throw Exception('Invalid response: data is null');
    }

    return DriverTrackingData.fromJson(dataJson);
  } else {
    throw Exception('Failed to load tracking data (${response.statusCode})');
  }
});
