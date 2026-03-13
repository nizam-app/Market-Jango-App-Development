// Fetches vendor products from GET api/product/vendor/{id} (see doc/API_PRODUCT_VENDOR.md).
// Used to show first 4 products on buyer vendor profile, then Popular section.
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/model/buyer_vendor_category_model.dart';

final vendorFirstFourProductsProvider = AutoDisposeAsyncNotifierProviderFamily<
    VendorFirstFourProductsNotifier,
    List<VcpProduct>,
    int>(VendorFirstFourProductsNotifier.new);

class VendorFirstFourProductsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<VcpProduct>, int> {
  static const int _takeCount = 4;

  @override
  Future<List<VcpProduct>> build(int vendorId) async {
    return _fetch(vendorId);
  }

  Future<List<VcpProduct>> _fetch(int vendorId) async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null) throw Exception('Token not found');

    final url = BuyerAPIController.productVendor(vendorId, page: 1);
    final res = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json', 'token': token},
    );

    if (res.statusCode != 200) {
      throw Exception('Vendor products failed: ${res.statusCode} ${res.body}');
    }

    final body = jsonDecode(res.body);
    if (body is! Map<String, dynamic>) return [];

    final data = body['data'];
    if (data == null) return [];

    // API may return data: [] when no products
    if (data is List) return [];

    if (data is! Map<String, dynamic>) return [];

    final productsBlock = data['products'];
    if (productsBlock == null || productsBlock is! Map<String, dynamic>) {
      return [];
    }

    final list = productsBlock['data'];
    if (list == null || list is! List) return [];

    final List<VcpProduct> result = [];
    for (final e in list) {
      if (e is Map<String, dynamic>) {
        try {
          result.add(VcpProduct.fromJson(e));
        } catch (_) {
          continue;
        }
      }
      if (result.length >= _takeCount) break;
    }
    return result;
  }
}
