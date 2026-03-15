import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logic/forget_password_reverport.dart';
import '../logic/verification_reverpod.dart';

class ForgetOTPVerificationScreen extends ConsumerWidget {
  const ForgetOTPVerificationScreen({super.key});
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
                          const SnackBar(
                            content: Text("Please enter 6-digit OTP"),
                          ),
                        );
                      }
                    },
                  ),
                  CustomVerificationResendText(
                    onEnter: onEnterWork,
                    loading: loading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onEnterWork({ref, context, isLoading}) {
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

class CustomVerificationResendText extends ConsumerStatefulWidget {
  CustomVerificationResendText({super.key, required this.onEnter, this.loading});
  final VoidCallback onEnter;
  final bool? loading;

  @override
  ConsumerState<CustomVerificationResendText> createState() =>
      _CustomVerificationResendTextState();
}

class _CustomVerificationResendTextState
    extends ConsumerState<CustomVerificationResendText> {
  static const int _countdownSeconds = 59;
  int _secondsRemaining = _countdownSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsRemaining = _countdownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _secondsRemaining--;
        if (_secondsRemaining <= 0) t.cancel();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final m = _secondsRemaining ~/ 60;
    final s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')} sec';
  }

  Future<void> _onResendTap() async {
    final isLoading = widget.loading ?? false;
    if (isLoading || _secondsRemaining > 0) return;
    widget.onEnter();
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';
    if (email.isNotEmpty) {
      await ref.read(forgetPasswordProvider.notifier).sendForgetPassword(
            context: context,
            email: email,
            resendOnly: true,
          );
      if (mounted) _startCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.loading ?? false;
    final canResend = _secondsRemaining <= 0 && !isLoading;
    return Column(
      children: [
        SizedBox(height: 32.h),
        Text.rich(
          TextSpan(
            text: "Didn't receive a code? ",
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: AllColor.grey),
            children: [
              TextSpan(
                text: isLoading ? "Resending" : "Resend",
                recognizer: TapGestureRecognizer()..onTap = _onResendTap,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: canResend ? AllColor.black : AllColor.grey,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(height: 32.h),
        Center(
          child: Text(
            _formattedTime,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }
}
