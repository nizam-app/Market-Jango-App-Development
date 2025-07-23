import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';

class VendorRequestFrom extends StatelessWidget {
  const VendorRequestFrom({super.key});
  static final String routeName ='/vendorRequstFrom'; 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(children: [

              
            ]),
          ),
        ),
      ),
    );
  }

}
