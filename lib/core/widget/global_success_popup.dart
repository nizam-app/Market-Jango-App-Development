import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/features/navbar/screen/buyer_bottom_nav_bar.dart';
import 'package:market_jango/features/navbar/screen/vendor_bottom_nav.dart';

import '../../features/navbar/screen/transport_bottom_nav_bar.dart';

class BookingSuccessPopup {
  static void show(BuildContext context,String massage) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must click button
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.orange, width: 2),
                  ),
                  child: Icon(Icons.check, size: 28.sp, color: Colors.orange),
                ),
                SizedBox(height: 16.h),

                /// Success Text
                Text(
                  massage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20.h),


                GestureDetector(
                  onTap: () {
                   // context.push(BuyerBottomNavBar.routeName);
                    context.pop(); 

                  },
                  child: Text(
                    "Go to Home",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                ),

                // GestureDetector(
                //   onTap: () {
                //
                //     String role = "buyer" ;
                //     if (role == "buyer") {
                //       context.push(BuyerBottomNavBar.routeName);
                //     } else if (role == "vendor") {
                //       context.push(VendorBottomNav.routeName);
                //     } else if (role == "transport") {
                //       context.push(TransportBottomNavBar.routeName);
                //     } else {
                //       // fallback
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         const SnackBar(content: Text("Invalid role")),
                //       );
                //     }
                //   },
                //   child: Text(
                //     "Go to Home",
                //     style: TextStyle(
                //       fontSize: 15.sp,
                //       fontWeight: FontWeight.w600,
                //       color: Colors.orange,
                //     ),
                //   ),
                // )

              ],
            ),
          ),
        );
      },
    );
  }
}