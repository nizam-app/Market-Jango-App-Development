import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/screen/global_notification/data/notification_data.dart';
import 'package:market_jango/core/screen/global_notification/screen/global_notifications_screen.dart';

class GlobalNotificationIcon extends ConsumerWidget {
  const GlobalNotificationIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(notificationUnreadCountProvider);

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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(Icons.notifications, size: 15.sp),
            onPressed: () {
              context.push(GlobalNotificationsScreen.routeName);
            },
          ),
          if (unread > 0)
            Positioned(
              right: 2.w,
              top: 2.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(minWidth: 14.w, minHeight: 14.w),
                child: Center(
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
