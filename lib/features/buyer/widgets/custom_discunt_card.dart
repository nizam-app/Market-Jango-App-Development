import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';

class CustomDiscountCord extends StatelessWidget {
  final String discount;
  const CustomDiscountCord({super.key, this.discount = ""});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AllColor.orange500,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        discount,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          fontSize: 12.sp,
          color: AllColor.white,
        ),
      ),
    );
  }
}
