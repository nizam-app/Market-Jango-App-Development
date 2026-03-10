// approved_drivers_pagination_notifier.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/transport_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

import '../screen/model/transport_driver_model.dart';

/// Search transporters via GET /shipments/search-transporters (transport_type, origin_address, destination_address).
class SearchTransportersRepository {
  final String baseUrl;
  final String token;

  SearchTransportersRepository({required this.baseUrl, required this.token});

  Future<List<TransporterItem>> search({
    String? transportType,
    String? originAddress,
    String? destinationAddress,
  }) async {
    final queryParams = <String, String>{};
    if (transportType != null && transportType.isNotEmpty) {
      queryParams['transport_type'] = transportType;
    }
    if (originAddress != null && originAddress.isNotEmpty) {
      queryParams['origin_address'] = originAddress;
    }
    if (destinationAddress != null && destinationAddress.isNotEmpty) {
      queryParams['destination_address'] = destinationAddress;
    }
    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams.isEmpty ? null : queryParams);
    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token.isNotEmpty) 'token': token,
      },
    );
    if (res.statusCode != 200) {
      throw Exception('Search transporters failed: ${res.statusCode} ${res.reasonPhrase}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if ((json['status'] as String?) != 'success') {
      throw Exception(json['message'] as String? ?? 'Search failed');
    }
    final data = json['data'] as Map<String, dynamic>?;
    final items = data?['items'] as List<dynamic>? ?? [];
    return items.map((e) => TransporterItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class ApprovedDriverRepository {
  final String baseUrl;
  final String token;

  ApprovedDriverRepository({required this.baseUrl, required this.token});

  Future<ApprovedDriverResponse> fetchApprovedDrivers({int page = 1}) async {
    final uri = Uri.parse('$baseUrl?page=$page');
    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token.isNotEmpty) 'token': token,
      },
    );

    if (res.statusCode == 200) {
      return ApprovedDriverResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception(
      'Failed to fetch drivers: ${res.statusCode} ${res.reasonPhrase}',
    );
  }
}

final approvedDriversProvider =
    AsyncNotifierProvider<ApprovedDriversNotifier, ApprovedDriverResponse?>(
      ApprovedDriversNotifier.new,
    );

class ApprovedDriversNotifier extends AsyncNotifier<ApprovedDriverResponse?> {
  int _page = 1;
  int get currentPage => _page;

  @override
  Future<ApprovedDriverResponse?> build() async => _fetch();

  Future<void> changePage(int newPage) async {
    if (newPage == _page) return;
    _page = newPage;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> nextPage() async {
    final last = state.value?.data.lastPage ?? _page + 1;
    if (_page < last) {
      await changePage(_page + 1);
    }
  }

  Future<void> prevPage() async {
    if (_page > 1) {
      await changePage(_page - 1);
    }
  }

  Future<ApprovedDriverResponse> _fetch() async {
    final token = await ref.read(authTokenProvider.future) ?? '';
    final repo = ApprovedDriverRepository(
      baseUrl: TransportAPIController.approved_driver,
      token: token,
    );
    return repo.fetchApprovedDrivers(page: _page);
  }
}

/// Holds result of search-transporters API. Null until user has searched; then AsyncValue.
final searchTransportersResultsProvider =
    StateNotifierProvider<SearchTransportersNotifier, AsyncValue<List<Driver>>?>(
  (ref) => SearchTransportersNotifier(ref),
);

class SearchTransportersNotifier extends StateNotifier<AsyncValue<List<Driver>>?> {
  SearchTransportersNotifier(this._ref) : super(null);
  final Ref _ref;

  Future<void> search({
    String? transportType,
    String? originAddress,
    String? destinationAddress,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final token = await _ref.read(authTokenProvider.future) ?? '';
      final repo = SearchTransportersRepository(
        baseUrl: TransportAPIController.searchTransporters,
        token: token,
      );
      final items = await repo.search(
        transportType: transportType,
        originAddress: originAddress,
        destinationAddress: destinationAddress,
      );
      return items.map(Driver.fromTransporterItem).toList();
    });
  }

  void clear() {
    state = null;
  }
}
