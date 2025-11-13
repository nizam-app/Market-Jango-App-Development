// transport_orders_pagination_notifier.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/transport_api.dart';

import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/features/transport/screens/my_booking/model/transport_booking_model.dart';
// BuyerAPIController.allTransportOrders => '/api/all-order/transport'

class TransportOrdersRepository {
  final String baseUrl;
  final String token;
  TransportOrdersRepository({required this.baseUrl, required this.token});

  Future<TransportOrdersResponse> fetchOrders({int page = 1}) async {
    final uri = Uri.parse('$baseUrl?page=$page');
    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token.isNotEmpty) 'token': token,
      },
    );
    if (res.statusCode == 200) {
      return TransportOrdersResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to fetch orders: ${res.statusCode} ${res.reasonPhrase}');
  }
}

final transportOrdersProvider =
AsyncNotifierProvider<TransportOrdersNotifier, TransportOrdersResponse?>(
  TransportOrdersNotifier.new,
);

class TransportOrdersNotifier extends AsyncNotifier<TransportOrdersResponse?> {
  int _page = 1;
  int get currentPage => _page;

  @override
  Future<TransportOrdersResponse?> build() async => _fetch();

  Future<void> changePage(int newPage) async {
    if (newPage == _page) return;
    _page = newPage;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> nextPage() async {
    final last = state.value?.data.lastPage ?? _page + 1;
    if (_page < last) await changePage(_page + 1);
  }

  Future<void> prevPage() async {
    if (_page > 1) await changePage(_page - 1);
  }

  Future<TransportOrdersResponse> _fetch() async {
    final token = await ref.read(authTokenProvider.future) ?? '';
    final repo = TransportOrdersRepository(
      baseUrl: TransportAPIController.all_order_transport,
      token: token,
    );
    return repo.fetchOrders(page: _page);
  }
}