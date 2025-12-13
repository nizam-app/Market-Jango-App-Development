import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/login/logic/email_validator.dart';
import 'package:market_jango/features/auth/screens/login/logic/login_riverpod.dart';
import 'package:market_jango/features/auth/screens/login/logic/obscureText_controller.dart';
import 'package:market_jango/features/auth/screens/user_type_screen.dart' show UserScreen;
import 'package:market_jango/features/buyer/screens/buyer_home_screen.dart';
import '../../forgot_password_screen.dart';
class LoginScreen extends StatelessWidget {
   const LoginScreen({super.key});
  static const String routeName = '/loginScreen';

  @override
  Widget build(BuildContext context) {
    TextEditingController controllerEmail = TextEditingController();
    TextEditingController controllerPassword = TextEditingController();
    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                 SizedBox(height: 30.h,),
                 CustomBackButton(),
                LoginHereText(),
                LoginTextFormField(
                  controllerEmail: controllerEmail,
                  controllerPassword: controllerPassword,
                ),
               
              ],
            ),
          ),
        ),
      ),
    );

  }
}


class LoginTextFormField extends ConsumerWidget {
   LoginTextFormField({
    super.key, required this.controllerEmail, required this.controllerPassword,
  });
  final TextEditingController controllerEmail;
  final TextEditingController controllerPassword;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isObscure = ref.watch(passwordVisibilityProvider);
    return Form(
      key: _formKey,
      child: Column(
        children: [
      SizedBox(height: 28.h,),
      TextFormField(
        autovalidateMode: AutovalidateMode.disabled,
        textInputAction: TextInputAction.next,
        controller: controllerEmail,
        validator: emailValidator,
        decoration: InputDecoration(
          hintText: "Email or Phone number",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
      SizedBox(height: 29.h,),
          TextFormField(
            controller: controllerPassword,
            textInputAction: TextInputAction.done,
            autovalidateMode: AutovalidateMode.disabled,
            validator: (_) {
              return null;
            },
            // passwordValidator,
            // তোমার existing function
            obscureText: isObscure,
           
            decoration: InputDecoration(
              hintText: "Password",
              isDense: true,
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
          Column(
            children: [
              SizedBox(height: 30.h,),
              InkWell(
                  onTap: () {
                    goToForgotPasswordScreen(context);
                  },
                  child: Text("Forgot your Password?",style: Theme.of(context).textTheme.titleSmall,),
                
              ),
              SizedBox(height: 30.h,),
              Consumer(
                builder: (context, ref, child) {
                  final loginState = ref.watch(loginStateProvider);
                  final isLoading = loginState.isLoading;
                  
                  return CustomAuthButton(
                    buttonText: isLoading ? "Logging in..." : "Login",
                    onTap: () {
                      if (!isLoading && _formKey.currentState!.validate()) {
                        ref.read(loginStateProvider.notifier).login(
                              context: context,
                              email: controllerEmail.text,
                              password: controllerPassword.text,
                            );
                      }
                    },
                  );
                },
              ),
              SizedBox(height: 50.h,),
              Text.rich(
                TextSpan(
                  text: "Don't have an account? ",
                  style: Theme.of(context).textTheme.titleSmall,
                  children: [
                    TextSpan(
                      text: "Sign up",
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AllColor.loginButtomColor,
                        fontWeight: FontWeight.w300,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          goToSignUpScreen(context);
                        },
                    ),
                  ],
                ),
              ),
      
            ],
          )
      
        ],
      ),
    );
  }
  // Removed loginDone - now handled by Riverpod provider

  void gotoHomeScreen(BuildContext content){
    content.push(BuyerHomeScreen.routeName);
  }

  void goToForgotPasswordScreen(BuildContext context) {
    context.push(ForgotPasswordScreen.routeName);}

  void goToSignUpScreen(BuildContext context) {
    context.push(UserScreen.routeName);
  }
}

class LoginHereText extends StatelessWidget {
  const LoginHereText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
    
    
    SizedBox(height: 50.h,),
    Center(child: Text("Login Here",style:textTheme.titleLarge,)),
    SizedBox(height: 12.h,),
    Center(child: Text("Welcome back you've \n been missed!",style:textTheme.titleMedium,textAlign: TextAlign.center,))
      ],
    );
  }
}
