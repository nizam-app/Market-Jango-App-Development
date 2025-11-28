import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/global_review_dialog.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/buyer/screens/order/data/buyer_orders_data.dart';
import 'package:market_jango/features/buyer/screens/order/logic/buyer_review_send.dart';
import 'package:market_jango/features/buyer/screens/order/model/order_summary.dart';

import '../../../../../core/constants/api_control/buyer_api.dart';

class BuyerOrderHistoryScreen extends ConsumerWidget {
  const BuyerOrderHistoryScreen({super.key});
  static const routeName = '/buyer_order_history';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(buyerOrdersProvider);

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                Tuppertextandbackbutton(screenName: "Order History"),
                SizedBox(height: 12.h),

                Expanded(
                  child: ordersAsync.when(
                    data: (page) {
                      final allOrders = page?.orders ?? const <Order>[];

                      // 🔹 শুধু complete status order filter করলাম
                      final completedOrders = allOrders
                          .where((o) => o.isCompleted)
                          .toList();

                      if (completedOrders.isEmpty) {
                        return Center(
                          child: Text(
                            "No completed orders yet",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AllColor.grey,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: completedOrders.length,
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (_, __) => SizedBox(height: 12.h),
                        itemBuilder: (_, i) =>
                            _ReviewTile(order: completedOrders[i]),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Text(
                        e.toString(),
                        style: TextStyle(color: Colors.red, fontSize: 13.sp),
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

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.order});
  final Order order;

  static const _orange = Color(0xFFFF8A00);

  @override
  Widget build(BuildContext context) {
    // 🔹 image, text, date prepare
    final imageUrl = order.product.image;
    final subtitle = order.statusDescription.isNotEmpty
        ? order.statusDescription
        : order.product.description;

    final orderId = order.orderCode; // tax_ref / tran_id
    final dateText = _formatDate(order.createdAt);
    final paymentText =
        order.paymentLabel; // "Payment successful" / "Cash on delivery" / ''

    return Container(
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.r),
        border: Border.all(color: Colors.black12.withOpacity(.01)),
      ),
      child: Row(
        children: [
          // left image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: imageUrl.isEmpty
                ? Container(
                    width: 90.w,
                    height: 90.h,
                    color: AllColor.grey.withOpacity(0.15),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 24.sp,
                      color: AllColor.grey,
                    ),
                  )
                : Image.network(
                    imageUrl,
                    width: 90.w,
                    height: 90.h,
                    fit: BoxFit.cover,
                  ),
          ),
          SizedBox(width: 10.w),

          // right texts & actions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ছোট description (status এর text / product description)
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.sp, color: AllColor.black),
                ),
                SizedBox(height: 4.h),

                // Order ID
                Text(
                  'Order $orderId',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AllColor.black,
                  ),
                ),

                if (paymentText.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    paymentText,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AllColor.grey,
                    ),
                  ),
                ],

                SizedBox(height: 10.h),

                Row(
                  children: [
                    // date chip
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6F8),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        dateText,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // review button (orange outline)
                    OutlinedButton(
                      onPressed: () {
                        ReviewDialog.show(
                          context,
                          onSubmit: (rating, comment) async {
                            final msg = await submitReviewToApi(
                              url: BuyerAPIController.review_buyer(
                                order.product.id,
                              ),
                              // ba data.productId / vendorId jeita lagbe
                              rating: rating,
                              comment: comment,
                            );

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(msg)));
                          },
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _orange, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 15.w,
                          vertical: 4.h,
                        ),
                      ),
                      child: Text(
                        'Review',
                        style: TextStyle(
                          color: _orange,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
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
    );
  }
}

/// simple date format: dd/MM/yyyy
String _formatDate(DateTime? dt) {
  if (dt == null) return '';
  final d = dt.toLocal();
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  final year = d.year.toString();
  return '$day/$month/$year';
}
