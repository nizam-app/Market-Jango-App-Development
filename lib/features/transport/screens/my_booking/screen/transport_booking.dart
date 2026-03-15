import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/screen/global_tracking_screen/screen/global_tracking_screen_1.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/features/transport/screens/booking_confirm/data/create_shipment_data.dart';
import 'package:market_jango/features/transport/screens/booking_confirm/transport_shipment_details_screen.dart';
import 'package:market_jango/features/transport/screens/my_booking/data/transport_booking_data.dart';

class TransportBooking extends ConsumerStatefulWidget {
  const TransportBooking({super.key});
  static const String routeName = "/transport_booking";

  @override
  ConsumerState<TransportBooking> createState() => _TransportBookingState();
}

class _TransportBookingState extends ConsumerState<TransportBooking> {
  /// tabs: value used for filtering; label from keys for language
  String selectedTab = "All";
  static const List<String> tabs = ["All", "On the way", "Completed"];
  static const List<String> tabKeys = [
    BKeys.shipment_tab_all,
    BKeys.shipment_tab_on_the_way,
    BKeys.shipment_tab_completed,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(myShipmentsProvider);
            final notifier = ref.read(myShipmentsProvider.notifier);
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Tuppertextandbackbutton(
                    screenName: ref.t(BKeys.shipment_list, fallback: 'Shipment list'),
                  ),
                ),

                /// -------- Tabs (All / On the way / Completed) ----------
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                  child: Row(
                    children: List.generate(tabs.length, (index) {
                      final tab = tabs[index];
                      final bool isActive = selectedTab == tab;
                      return Padding(
                        padding: EdgeInsets.only(right: index < tabs.length - 1 ? 10.w : 0),
                        child: GestureDetector(
                          onTap: () => setState(() => selectedTab = tab),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.orange.shade700
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(30.r),
                              border: Border.all(
                                color: isActive
                                    ? Colors.orange.shade700
                                    : Colors.grey.shade400,
                                width: 1,
                              ),
                              boxShadow: isActive
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                            ),
                            child: Center(
                              child: Text(
                                ref.t(tabKeys[index], fallback: tab),
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                /// -------- Shipment list + pagination ----------
                Expanded(
                  child: state.when(
                    loading: () =>
                        Center(child: Text(ref.t(BKeys.loading, fallback: 'Loading...'))),
                    error: (e, _) => Center(child: Text('${ref.t(BKeys.error, fallback: 'Failed to load')}: $e')),
                    data: (resp) {
                      final items = resp?.items ?? <ShipmentListItem>[];
                      List<ShipmentListItem> filtered;
                      if (selectedTab == "All") {
                        filtered = items;
                      } else {
                        filtered = items
                            .where((o) => o.deliveryStatus == selectedTab)
                            .toList();
                      }

                      if (filtered.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async => notifier.refresh(),
                          child: ListView(
                            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                            children: [
                              _emptyBox(
                                "No ${selectedTab.toLowerCase()} shipments found",
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async => notifier.refresh(),
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(0, 16.h, 0, 24.h),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final orderIdText = "#${item.id}";
                            final dateText = _formatDate(item.createdAt ?? '');
                            final fromText = item.originAddress ?? '';
                            final toText = item.destinationAddress ?? '';
                            final status = item.deliveryStatus;
                            final statusColor = _statusColor(status);
                            final showTrack = status == 'Completed';
                            final paymentStatus = item.paymentStatus ?? '';
                            final price = item.finalPrice ?? item.estimatedPrice;
                            final pieces = item.totalPieces;
                            final weight = item.totalWeightKg;

                            return _bookingCard(
                              status: status,
                              statusColor: statusColor,
                              showTrack: showTrack,
                              orderIdText: orderIdText,
                              dateText: dateText,
                              fromText: fromText,
                              toText: toText,
                              paymentStatus: paymentStatus,
                              price: price,
                              totalPieces: pieces,
                              totalWeightKg: weight,
                              orderId: item.id,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                /// -------- Simple Prev / Next (pagination) ----------
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                  child: state.maybeWhen(
                    data: (resp) {
                      final cp = resp?.currentPage ?? 1;
                      final lp = resp?.lastPage ?? 1;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Page $cp of $lp",
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: cp > 1 ? notifier.prevPage : null,
                                child: Text(ref.t(BKeys.prev, fallback: 'Prev')),
                              ),
                              TextButton(
                                onPressed: cp < lp ? notifier.nextPage : null,
                                child: Text(ref.t(BKeys.next, fallback: 'Next')),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    orElse: () => const SizedBox.shrink(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---------- helpers ----------

  Widget _emptyBox(String text) => Container(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Center(
      child: Text(
        text,
        style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
      ),
    ),
  );

  ///  - On the way -> blue
  ///  - Completed -> green
  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('way')) return Colors.blue;
    if (s.contains('complete')) return Colors.green;
    return Colors.grey;
  }

  /// Payment status color based on API response value.
  Color _paymentStatusColor(String? status) {
    final s = (status ?? '').toLowerCase();
    if (s == 'paid' || s.contains('success')) return Colors.green;
    if (s == 'pending' || s.contains('await')) return Colors.orange;
    if (s.isEmpty) return Colors.grey;
    return Colors.redAccent;
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return "${months[dt.month - 1]} ${dt.day}, ${dt.year}";
  }

  /// Shipment list card – #ID, status pill, title ("Shipment"), date, route, payment + price + pieces/weight summary.
  Widget _bookingCard({
    required String status,
    required Color statusColor,
    bool showTrack = false,
    String? orderIdText,
    String? dateText,
    String? fromText,
    String? toText,
    String? paymentStatus,
    num? price,
    int? totalPieces,
    double? totalWeightKg,
    int? orderId,
  }) {
    return Container(
      margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Shipment #ID + Status pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  orderIdText ?? "#—",
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                if (status.isNotEmpty)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 14.h),

            /// Title, date, origin, destination (no image)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shipment',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  dateText ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 16.sp, color: Colors.grey[600]),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        fromText ?? '—',
                        style:
                            TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.flag_outlined,
                        size: 16.sp, color: Colors.grey[600]),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        toText ?? '—',
                        style:
                            TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),

            /// See Details (orange) + Track Order (blue, only when Completed)
            SizedBox(height: 12.h),

            /// Payment + summary row (payment status pill + price + pieces/weight)
            Row(
              children: [
                if ((paymentStatus ?? '').isNotEmpty)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _paymentStatusColor(paymentStatus)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      (paymentStatus ?? '').toUpperCase(),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: _paymentStatusColor(paymentStatus),
                      ),
                    ),
                  ),
                const Spacer(),
                if (price != null)
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
              ],
            ),
            if ((totalPieces ?? 0) > 0 || (totalWeightKg ?? 0) > 0)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Row(
                  children: [
                    if ((totalPieces ?? 0) > 0)
                      Text(
                        '${totalPieces ?? 0} pcs',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    if ((totalPieces ?? 0) > 0 && (totalWeightKg ?? 0) > 0)
                      Text(
                        '  •  ',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    if ((totalWeightKg ?? 0) > 0)
                      Text(
                        '${(totalWeightKg ?? 0).toStringAsFixed(1)} kg',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                  ],
                ),
              ),

            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    onPressed: () {
                      context.push(
                        TransportShipmentDetailsScreen.routeName,
                        extra: TransportShipmentDetailsArgs(shipmentId: orderId),
                      );
                    },
                    child: Text(
                      ref.t(BKeys.see_details),
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                if (showTrack) ...[
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      onPressed: () {
                        context.pushNamed(
                          GlobalTrackingScreen1.routeName,
                          pathParameters: {"screenName": "transport"},
                        );
                      },
                      child: Text(
                        ref.t(BKeys.track_order),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
