import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/api_control/auth_api.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/email_screen.dart';
import 'package:market_jango/features/auth/screens/forget_otp_verification_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../logic/phone_otp_riverpod.dart';

class CodeScreen extends ConsumerStatefulWidget {
  const CodeScreen({super.key});
  static const String routeName = '/codeScreen';

  @override
  ConsumerState<CodeScreen> createState() => _CodeScreenState();
}


class _CodeScreenState extends ConsumerState<CodeScreen> {
  String _otp = '';

  Future<void> _submit() async {
    if (_otp.length != 6) {
      GlobalSnackbar.show(context,
          title: "Error",
          message: "Enter a valid 6-digit OTP",
          type: CustomSnackType.error);
      return;
    }

    try {
      final notifier = ref.read(verifyOtpProvider.notifier);
      await notifier.verifyOtp(
        url: AuthAPIController.phoneVerifyOtp,
        otp: _otp,
      );

      final state = ref.read(verifyOtpProvider);

      // ✅ Direct result handle
      state.when(
        data: (ok) {
          if (ok) {
            GlobalSnackbar.show(context,
                title: "Success",
                message: "OTP verified successfully!",
                type: CustomSnackType.success);

            // ✅ Navigate instantly
            context.pushReplacement(EmailScreen.routeName);
          } else {
            GlobalSnackbar.show(context,
                title: "Error",
                message: "Verification failed. Try again.",
                type: CustomSnackType.error);
          }
        },
        error: (e, _) => GlobalSnackbar.show(context,
            title: "Error",
            message: e.toString(),
            type: CustomSnackType.error),
        loading: () {},
      );
    } catch (e) {
      GlobalSnackbar.show(context,
          title: "Error", message: e.toString(), type: CustomSnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(verifyOtpProvider).isLoading;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 30.h),
              const CustomBackButton(),
              SizedBox(height: 20.h),
              Center(child: Text("Enter your Code", style: t.titleLarge)),
              SizedBox(height: 12.h),
              Text("We’ve sent a code to your number", style: t.titleSmall),
              SizedBox(height: 30.h),
              PinCodeTextField(
                appContext: context,
                length: 6,
                onChanged: (v) => _otp = v,
                onCompleted: (v) => _otp = v,
                keyboardType: TextInputType.number,
                enableActiveFill: true,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(6),
                  fieldHeight: 52.h,
                  fieldWidth: 44.w,
                  activeFillColor: Colors.grey.shade200,
                  inactiveFillColor: Colors.grey.shade200,
                  selectedFillColor: Colors.grey.shade300,
                  activeColor: Colors.transparent,
                  inactiveColor: Colors.transparent,
                  selectedColor: Colors.transparent,
                ),
              ),
              SizedBox(height: 50.h),
              CustomAuthButton(
                buttonText: loading ? "Verifying..." : "Next",
                onTap: loading ? () {} : _submit,
              ),
              CustomVerificationResendText(onEnter: () {  },)
            ],
          ),
        ),
      ),
    );
  }
}
