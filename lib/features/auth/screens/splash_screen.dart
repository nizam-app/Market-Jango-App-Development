import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/features/auth/screens/name_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
   static const String routeName = '/splashScreen'; 

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(right: 49, left: 49, top: 89),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/splash-logo.png", height: 300, width: 300,fit: BoxFit.cover,), 
               SplashScreenText(),
            ],
          ),
        ),
      ),
    );
  }


}
class SplashScreenText extends StatelessWidget{
  SplashScreenText({
    super.key
    
      });

      @override
     Widget build(BuildContext context){
         final textTheme = Theme.of(context).textTheme; 
         return Column(
          children: [
                 SizedBox(height: 48.h,), 
                 Center(child: Text("One Marketplace, \n Endless Possibilities",style:textTheme.titleLarge,)),
                 SizedBox(height: 20.h,), 
              CustomAuthButton(buttonText: "Login", onTap: () => loginDone(context)),
              SizedBox(height: 20.h,), 
              SplashSignUpButton(buttonText: "Sign Up", onTap: ()=>signupDone(context)),
              SizedBox(height: 28.h,), 
             InkWell(
              onTap: (){
                goToTroubleSigning(context);
              },
               child: Text("Trouble signing in?" ,style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AllColor.loginButtonColor,
                    fontWeight: FontWeight.w300,),),
             )
           
          ],
         );

      }
      
void loginDone(BuildContext context) {
    context.push('/login');
  }

  void signupDone(BuildContext context) {
    goToNameScreen(context);
  }

  void goToTroubleSigning(BuildContext context) {
    context.push('/trouble-signing');
  }

  void goToNameScreen(BuildContext context) {
    context.push(NameScreen.routeName);
  }
}