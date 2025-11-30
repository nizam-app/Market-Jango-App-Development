// driver_status_update.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/driver_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

final driverTrackingServiceProvider = Provider<DriverTrackingService>(
  (ref) => DriverTrackingService(ref),
);

class DriverTrackingService {
  DriverTrackingService(this.ref);
  final Ref ref;

  Future<void> updateStatus({
    required int id,
    required String status,
    required String note,
    double? currentLatitude,
    double? currentLongitude,
    String? currentAddress,
    String? paymentProofId, // 🔥 new
  }) async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null) throw Exception('Token not found');

    final body = <String, dynamic>{
      'status': status,
      'note': note,
      if (currentLatitude != null)
        'current_latitude': currentLatitude.toString(),
      if (currentLongitude != null)
        'current_longitude': currentLongitude.toString(),
      if (currentAddress != null && currentAddress.isNotEmpty)
        'current_address': currentAddress,
      if (paymentProofId != null && paymentProofId.isNotEmpty)
        'payment_proof_id': paymentProofId, // 🔥 OPU cash proof
    };

    final res = await http.put(
      Uri.parse(DriverAPIController.invoiceUpdateStatus(id)),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'token': token,
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('Update failed: ${res.statusCode} ${res.body}');
    }
  }
}
