import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/features/auth/screens/login/screen/login_screen.dart';
import 'package:market_jango/features/auth/screens/user_type_screen.dart';
import 'package:market_jango/features/navbar/screen/buyer_bottom_nav_bar.dart';
import 'package:market_jango/features/navbar/screen/driver_bottom_nav_bar.dart';
import 'package:market_jango/features/navbar/screen/transport_bottom_nav_bar.dart';
import 'package:market_jango/features/navbar/screen/vendor_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/splashScreen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
                Image.asset(
                  "assets/images/logos.png",
                  height: 333.h,
                  width: 300.w,
                  fit: BoxFit.contain,
                ),
                SplashScreenText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SplashScreenText extends ConsumerWidget {
  SplashScreenText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        SizedBox(height: 48.h),
        Center(
          child: Text(
            "One Marketplace,\n Endless Possibilities",
            textAlign: TextAlign.center,
            style: textTheme.titleLarge,
          ),
        ),
        SizedBox(height: 20.h),
        CustomAuthButton(
          buttonText: "Login",
          onTap: () {
            loginDone(context);
          },
        ),
        SizedBox(height: 20.h),
        SplashSignUpButton(
          buttonText: "Sign Up",
          onTap: () {
            signupDone(context);
          },
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

  Future<dynamic> loginDone(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final type = prefs.getString('user_type');

    Logger().e("token $token type $type");

    // ✅ token & type thakle matro home e pathabo
    if (token != null && token.isNotEmpty && type != null) {
      switch (type) {
        case 'buyer':
          return context.push(BuyerBottomNavBar.routeName);
        case 'vendor':
          return context.push(VendorBottomNav.routeName);
        case 'transport':
          return context.push(TransportBottomNavBar.routeName);
        case 'driver':
          return context.push(DriverBottomNavBar.routeName);
        default:
          // unknown type -> login e niye jao
          return context.push(LoginScreen.routeName);
      }
    }

    // ❌ token nai / empty / type null -> always login
    return context.push(LoginScreen.routeName);
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
