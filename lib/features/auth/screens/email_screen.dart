import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';

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
            child: Column(children: [EmailScreen(), NextBotton()]),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30.h),
        IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        SizedBox(height: 20.h),
        Center(child: Text("Your email ", style: textTheme.titleLarge)),
        SizedBox(height: 24.h),
        SizedBox(height: 16.h),
        Center(
          child: Text(
            "Don't lose access to your account, verify your email ",
            style: Theme.of(context).textTheme.titleSmall,
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
    goToEmailScreen(context);
  }

  void goToEmailScreen(BuildContext context) {
    context.push(EmailScreen.routeName);
  }
}
