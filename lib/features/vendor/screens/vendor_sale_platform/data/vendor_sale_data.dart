import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/vendor/screens/vendor_sale_platform/model/vendor_sale_model.dart';

final selectedIncomeDaysProvider = StateProvider<int>((ref) => 7);

final vendorIncomeProvider = FutureProvider.family<VendorIncomeData, int>((
  ref,
  int days,
) async {
  final token = await ref.read(authTokenProvider.future);
  if (token == null) throw Exception('Token not found');

  final uri = Uri.parse(VendorAPIController.vendor_income_update(days));

  final res = await http.get(
    uri,
    headers: {'Accept': 'application/json', 'token': token},
  );

  if (res.statusCode != 200) {
    throw Exception('Failed to load income: ${res.statusCode} ${res.body}');
  }

  final decoded = vendorIncomeResponseFromJson(res.body);
  return decoded.data;
});
