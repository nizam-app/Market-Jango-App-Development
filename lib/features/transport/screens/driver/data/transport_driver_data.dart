// approved_drivers_pagination_notifier.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/transport_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

import '../screen/model/transport_driver_model.dart';

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
