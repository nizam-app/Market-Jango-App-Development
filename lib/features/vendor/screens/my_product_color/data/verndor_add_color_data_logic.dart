import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/get_user_type.dart';
import 'package:market_jango/features/vendor/screens/product_edit/model/product_attribute_response_model.dart';

/// ================= FETCH SPECIFIC ATTRIBUTE =================

Future<VendorProductAttribute> fetchAttributeShow({
  required Ref ref,
  required int attributeId,
}) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  final token = prefs.getString("auth_token");
  if (token == null) throw Exception("Token not found");

  // e.g.  http://..../api/product-attribute/vendor/show?id=21
  final base = VendorAPIController.product_attribute_vendor_show;
  final url = Uri.parse('$base?id=$attributeId');

  final response = await http.get(
    url,
    headers: {
      'Accept': 'application/json',
      'token': token,
    },
  );

  final json = jsonDecode(response.body);

  if (response.statusCode == 200 && json['status'] == 'success') {
    final res = ProductAttributeResponse.fromJson(json);
    if (res.data.isEmpty) {
      throw Exception('No attribute found');
    }
    return res.data.first; // ekhane attribute_values list thakbe
  }

  throw Exception(json['message'] ?? 'Fetch failed');
}

/// Riverpod provider – screen theke use korbe
final attributeShowProvider =
FutureProvider.family<VendorProductAttribute, int>((ref, attributeId) {
  return fetchAttributeShow(ref: ref, attributeId: attributeId);
});
/// ================= ADD NEW COLOR =================

Future<AttributeValue> addAttributeValue({
  required WidgetRef ref,
  required String name,
  required int attributeId,
}) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  final token = prefs.getString('auth_token');

  final url = Uri.parse(VendorAPIController.attribute_value_create);

  final res = await http.post(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'token': token ?? '',
    },
    body: jsonEncode({
      'name': name,
      // 🔴 backend “21” (String) expect kore, tai toString()
      'product_attribute_id': attributeId.toString(),
    }),
  );

  final data = jsonDecode(res.body);
  return AttributeValue.fromJson(data['data']);
}



/// ================= UPDATE COLOR =================
Future<AttributeValue> updateAttributeValue({
  required WidgetRef ref,
  required int valueId,
  required String name,
}) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  final token = prefs.getString("auth_token");

  final url =
  Uri.parse("${VendorAPIController.attribute_value_update}/$valueId");

  final response = await http.post(
    url,
    headers: {"token": token!},
    body: {"name": name},
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return AttributeValue.fromJson(data["data"]);
  } else {
    throw Exception(data["message"]);
  }
}


/// ================= DELETE COLOR =================
Future<bool> deleteAttributeValue({
  required WidgetRef ref,
  required int valueId,
}) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  final token = prefs.getString("auth_token");

  final url =
  Uri.parse("${VendorAPIController.attribute_value_destroy}/$valueId");

  final response = await http.post(
    url,
    headers: {"token": token!},
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) return true;

  throw Exception(data["message"]);
}