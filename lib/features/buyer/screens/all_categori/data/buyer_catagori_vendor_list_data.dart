import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/buyer/screens/all_categori/model/buyer_category_vendor_model.dart';

/// GET /api/vendor/list/{limit}
class VendorService {
  static Future<List<VendorMini>> list({required int limit, required String token}) async {
    // if you already have a helper, expose a method like:
    // final uri = BuyerAPIController.vendorList(limit);
    final uri = Uri.parse('${BuyerAPIController.vendor_list(limit)}');

    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token.isNotEmpty) 'token': token,
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Vendor list failed: ${res.statusCode} ${res.reasonPhrase}');
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (map['data'] as List).cast<Map<String, dynamic>>();
    return list.map((e) => VendorMini.fromJson(e)).toList();
  }
}

/// family provider so you can control how many to fetch
final vendorsProvider = FutureProvider.family<List<VendorMini>, int>((ref, limit) async {
  final token = await ref.read(authTokenProvider.future) ?? '';
  return VendorService.list(limit: limit, token: token);
});