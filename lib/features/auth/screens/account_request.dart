import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/login/screen/login_screen.dart';
import 'package:market_jango/features/navbar/screen/vendor_bottom_nav.dart';

class AccountRequest extends StatelessWidget {
  const AccountRequest({super.key,});

  static final String routeName = '/accountRequest';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
            child: Column(
              children: [
                 SizedBox(height: 30.h),
                 CustomBackButton(),
                WelcomeText(),
                NextBotton(),
               
              ],
            ),
          ),
        ),
     
    );
  }
}

class WelcomeText extends StatelessWidget {
  const WelcomeText({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          SvgPicture.asset(
                  "assets/images/congratulations.svg",
                  height: 393.h,
                  width: 396.w,
                  fit: BoxFit.cover,
                ),
        SizedBox(height: 56.h),
        Center(child: Text("Wait for confirmation ", style: textTheme.titleLarge)),
        SizedBox(height: 20.h),
        Center(
          child: Text(
            "Your account has been under review",
            style: textTheme.bodySmall,
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
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          CustomAuthButton(
            buttonText: "Go To Login",
            onTap: () => nextButonDone(context),
          ),
        ],
      ),
    );
  }

  void nextButonDone(BuildContext context) {
    context.go(LoginScreen.routeName);
  }


}
