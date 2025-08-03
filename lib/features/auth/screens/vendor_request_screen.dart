import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';

class VendorRequestScreen extends StatelessWidget {
  const VendorRequestScreen({super.key});
  static final String routeName = '/vendor_request';

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(children: [
              SizedBox(height: 30.h,),
              CustomBackButton(), 
              VendorRequestText(), 

                
            ] 
          ),
        ),
      ),
    )
    );
    
  }
}


class VendorRequestText extends StatelessWidget {
  const VendorRequestText({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Center(child: Text("Create Store", style: textTheme.titleLarge)),
        SizedBox(height: 20.h),
        Center(
          child: Text(
            "Get started with your access in just a few steps",
            style: textTheme.bodySmall,
          ),
        ),
        SizedBox(height: 56.h),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'New Password',
            suffixIcon: Icon(Icons.visibility_off_outlined)
          ),
          obscureText: true,
        ),
        SizedBox(height: 30.h,),
        TextFormField(
          decoration: InputDecoration(
              hintText: 'Confirm Password',
              suffixIcon: Icon(Icons.visibility_off_outlined)
          ),
          obscureText: true,
        ),
        
      ],
    );
  }
}
 