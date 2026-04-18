import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/features/buyer/screens/wallet/model/buyer_wallet_models.dart';
import 'package:market_jango/features/transport/screens/wallet/data/transport_wallet_api.dart';

class TransportWalletTxParams {
  final int page;
  final String? fromDate;
  final String? toDate;

  const TransportWalletTxParams({
    this.page = 1,
    this.fromDate,
    this.toDate,
  });

  TransportWalletTxParams copyWith({
    int? page,
    String? fromDate,
    String? toDate,
    bool clearDates = false,
  }) {
    return TransportWalletTxParams(
      page: page ?? this.page,
      fromDate: clearDates ? null : (fromDate ?? this.fromDate),
      toDate: clearDates ? null : (toDate ?? this.toDate),
    );
  }
}

final transportWalletTxParamsProvider =
    StateProvider<TransportWalletTxParams>((ref) => const TransportWalletTxParams());

final transportWalletTxTypeFilterProvider = StateProvider<String?>((ref) => null);

final transportWalletTxStatusFilterProvider = StateProvider<String?>((ref) => null);

final transportWalletOverviewProvider =
    FutureProvider.autoDispose<BuyerWalletOverview>((ref) async {
  return TransportWalletApi.instance.fetchWallet();
});

final transportWalletTransactionsProvider =
    FutureProvider.autoDispose<BuyerWalletPage<BuyerWalletTransaction>>((
  ref,
) async {
  final p = ref.watch(transportWalletTxParamsProvider);
  final txType = ref.watch(transportWalletTxTypeFilterProvider);
  final txStatus = ref.watch(transportWalletTxStatusFilterProvider);
  return TransportWalletApi.instance.fetchTransactions(
    page: p.page,
    fromDate: p.fromDate,
    toDate: p.toDate,
    type: (txType == null || txType.trim().isEmpty) ? null : txType.trim(),
    status: (txStatus == null || txStatus.trim().isEmpty)
        ? null
        : txStatus.trim(),
  );
});

final transportWalletPayoutsPageProvider = StateProvider<int>((ref) => 1);

final transportWalletPayoutStatusFilterProvider =
    StateProvider<String?>((ref) => null);

final transportWalletPayoutsProvider =
    FutureProvider.autoDispose<BuyerWalletPage<BuyerPayoutRequest>>((ref) async {
  final page = ref.watch(transportWalletPayoutsPageProvider);
  final st = ref.watch(transportWalletPayoutStatusFilterProvider);
  return TransportWalletApi.instance.fetchPayouts(
    page: page,
    status: (st == null || st.trim().isEmpty) ? null : st.trim(),
  );
});
