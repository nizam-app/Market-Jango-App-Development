import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../features/buyer/screens/order/screen/buyer_order_page.dart';
import '../../features/vendor/widgets/custom_back_button.dart';
import 'global_tracking_screen_2.dart';


class GlobalTrackingScreen1 extends StatefulWidget {
  const GlobalTrackingScreen1({super.key, required this.screenName});
  static const String routeName = "/transportTracking";
  final String screenName;

  @override
  State<GlobalTrackingScreen1> createState() => _GlobalTrackingScreen1State();
}



class _GlobalTrackingScreen1State extends State<GlobalTrackingScreen1> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _redirectTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      // replace = true (current screen replace করবে)
      context.push(
        GlobalTrackingScreen2.routeName,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h,),
            CustomBackButton(),
            SizedBox(height: 10.h,),
            /// Avatar + Title
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: const NetworkImage(
                      "https://randomuser.me/api/portraits/women/65.jpg"),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("To Receive",
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    Text("Track Your Order",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                  ],
                )
              ],
            ),
            SizedBox(height: 20.h),

            /// Progress Bar
            Row(
              children: [
                _progressCircle(true),
                _progressLine(true),
                _progressCircle(true),
                _progressLine(false),
                _progressCircle(false),
              ],
            ),
            SizedBox(height: 20.h),

            /// Current Status
            Text("Packed",
                style: TextStyle(
                    fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),

            /// Tracking Number
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tracking Number",
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("LGS-129827839300763731",
                          style: TextStyle(fontSize: 13.sp)),
                      Icon(Icons.copy, color: Colors.grey, size: 20.sp),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            /// Timeline Items
            _timelineItem(
              title: "Packed",
              desc: "Your parcel is packed and will be handed over to our delivery partner.",
              time: "April.19 12:31",
              active: true,
            ),
            InkWell(
              onTap: (){
                context.push("/transport_booking3");
              },
              child: _timelineItem(
                title: "On the Way to Logistic Facility",
                desc: "Lorem ipsum dolor sit amet consectetur adipiscing elit.",
                time: "April.19 16:20",
                active: true,
              ),
            ),
            _timelineItem(
              title: "Arrived at Logistic Facility",
              desc: "Lorem ipsum dolor sit amet consectetur adipiscing elit.",
              time: "April.19 19:07",
              active: true,
            ),
            _timelineItem(
              title: "Shipped",
              desc: "Lorem ipsum dolor sit amet consectetur adipiscing elit.",
              time: "Expected on April.20",
              active: false,
              shipped: true,
            ),
            SizedBox(height: 20.h),
if (widget.screenName != BuyerOrderPage.routeName)
           Column(
             children: [
               Text("Driver Information",
                   style: TextStyle(
                       fontSize: 16.sp, fontWeight: FontWeight.bold)),
               SizedBox(height: 10.h),
               Container(
                 padding: EdgeInsets.all(12.w),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(12.r),
                   border: Border.all(color: Colors.grey.shade300),
                 ),
                 child: Row(
                   children: [
                     CircleAvatar(
                       radius: 20.r,
                       backgroundImage: const NetworkImage(
                           "https://randomuser.me/api/portraits/men/43.jpg"),
                     ),
                     SizedBox(width: 12.w),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text("Mr John Doe",
                               style: TextStyle(
                                   fontSize: 14.sp,
                                   fontWeight: FontWeight.w600)),
                           Text("01780053624",
                               style: TextStyle(
                                   fontSize: 12.sp, color: Colors.grey[600])),
                         ],
                       ),
                     ),
                     IconButton(
                       icon: const Icon(Icons.message, color: Colors.blue),
                       onPressed: () {},
                     ),
                     IconButton(
                       icon: const Icon(Icons.call, color: Colors.green),
                       onPressed: () {},
                     ),
                   ],
                 ),
               ),
             ],
           )

          ],
        ),
      ),
    );
  }

  /// Progress Circle Widget
  Widget _progressCircle(bool active) {
    return CircleAvatar(
      radius: 10.r,
      backgroundColor: active ? Colors.blue : Colors.grey.shade300,
    );
  }

  /// Progress Line Widget
  Widget _progressLine(bool active) {
    return Expanded(
      child: Container(
        height: 3.h,
        color: active ? Colors.blue : Colors.grey.shade300,
      ),
    );
  }

  /// Timeline Item
  Widget _timelineItem({
    required String title,
    required String desc,
    required String time,
    bool active = false,
    bool shipped = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: shipped
                          ? Colors.blue
                          : Colors.black)),
              Text(time,
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: shipped ? Colors.blue : Colors.grey)),
            ],
          ),
          SizedBox(height: 4.h),
          Text(desc,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: shipped ? Colors.blue : Colors.grey[700])),
        ],
      ),
    );
  }
}
