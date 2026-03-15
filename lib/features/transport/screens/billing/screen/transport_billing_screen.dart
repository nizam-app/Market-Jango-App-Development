import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/transport/screens/billing/screen/transport_billing_details_screen.dart';
import 'package:market_jango/features/transport/screens/booking_confirm/data/create_shipment_data.dart';
import 'package:market_jango/features/transport/screens/my_booking/data/transport_booking_data.dart';

class TransportBillingScreen extends ConsumerWidget {
  const TransportBillingScreen({super.key});
  static const routeName = '/transport_billing';

  static String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myShipmentsProvider);

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                Tuppertextandbackbutton(
                  screenName: ref.t(BKeys.billing),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: state.when(
                    data: (result) {
                      final all = result?.items ?? const <ShipmentListItem>[];
                      final items = all
                          .where((e) =>
                              (e.paymentStatus ?? '').toLowerCase() == 'paid')
                          .toList();
                      if (items.isEmpty) {
                        return Center(
                          child: Text(
                            ref.t(BKeys.noInvoicesYet),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AllColor.grey,
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: items.length,
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (_, i) {
                          final item = items[i];
                          final dateStr = _formatDate(item.createdAt);
                          final price = item.finalPrice ?? item.estimatedPrice;
                          final amount = price != null ? price.toDouble() : 0.0;
                          return _ShipmentCard(
                            title: '${ref.t(BKeys.invoiceLabel)}${item.id}',
                            date: dateStr,
                            amount: amount,
                            status: item.paymentStatus ?? item.status ?? '',
                            onTap: () => context.push(
                              TransportBillingDetailsScreen.routeName,
                              extra: item.id,
                            ),
                          );
                        },
                      );
                    },
                    loading: () => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          SizedBox(height: 12.h),
                          Text(
                            ref.t(BKeys.loading),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AllColor.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    error: (e, _) => Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Text(
                          ref.t(BKeys.errorOccurred),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AllColor.red,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  const _ShipmentCard({
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
    required this.onTap,
  });

  final String title;
  final String date;
  final double amount;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AllColor.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AllColor.orange50,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: AllColor.orange,
                  size: 26.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AllColor.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AllColor.grey,
                      ),
                    ),
                    if (status.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AllColor.orange,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AllColor.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Icon(
                    Icons.chevron_right,
                    color: AllColor.grey,
                    size: 22.sp,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
