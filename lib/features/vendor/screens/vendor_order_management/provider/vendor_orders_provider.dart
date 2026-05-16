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

/// Refunds tab filters — doc/VENDOR_WALLET_AND_REFUND_API.md §5.2
class VendorRefundListParams {
  final int page;
  final String? status;
  final String? fromDate;
  final String? toDate;

  const VendorRefundListParams({
    this.page = 1,
    this.status,
    this.fromDate,
    this.toDate,
  });

  VendorRefundListParams copyWith({
    int? page,
    String? status,
    String? fromDate,
    String? toDate,
    bool clearDates = false,
    bool clearStatus = false,
  }) {
    return VendorRefundListParams(
      page: page ?? this.page,
      status: clearStatus ? null : (status ?? this.status),
      fromDate: clearDates ? null : (fromDate ?? this.fromDate),
      toDate: clearDates ? null : (toDate ?? this.toDate),
    );
  }
}

final vendorMarketplaceListParamsProvider =
    StateProvider<VendorOrderListParams>((ref) => const VendorOrderListParams());

final vendorManualListParamsProvider =
    StateProvider<VendorOrderListParams>((ref) => const VendorOrderListParams());

final vendorWalletTxParamsProvider =
    StateProvider<VendorOrderListParams>((ref) => const VendorOrderListParams());

/// Optional `type` / `status` query for `GET /vendor/wallet/transactions`.
final vendorWalletTxTypeFilterProvider = StateProvider<String?>((ref) => null);

final vendorWalletTxStatusFilterProvider = StateProvider<String?>((ref) => null);

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
  final txType = ref.watch(vendorWalletTxTypeFilterProvider);
  final txStatus = ref.watch(vendorWalletTxStatusFilterProvider);
  return VendorOrderApi.instance.fetchWalletTransactions(
    page: p.page,
    fromDate: p.fromDate,
    toDate: p.toDate,
    type: (txType == null || txType.trim().isEmpty) ? null : txType.trim(),
    status: (txStatus == null || txStatus.trim().isEmpty)
        ? null
        : txStatus.trim(),
  );
});

final vendorRefundListParamsProvider =
    StateProvider<VendorRefundListParams>(
        (ref) => const VendorRefundListParams());

final vendorRefundsPayloadProvider =
    FutureProvider.autoDispose<VendorRefundsPayload>((ref) async {
  final p = ref.watch(vendorRefundListParamsProvider);
  return VendorOrderApi.instance.fetchRefunds(
    page: p.page,
    status: (p.status == null || p.status!.trim().isEmpty)
        ? null
        : p.status!.trim(),
    fromDate: p.fromDate,
    toDate: p.toDate,
  );
});

final vendorRefundDetailProvider = FutureProvider.autoDispose
    .family<VendorRefundDetail, int>((ref, id) async {
  return VendorOrderApi.instance.fetchRefundDetail(id);
});

final vendorWalletPayoutsPageProvider = StateProvider<int>((ref) => 1);

final vendorWalletPayoutStatusFilterProvider =
    StateProvider<String?>((ref) => null);

final vendorWalletPayoutsProvider =
    FutureProvider.autoDispose<VendorOrdersPage<VendorPayoutRequest>>((ref) async {
  final page = ref.watch(vendorWalletPayoutsPageProvider);
  final st = ref.watch(vendorWalletPayoutStatusFilterProvider);
  return VendorOrderApi.instance.fetchWalletPayouts(
    page: page,
    status: (st == null || st.trim().isEmpty) ? null : st.trim(),
  );
});
