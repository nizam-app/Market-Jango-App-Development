import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';

class NameScreen extends StatelessWidget {
  const NameScreen({super.key});
  static final String routeName= '/nameScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
                 NameText(), 
                 NextBotton(),

            ],
          ),),
        ),
      ),
    );
  }
}

class NameText extends StatelessWidget {
  const NameText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         SizedBox(height: 30.h,),
        IconButton(onPressed: (){
           context.pop(); 
        }, icon:Icon(Icons.arrow_back_ios)),
    SizedBox(height: 20.h,),
    Center(child: Text("What's your name",style:textTheme.titleLarge,)),
    SizedBox(height: 24.h,),
    TextFormField(
      keyboardType:TextInputType.name,
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
  const NextBotton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12.h,),
        Center(
          child: Text.rich(
            TextSpan(
              text: "This is ho it'll appear on your profile ",
              style: Theme.of(context).textTheme.titleSmall,
              children: [
                TextSpan(
                  text: "Can't change it letter ",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AllColor.loginButtonColor,
                    fontWeight: FontWeight.w300,),
                  onEnter: (_){
                   
                  }
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 32.h,),
        CustomAuthButton(buttonText:"User",onTap: (){
         loginDone();
         },),
    
      ],
    );
  }
void loginDone() {}

void goToForgotPasswordScreen(BuildContext context) {
  

  void goToSignUpScreen(BuildContext context) {
    context.push('');
  }

}
}