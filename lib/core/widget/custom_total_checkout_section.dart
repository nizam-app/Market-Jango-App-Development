import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/buyer/screens/prement/screen/buyer_payment_screen.dart';

class CustomTotalCheckoutSection extends StatelessWidget {
  const CustomTotalCheckoutSection({
    super.key,
    required this.totalPrice,
    required this.context,
  });

  final double totalPrice;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AllColor.white,
        boxShadow: [
          BoxShadow(
            color: AllColor.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, -3.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ==== TOTAL TEXT ====
          Row(
            children: [
              Text(
                "Total ",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AllColor.black,
                ),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2).replaceAll(".", ",")}', // 34,00
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AllColor.black,
                ),
              ),
            ],
          ),

          // ==== CHECKOUT BUTTON ====
          ElevatedButton(
            onPressed: () {
              context.push(BuyerPaymentScreen.routeName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AllColor.blue, // Blue button
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r), // not fully round
              ),
            ),
            child: Text(
              "Checkout",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AllColor.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}