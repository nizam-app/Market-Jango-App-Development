import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/features/vendor/screens/vendor_track_shipment/data/vendor_product_tracking_data.dart';

import '../model/vendor_product_tracking_model.dart';

class VendorShipmentsScreen extends ConsumerWidget {
  const VendorShipmentsScreen({super.key});

  static const routeName = "/vendortrack_shipments";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vendorShipmentsProvider);
    final notifier = ref.read(vendorShipmentsProvider.notifier);

    return async.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (state) {
        final items = state.filtered;

        return Scaffold(
          backgroundColor: AllColor.white,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  const CustomBackButton(),
                  SizedBox(height: 20.h),

                  // Segmented toggle
                  _SegmentedToggle(
                    leftText: ' Track shipments',
                    value: state.segment,
                    onChanged: (v) {
                      notifier.setSegment(v);
                    },
                  ),
                  SizedBox(height: 30.h),

                  // Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final tab in TrackingOrderStatus.values.where(
                          // ❗ Cancelled tab UI theke hide kore dilam
                          (t) => t != TrackingOrderStatus.cancelled,
                        ))
                          Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: _TabChip(
                              text: tab.label,
                              selected: state.status == tab,
                              onTap: () => notifier.setStatus(tab),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // List
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(0, 6.h, 0, 16.h),
                      physics: const BouncingScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (_, i) => _ShipmentCard(
                        data: items[i],
                        selected:
                            state.selectedIndex == i &&
                            state.status == TrackingOrderStatus.pending,
                        onTap: () {
                          notifier.selectIndex(i);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/* =============================== UI PARTS =============================== */

class _SegmentedToggle extends StatelessWidget {
  final String leftText;
  final int value; // 0/1
  final ValueChanged<int> onChanged;

  const _SegmentedToggle({
    required this.leftText,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget seg(String text, bool active, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            height: 38.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AllColor.loginButtomColor : AllColor.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: active ? AllColor.loginButtomColor : AllColor.grey200,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6.r,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              text,
              style: TextStyle(
                color: active ? AllColor.white : AllColor.black,
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
              ),
            ),
          ),
        ),
      );
    }

    return Row(children: [seg(leftText, value == 0, () => onChanged(0))]);
  }
}

class _TabChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _TabChip({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? AllColor.loginButtomColor : AllColor.grey100,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AllColor.loginButtomColor : AllColor.grey200,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? AllColor.white : AllColor.black,
            fontWeight: FontWeight.w700,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  final ShipmentItem data;
  final VoidCallback onTap;
  final bool selected;
  const _ShipmentCard({
    required this.data,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    // status pill
    Widget pill;
    switch (data.status) {
      case TrackingOrderStatus.pending:
        pill = _StatusPill('Pending', AllColor.loginButtomColor, solid: false);
        break;
      case TrackingOrderStatus.assigned:
        pill = const _StatusPill('Assigned', Colors.orange, solid: false);
        break;
      case TrackingOrderStatus.onTheWay:
        pill = const _StatusPill('On the way', Colors.blueAccent, solid: false);
        break;
      case TrackingOrderStatus.completed:
        pill = const _StatusPill('Complete', Colors.green, solid: false);
        break;
      case TrackingOrderStatus.cancelled:
        // theoretically ekhane ar ashar kotha na,
        // karon Cancelled ke already On the way e map korechi.
        pill = const _StatusPill('On the way', Colors.blueAccent, solid: false);
        break;
      case TrackingOrderStatus.all:
      default:
        pill = const _StatusPill('Status', Colors.grey, solid: false);
        break;
    }

    return Material(
      color: AllColor.transparent,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AllColor.white,
            borderRadius: BorderRadius.circular(12.r),
            border: selected
                ? Border.all(color: AllColor.blue500, width: 2.w)
                : Border.all(color: AllColor.grey200),
          ),
          padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top: Order # + status pill
              Row(
                children: [
                  Text(
                    'Order #${data.orderNo}',
                    style: TextStyle(
                      color: AllColor.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  pill,
                ],
              ),
              SizedBox(height: 10.h),

              // Middle: thumbnail + info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      height: 56.h,
                      width: 56.w,
                      color: AllColor.grey100,
                      child: Image.network(data.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title,
                          style: TextStyle(
                            color: AllColor.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          data.customer,
                          style: TextStyle(
                            color: AllColor.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          data.address,
                          style: TextStyle(color: AllColor.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              // Bottom: qty + price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Qty: ${data.qty}',
                    style: TextStyle(color: AllColor.black54),
                  ),
                  Text(
                    '\$${data.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: AllColor.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                'Order placed on ${data.date}',
                style: TextStyle(color: AllColor.black54, fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  final bool solid;
  const _StatusPill(this.text, this.color, {this.solid = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: solid ? color : color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20.r),
        border: solid ? null : Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: solid ? Colors.white : color,
          fontWeight: FontWeight.w700,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}

class _SeeDetailsButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SeeDetailsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AllColor.loginButtomColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          'See Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}
