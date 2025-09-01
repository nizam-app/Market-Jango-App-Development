import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/Congratulation.dart';
import 'package:market_jango/features/auth/screens/account_request.dart';

import 'login/logic/obscureText_controller.dart';
import 'login/logic/password_validator.dart';

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

class PasswordText extends ConsumerWidget {
  const PasswordText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isObscure = ref.watch(passwordVisibilityProvider);
    TextEditingController  controllerPassword = TextEditingController();
    return Column(
      children: [
        SizedBox(height: 50.h,),
        TextFormField(
          controller: controllerPassword,
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.disabled,
          validator: passwordValidator, // তোমার existing function
          obscureText: isObscure,
          decoration: InputDecoration(
            hintText: "New Password",
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              ),
              onPressed: () {
                ref.read(passwordVisibilityProvider.notifier).state = !isObscure;
              },
            ),
          ),
        ),
        SizedBox(height: 30.h,),
        TextFormField(
          controller: controllerPassword,
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.disabled,
          validator: passwordValidator, // তোমার existing function
          obscureText: isObscure,
          decoration: InputDecoration(
            hintText: "Confirm Password",
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              ),
              onPressed: () {
                ref.read(passwordVisibilityProvider.notifier).state = !isObscure;
              },
            ),
          ),
        ),
        SizedBox(height: 30.h,),
        CustomAuthButton(buttonText: "Save", onTap: (){goToNextScreen(context);}),
      ],
    );
  }
  void goToNextScreen( BuildContext context
      ){
    context.push(AccountRequest.routeName);
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