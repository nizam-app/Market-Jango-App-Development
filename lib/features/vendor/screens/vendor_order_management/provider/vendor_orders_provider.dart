import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/data/vendor_order_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';

/// Shared filter fields for marketplace + manual lists.
class VendorOrderListParams {
  final int page;
  final int perPage;
  final String? fromDate;
  final String? toDate;
  final String orderNumber;
  final String status;

  const VendorOrderListParams({
    this.page = 1,
    this.perPage = 10,
    this.fromDate,
    this.toDate,
    this.orderNumber = '',
    this.status = '',
  });

  VendorOrderListParams copyWith({
    int? page,
    int? perPage,
    String? fromDate,
    String? toDate,
    String? orderNumber,
    String? status,
    bool clearDates = false,
  }) {
    return VendorOrderListParams(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      fromDate: clearDates ? null : (fromDate ?? this.fromDate),
      toDate: clearDates ? null : (toDate ?? this.toDate),
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
    );
  }
}

final vendorMarketplaceListParamsProvider =
    StateProvider<VendorOrderListParams>((ref) => const VendorOrderListParams());

final vendorManualListParamsProvider =
    StateProvider<VendorOrderListParams>((ref) => const VendorOrderListParams());

final vendorWalletTxParamsProvider =
    StateProvider<VendorOrderListParams>((ref) => const VendorOrderListParams());

final vendorOrderStatusesProvider =
    FutureProvider<VendorOrderStatusesPayload>((ref) async {
  return VendorOrderApi.instance.fetchOrderStatuses();
});

final vendorMarketplaceOrdersProvider =
    FutureProvider.autoDispose<VendorOrdersPage<VendorMarketplaceLine>>((
  ref,
) async {
  final p = ref.watch(vendorMarketplaceListParamsProvider);
  return VendorOrderApi.instance.fetchMarketplaceOrders(
    page: p.page,
    perPage: p.perPage,
    fromDate: p.fromDate,
    toDate: p.toDate,
    orderNumber: p.orderNumber.isEmpty ? null : p.orderNumber,
    status: p.status.isEmpty ? null : p.status,
  );
});

final vendorManualOrdersProvider =
    FutureProvider.autoDispose<VendorOrdersPage<VendorManualOrderInvoice>>((
  ref,
) async {
  final p = ref.watch(vendorManualListParamsProvider);
  return VendorOrderApi.instance.fetchManualOrders(
    page: p.page,
    perPage: p.perPage,
    fromDate: p.fromDate,
    toDate: p.toDate,
    orderNumber: p.orderNumber.isEmpty ? null : p.orderNumber,
    status: p.status.isEmpty ? null : p.status,
  );
});

final vendorWalletOverviewProvider =
    FutureProvider.autoDispose<VendorWalletOverview>((ref) async {
  return VendorOrderApi.instance.fetchWallet();
});

final vendorWalletTransactionsProvider =
    FutureProvider.autoDispose<VendorOrdersPage<VendorWalletTransaction>>((
  ref,
) async {
  final p = ref.watch(vendorWalletTxParamsProvider);
  return VendorOrderApi.instance.fetchWalletTransactions(
    page: p.page,
    fromDate: p.fromDate,
    toDate: p.toDate,
  );
});
