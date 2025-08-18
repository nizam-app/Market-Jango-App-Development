import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
class CustomAuthButton extends StatelessWidget {

  CustomAuthButton({
    super.key,required this.buttonText, required this.onTap, 
    
  });
  final String buttonText;
  final VoidCallback onTap;

  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 55.h,
        decoration: BoxDecoration(
          color: AllColor.loginButtomColor,
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Center(
          child: Text("${buttonText}",style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 16.sp),),
        ),
      ),
    );
  }
}


class SplashSignUpButton extends StatelessWidget {

  SplashSignUpButton({
    super.key,required this.buttonText, required this.onTap,
  });
  final String buttonText;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 55.h,
        decoration: BoxDecoration(
          color: AllColor.green500,
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Center(
          child: Text("${buttonText}",style: Theme.of(context).textTheme.titleSmall!.copyWith(fontSize: 16.sp, color: Colors.white),),
        ),
      ),
    );
  }
}



class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
     
        
        child: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
          tooltip: 'Back',
        ),
    
    );
  }
}