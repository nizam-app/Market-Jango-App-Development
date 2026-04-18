import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/features/driver/screen/deliveries/data/driver_deliveries_api.dart';
import 'package:market_jango/features/driver/screen/deliveries/model/driver_assignment_models.dart';

final driverDeliveriesPageProvider = StateProvider<int>((ref) => 1);

final driverDeliveriesStatusFilterProvider = StateProvider<String?>((ref) => null);

final driverDeliveriesListProvider =
    FutureProvider.autoDispose<DriverAssignmentsPage>((ref) async {
  final page = ref.watch(driverDeliveriesPageProvider);
  final st = ref.watch(driverDeliveriesStatusFilterProvider);
  return DriverDeliveriesApi.instance.fetchDeliveries(
    page: page,
    status: (st == null || st.trim().isEmpty) ? null : st.trim(),
  );
});

final driverDeliveryDetailProvider =
    FutureProvider.autoDispose.family<DriverAssignmentRow, int>((ref, id) async {
  return DriverDeliveriesApi.instance.fetchDelivery(id);
});
