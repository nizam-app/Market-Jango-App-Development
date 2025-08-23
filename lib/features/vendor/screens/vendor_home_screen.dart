import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_new_product.dart';
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
        body: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 25.h),
              buildProfileScetion(),
              SizedBox(height: 30.h),
              CustomSearchBar(),
              SizedBox(height: 10.h),
              Expanded(
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      childAspectRatio: 9/13,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 15
                        ),

                    itemCount: 10,
                    itemBuilder: (context,index){
                      if(index==0){
                        return buildAddUrProduct(context);
                      }
                      else{
                        return CustomNewProduct(width: 169.w,height: 262.h,);
                      }


                    }),
              )






            ],
          ),
        ),
      
      ),
    );
  }

  Widget buildAddUrProduct(BuildContext context) {
    return Card(
                        elevation: 2,
                        child: Container(
                          height: 244.h,
                          width: 169.w,
                          decoration: BoxDecoration(

                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 30,
                            children: [
                              Icon(Icons.add, size: 70,color: Color(0xff575757),),
                              Text("Add your\nProduct",style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Color(0xff2F2F2F),fontWeight: FontWeight.w700))
                            ],
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
