import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/common_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/model/vendor_affiliate_link_model.dart';

/// GET api/affiliate/driver-links/{driverId} — same structure as vendor-links
final driverAffiliateLinksProvider =
    FutureProvider.autoDispose.family<List<VendorAffiliateLinkModel>, int>(
  (ref, driverId) async {
    final token = await ref.watch(authTokenProvider.future);
    if (token == null || token.isEmpty) throw Exception('Not logged in');

    final uri = Uri.parse(CommonAPIController.affiliateDriverLinks(driverId));
    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'token': token},
    );

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      final msg = map['message']?.toString() ?? 'Failed to load links';
      throw Exception(msg);
    }

    final data = map['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(VendorAffiliateLinkModel.fromJson)
        .toList();
  },
);

/// POST api/affiliate/generate-referral-link-driver (or same endpoint with driver params)
/// Body: affiliate_code, driver_id, driver_affiliate_link_id, destination_url
Future<Map<String, dynamic>> generateReferralLinkForDriver(
  String? token, {
  required String affiliateCode,
  required int driverId,
  required int driverAffiliateLinkId,
  required String destinationUrl,
}) async {
  if (token == null || token.isEmpty) throw Exception('Not logged in');

  final uri = Uri.parse(CommonAPIController.affiliateGenerateReferralLinkDriver);
  final body = <String, dynamic>{
    'affiliate_code': affiliateCode,
    'driver_id': driverId,
    'driver_affiliate_link_id': driverAffiliateLinkId,
    'destination_url': destinationUrl,
  };

  final res = await http.post(
    uri,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'token': token,
    },
    body: jsonEncode(body),
  );

  final map = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200 || res.statusCode == 201) {
    return map;
  }
  final msg = map['message']?.toString() ?? 'Failed to generate referral link';
  throw Exception(msg);
}
