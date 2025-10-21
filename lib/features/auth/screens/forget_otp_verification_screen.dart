import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../logic/forget_password_reverport.dart';
import '../logic/phone_otp_riverpod.dart';
import '../logic/verification_reverpod.dart';

class ForgetOTPVerificationScreen extends ConsumerWidget {
  const ForgetOTPVerificationScreen({super.key,});
  static const String routeName = '/verification_screen';
  // final String? email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(forgetPasswordProvider).isLoading;
    final otpController = TextEditingController();

    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 30.h),
                  const CustomBackButton(),
                  const VerifiUpperText(),

                  // 🔢 OTP Input
                  OTPPin(controller: otpController),

                  // ✅ Submit Button
                  CustomAuthButton(
                    buttonText: "Next",
                    onTap: () {
                      final otp = otpController.text.trim();
                      if (otp.length == 6) {
                        verifyOtpFunction(context: context, otp: otp);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter 6-digit OTP")),
                        );
                      }
                    },
                  ),
                  CustomVerificationResendText(onEnter: onEnterWork, loading: loading,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  void onEnterWork ({ref, context, isLoading}){
    // final notifier = ref.read(forgetPasswordProvider.notifier);
    // isLoading
    //     ? (){}
    //     : notifier.sendForgetPassword(
    //   context: context,
    //   email: emailController.text.trim(),
    // );

  }
}

class OTPPin extends StatelessWidget {
  const OTPPin({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          PinCodeTextField(
            appContext: context,
            length: 6,
            controller: controller,
            onChanged: (_) {},
            keyboardType: TextInputType.number,
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
            enableActiveFill: true,
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}

class VerifiUpperText extends StatelessWidget {
  const VerifiUpperText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 190.h),
        Text("Verification", style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 20.h),
        Text(
          "We sent a verification code to your email address.",
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 56.h),
      ],
    );
  }
}

class CustomVerificationResendText extends ConsumerWidget {
   CustomVerificationResendText({super.key, required this.onEnter,this.loading});
  final VoidCallback onEnter;
   var loading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Column(
      children: [
        SizedBox(height: 32.h),
        Text.rich(
          TextSpan(
            text: "Didn't receive a code? ",
            style: Theme.of(context).textTheme.titleSmall!.copyWith(color: AllColor.grey),
            children: [
              TextSpan(
                text: loading? "Resending": "Resend",
                onEnter: (_) =>  loading ? () {} : onEnter,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AllColor.black,
                  fontWeight: FontWeight.w700,

                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 32.h),
        Center(
          child: Text(
            "00:59 sec",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }
}
