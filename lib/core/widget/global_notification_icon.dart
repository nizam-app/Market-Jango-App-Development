import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/screen/global_notification/screen/global_notifications_screen.dart';

class GlobalNotificationIcon extends StatelessWidget {
  const GlobalNotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.h,
      width: 35.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 0.5.sp),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(Icons.notifications, size: 15.sp),
        onPressed: () {
          goToNotificationScreen(context);
        },
      ),
    );
  }

  void goToNotificationScreen(BuildContext context) {
    context.push(GlobalNotificationsScreen.routeName);
  }
}
