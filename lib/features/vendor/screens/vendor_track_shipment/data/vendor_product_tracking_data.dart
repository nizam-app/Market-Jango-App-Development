import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

import '../model/vendor_product_tracking_model.dart';

/// ===================== PROVIDER =====================

final vendorShipmentsProvider =
    AsyncNotifierProvider<VendorShipmentsNotifier, VendorShipmentsState>(
      VendorShipmentsNotifier.new,
    );

class VendorShipmentsNotifier extends AsyncNotifier<VendorShipmentsState> {
  @override
  Future<VendorShipmentsState> build() async {
    // initial load
    final pageData = await _fetch(page: 1);

    final items = pageData.data.map(ShipmentItem.fromEntity).toList();

    return VendorShipmentsState.initial().copyWith(allItems: items);
  }

  Future<VendorOrdersPage> _fetch({int page = 1}) async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null) throw Exception('Token not found');

    // tumi jeta use korte chau: all order / complete order
    final url = VendorAPIController.vendorCompleteOrder(page: page);
    // or: VendorAPIController.vendorAllOrder(page: page);

    final uri = Uri.parse(VendorAPIController.vendorCompleteOrder(page: page));

    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'token': token,
      },
    );

    if (res.statusCode != 200) {
      return VendorOrdersPage.empty();
    }

    try {
      final decoded = vendorAllOrdersResponseFromJson(res.body);
      return decoded.data;
    } catch (_) {
      return VendorOrdersPage.empty();
    }
  }

  /// Tab change
  void setStatus(TrackingOrderStatus status) {
    state = state.whenData(
      (value) => value.copyWith(
        status: status,
        selectedIndex: null, // tab change korle selection clear
      ),
    );
  }

  /// segmented toggle change
  void setSegment(int segment) {
    state = state.whenData(
      (value) => value.copyWith(segment: segment, selectedIndex: null),
    );
  }

  /// search query change
  void setQuery(String query) {
    state = state.whenData(
      (value) => value.copyWith(query: query, selectedIndex: null),
    );
  }

  /// select card (UI theke just index pathao)
  void selectIndex(int index) {
    state = state.whenData((value) => value.copyWith(selectedIndex: index));
  }

  /// manual refresh (pull to refresh etc.)
  Future<void> refresh() async {
    final pageData = await _fetch(page: 1);
    final items = pageData.data.map(ShipmentItem.fromEntity).toList();

    state = AsyncData(VendorShipmentsState.initial().copyWith(allItems: items));
  }
}
