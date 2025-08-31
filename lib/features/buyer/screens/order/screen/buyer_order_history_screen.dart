import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/widget/global_review_dialog.dart';

import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/features/buyer/screens/order/data/order_history_data.dart';
import 'package:market_jango/features/buyer/screens/order/model/order_history_model.dart';
import 'package:market_jango/features/transport/screens/transport_completed.dart';

import '../../../../../core/constants/color_control/all_color.dart';

class BuyerOrderHistoryScreen extends StatelessWidget {
  const BuyerOrderHistoryScreen({super.key});
  static const routeName = '/buyer_order_history';

  @override
  Widget build(BuildContext context) {
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
                  child: ListView.separated(
                    itemCount: demoReviewOrders.length,
                    physics: const BouncingScrollPhysics(),
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (_, i) => _ReviewTile(data: demoReviewOrders[i]),
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
  const _ReviewTile({required this.data});
  final ReviewOrder data;

  static const _orange = Color(0xFFFF8A00);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.r),
        border: Border.all(color: Colors.black12.withOpacity(.01)), // light border (image2)
      ),
      child: Row(
        children: [
          // left image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.network(
              data.imageUrl,
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
                Text(
                  data.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.sp, color: AllColor.black),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Order ${data.orderId}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AllColor.black,
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    // date chip
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6F8),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        data.dateText,
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Spacer(),
                    // review button (orange outline)
                    OutlinedButton(

                      onPressed:(){ReviewDialog.show(context);},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _orange, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 4.h),
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
