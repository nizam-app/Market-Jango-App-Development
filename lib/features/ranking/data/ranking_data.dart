import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/common_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/ranking/model/ranking_model.dart';

// ---------------------------------------------------------------------------
// Get ranked vendors (GET /api/ranking/vendors)
// ---------------------------------------------------------------------------

class RankedVendorsParams {
  final String? country;
  final String? state;
  final String? town;
  final int? categoryId;
  final int page;
  final int perPage;

  const RankedVendorsParams({
    this.country,
    this.state,
    this.town,
    this.categoryId,
    this.page = 1,
    this.perPage = 20,
  });
}

class RankedVendorsResult {
  final List<RankedVendorModel> vendors;
  final int currentPage;
  final int perPage;
  final int total;

  const RankedVendorsResult({
    required this.vendors,
    required this.currentPage,
    required this.perPage,
    required this.total,
  });
}

final rankedVendorsProvider =
    FutureProvider.autoDispose.family<RankedVendorsResult, RankedVendorsParams>(
  (ref, params) async {
    final token = await ref.watch(authTokenProvider.future);
    if (token == null || token.isEmpty) throw Exception('Not logged in');

    final query = <String, String>{
      'page': '${params.page}',
      'per_page': '${params.perPage}',
    };
    if (params.country != null && params.country!.isNotEmpty) query['country'] = params.country!;
    if (params.state != null && params.state!.isNotEmpty) query['state'] = params.state!;
    if (params.town != null && params.town!.isNotEmpty) query['town'] = params.town!;
    if (params.categoryId != null && params.categoryId! > 0) query['category_id'] = '${params.categoryId}';

    final uri = Uri.parse(CommonAPIController.rankingVendors).replace(queryParameters: query);
    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'token': token},
    );

    if (res.statusCode != 200) {
      final map = jsonDecode(res.body) as Map<String, dynamic>?;
      throw Exception(map?['message']?.toString() ?? 'Failed to load vendors');
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>?;
    if (data == null) return const RankedVendorsResult(vendors: [], currentPage: 1, perPage: 20, total: 0);

    final list = data['data'] as List<dynamic>? ?? [];
    final vendors = list
        .whereType<Map<String, dynamic>>()
        .map(RankedVendorModel.fromJson)
        .toList();

    return RankedVendorsResult(
      vendors: vendors,
      currentPage: (data['current_page'] as num?)?.toInt() ?? 1,
      perPage: (data['per_page'] as num?)?.toInt() ?? 20,
      total: (data['total'] as num?)?.toInt() ?? 0,
    );
  },
);

// ---------------------------------------------------------------------------
// Get ranked drivers (GET /api/ranking/drivers)
// ---------------------------------------------------------------------------

class RankedDriversParams {
  final String? country;
  final String? state;
  final String? town;
  final int page;
  final int perPage;

  const RankedDriversParams({
    this.country,
    this.state,
    this.town,
    this.page = 1,
    this.perPage = 20,
  });
}

class RankedDriversResult {
  final List<RankedDriverModel> drivers;
  final int currentPage;
  final int perPage;
  final int total;

  const RankedDriversResult({
    required this.drivers,
    required this.currentPage,
    required this.perPage,
    required this.total,
  });
}

final rankedDriversProvider =
    FutureProvider.autoDispose.family<RankedDriversResult, RankedDriversParams>(
  (ref, params) async {
    final token = await ref.watch(authTokenProvider.future);
    if (token == null || token.isEmpty) throw Exception('Not logged in');

    final query = <String, String>{
      'page': '${params.page}',
      'per_page': '${params.perPage}',
    };
    if (params.country != null && params.country!.isNotEmpty) query['country'] = params.country!;
    if (params.state != null && params.state!.isNotEmpty) query['state'] = params.state!;
    if (params.town != null && params.town!.isNotEmpty) query['town'] = params.town!;

    final uri = Uri.parse(CommonAPIController.rankingDrivers).replace(queryParameters: query);
    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'token': token},
    );

    if (res.statusCode != 200) {
      final map = jsonDecode(res.body) as Map<String, dynamic>?;
      throw Exception(map?['message']?.toString() ?? 'Failed to load drivers');
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>?;
    if (data == null) return const RankedDriversResult(drivers: [], currentPage: 1, perPage: 20, total: 0);

    final list = data['data'] as List<dynamic>? ?? [];
    final drivers = list
        .whereType<Map<String, dynamic>>()
        .map(RankedDriverModel.fromJson)
        .toList();

    return RankedDriversResult(
      drivers: drivers,
      currentPage: (data['current_page'] as num?)?.toInt() ?? 1,
      perPage: (data['per_page'] as num?)?.toInt() ?? 20,
      total: (data['total'] as num?)?.toInt() ?? 0,
    );
  },
);

// ---------------------------------------------------------------------------
// Get my rank (GET /api/ranking/me) – Vendor or Driver only
// ---------------------------------------------------------------------------

final myRankProvider = FutureProvider.autoDispose<MyRankModel?>((ref) async {
  final token = await ref.watch(authTokenProvider.future);
  if (token == null || token.isEmpty) return null;

  final uri = Uri.parse(CommonAPIController.rankingMe);
  final res = await http.get(
    uri,
    headers: {'Accept': 'application/json', 'token': token},
  );

  if (res.statusCode != 200) {
    return null;
  }

  final map = jsonDecode(res.body) as Map<String, dynamic>;
  final data = map['data'];
  if (data is! Map<String, dynamic>) return null;

  return MyRankModel.fromJson(data);
});
