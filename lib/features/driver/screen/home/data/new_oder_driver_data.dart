import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/driver_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/driver/screen/home/model/new_oder_driver_model.dart';

final driverNewOrdersProvider =
    AutoDisposeAsyncNotifierProvider<
      DriverNewOrdersNotifier,
      DriverNewOrdersResponse?
    >(DriverNewOrdersNotifier.new);

class DriverNewOrdersNotifier
    extends AutoDisposeAsyncNotifier<DriverNewOrdersResponse?> {
  int _page = 1;

  @override
  Future<DriverNewOrdersResponse?> build() async {
    _page = 1;
    return _fetch(_page);
  }

  Future<void> changePage(int page) async {
    if (page < 1) return;
    _page = page;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(_page));
  }

  int get currentPage => state.value?.data.currentPage ?? 1;
  int get lastPage => state.value?.data.lastPage ?? 1;

  Future<DriverNewOrdersResponse> _fetch(int page) async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null) throw Exception('Token not found');

    final res = await http.get(
      Uri.parse(DriverAPIController.newOrders(page: page)),
      headers: {'Accept': 'application/json', 'token': token},
    );

    if (res.statusCode != 200) {
      throw Exception('Fetch failed: ${res.statusCode} ${res.body}');
    }
    return driverNewOrdersResponseFromJson(res.body);
  }
}
