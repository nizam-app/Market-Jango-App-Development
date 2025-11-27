import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/screen/global_notification/screen/global_notifications_screen.dart';
import 'package:market_jango/core/screen/profile_screen/data/profile_data.dart';
import 'package:market_jango/core/utils/get_user_type.dart';
import 'package:market_jango/core/widget/global_pagination.dart';
import 'package:market_jango/features/driver/screen/driver_order/screen/driver_order_details.dart';
import 'package:market_jango/features/driver/screen/driver_traking_screen.dart';
import 'package:market_jango/features/driver/screen/home/data/new_oder_driver_data.dart';

import '../data/driver_home_status_data.dart';
import '../model/new_oder_driver_model.dart';

class DriverHomeScreen extends ConsumerWidget {
  const DriverHomeScreen({super.key});
  static const routeName = "/driverHome";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(driverHomeStatsProvider);
    final newOrdersAsync = ref.watch(driverNewOrdersProvider);

    return Scaffold(
      body: SafeArea(
        child: statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Failed to load stats: $e')),
          data: (stats) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderSection(
                  name: "John", // later tumi driver profile theke dibe
                  subtitle: "Keep going! You're doing great today.",
                ),
                const SizedBox(height: 12),

                _StatsGrid(
                  stats: [
                    _StatItem(
                      title: "Total Active Orders",
                      value: stats.totalActiveOrders.toString(),
                    ),
                    _StatItem(title: "Picked", value: stats.picked.toString()),
                    _StatItem(
                      title: "Pending Deliveries",
                      value: stats.pendingsDeliveries.toString(),
                    ),
                    _StatItem(
                      title: "Delivered Today",
                      value: stats.deliveredToday.toString(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const _SectionTitle(title: "New Orders"),
                const SizedBox(height: 10),

                // আগের মতই new orders list – শুধু async handle করে দিচ্ছি
                Expanded(
                  child: newOrdersAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('Failed to load orders: $e')),
                    data: (_) => const _OrdersList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/* ------------------------------ Custom Codebase ------------------------------ */

class _HeaderSection extends ConsumerWidget {
  const _HeaderSection({required this.name, required this.subtitle});
  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userID = ref.watch(getUserIdProvider.select((value) => value.value));
    final async = ref.watch(userProvider(userID ?? ''));
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // left: greetings
          Expanded(
            child: async.when(
              data: (data) {
                final name = data.name;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: AllColor.black,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.verified,
                          color: AllColor.blue500,
                          size: 18.sp,
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AllColor.black54,
                        height: 1.25,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),

          InkWell(
            onTap: () {
              context.push(GlobalNotificationsScreen.routeName);
            },
            child: Icon(
              Icons.notifications,
              color: AllColor.black,
              size: 22.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});
  final List<_StatItem> stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Wrap(
        spacing: 12.w,
        runSpacing: 12.h,
        children: stats
            .map((s) => _StatTile(title: s.title, value: s.value))
            .toList(),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (1.sw - 16.w * 2 - 12.w) / 2,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AllColor.grey200, width: 1),
        boxShadow: [
          BoxShadow(
            color: AllColor.black.withOpacity(.04),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 11.sp, color: AllColor.black54),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AllColor.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: AllColor.black,
        ),
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  const _OrdersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(driverNewOrdersProvider);
    final notifier = ref.read(driverNewOrdersProvider.notifier);

    return async.when(
      loading: () =>
          const Expanded(child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Expanded(child: Center(child: Text(e.toString()))),
      data: (resp) {
        // raw entity list
        final raw = resp?.data.data ?? const <DriverOrder>[];
        final orders = raw.map((e) => _OrderModel.fromEntity(e)).toList();

        return Expanded(
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  itemBuilder: (_, i) =>
                      _OrderCard(order: orders[i], orderId: raw[i].id),
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemCount: orders.length,
                ),
              ),
              SizedBox(height: 8.h),
              GlobalPagination(
                currentPage: notifier.currentPage,
                totalPages: notifier.lastPage,
                onPageChanged: notifier.changePage,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.orderId});
  final _OrderModel order;
  final int orderId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AllColor.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AllColor.black.withOpacity(.06),
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // left block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusPill(text: order.status),
                  SizedBox(height: 10.h),
                  Text(
                    "Order ID ${order.id}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AllColor.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _KVRow(
                    k: "Pick up location:",
                    v: order.pickup,
                    boldValue: true,
                  ),
                  SizedBox(height: 4.h),
                  _KVRow(
                    k: "Destination:",
                    v: order.destination,
                    boldValue: true,
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _FilledBtn(
                        label: "See details",
                        onTap: () => _onSeeDetails(context, orderId),
                        bg: AllColor.loginButtomColor,
                        fg: AllColor.white,
                      ),

                      _FilledBtn(
                        label: "Track order",
                        onTap: () => _onTrack(context, order),
                        bg: AllColor.blue500,
                        fg: AllColor.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // price
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 6.h),
                Text(
                  _formatPrice(order.price),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AllColor.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onSeeDetails(BuildContext context, orderId) {
    context.push(OrderDetailsScreen.routeName, extra: orderId);
  }

  void _onTrack(BuildContext context, _OrderModel order) {
    context.push(DriverTrakingScreen.routeName);
  }
}

class _KVRow extends StatelessWidget {
  const _KVRow({required this.k, required this.v, this.boldValue = false});
  final String k;
  final String v;
  final bool boldValue;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: "$k ",
        style: TextStyle(fontSize: 12.sp, color: AllColor.black54),
        children: [
          TextSpan(
            text: v,
            style: TextStyle(
              fontSize: 12.sp,
              color: AllColor.black,
              fontWeight: boldValue ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AllColor.blue50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AllColor.blue500, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          color: AllColor.blue500,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FilledBtn extends StatelessWidget {
  const _FilledBtn({
    required this.label,
    required this.onTap,
    required this.bg,
    required this.fg,
  });
  final String label;
  final VoidCallback onTap;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w700,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}

/* ------------------------------ Helper Models ------------------------------ */

class _OrderModel {
  final String id;
  final String status;
  final String pickup;
  final String destination;
  final double price;

  _OrderModel({
    required this.id,
    required this.status,
    required this.pickup,
    required this.destination,
    required this.price,
  });

  factory _OrderModel.fromEntity(DriverOrder o) {
    final inv = o.invoice;
    final pickup = (inv?.pickupAddress?.trim().isNotEmpty ?? false)
        ? inv!.pickupAddress
        : (inv?.shipAddress ?? '—');
    final dest = (inv?.dropOfAddress?.trim().isNotEmpty ?? false)
        ? inv!.dropOfAddress
        : (inv?.shipCity ?? '—');
    // final id = int.parse(o.invoice!.taxRef);
    return _OrderModel(
      id: o.invoice!.taxRef,
      status: o.status,
      pickup: pickup,
      destination: dest,
      price: o.salePrice,
    );
  }
}

// class _OrdersListData {
//   static final list = [
//     _OrderModel(
//       id: "ORD12345",
//       status: "Pending",
//       pickup: "Urban tech store",
//       destination: "Alex Hossain",
//       price: 750,
//     ),
//     _OrderModel(
//       id: "ORD12346",
//       status: "Pending",
//       pickup: "Urban tech store",
//       destination: "Alex Hossain",
//       price: 750,
//     ),
//     _OrderModel(
//       id: "ORD12347",
//       status: "Pending",
//       pickup: "Urban tech store",
//       destination: "Alex Hossain",
//       price: 750,
//     ),
//   ];
// }

// List<_OrderModel> _mockOrders() => _OrdersListData.list;

class _StatItem {
  final String title;
  final String value;
  const _StatItem({required this.title, required this.value});
}

/* ------------------------------ Helper Functions ------------------------------ */
String _formatPrice(double v) => "\$${v.toStringAsFixed(2)}";
