import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';

class GlobalSaveBotton extends ConsumerWidget {
  const GlobalSaveBotton({
    super.key, required this.bottonName,required this.onPressed,
  });
  final String bottonName;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context,ref ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AllColor.orange700,
          foregroundColor: AllColor.white,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: Text(
          // bottonName
           bottonName,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AllColor.black
          ),
        ),
      ),
    );
  }
}
