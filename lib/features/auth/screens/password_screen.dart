import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/Congratulation.dart';
import 'package:market_jango/features/auth/screens/account_request.dart';

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
            child: Column(children: [
              SizedBox(height: 30.h,),
                 CustomBackButton(),
              PasswordText(), NextBotton()]),
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
        SizedBox(height: 20.h),
        Center(child: Text("Create New Password", style: textTheme.titleLarge)),
        SizedBox(height: 20.h),
        Center(
          child: Text(
            "Type and confirm a secure new password for your amount",
            style: textTheme.bodySmall,
          ),
        ),
        SizedBox(height: 56.h),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'New Password',
            suffixIcon: Icon(Icons.visibility_off_outlined)
          ),
          obscureText: true,
        ),
        SizedBox(height: 30.h,),
        TextFormField(
          decoration: InputDecoration(
              hintText: 'Confirm Password',
              suffixIcon: Icon(Icons.visibility_off_outlined)
          ),
          obscureText: true,
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
        SizedBox(height: 30.h),
        CustomAuthButton(
          buttonText: "Confirm",
          onTap: () => nextButonDone(context),
        ),
      ],
    );
  }

  void nextButonDone(BuildContext context) {
    goToAccountRequest(context);
  }

  void goToAccountRequest(BuildContext context) {
    context.push(AccountRequest.routeName);
  }
}
