import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/features/buyer/screens/refunds/data/buyer_order_track_api.dart';
import 'package:market_jango/features/buyer/screens/refunds/data/buyer_refunds_api.dart';
import 'package:market_jango/features/buyer/screens/refunds/model/buyer_refund_models.dart';
import 'package:market_jango/features/buyer/screens/refunds/model/buyer_track_path_model.dart';

final buyerRefundsPageProvider = StateProvider<int>((ref) => 1);

final buyerRefundsStatusFilterProvider = StateProvider<String?>((ref) => null);

final buyerRefundsListProvider =
    FutureProvider.autoDispose<BuyerRefundsPayload>((ref) async {
  final page = ref.watch(buyerRefundsPageProvider);
  final st = ref.watch(buyerRefundsStatusFilterProvider);
  return BuyerRefundsApi.instance.fetchRefunds(
    page: page,
    status: (st == null || st.trim().isEmpty) ? null : st.trim(),
  );
});

final buyerRefundDetailProvider =
    FutureProvider.autoDispose.family<BuyerRefundDetail, int>((ref, id) async {
  return BuyerRefundsApi.instance.fetchRefundDetail(id);
});

/// Live per-invoice tracking (invoice id = order_id in API).
final buyerLiveTrackProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, int>((ref, invoiceId) async {
  if (invoiceId <= 0) return {};
  return BuyerOrderTrackApi.instance.fetchLiveTrack(invoiceId);
});

/// GPS breadcrumb for one line item (`invoice_items.id` = [key.itemId]).
final buyerOrderTrackPathProvider =
    FutureProvider.autoDispose.family<BuyerTrackPathData, BuyerTrackPathKey>((
  ref,
  key,
) async {
  if (key.invoiceId <= 0 || key.itemId <= 0) {
    return const BuyerTrackPathData(
      orderId: 0,
      itemId: null,
      assignmentId: null,
      status: null,
      points: [],
    );
  }
  return BuyerOrderTrackApi.instance.fetchTrackPath(
    key.invoiceId,
    itemId: key.itemId,
  );
});
