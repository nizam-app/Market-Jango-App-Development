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
                _glossyCircle(active: true),
        _glossyLine(active: true),
        _glossyCircle(active: true),
        _glossyLine(active: false),
        _glossyCircle(active: false),
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
  // Widget _progressCircle(bool active) {
  //   return CircleAvatar(
  //     radius: 10.r,
  //     backgroundColor: active ? Colors.blue : Colors.grey.shade300,
  //   );
  // }
  //
  // /// Progress Line Widget
  // Widget _progressLine(bool active) {
  //   return Expanded(
  //     child: Container(
  //       height: 3.h,
  //       color: active ? Colors.blue : Colors.grey.shade300,
  //     ),
  //   );
  // }

  Widget _glossyCircle({required bool active}) {
    final Gradient gActive = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF58A6FF), Color(0xFF0B3E7C)],
    );
    final Gradient gInactive = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF9FB1C2), Color(0xFF6F8091)],
    );

    // Outer glow color
    final Color glow = active
        ? const Color(0xFF58A6FF).withOpacity(0.35)
        : const Color(0xFF9FB1C2).withOpacity(0.30);

    return Stack(
      alignment: Alignment.center,
      children: [
        // soft halo
        Container(
          width: 28.r,
          height: 28.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: glow, blurRadius: 16.r, spreadRadius: 2.r),
            ],
          ),
        ),

        // white ring
        Container(
          width: 24.r,
          height: 24.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
        ),

        // inner glossy disc
        Container(
          width: 16.r,
          height: 16.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: active ? gActive : gInactive,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 4.r,
                offset: Offset(0, 2.h),
              ),
            ],
            border: Border.all(color: Colors.white, width: 2.r),
          ),
        ),
      ],
    );
  }

  Widget _glossyLine({required bool active}) {
    final Gradient gActive = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF6DB2FF), Color(0xFF0D4183)],
    );
    final Gradient gInactive = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFFE5EBF1), Color(0xFFDDE3EA)],
    );

    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // outer soft glow
          Container(
            height: 12.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: (active ? const Color(0xFF6DB2FF) : const Color(0xFFCAD4DE))
                      .withOpacity(0.35),
                  blurRadius: 12.r,
                  spreadRadius: 1.r,
                ),
              ],
            ),
          ),

          // main track
          Container(
            height: 6.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              gradient: active ? gActive : gInactive,
            ),
          ),

          // subtle top highlight to fake “emboss”
          Positioned.fill(
            child: Align(
              alignment: const Alignment(0, -0.6),
              child: Container(
                height: 1.2.h,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(1.r),
                ),
              ),
            ),
          ),

          // subtle bottom shadow line
          Positioned.fill(
            child: Align(
              alignment: const Alignment(0, 0.7),
              child: Container(
                height: 1.2.h,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(1.r),
                ),
              ),
            ),
          ),
        ],
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