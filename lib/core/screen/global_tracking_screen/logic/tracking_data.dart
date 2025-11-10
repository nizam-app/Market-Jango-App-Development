// lib/features/buyer/data/invoice_tracking_data.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/screen/global_tracking_screen/model/tracking_model.dart';

import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

/// Family provider: invoiceId দিয়ে কল করো
final invoiceTrackingProvider = FutureProvider.family<InvoiceTracking, int>((ref, invoiceId) async {
  final token = await ref.read(authTokenProvider.future);
  if (token == null || token.isEmpty) {
    throw Exception('No authentication token found');
  }

  final uri = Uri.parse('${BuyerAPIController.invoice_tracking(invoiceId)}');

  final res = await http.get(
    uri,
    headers: {
      'Accept': 'application/json',
      'token': token, // <- header key per your screenshot
    },
  );

  if (res.statusCode != 200) {
    throw Exception('Failed: ${res.statusCode} ${res.reasonPhrase}');
  }

  final map = jsonDecode(res.body) as Map<String, dynamic>;
  final parsed = InvoiceTrackingResponse.fromJson(map);
  return parsed.data;
});

/// আলাদা ফাংশন দরকার হলে:
Future<InvoiceTracking> fetchInvoiceTracking({
  required String baseUrl,
  required int invoiceId,
  required String token,
}) async {
  final uri = Uri.parse('$baseUrl/api/invoice/tracking/$invoiceId');
  final res = await http.get(uri, headers: {
    'Accept': 'application/json',
    'token': token,
  });

  if (res.statusCode != 200) {
    throw Exception('Failed: ${res.statusCode} ${res.reasonPhrase}');
  }

  final map = jsonDecode(res.body) as Map<String, dynamic>;
  return InvoiceTrackingResponse.fromJson(map).data;
}