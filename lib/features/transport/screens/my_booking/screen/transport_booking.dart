import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/screen/global_tracking_screen/screen/global_tracking_screen_1.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/features/transport/screens/my_booking/data/transport_booking_data.dart';
import 'package:market_jango/features/transport/screens/my_booking/model/transport_booking_model.dart';

class TransportBooking extends StatefulWidget {
  const TransportBooking({super.key});
  static const String routeName = "/transport_booking";

  @override
  State<TransportBooking> createState() => _TransportBookingState();
}

class _TransportBookingState extends State<TransportBooking> {
  /// tabs: VendorShipmentsScreen er moto simple chips
  String selectedTab = "All";
  final List<String> tabs = ["All", "On the way", "Completed"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(transportOrdersProvider);
            final notifier = ref.read(transportOrdersProvider.notifier);

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: const Tuppertextandbackbutton(
                    screenName: "My Booking",
                  ),
                ),

                /// -------- Tabs (All / On the way / Completed) ----------
                SizedBox(
                  height: 55.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    itemCount: tabs.length,
                    separatorBuilder: (_, __) => SizedBox(width: 10.w),
                    itemBuilder: (context, index) {
                      final tab = tabs[index];
                      final bool isActive = selectedTab == tab;
                      return GestureDetector(
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
                            ),
                          ),
                          child: Center(
                            child: Text(
                              tab,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: isActive ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// -------- List + pagination ----------
                Expanded(
                  child: state.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Failed to load: $e')),
                    data: (resp) {
                      final page = resp?.data;
                      final items = page?.data ?? <TransportOrder>[];

                      /// 🔹 deliveryStatus already:
                      ///  - "Completed"
                      ///  - "On the way"
                      /// (Cancelled / Canceled / Rejected sob "On the way")
                      List<TransportOrder> filtered;

                      if (selectedTab == "All") {
                        filtered = items;
                      } else {
                        filtered = items
                            .where((o) => o.deliveryStatus == selectedTab)
                            .toList();
                      }

                      if (filtered.isEmpty) {
                        return ListView(
                          padding: EdgeInsets.all(16.w),
                          children: [
                            _emptyBox(
                              "No ${selectedTab.toLowerCase()} orders found",
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final o = filtered[index];
                          final firstItem = (o.items.isNotEmpty)
                              ? o.items.first
                              : null;

                          final orderIdText = "#${o.taxRef}";
                          final driverText = firstItem?.driver != null
                              ? "${firstItem!.driver!.carName} (${firstItem.driver!.carModel})"
                              : "Assigned Driver";

                          final dateText = _formatDate(o.createdAt);
                          final fromText = o.pickupAddress;
                          final toText = o.dropOfAddress;

                          final status = o.deliveryStatus;
                          final statusColor = _statusColor(status);

                          /// On the way holei track button dekhabo
                          final showTrack = status == "Completed";

                          return _bookingCard(
                            status: status,
                            statusColor: statusColor,
                            showTrack: showTrack,
                            orderIdText: orderIdText,
                            driverText: driverText,
                            dateText: dateText,
                            fromText: fromText,
                            toText: toText,
                          );
                        },
                      );
                    },
                  ),
                ),

                /// -------- Simple Prev / Next (pagination) ----------
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                  child: state.maybeWhen(
                    data: (resp) {
                      final cp = resp?.data.currentPage ?? 1;
                      final lp = resp?.data.lastPage ?? 1;
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
                                child: const Text("Prev"),
                              ),
                              TextButton(
                                onPressed: cp < lp ? notifier.nextPage : null,
                                child: const Text("Next"),
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
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Text(text),
  );

  /// ekhane amra only effective UI status color dicchi:
  ///  - On the way -> blue
  ///  - Completed -> green
  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('way')) return Colors.blue;
    if (s.contains('complete')) return Colors.green;
    return Colors.grey;
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

  /// Booking Card Widget (same UI, dynamic text)
  Widget _bookingCard({
    required String status,
    required Color statusColor,
    bool showTrack = false,
    String? orderIdText,
    String? driverText,
    String? dateText,
    String? fromText,
    String? toText,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Order ID + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderIdText ?? "Order #fond found",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
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
          SizedBox(height: 12.h),

          /// Item + Driver Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  "https://www.pngall.com/wp-content/uploads/2016/07/Dress-Transparent.png",
                  height: 80.h,
                  width: 80.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverText ?? "Driver",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      dateText ?? "",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            fromText ?? "",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.flag, size: 14.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            toText ?? "",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          /// Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  onPressed: () {
                    context.push("/cancelledDetails");
                  },
                  child: Text(
                    "See details",
                    style: TextStyle(fontSize: 13.sp, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              if (showTrack)
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
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
                      "Track order",
                      style: TextStyle(fontSize: 13.sp, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
