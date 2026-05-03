import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/features/driver/screen/deliveries/model/driver_assignment_models.dart';
import 'package:market_jango/features/driver/screen/deliveries/provider/driver_deliveries_provider.dart';
import 'package:market_jango/features/driver/screen/deliveries/screen/driver_delivery_detail_screen.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

/// `GET /api/driver/deliveries` — `doc/details.md`.
class DriverDeliveriesScreen extends ConsumerWidget {
  const DriverDeliveriesScreen({super.key});

  static const routeName = '/driver/deliveries';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(driverDeliveriesPageProvider);
    final statusFilter = ref.watch(driverDeliveriesStatusFilterProvider);
    final async = ref.watch(driverDeliveriesListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AllColor.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: const CustomBackButton(),
        ),
        title: Text(
          ref.t(BKeys.my_deliveries, fallback: 'My deliveries'),
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: AllColor.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
            child: DropdownButtonFormField<String?>(
              initialValue: statusFilter,
              decoration: InputDecoration(
                labelText: ref.t(
                  BKeys.driver_deliveries_status_filter,
                  fallback: 'Status filter',
                ),
                filled: true,
                fillColor: AllColor.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    ref.t(BKeys.shipment_tab_all, fallback: 'All'),
                  ),
                ),
                DropdownMenuItem(
                  value: 'pending',
                  child: Text(ref.t(BKeys.pending, fallback: 'Pending')),
                ),
                DropdownMenuItem(
                  value: 'accepted',
                  child: Text(
                    ref.t(
                      BKeys.delivery_status_accepted,
                      fallback: 'Accepted',
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'rejected',
                  child: Text(
                    ref.t(
                      BKeys.delivery_status_rejected,
                      fallback: 'Rejected',
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'in_transit',
                  child: Text(
                    ref.t(
                      BKeys.delivery_status_in_transit,
                      fallback: 'In transit',
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'delivered',
                  child: Text(ref.t(BKeys.delivered, fallback: 'Delivered')),
                ),
                DropdownMenuItem(
                  value: 'cancelled',
                  child: Text(ref.t(BKeys.cancelled, fallback: 'Cancelled')),
                ),
              ],
              onChanged: (v) {
                ref.read(driverDeliveriesStatusFilterProvider.notifier).state =
                    v;
                ref.read(driverDeliveriesPageProvider.notifier).state = 1;
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(driverDeliveriesListProvider);
                await ref.read(driverDeliveriesListProvider.future);
              },
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Text(
                        _driverDeliveriesErrorText(ref, e),
                        style: TextStyle(color: AllColor.red, fontSize: 13.sp),
                      ),
                    ),
                  ],
                ),
                data: (p) {
                  if (p.items.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 80.h),
                        Center(
                          child: Text(
                            ref.t(
                              BKeys.driver_deliveries_empty,
                              fallback: 'No assignments.',
                            ),
                            style: TextStyle(
                              color: AllColor.grey500,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    itemCount: p.items.length + 1,
                    itemBuilder: (context, i) {
                      if (i == p.items.length) {
                        return _PaginationRow(
                          page: page,
                          lastPage: p.lastPage,
                          onPrev: page <= 1
                              ? null
                              : () {
                                  ref
                                      .read(driverDeliveriesPageProvider
                                          .notifier)
                                      .state = page - 1;
                                },
                          onNext: page >= p.lastPage
                              ? null
                              : () {
                                  ref
                                      .read(driverDeliveriesPageProvider
                                          .notifier)
                                      .state = page + 1;
                                },
                        );
                      }
                      final row = p.items[i];
                      return _AssignmentTile(row: row);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _driverDeliveriesErrorText(WidgetRef ref, Object e) {
  final msg = e.toString().replaceFirst('Exception: ', '');
  if (msg.toLowerCase().contains('driver not found')) {
    return ref.t(
      BKeys.driver_not_found,
      fallback: msg,
    );
  }
  return msg;
}

class _AssignmentTile extends StatelessWidget {
  const _AssignmentTile({required this.row});
  final DriverAssignmentRow row;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: AllColor.grey200),
      ),
      child: ListTile(
        title: Text(
          '#${row.id} · ${row.status}',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 6.h),
          child: Text(
            row.displaySubtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.sp, height: 1.3),
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(
          DriverDeliveryDetailScreen.routePath(row.id),
        ),
      ),
    );
  }
}

class _PaginationRow extends ConsumerWidget {
  const _PaginationRow({
    required this.page,
    required this.lastPage,
    required this.onPrev,
    required this.onNext,
  });

  final int page;
  final int lastPage;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mid = ref
        .t(BKeys.pagination_slash, fallback: '{current} / {total}')
        .replaceAll('{current}', '$page')
        .replaceAll('{total}', '$lastPage');
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: onPrev,
            child: Text(ref.t(BKeys.prev, fallback: 'Prev')),
          ),
          Text(mid),
          TextButton(
            onPressed: onNext,
            child: Text(ref.t(BKeys.next, fallback: 'Next')),
          ),
        ],
      ),
    );
  }
}
