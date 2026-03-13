import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/vendor/screens/vendor_delivery_setting/model/vendor_route_point_model.dart';

final routePointsProvider =
    AsyncNotifierProvider<RoutePointsNotifier, RoutePointsResponse?>(
  RoutePointsNotifier.new,
);

class RoutePointsNotifier extends AsyncNotifier<RoutePointsResponse?> {
  String _search = '';
  int _page = 1;

  String get search => _search;
  int get page => _page;

  @override
  Future<RoutePointsResponse?> build() async {
    return _fetch();
  }

  Future<void> setSearch(String value) async {
    _search = value.trim();
    _page = 1;
    // Don't set AsyncLoading here – keeps previous data visible and avoids
    // rebuilding the body so the search TextField keeps focus and keyboard stays.
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> changePage(int newPage) async {
    if (newPage < 1) return;
    _page = newPage;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<RoutePointsResponse> _fetch() async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null || token.isEmpty) throw Exception('Token not found');

    final url = VendorAPIController.vendorRoutePoints(
      search: _search.isEmpty ? null : _search,
      page: _page,
    );
    final res = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json', 'token': token},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch route points: ${res.statusCode}');
    }

    try {
      final body = jsonDecode(res.body);
      if (body is! Map<String, dynamic>) {
        return RoutePointsResponse(
          items: [],
          pagination: RoutePointsPagination.empty(),
        );
      }

      final data = body['data'];
      if (data == null || data is! Map<String, dynamic>) {
        return RoutePointsResponse(
          items: [],
          pagination: RoutePointsPagination.empty(),
        );
      }

      return RoutePointsResponse.fromJson(data);
    } catch (e) {
      throw Exception('Invalid response: $e');
    }
  }

  /// Opt-in: vendor delivers on this route. POST then refresh list.
  Future<void> optIn(int deliveryChargeRouteId) async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null || token.isEmpty) throw Exception('Token not found');

    final uri = Uri.parse(VendorAPIController.vendor_route_points);
    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'token': token,
      },
      body: jsonEncode({
        'delivery_charge_route_id': deliveryChargeRouteId,
      }),
    );

    if (res.statusCode != 201 && res.statusCode != 200) {
      final body = jsonDecode(res.body);
      final msg = body is Map ? (body['message'] ?? res.body) : res.body;
      throw Exception(msg.toString());
    }

    await refresh();
  }

  /// Opt-out: vendor stops delivering on this route. DELETE then refresh list.
  Future<void> optOut(int routePointId) async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null || token.isEmpty) throw Exception('Token not found');

    final url = VendorAPIController.vendorRoutePointsDelete(routePointId);
    final res = await http.delete(
      Uri.parse(url),
      headers: {'Accept': 'application/json', 'token': token},
    );

    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      final msg = body is Map ? (body['message'] ?? res.body) : res.body;
      throw Exception(msg.toString());
    }

    await refresh();
  }
}
