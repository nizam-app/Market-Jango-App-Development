// lib/core/screen/global_tracking/data/tracking_details_provider.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/screen/global_tracking_screen/model/global_tracking_model.dart';

import 'package:market_jango/core/utils/get_user_type.dart';
import 'package:market_jango/core/constants/api_control/buyer_api.dart';

final trackingDetailsProvider =
FutureProvider.family<TrackingInvoice, int>((ref, int invoiceId) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final token = prefs.getString('auth_token');

  // BuyerAPIController.invoiceTrackingDetails = "http://.../api/buyer/invoice/tracking/details"
  final uri = Uri.parse(
      '${BuyerAPIController.paymen_tresponse}/$invoiceId');

  final res = await http.get(
    uri,
    headers: {
      'Accept': 'application/json',
      if (token != null) 'token': token,
    },
  );

  if (res.statusCode != 200) {
    throw Exception(
        'Failed to fetch tracking details (${res.statusCode})');
  }

  final Map<String, dynamic> decoded = jsonDecode(res.body);
  final response = TrackingDetailsResponse.fromJson(decoded);
  return response.data;
});