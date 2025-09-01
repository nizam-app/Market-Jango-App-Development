import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/car_info.dart';
import 'package:market_jango/features/auth/screens/phone_number.dart';
import 'package:market_jango/features/auth/screens/vendor_request_from.dart';
import 'package:market_jango/features/auth/screens/vendor_request_screen.dart';

class NameScreen extends StatelessWidget {
  const NameScreen({super.key, required this.roleName});
  final String roleName;
  static final String routeName = '/nameScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.w),
            child: Column(
                children: [
               SizedBox(height: 30.h),
               CustomBackButton(),
              NameText(), 
              NextBotton(role: roleName,)]),
          ),
        ),
      ),
    );
  }
}

class NameText extends StatelessWidget {
  const NameText({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20.h),
        Center(child: Text("What's your name", style: textTheme.titleLarge)),
        SizedBox(height: 24.h),
        TextFormField(
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            hintText: "Enter your name",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
        ),
      ],
    );
  }
}

class NextBotton extends StatelessWidget {
  const NextBotton({super.key, required this.role});
  final String role;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12.h),
        Text(
          "This is ho it'll appear on your $role profile  ",            textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall,     
        ),

        Text(
          "Can't change it letter ",
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AllColor.loginButtomColor,
            fontWeight: FontWeight.w300,
          ),
        ),

        SizedBox(height: 40.h),
        CustomAuthButton(
          buttonText: "Next",
          onTap: ()=> nextButonDone(context,role),
           ),
      ],
    );
  }


  void nextButonDone(BuildContext context,String role) {
    if (role == "Vendor") {
          context.push(VendorRequestScreen.routeName) ;
    }  else if(role == "Driver") {
      context.push(CarInfoScreen.routeName) ;
    }  else{
           context.push(PhoneNumberScreen.routeName);
    }


  }
  }