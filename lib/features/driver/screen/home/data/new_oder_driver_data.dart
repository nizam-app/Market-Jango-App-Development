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
    // Retry once if the first attempt fails (handles first load race conditions)
    try {
      return await _fetch(_page);
    } catch (e) {
      // If error contains "token", "auth", "null" (common first load issues), retry once
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('token') ||
          errorStr.contains('auth') ||
          errorStr.contains('null')) {
        // Wait a bit before retry to allow token provider to refresh
        await Future.delayed(const Duration(milliseconds: 500));
        // Invalidate token provider to force refresh before retry
        ref.invalidate(authTokenProvider);
        return await _fetch(_page);
      }
      rethrow;
    }
  }

  Future<void> changePage(int page) async {
    if (page < 1) return;
    _page = page;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(_page));
  }

  int get currentPage => state.value?.data?.currentPage ?? 1;
  int get lastPage => state.value?.data?.lastPage ?? 1;

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
