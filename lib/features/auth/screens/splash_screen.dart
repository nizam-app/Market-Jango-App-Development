import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/features/auth/screens/login/screen/login_screen.dart';
import 'package:market_jango/features/auth/screens/user.dart';
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  static const String routeName = '/splashScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 55.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/logos.png",
                height: 333.h,
                width: 300.w,
                fit: BoxFit.contain,),
                SplashScreenText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class SplashScreenText extends StatelessWidget {
  SplashScreenText({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        SizedBox(height: 48.h),
        Center(
          child: Text(
            "One Marketplace,\n Endless Possibilities",
            style: textTheme.titleLarge,
          ),
        ),
        SizedBox(height: 20.h),
        CustomAuthButton(buttonText: "Login", onTap: () => loginDone(context)),
        SizedBox(height: 20.h),
        SplashSignUpButton(
          buttonText: "Sign Up",
          onTap: () => signupDone(context),
        ),
        SizedBox(height: 28.h),
        // InkWell(
        //   onTap: () {
        //     goToTroubleSigning(context);
        //   },
        //   child: Text(
        //     "Trouble signing in?",
        //     style: Theme.of(context).textTheme.titleSmall?.copyWith(
        //       color: AllColor.loginButtomColor,
        //       fontWeight: FontWeight.w300,
        //     ),
        //   ),
        // ),
      ],
    );
  }
  void loginDone(BuildContext context) {
    context.push('/loginScreen');
  }

  void gotoLoginScreen(BuildContext content) {
    content.push(LoginScreen.routeName);
  }

  void goToTroubleSigning(BuildContext context) {
    context.push('/trouble-signing');
  }
  void signupDone(BuildContext context) {
    goToUserScreen(context);
  }
  void goToUserScreen(BuildContext context) {
    context.push(UserScreen.routeName);
  }
}                                                        