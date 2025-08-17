import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});
  static final routeName = "/filterScreen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child:
      SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              Tuppertextandbackbutton(screenName: "Filteing Name"),
              buildLocation(context),
          GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                // mainAxisSpacing: 0.h,
                crossAxisSpacing: 9.w,
                childAspectRatio: 0.6.h,
              ),
              itemCount: 20,
              // Example item count
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        // Image
                        Image.asset(
                          'assets/images/clothing3.jpg', // আপনার ইমেজ পাথ দিন এখানে
                          fit: BoxFit.cover,
                        ),
                        // Discount Tag
                        Positioned(
                          top: 0.h,
                          right: 0.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: AllColor.yellow500,
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Text(
                              '-20%',
                              style:Theme.of(context).textTheme.titleLarge!.copyWith(
                                  fontSize: 12.sp,color: AllColor.white
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.h),
                      child: Column(
                        children: [
                          Text("T shirt",style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AllColor.black),),
                          Text("\$120.00",style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.w500),)
                        ],
                      ),
                    )
                  ],
                );}
          )

            ],
          ),
        ),
      )),
    );
  }

  Column buildLocation(BuildContext context) {
    return Column(
      children: [
        Row(
                  children: [
                    Icon(Icons.location_on,size: 16.sp,color: AllColor.blue900,),
                    SizedBox(width: 4.w,),
                    Text("Dhaka,Bangladesh",style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontSize: 14.sp,color: AllColor.blue500),)
                 ],
                ),
        SizedBox(height: 10.h,)
      ],
    );
  }
}
