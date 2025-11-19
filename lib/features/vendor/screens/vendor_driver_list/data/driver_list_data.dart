// driver_notifier.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/features/vendor/screens/vendor_driver_list/model/driver_list_model.dart';
import '../../../../../core/utils/get_token_sharedpefarens.dart';
import '../../../../../core/constants/api_control/vendor_api.dart';

final driverNotifierProvider =
AsyncNotifierProvider<DriverNotifier, PaginatedDrivers?>(DriverNotifier.new);

class DriverNotifier extends AsyncNotifier<PaginatedDrivers?> {
  int _page = 1;

  int get currentPage => _page;

  @override
  Future<PaginatedDrivers?> build() async {
    return _fetchDrivers();
  }

  Future<void> changePage(int newPage) async {
    _page = newPage;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchDrivers);
  }

  Future<PaginatedDrivers> _fetchDrivers() async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null) throw Exception('Token not found');

    final baseUrl = VendorAPIController.approved_driver;
    final uri = Uri.parse('$baseUrl?page=$_page');

    final response = await http.get(uri, headers: {'token': token});

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data'];
      // if (data == null) {
      //   return PaginatedDrivers(
      //     currentPage: 1,
      //     lastPage: 1,
      //     total: 0,
      //     drivers: [],
      //   );
      // }
      return PaginatedDrivers.fromJson(data);
    } else {
      throw Exception('Failed to fetch drivers: ${response.statusCode}');
    }
  }
}