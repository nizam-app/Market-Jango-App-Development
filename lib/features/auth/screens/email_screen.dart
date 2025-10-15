import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/api_control/auth_api.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/login/logic/email_validator.dart';
import 'package:market_jango/features/auth/screens/new_password_screen.dart';
import 'package:market_jango/features/auth/screens/recover_password_screen.dart';
import '../logic/register_email_riverpod.dart';

class EmailScreen extends ConsumerStatefulWidget {
  const EmailScreen({super.key});
  static const String routeName = '/emailScreen';

  @override
  ConsumerState<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends ConsumerState<EmailScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(emailRegisterProvider.notifier);
    await notifier.registerEmail(
      url: AuthAPIController.registerEmail,
      email: _emailCtrl.text.trim(),
    );

    final state = ref.read(emailRegisterProvider);
    state.when(
      data: (ok) {
        if (ok) {
          GlobalSnackbar.show(
            context,
            title: "Success",
            message: "Email set successfully!",
            type: CustomSnackType.success,
          );
          context.push(NewPasswordScreen.routeName);
        }
      },
      error: (e, _) {
        GlobalSnackbar.show(
          context,
          title: "Error",
          message: e.toString(),
          type: CustomSnackType.error,
        );
      },
      loading: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(emailRegisterProvider).isLoading;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 30.h),
                  const CustomBackButton(),
                  SizedBox(height: 20.h),
                  Center(child: Text("Your Email", style: t.titleLarge)),
                  SizedBox(height: 14.h),
                  Text(
                    "Don't lose access to your account, verify \n your email.",
                    textAlign: TextAlign.center,
                    style: t.titleSmall,
                  ),
                  SizedBox(height: 24.h),
                  TextFormField(
                    controller: _emailCtrl,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: emailValidator,
                    decoration: InputDecoration(
                      hintText: "Enter your email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 120.h),
                  CustomAuthButton(
                    buttonText: loading ? "Submitting..." : "Next",
                    onTap: loading ? () {} : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
