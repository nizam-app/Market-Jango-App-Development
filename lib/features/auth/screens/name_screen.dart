import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/user.dart';

class NameScreen extends StatelessWidget {
  const NameScreen({super.key});
  static final String routeName = '/nameScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading:IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.arrow_back_ios),
        ), 
      ),
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(children: [NameText(), NextBotton()]),
          ),
        ),
      ),
    );
  }
}

class NameText extends StatelessWidget {
  const NameText({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30.h),
        
        SizedBox(height: 20.h),
        Center(child: Text("What's your name", style: textTheme.titleLarge)),
        SizedBox(height: 24.h),
        TextFormField(
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            hintText: "Enter your name",
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
        SizedBox(height: 12.h),
        Text(
          "This is ho it'll appear on your profile  ",
          style: Theme.of(context).textTheme.titleSmall,
        ),

        Text(
          "Can't change it letter ",
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AllColor.loginButtonColor,
            fontWeight: FontWeight.w300,
          ),
        ),

        SizedBox(height: 40.h),
        CustomAuthButton(
          buttonText: "Next",
          onTap: ()=> nextButonDone(context),  
           ),
      ],
    );
  }


  void nextButonDone(BuildContext context) {
    goToUserScreen(context);

  }
      void goToUserScreen(BuildContext context) {
    context.push(UserScreen.routeName);
  }
  }
