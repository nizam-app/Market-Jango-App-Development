import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';

import '../../../core/widget/global_review_dialog.dart';

class TransportCompleted extends StatefulWidget {
  const TransportCompleted({super.key});
  static const String routeName = "/completedOrders";

  @override
  State<TransportCompleted> createState() => _TransportCompletedState();
}

class _TransportCompletedState extends State<TransportCompleted> {
  String selectedTab = "Completed";
  final List<String> tabs = ["All", "Ongoing", "Completed", "Cancelled"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Column(
        children: [
          SizedBox(height: 20.h,), 
            CustomBackButton(), 
            SizedBox(height: 10.h,), 

          /// Tabs Row
          SizedBox(
            height: 55.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              itemCount: tabs.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                final tab = tabs[index];
                final bool isActive = selectedTab == tab;
                return GestureDetector(
                  onTap: () => setState(() => selectedTab = tab),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.orange : Colors.white,
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(
                          color: isActive ? Colors.orange : Colors.grey.shade400),
                    ),
                    child: Center(
                      child: Text(
                        tab,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: isActive ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          /// Booking List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: 3, // example count
              itemBuilder: (context, index) {
                return _bookingCard(
                  status: "Completed",
                  statusColor: Colors.green,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Booking Card Widget
  Widget _bookingCard({
    required String status,
    required Color statusColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Order ID + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Order #12345",
                  style: TextStyle(
                      fontSize: 14.sp, fontWeight: FontWeight.w600)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          /// Item + Driver Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  "https://www.pngall.com/wp-content/uploads/2016/07/Dress-Transparent.png",
                  height: 80.h,
                  width: 80.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.w),

              /// Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Driver Rahim Hossain",
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4.h),
                    Text("July 24,2025",
                        style:
                            TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text("Dhanmondi, Dhaka",
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.grey[700])),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.flag, size: 14.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text("Agartala, India",
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.grey[700])),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          /// Buttons
          Row(
            children: [
              /// See Details Button
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  onPressed: () {
                    context.push("/completedDetails"); 
                  },
                  child: Text("See details",
                      style: TextStyle(fontSize: 13.sp, color: Colors.white)),
                ),
              ),
              SizedBox(width: 10.w),

              /// Review Button (outlined)
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.orange, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  onPressed: () {
                    ReviewDialog.show(context); 
                  },
                  child: Text("Review",
                      style: TextStyle(fontSize: 13.sp, color: Colors.orange)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
