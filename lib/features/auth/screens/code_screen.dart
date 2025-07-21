import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/email_screen.dart';

class CodeScreen extends StatelessWidget {
  const CodeScreen({super.key});
  static final String routeName = '/codeScreen';  

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ScreenBackground(
        
        child: SingleChildScrollView(
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              CodeText(),
              NextBotton(),

            ],
          ),),
        ),
      ),

    );
  }
}


class CodeText extends StatelessWidget {
  const CodeText({super.key});

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
        Center(child: Text("Enter your Code ", style: textTheme.titleLarge)),
        SizedBox(height: 16.h),
          Center(
            child: Text(
            "011 221 333 56 Resend?",
            style: Theme.of(context).textTheme.titleSmall,
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
    goToEmailScreen(context);
  }

  void goToEmailScreen(BuildContext context) {
    context.push(EmailScreen.routeName);
  }
}
