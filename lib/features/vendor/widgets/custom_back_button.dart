import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
    this.onTap,
  });

  /// When null, pops the current route if [context.canPop]; otherwise does nothing.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else if (context.canPop()) {
          context.pop();
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Container(
          height: 24.w,
          width: 24.w,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xffF5F4F8),
          ),
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 10.r,
          ),
        ),
      ),
    );
  }
}