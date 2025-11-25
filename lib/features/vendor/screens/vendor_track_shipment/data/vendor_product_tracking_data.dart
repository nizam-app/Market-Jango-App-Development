import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

import '../model/vendor_product_tracking_model.dart';

final vendorShipmentsProvider =
AsyncNotifierProvider<VendorShipmentsNotifier, VendorShipmentsState>(
  VendorShipmentsNotifier.new,
);

class VendorShipmentsNotifier extends AsyncNotifier<VendorShipmentsState> {
  @override
  Future<VendorShipmentsState> build() async {
    final pageData = await _fetch(page: 1);

    final items =
    pageData.data.map((e) => ShipmentItem.fromEntity(e)).toList();

    return VendorShipmentsState.initial().copyWith(
      allItems: items,
    );
  }

  Future<VendorOrdersPage> _fetch({int page = 1}) async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null) throw Exception('Token not found');

    // tumi jeta use korte chau: all order / complete order
    final url = VendorAPIController.vendorCompleteOrder(page: page);
    // or: VendorAPIController.vendorAllOrder(page: page);

    final r = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'token': token,
      },
    );

    if (r.statusCode != 200) {
      throw Exception('Fetch failed: ${r.statusCode} ${r.body}');
    }

    return vendorAllOrdersResponseFromJson(r.body).data;
  }

  Future<void> reload({int page = 1}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final pageData = await _fetch(page: page);
      final items =
      pageData.data.map((e) => ShipmentItem.fromEntity(e)).toList();

      return VendorShipmentsState.initial().copyWith(
        allItems: items,
      );
    });
  }

  void setStatus(TrackingOrderStatus s) {
    final value = state.valueOrNull;
    if (value == null) return;
    state = AsyncData(
      value.copyWith(
        status: s,
        selectedIndex: null,
      ),
    );
  }

  void setSegment(int v) {
    final value = state.valueOrNull;
    if (value == null) return;
    state = AsyncData(
      value.copyWith(segment: v),
    );
  }

  void setQuery(String q) {
    final value = state.valueOrNull;
    if (value == null) return;
    state = AsyncData(
      value.copyWith(query: q),
    );
  }

  void selectIndex(int i) {
    final value = state.valueOrNull;
    if (value == null) return;
    state = AsyncData(
      value.copyWith(selectedIndex: i),
    );
  }
}