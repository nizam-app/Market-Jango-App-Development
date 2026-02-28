import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';
import 'package:market_jango/features/buyer/screens/filter/model/filter_search_product_model.dart';

/// Params for product search filter
class FilterSearchParams {
  final String visibilityCountry;
  final int categoryId;
  final String? visibilityState;

  const FilterSearchParams({
    required this.visibilityCountry,
    required this.categoryId,
    this.visibilityState,
  });

  bool get isValid =>
      visibilityCountry.trim().isNotEmpty && categoryId > 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterSearchParams &&
          visibilityCountry == other.visibilityCountry &&
          categoryId == other.categoryId &&
          visibilityState == other.visibilityState;

  @override
  int get hashCode => Object.hash(visibilityCountry, categoryId, visibilityState);
}

/// GET api/product/search?visibility_country=&category_id=&visibility_state=
final filterProductSearchProvider =
    FutureProvider.autoDispose.family<List<FilterSearchProduct>, FilterSearchParams>(
  (ref, params) async {
    if (!params.isValid) return [];

    final authStorage = AuthLocalStorage();
    final t = await authStorage.getToken();

    final url = BuyerAPIController.productSearch(
      visibilityCountry: params.visibilityCountry,
      categoryId: params.categoryId,
      visibilityState: params.visibilityState,
    );

    final res = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        if (t != null && t.isNotEmpty) 'token': t,
      },
    );

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      final msg = map['message']?.toString() ?? 'Failed to fetch products';
      throw Exception(msg);
    }

    final data = map['data'];
    if (data == null) return [];

    // Response shapes: { data: [products] } or { data: { data: [products] } } or { data: { data: { data: [products] } } }
    List<dynamic> list = const [];
    if (data is List) {
      list = data;
    } else if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is List) {
        list = inner;
      } else if (inner is Map<String, dynamic>) {
        final arr = inner['data'];
        list = arr is List ? arr : const [];
      }
    }

    final products = <FilterSearchProduct>[];
    for (final item in list) {
      if (item is! Map<String, dynamic>) continue;
      try {
        products.add(FilterSearchProduct.fromJson(item));
      } catch (_) {
        // skip invalid item
      }
    }
    return products;
  },
);
