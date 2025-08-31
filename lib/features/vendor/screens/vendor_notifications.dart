import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/buyer/data/notification_list.dart';

class VendorNotifications extends StatefulWidget {
  const VendorNotifications({super.key});

   static const String routeName = '/vendor_notificatons';

  @override
  State<VendorNotifications> createState() => _VendorNotificationsState();
}

class _VendorNotificationsState extends State<VendorNotifications> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
       body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 10.w),
          child: Column(
            children: [
              //Tuppertextandbackbutton(screenName: "Notification"),
              Align(
                alignment: Alignment.center,
                child: Text("Notification",style:TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),), 
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return NotificationTile(
                      title: item['title']!,
                      time: item['time']!,
                      isUnread: item['unread'] == 'true',
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String title;
  final String time;
  final bool isUnread;

  const NotificationTile({
    super.key,
    required this.title,
    required this.time,
    required this.isUnread,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  EdgeInsets.only(bottom: 16.h),
      padding:  EdgeInsets.symmetric(horizontal: 16.w,vertical: 16.h),
      decoration: BoxDecoration(
        color:isUnread ? AllColor.grey100:AllColor.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AllColor.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
           CircleAvatar(
            backgroundColor: AllColor.blue50,
            radius: 24.r,
            child: Icon(Icons.notifications_none, color: AllColor.blue),
          ),
           SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w500),
                ),
                 SizedBox(height: 4.h),
                 Text(
                  'Learn more about managing account info and activity',
                  style: Theme.of(context).textTheme.titleMedium,
                )
              ],
            ),
          ),
           SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 8.sp),
              ),

               SizedBox(height: 8.h),
              if (isUnread)
                 CircleAvatar(
                  radius: 5.r,
                  backgroundColor: AllColor.orange700,
                )
            ],
          )
        ],
      ),
    );
  }
   
}