import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_search_bar.dart';

class VendorHomeScreen extends StatefulWidget {
  const VendorHomeScreen({super.key});

  @override
  State<VendorHomeScreen> createState() => _VendorHomeScreenState();
}

class _VendorHomeScreenState extends State<VendorHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white24,
        body: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 25.h),
                buildProfileScetion(),
                SizedBox(height: 30.h),
                CustomSearchBar(),




              ],
            ),
          ),
        ),
      
      ),
    );
  }

  Widget buildProfileScetion() {
    return Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    SizedBox(
                      width: 90.w,
                      height: 86.w,
                      child: Container(
                        height: 82.w,
                        width: 82.w,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                width: 1.w,
                                color: AllColor.loginButtomColor
                            ),
                            image: DecorationImage(image: AssetImage("assets/images/vendor_profile.png",),fit: BoxFit.cover)
                        ),

                      ),

                    ),
                    Positioned(
                        top: 15,
                        left: 8,
                        child: Container(
                          height: 10.w,
                          width: 10.w,
                          decoration: BoxDecoration(
                              color: AllColor.activityColor,
                              shape: BoxShape.circle
                          ),
                        )),
                    Positioned(
                        bottom: 10,
                        right: 0,
                        child: Container(
                          height: 21.w,
                          width: 21.w,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle
                          ),
                          child: ImageIcon(AssetImage("assets/icon/edit_ic.png")),
                        ))
                  ],
                ),

              ),
              SizedBox(height: 20.h),
              Text("TrendLoop",style: TextStyle(fontSize: 16.sp,color: AllColor.loginButtomColor))
            ],
          );
  }
}
