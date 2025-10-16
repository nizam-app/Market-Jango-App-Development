import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/api_control/auth_api.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/account_request.dart';
import 'package:market_jango/features/auth/screens/login/logic/obscureText_controller.dart';
import 'package:market_jango/features/auth/screens/login/logic/password_validator.dart';
import 'package:market_jango/features/auth/logic/reset_password_riverpod.dart';
import 'package:market_jango/features/auth/screens/login/screen/login_screen.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});
  static final String routeName = '/passwordScreen';

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final pass = _passwordCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (pass != confirm) {
      GlobalSnackbar.show(context,
          title: "Error",
          message: "Passwords do not match",
          type: CustomSnackType.error);
      return;
    }

    final notifier = ref.read(resetPasswordProvider.notifier);
    await notifier.resetPassword(
      url: AuthAPIController.resetPassword, // তোমার API endpoint
      password: pass,
    );

    final state = ref.read(resetPasswordProvider);
    state.when(
      data: (ok) {
        if (ok) {
          GlobalSnackbar.show(context,
              title: "Success",
              message: "Password reset successfully!",
              type: CustomSnackType.success);
          context.push(LoginScreen.routeName);
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
    final loading = ref.watch(resetPasswordProvider).isLoading;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: _formKey,
            child: Column(children: [
              SizedBox(height: 30.h),
              const CustomBackButton(),
              SizedBox(height: 50.h),
              Text("Reset Password", style: t.titleLarge),
              SizedBox(height: 10.h),
              Text(
                "Type and confirm your new password",
                style: t.titleMedium!.copyWith(fontSize: 12.sp),
              ),
              SizedBox(height: 40.h),

              // Password Field
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
                    onPressed: () {
                      ref.read(passwordVisibilityProvider.notifier).state =
                      !isObscure;
                    },
                  ),
                ),
              ),

              SizedBox(height: 30.h),

              // Confirm Password Field
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
                    onPressed: () {
                      ref.read(passwordVisibilityProvider.notifier).state =
                      !isObscure;
                    },
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Save Button
              CustomAuthButton(
                buttonText: loading ? "Saving..." : "Save",
                onTap: loading ? () {} : _submit,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
