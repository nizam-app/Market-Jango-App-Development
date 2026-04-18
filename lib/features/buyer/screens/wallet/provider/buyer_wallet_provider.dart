import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/features/buyer/screens/wallet/data/buyer_wallet_api.dart';
import 'package:market_jango/features/buyer/screens/wallet/model/buyer_wallet_models.dart';

class BuyerWalletTxParams {
  final int page;
  final String? fromDate;
  final String? toDate;

  const BuyerWalletTxParams({
    this.page = 1,
    this.fromDate,
    this.toDate,
  });

  BuyerWalletTxParams copyWith({
    int? page,
    String? fromDate,
    String? toDate,
    bool clearDates = false,
  }) {
    return BuyerWalletTxParams(
      page: page ?? this.page,
      fromDate: clearDates ? null : (fromDate ?? this.fromDate),
      toDate: clearDates ? null : (toDate ?? this.toDate),
    );
  }
}

final buyerWalletTxParamsProvider =
    StateProvider<BuyerWalletTxParams>((ref) => const BuyerWalletTxParams());

final buyerWalletTxTypeFilterProvider = StateProvider<String?>((ref) => null);

final buyerWalletTxStatusFilterProvider = StateProvider<String?>((ref) => null);

final buyerWalletOverviewProvider =
    FutureProvider.autoDispose<BuyerWalletOverview>((ref) async {
  return BuyerWalletApi.instance.fetchWallet();
});

final buyerWalletTransactionsProvider =
    FutureProvider.autoDispose<BuyerWalletPage<BuyerWalletTransaction>>((
  ref,
) async {
  final p = ref.watch(buyerWalletTxParamsProvider);
  final txType = ref.watch(buyerWalletTxTypeFilterProvider);
  final txStatus = ref.watch(buyerWalletTxStatusFilterProvider);
  return BuyerWalletApi.instance.fetchTransactions(
    page: p.page,
    fromDate: p.fromDate,
    toDate: p.toDate,
    type: (txType == null || txType.trim().isEmpty) ? null : txType.trim(),
    status: (txStatus == null || txStatus.trim().isEmpty)
        ? null
        : txStatus.trim(),
  );
});

final buyerWalletPayoutsPageProvider = StateProvider<int>((ref) => 1);

final buyerWalletPayoutStatusFilterProvider =
    StateProvider<String?>((ref) => null);

final buyerWalletPayoutsProvider =
    FutureProvider.autoDispose<BuyerWalletPage<BuyerPayoutRequest>>((ref) async {
  final page = ref.watch(buyerWalletPayoutsPageProvider);
  final st = ref.watch(buyerWalletPayoutStatusFilterProvider);
  return BuyerWalletApi.instance.fetchPayouts(
    page: page,
    status: (st == null || st.trim().isEmpty) ? null : st.trim(),
  );
});
