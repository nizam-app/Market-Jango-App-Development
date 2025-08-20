import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:market_jango/core/constants/color_control/all_color.dart';

class CustomDiscountCord extends StatelessWidget {
  const CustomDiscountCord({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0.h,
      right: 0.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AllColor.yellow500,
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Text(
          '-20%',
          style:Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 12.sp,color: AllColor.white
          ),
        ),
      ),
    );
  }
}
