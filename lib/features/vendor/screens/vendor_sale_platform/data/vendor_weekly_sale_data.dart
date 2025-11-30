// vendor_weekly_sell_data.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/vendor/screens/vendor_sale_platform/model/vendor_weekly_sele_modle.dart';

final vendorWeeklySellProvider = FutureProvider<WeeklySellData>((ref) async {
  final token = await ref.read(authTokenProvider.future);
  if (token == null) {
    throw Exception('Auth token not found');
  }

  final uri = Uri.parse(VendorAPIController.weekly_sell);
  // e.g. static String get weeklySell => "${BaseURL.baseUrl}/api/vendor/weekly-sell";

  final res = await http.get(
    uri,
    headers: {'Accept': 'application/json', 'token': token},
  );

  if (res.statusCode != 200) {
    throw Exception('Weekly sell fetch failed: ${res.statusCode} ${res.body}');
  }

  final decoded = vendorWeeklySellResponseFromJson(res.body);
  return decoded.data;
});
