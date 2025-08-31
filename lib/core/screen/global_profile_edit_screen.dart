import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/global_save_botton.dart';
import 'package:market_jango/features/buyer/screens/prement/widget/show_shipping_address_sheet.dart';
class BuyerProfileEditScreen extends StatelessWidget {
  const BuyerProfileEditScreen({super.key});
  static final routeName= "/buyerProfileEditScreen";

  @override
  Widget build(BuildContext context) {

    final nameC = TextEditingController(text: "Mirable Lily");
    final emailC = TextEditingController(text: "mirable@gmail.com");
    final phoneC = TextEditingController(text: "(319) 555-0115");
    final aboutC = TextEditingController(
        text:
        "Lorem ipsum dolore amet. consectetur adipisicing elit n’s. Curabitur tempus donec con loreet, eget finibus pharetra.");
    final locationC = TextEditingController(text: "Chicago, United States");

    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                children: [
                  Tuppertextandbackbutton(screenName: "My Profile") ,
                  buildStackProfileImage()      ,
                  CustomTextFormField(label: "Your Name", controller: nameC),
                  SizedBox(height: 12.h),
                  CustomTextFormField(label: "Email", controller: emailC),
                  SizedBox(height: 12.h),
                  CustomTextFormField(label: "Phone", controller: phoneC),

                  SizedBox(height: 12.h),
                  // ---- Gender & Age Row ----
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          label: "Gender",
                          controller: TextEditingController(text: "Female"),
                          hintText: "Select Gender",
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: CustomTextFormField(
                          label: "Age",
                          controller: TextEditingController(text: "23"),
                          hintText: "Enter Age",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),
                  CustomTextFormField(
                    label: "About",
                    controller: aboutC,
                    maxLines: 3,
                  ),

                  SizedBox(height: 12.h),
                  CustomTextFormField(
                    label: "Location",
                    controller: locationC,
                    hintText: "Enter Location",
                  ),
                  SizedBox(height: 20.h,)     ,
                  GlobalSaveBotton(bottonName: "Save Changes")
                ],

                    ),
            ),
          )),
    );
  }

  Stack buildStackProfileImage() {
    return Stack(
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundImage: NetworkImage("https://picsum.photos/200"),
                ),
                Positioned(
                  bottom: 0.h,
                  right: 0.w,
                  child: CircleAvatar(

                    radius: 12.r, backgroundColor: AllColor.white,
                    child: Padding(
                      padding:  EdgeInsets.all(5.r),
                      child: Icon(Icons.camera_alt,color: AllColor.black,size: 15.sp,),
                    ),
                  ),
                ),
              ],
            );
  }
}