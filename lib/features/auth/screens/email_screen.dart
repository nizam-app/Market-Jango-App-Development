import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/login/logic/email_validator.dart';
import 'package:market_jango/features/auth/screens/password_screen.dart';

class EmailScreen extends StatelessWidget {
  const EmailScreen({super.key});
  static final String routeName = '/emailScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 30.h),
                CustomBackButton(),
                EmailText(),
                NextBotton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmailText extends StatelessWidget {
  const EmailText({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        SizedBox(height: 20.h),
        Center(child: Text("Your email ", style: textTheme.titleLarge)),
        SizedBox(height: 14.h),

        Center(
        
          child: Text(
            "Don't lose access to your account, verify\n your email ",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        SizedBox(height: 24.h),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: emailValidator,
          decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
        ),
      ],
    );
  }
}

class NextBotton extends StatelessWidget {
  const NextBotton({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 120.h),
        CustomAuthButton(
          buttonText: "Next",
          onTap: () => nextButonDone(context),
        ),
      ],
    );
  }

  void nextButonDone(BuildContext context) {
    goToPasswordScreen(context);
  }

  void goToPasswordScreen(BuildContext context) {
    context.push(PasswordScreen.routeName);
  }
}