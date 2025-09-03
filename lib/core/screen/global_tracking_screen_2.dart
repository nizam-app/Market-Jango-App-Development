import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'buyer_massage/screen/global_chat_screen.dart';

class GlobalTrackingScreen2 extends StatelessWidget {
  const GlobalTrackingScreen2({super.key});
  static const String routeName = "/transport_booking3";

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
                _progressLine(true),
                _progressCircle(true),
              ],
            ),
            SizedBox(height: 20.h),

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

            /// Timeline Events
            _timelineItem(
              title: "Packed",
              desc:
                  "Your parcel is packed and will be handed over to our delivery partner.",
              time: "April.19 12:31",
            ),
            _timelineItem(
              title: "On the Way to Logistic Facility",
              desc:
                  "Lorem ipsum dolor sit amet consectetur adipiscing elit.",
              time: "April.19 16:20",
            ),
            _timelineItem(
              title: "Arrived at Logistic Facility",
              desc:
                  "Lorem ipsum dolor sit amet consectetur adipiscing elit.",
              time: "April.19 19:07",
            ),
            _timelineItem(
              title: "Shipped",
              desc:
                  "Lorem ipsum dolor sit amet consectetur adipiscing elit.",
              time: "April.20 06:15",
            ),
            _timelineItem(
              title: "Out for Delivery",
              desc:
                  "Lorem ipsum dolor sit amet consectetur adipiscing elit.",
              time: "April.22 11:10",
            ),

            /// Failed Attempt (special styling)
            InkWell(
              onTap: (){
                DeliveryFailedPopup.show(context); 
              },
              child: _timelineItem(
                title: "Attempt to deliver your parcel was not successful →",
                desc:
                    "Lorem ipsum dolor sit amet consectetur adipiscing elit.",
                time: "April.19 12:50",
                highlight: true,
              ),
            ),
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
    bool highlight = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title + Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: highlight ? Colors.orange : Colors.black)),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: highlight
                     ?  Colors.orange.withOpacity(0.1)
                     :Colors.grey.shade200,
                      
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: highlight ? Colors.orange : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(desc,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: highlight ? Color(0xFF0059A0) : Colors.grey[700])),
        ],
      ),
    );
  }
}



class DeliveryFailedPopup {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header with Blue Bar
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Delivery was not successful",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              /// Subtitle
              Text("What should I do?",
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),

              /// Info Text
              Text(
                "Don’t worry, we will shortly contact you to arrange more suitable time for the delivery. "
                "You can also contact us by using this number +00 000 000 000 or chat with our customer care service.",
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
              ),
              SizedBox(height: 20.h),

              /// Chat Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  onPressed: () {
                    context.push(ChatScreen.routeName) ;
                    // BookingSuccessPopup.show(context, "Your Booking\nHas been Successfull");
                  
                  },
                  child: Text("Chat Now",
                      style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                ),
              ),
              SizedBox(height: 50.h),
            ],
          ),
        );
      },
    );
  }
}