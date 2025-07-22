import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/vendor_request_from.dart';

class PasswordScreen extends StatelessWidget {
  const PasswordScreen({super.key});
  static final String routeName = '/passwordScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(children: [PasswordText(), NextBotton()]),
          ),
        ),
      ),
    );
  }
}

class PasswordText extends StatelessWidget {
  const PasswordText({super.key});

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
          icon: const Icon(Icons.arrow_back_ios),
        ),
        SizedBox(height: 20.h),
        Center(child: Text("Create New Password", style: textTheme.titleLarge)),
        SizedBox(height: 20.h),
        Center(
          child: Text(
            "Type and confirm a secure new password for your amount",
            style: textTheme.titleSmall,
          ),
        ),
        SizedBox(height: 20.h),
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
    goToVendorRequestFrom(context);
  }

  void goToVendorRequestFrom(BuildContext context) {
    context.push(VendorRequestFrom.routeName);
  }
}
