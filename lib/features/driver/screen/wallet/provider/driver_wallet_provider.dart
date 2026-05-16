import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/features/driver/screen/wallet/data/driver_wallet_api.dart';
import 'package:market_jango/features/driver/screen/wallet/model/driver_wallet_models.dart';

class DriverWalletTxParams {
  final int page;
  final String? fromDate;
  final String? toDate;

  const DriverWalletTxParams({
    this.page = 1,
    this.fromDate,
    this.toDate,
  });

  DriverWalletTxParams copyWith({
    int? page,
    String? fromDate,
    String? toDate,
    bool clearDates = false,
  }) {
    return DriverWalletTxParams(
      page: page ?? this.page,
      fromDate: clearDates ? null : (fromDate ?? this.fromDate),
      toDate: clearDates ? null : (toDate ?? this.toDate),
    );
  }
}

final driverWalletTxParamsProvider =
    StateProvider<DriverWalletTxParams>((ref) => const DriverWalletTxParams());

final driverWalletTxTypeFilterProvider = StateProvider<String?>((ref) => null);

final driverWalletTxStatusFilterProvider = StateProvider<String?>((ref) => null);

final driverWalletOverviewProvider =
    FutureProvider.autoDispose<DriverWalletOverview>((ref) async {
  return DriverWalletApi.instance.fetchWallet();
});

final driverWalletTransactionsProvider =
    FutureProvider.autoDispose<DriverOrdersPage<DriverWalletTransaction>>((
  ref,
) async {
  final p = ref.watch(driverWalletTxParamsProvider);
  final txType = ref.watch(driverWalletTxTypeFilterProvider);
  final txStatus = ref.watch(driverWalletTxStatusFilterProvider);
  return DriverWalletApi.instance.fetchTransactions(
    page: p.page,
    fromDate: p.fromDate,
    toDate: p.toDate,
    type: (txType == null || txType.trim().isEmpty) ? null : txType.trim(),
    status: (txStatus == null || txStatus.trim().isEmpty)
        ? null
        : txStatus.trim(),
  );
});

final driverWalletPayoutsPageProvider = StateProvider<int>((ref) => 1);

final driverWalletPayoutStatusFilterProvider =
    StateProvider<String?>((ref) => null);

final driverWalletPayoutsProvider =
    FutureProvider.autoDispose<DriverOrdersPage<DriverPayoutRequest>>((ref) async {
  final page = ref.watch(driverWalletPayoutsPageProvider);
  final st = ref.watch(driverWalletPayoutStatusFilterProvider);
  return DriverWalletApi.instance.fetchPayouts(
    page: page,
    status: (st == null || st.trim().isEmpty) ? null : st.trim(),
  );
});
