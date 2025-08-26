import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/password_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class CodeScreen extends StatelessWidget {
  const CodeScreen({super.key});
  static final String routeName = '/codeScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children:  [
                SizedBox(height: 30.h),
                CustomBackButton(),
                CodeText(),
                OTPPin(),
                NextButton(), // Only one Next button
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CodeText extends StatelessWidget {
  const CodeText({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Center(child: Text("Enter your Code", style: textTheme.titleLarge)),
        SizedBox(height: 16.h),
        Center(
          child: Text(
            "011 221 333 56 Resend?",
            style: textTheme.titleSmall,
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
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

class NextButton extends StatelessWidget {
  const NextButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 50.h),

        CustomAuthButton(
          buttonText: "Next",
          onTap: () => context.push(PasswordScreen.routeName),
        ),
      ],
    );
  }
}
