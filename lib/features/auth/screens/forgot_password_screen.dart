import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/login/logic/email_validator.dart';
import '../logic/forget_password_reverport.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  static const String routeName = '/forgot_password';

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgetPasswordProvider);
    final notifier = ref.read(forgetPasswordProvider.notifier);

    ref.listenManual(forgetPasswordProvider, (prev, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        ),
      );
    });

    return Scaffold(
      body: ScreenBackground(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 30.h),
                  const CustomBackButton(),
                  const ForgetUpperText(),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailController,
                          validator: emailValidator,
                          decoration: InputDecoration(
                            hintText: 'Email Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),
                        CustomAuthButton(
                          buttonText:
                          state.isLoading ? "Sending..." : "Submit",
                          onTap: state.isLoading
                              ? (){}
                              : () {
                            if (_formKey.currentState!.validate()) {
                              notifier.sendForgetPassword(
                                context: context,
                                email: emailController.text.trim(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ForgetUpperText extends StatelessWidget {
  const ForgetUpperText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 190.h),
        Text(
          "Recover Password",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 20.h),
        Text(
          "Enter the Email Address that you used when \nregistering to recover your password. You will receive a \nverification code.",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(height: 1.4),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 50.h),
      ],
    );
  }
}
