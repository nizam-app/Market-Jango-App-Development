import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/vendor/screens/visibility/model/visibility_model.dart';

/// Product id, name and image for visibility form dropdown.
class ProductOption {
  final int id;
  final String name;
  final String? image;
  const ProductOption({required this.id, required this.name, this.image});
}

/// Fetches first page of vendor products for "Add visibility" dropdown.
final vendorProductsForVisibilityProvider =
    FutureProvider.autoDispose<List<ProductOption>>((ref) async {
  final token = await ref.watch(authTokenProvider.future);
  if (token == null) return [];
  final uri = Uri.parse('${VendorAPIController.vendor_product}?page=1');
  final res = await http.get(
    uri,
    headers: {'Accept': 'application/json', 'token': token},
  );
  if (res.statusCode != 200) return [];
  final body = jsonDecode(res.body) as Map<String, dynamic>?;
  final data = body?['data'] as Map<String, dynamic>?;
  final products = data?['products'] as Map<String, dynamic>?;
  final list = products?['data'] as List<dynamic>? ?? [];
  return list
      .whereType<Map<String, dynamic>>()
      .map((e) => ProductOption(
            id: (e['id'] is int) ? e['id'] as int : int.tryParse(e['id'].toString()) ?? 0,
            name: e['name']?.toString() ?? '',
            image: e['image']?.toString(),
          ))
      .where((o) => o.id > 0)
      .toList();
});

// ---------------------------------------------------------------------------
// Dashboard: GET /api/vendor-dashboard/visibility
// ---------------------------------------------------------------------------

final visibilityDashboardProvider =
    AsyncNotifierProvider<VisibilityDashboardNotifier, VisibilityDashboardModel?>(
  VisibilityDashboardNotifier.new,
);

class VisibilityDashboardNotifier
    extends AsyncNotifier<VisibilityDashboardModel?> {
  @override
  Future<VisibilityDashboardModel?> build() async {
    return _fetchDashboard();
  }

  Future<VisibilityDashboardModel?> _fetchDashboard() async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null || token.isEmpty) throw Exception('Not logged in');

    final uri = Uri.parse(VendorAPIController.vendorDashboardVisibility);
    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'token': token},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load visibility: ${res.statusCode}');
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final data = map['data'];
    if (data == null) return null;

    return VisibilityDashboardModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchDashboard());
  }
}

// ---------------------------------------------------------------------------
// List: GET /api/product-visibility/vendor (fallback if dashboard not used)
// ---------------------------------------------------------------------------

final visibilityListProvider =
    AsyncNotifierProvider<VisibilityListNotifier, List<VisibilityModel>>(
  VisibilityListNotifier.new,
);

class VisibilityListNotifier extends AsyncNotifier<List<VisibilityModel>> {
  @override
  Future<List<VisibilityModel>> build() async {
    return _fetchList();
  }

  Future<List<VisibilityModel>> _fetchList() async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null || token.isEmpty) throw Exception('Not logged in');

    final uri = Uri.parse(VendorAPIController.productVisibilityVendor);
    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'token': token},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load visibilities: ${res.statusCode}');
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final data = map['data'];
    if (data is! List) return [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(VisibilityModel.fromJson)
        .toList();
  }
}

// ---------------------------------------------------------------------------
// Set: POST /api/product-visibility/set
// ---------------------------------------------------------------------------

Future<void> visibilitySet(
  String? token, {
  required int productId,
  String? country,
  String? state,
  String? town,
  bool isActive = true,
  void Function()? onSuccess,
}) async {
  if (token == null || token.isEmpty) throw Exception('Not logged in');

  final uri = Uri.parse(VendorAPIController.productVisibilitySet);
  final body = <String, dynamic>{
    'product_id': productId,
    'is_active': isActive,
  };
  if (country != null && country.isNotEmpty) body['country'] = country;
  if (state != null && state.isNotEmpty) body['state'] = state;
  if (town != null && town.isNotEmpty) body['town'] = town;

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
  if (res.statusCode == 201 || res.statusCode == 200) {
    onSuccess?.call();
    return;
  }
  final msg = map['message']?.toString() ?? 'Failed to set visibility';
  throw Exception(msg);
}

// ---------------------------------------------------------------------------
// Update: PUT /api/product-visibility/{id}
// ---------------------------------------------------------------------------

Future<void> visibilityUpdate(
  String? token, {
  required int visibilityId,
  String? country,
  String? state,
  String? town,
  bool? isActive,
  void Function()? onSuccess,
}) async {
  if (token == null || token.isEmpty) throw Exception('Not logged in');

  final uri =
      Uri.parse(VendorAPIController.productVisibilityUpdate(visibilityId));
  final body = <String, dynamic>{};
  if (country != null) body['country'] = country;
  if (state != null) body['state'] = state;
  if (town != null) body['town'] = town;
  if (isActive != null) body['is_active'] = isActive;

  final res = await http.put(
    uri,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'token': token,
    },
    body: jsonEncode(body),
  );

  final map = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200) {
    onSuccess?.call();
    return;
  }
  final msg = map['message']?.toString() ?? 'Failed to update visibility';
  throw Exception(msg);
}

// ---------------------------------------------------------------------------
// Delete: DELETE /api/product-visibility/{id}
// ---------------------------------------------------------------------------

Future<void> visibilityDelete(
  String? token, {
  required int visibilityId,
  void Function()? onSuccess,
}) async {
  if (token == null || token.isEmpty) throw Exception('Not logged in');

  final uri =
      Uri.parse(VendorAPIController.productVisibilityDelete(visibilityId));
  final res = await http.delete(
    uri,
    headers: {'Accept': 'application/json', 'token': token},
  );

  final map = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode == 200) {
    onSuccess?.call();
    return;
  }
  final msg = map['message']?.toString() ?? 'Failed to delete visibility';
  throw Exception(msg);
}
