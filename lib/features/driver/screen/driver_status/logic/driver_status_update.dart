// driver_tracking_provider.dart

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/driver_api.dart';
import 'package:market_jango/features/driver/screen/driver_order/model/driver_order_details_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  if (response.statusCode != 200) {
    throw Exception('Failed to load tracking data (${response.statusCode})');
  }

  final decoded = jsonDecode(response.body) as Map<String, dynamic>;
  final dataJson = decoded['data'] as Map<String, dynamic>?;

  if (dataJson == null) {
    throw Exception('Invalid response: data is null');
  }

  return DriverTrackingData.fromJson(dataJson);
});

/// ================== UPDATE STATUS service ==================

final driverTrackingServiceProvider = Provider<DriverTrackingService>(
  (ref) => DriverTrackingService(ref),
);

class DriverTrackingService {
  DriverTrackingService(this.ref);
  final Ref ref;

  /// PUT {{baseurl}}/api/driver/invoice/update-status/{id}
  Future<DriverTrackingData> updateStatus({
    required int id,
    required String status, // "On The Way" | "Complete" | "Not Deliver"
    String? note,
    double? currentLatitude,
    double? currentLongitude,
    String? currentAddress,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('auth token not found');
    }

    // এখানে তোমার DriverAPIController-এ একটা helper রাখো:
    // static String invoiceUpdateStatus(int id) => '$baseUrl/api/driver/invoice/update-status/$id';
    final url = Uri.parse(
      DriverAPIController.invoiceUpdateStatus(id),
    ); // <-- এটা বানিয়ে নাও

    final Map<String, dynamic> payload = {'status': status};

    if (note != null && note.trim().isNotEmpty) {
      payload['note'] = note.trim();
    }

    // Not Deliver হলে extra field গুলো পাঠাবো
    if (status == 'Not Deliver') {
      if (!payload.containsKey('note')) {
        throw Exception('Note is required for Not Deliver');
      }

      if (currentLatitude != null) {
        payload['current_latitude'] = currentLatitude.toString();
      }
      if (currentLongitude != null) {
        payload['current_longitude'] = currentLongitude.toString();
      }
      if (currentAddress != null && currentAddress.trim().isNotEmpty) {
        payload['current_address'] = currentAddress.trim();
      }
    }

    final response = await http.put(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'token': token,
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update status: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final dataJson = decoded['data'] as Map<String, dynamic>;
    final updated = DriverTrackingData.fromJson(dataJson);

    // reload tracking data
    ref.invalidate(driverTrackingProvider(id));

    return updated;
  }
}
