import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:market_jango/core/constants/api_control/auth_api.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/Congratulation.dart';
import 'package:market_jango/features/auth/screens/login/logic/obscureText_controller.dart';
import 'package:market_jango/features/auth/screens/login/logic/password_validator.dart';
import 'package:market_jango/features/auth/screens/login/screen/login_screen.dart';
import 'package:market_jango/features/auth/logic/register_password_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_request.dart';

class NewPasswordScreen extends ConsumerStatefulWidget {
  const NewPasswordScreen({super.key});
  static const String routeName = '/new_password_screen';

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final password = _passwordCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (password != confirm) {
      GlobalSnackbar.show(context,
          title: "Error",
          message: "Passwords do not match",
          type: CustomSnackType.error);
      return;
    }

    final notifier = ref.read(registerPasswordProvider.notifier);
    await notifier.setPassword(
      url: AuthAPIController.registerPassword, // তোমার endpoint
      password: password,
      confirmPassword: confirm,
    );

    final state = ref.read(registerPasswordProvider);
    state.when(
      data: (ok)async {
        SharedPreferences pref =await SharedPreferences.getInstance();
        String? type = await pref.getString("user_type");
        Logger().i(type);
        if (ok) {
          GlobalSnackbar.show(context,
              title: "Success",
              message: "Password set successfully!",
              type: CustomSnackType.success);

        switch (type){
          case "buyer":
            context.pushReplacement(CongratulationScreen.routeName,);
            break;
          case "transport":
            context.pushReplacement(CongratulationScreen.routeName,);
            break;
          default:
            context.pushReplacement(AccountRequest.routeName,);

        }

        }
      },
      error: (e, _) => GlobalSnackbar.show(context,
          title: "Error", message: e.toString(), type: CustomSnackType.error),
      loading: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isObscure = ref.watch(passwordVisibilityProvider);
    final loading = ref.watch(registerPasswordProvider).isLoading;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 30.h),
                const CustomBackButton(),
                SizedBox(height: 138.h),
                Text('Create New Password', style: t.titleLarge),
                SizedBox(height: 30.h),
                Text(
                  'Type and confirm a secure new password for your account',
                  style: t.titleMedium!.copyWith(fontSize: 11.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50.h),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: isObscure,
                  validator: passwordValidator,
                  decoration: InputDecoration(
                    hintText: "New Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        isObscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () => ref
                          .read(passwordVisibilityProvider.notifier)
                          .state = !isObscure,
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: isObscure,
                  validator: passwordValidator,
                  decoration: InputDecoration(
                    hintText: "Confirm Password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        isObscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () => ref
                          .read(passwordVisibilityProvider.notifier)
                          .state = !isObscure,
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                CustomAuthButton(
                  buttonText: loading ? "Saving..." : "Save",
                  onTap: loading ? () {} : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
