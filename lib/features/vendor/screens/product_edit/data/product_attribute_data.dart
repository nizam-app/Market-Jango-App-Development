import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';

import '../model/product_attribute_response_model.dart';

/// 🌐 API base URL
final String baseUrl = VendorAPIController.product_attribute_vendor;

final productAttributesProvider =
FutureProvider<ProductAttributeResponse>((ref) async {
  final url = Uri.parse(baseUrl);
  final authStorage = AuthLocalStorage();
  final token = await authStorage.getToken();
  if (token == null) throw Exception("Token not found");

  final response = await http.get(
    url,
    headers: {
      'token': token,
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return ProductAttributeResponse.fromJson(data);
  } else {
    throw Exception('Failed to fetch product attributes');
  }
});

/// ================= CREATE ATTRIBUTE =================
Future<VendorProductAttribute> createAttribute({
  required String name,
  required int vendorId,
}) async {
  final authStorage = AuthLocalStorage();
  final token = await authStorage.getToken();
  if (token == null) throw Exception("Token not found");

  final url = Uri.parse(VendorAPIController.product_attribute_create);

  final response = await http.post(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'token': token,
    },
    body: jsonEncode({
      'name': name,
      'vendor_id': vendorId.toString(),
    }),
  );

  final data = jsonDecode(response.body);
  if ((response.statusCode == 200 || response.statusCode == 201) && data['status'] == 'success') {
    return VendorProductAttribute.fromJson(data['data']);
  } else {
    throw Exception(data['message'] ?? 'Failed to create attribute');
  }
}

/// ================= UPDATE ATTRIBUTE =================
Future<VendorProductAttribute> updateAttribute({
  required int attributeId,
  required String name,
}) async {
  final authStorage = AuthLocalStorage();
  final token = await authStorage.getToken();
  if (token == null) throw Exception("Token not found");

  final url = Uri.parse(VendorAPIController.product_attribute_update(attributeId));

  final response = await http.put(
    url,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'token': token,
    },
    body: jsonEncode({
      'name': name,
    }),
  );

  final data = jsonDecode(response.body);
  if (response.statusCode == 200 && data['status'] == 'success') {
    return VendorProductAttribute.fromJson(data['data']);
  } else {
    throw Exception(data['message'] ?? 'Failed to update attribute');
  }
}

/// ================= DELETE ATTRIBUTE =================
Future<bool> deleteAttribute({
  required int attributeId,
}) async {
  final authStorage = AuthLocalStorage();
  final token = await authStorage.getToken();
  if (token == null) throw Exception("Token not found");

  final url = Uri.parse(VendorAPIController.product_attribute_destroy(attributeId));

  final response = await http.delete(
    url,
    headers: {
      'Accept': 'application/json',
      'token': token,
    },
  );

  final data = jsonDecode(response.body);
  if (response.statusCode == 200 && data['status'] == 'success') {
    return true;
  } else {
    throw Exception(data['message'] ?? 'Failed to delete attribute');
  }
}