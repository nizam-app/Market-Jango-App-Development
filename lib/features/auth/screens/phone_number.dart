import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';

class PhoneNumberScreen extends StatelessWidget {
  const PhoneNumberScreen({super.key});
  static final String routeName = '/phoneNumberScreen'; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
        
            ],
          ),),
        ),
      ),

    );
  }
}