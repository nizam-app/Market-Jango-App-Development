import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/code_screen.dart';

class PhoneNumberScreen extends StatelessWidget {
  const PhoneNumberScreen({super.key});
  static final String routeName = '/phoneNumberScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(children: [
               SizedBox(height: 30.h),
               CustomBackButton(),
              NumberText(), NextBotton()]),
          ),
        ),
      ),
    );
  }
}

class NumberText extends StatelessWidget {
  const NumberText({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [


        SizedBox(height: 20.h),

        Center(
          child: Text(
            "Can we get to your \n number?",
            style: textTheme.titleLarge,
          ),
        ),
        SizedBox(height: 28.h),

        IntlPhoneField(
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(borderSide: BorderSide()),
          ),
          initialCountryCode: 'BD', // Bangladesh
          onChanged: (phone) {
            print(phone.completeNumber); // Full number with country code
          },
        ),
        SizedBox(height: 28.h),
        Center(
          child: Text(
            "we'll text you a cde to verify you're really you \n Message and data rates may apply. \n What happens if lyour number changes? ",textAlign: TextAlign.center,
            style: textTheme.titleSmall,
          ),
        ),
        SizedBox(height: 24.h),
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
    goToCodeScreen(context);
  }

  void goToCodeScreen(BuildContext context) {
    context.push(CodeScreen.routeName);
  }
}
