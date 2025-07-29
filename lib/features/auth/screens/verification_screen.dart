import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:pin_code_fields/pin_code_fields.dart';


import 'new_password_screen.dart';
class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});
  static const String routeName = '/verification_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body:ScreenBackground(child: SingleChildScrollView(
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 20.w),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 30.h),
              CustomBackButton(),
              VerifiUpperText(),
              OTPPin(),
              CustomAuthButton(buttonText: "Verify", onTap: (){gotoNextScreen(context);},),
            ],
          ),
        ),
      ),
    ),),);
  }
  void gotoNextScreen(BuildContext context) {
    context.push(NewPasswordScreen.routeName);
  }
}


class OTPPin extends StatelessWidget {
  const OTPPin({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PinCodeTextField(
            appContext: context,
            length: 6,
            onChanged: (value) {},
            onCompleted: (code) {
              print("OTP Entered: $code");
            },
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(8),
              fieldHeight: 52.h,
              fieldWidth: 44.w,
              activeFillColor: Colors.grey.shade200,
              inactiveFillColor: Colors.grey.shade200,
              selectedFillColor: Colors.grey.shade300,
              activeColor: Colors.transparent,
              inactiveColor: Colors.transparent,
              selectedColor: Colors.transparent,
            ),
            keyboardType: TextInputType.number,
            enableActiveFill: true,
          ),
          SizedBox(height: 50.h), // Reduced height for better layout
        ],
      ),
    );
  }
}

class VerifiUpperText extends StatelessWidget {
  const VerifiUpperText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
         SizedBox(height: 190.h,),
        Text("Verification",style: Theme.of(context).textTheme.titleLarge,),
         SizedBox(height: 20.h,),
        Text("We sent Verification code to your Email address",style: Theme.of(context).textTheme.titleMedium,),
      ],
    );
  }
}
