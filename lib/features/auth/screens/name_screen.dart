import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/api_control/auth_api.dart';
import '../../../core/constants/color_control/all_color.dart';
import '../../../core/widget/custom_auth_button.dart';
import '../../../core/widget/global_snackbar.dart';
import '../../../core/widget/sreeen_brackground.dart';
import '../logic/register_name_riverpod.dart';
import '../logic/empty_validator.dart';
import 'car_info_screen.dart';
import 'phone_number.dart';
import 'vendor_request_screen.dart';

class NameScreen extends ConsumerStatefulWidget {
  const NameScreen({super.key, required this.roleName});
  final String roleName;
  static const String routeName = '/nameScreen';

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(postProvider.notifier);
    await notifier.send(
      keyname: "name",
      value: _nameCtrl.text.trim(),
      url: AuthAPIController.registerName,
    );

    // ✅ এখন আমরা state read করব, listen না করে
    final state = ref.read(postProvider);

    state.when(
      data: (ok) {
        if (!ok) {
          GlobalSnackbar.show(
            context,
            title: "Error",
            message: "Failed to save name",
            type: CustomSnackType.error,
          );
          return;
        }

        // ✅ Navigation এখনই হবে, প্রথম ক্লিকেই
        final role = widget.roleName.toLowerCase();
        if (role == "vendor") {
          context.push(VendorRequestScreen.routeName);
        } else if (role == "driver") {
          context.push(CarInfoScreen.routeName);
        } else {
          context.push(PhoneNumberScreen.routeName);
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
    final loading = ref.watch(postProvider).isLoading;

    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.w),
          child: Column(
            children: [
              SizedBox(height: 30.h),
              const CustomBackButton(),
              _NameForm(formKey: _formKey, ctrl: _nameCtrl),
              _NextSection(
                role: widget.roleName,
                loading: loading,
                onNext: _onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameForm extends StatelessWidget {
  const _NameForm({required this.formKey, required this.ctrl});
  final GlobalKey<FormState> formKey;
  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Form(
      key: formKey,
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Text("What's your name", style: t.titleLarge),
          SizedBox(height: 24.h),
          TextFormField(
            controller: ctrl,
            validator: emptyValidator,
            decoration: InputDecoration(
              hintText: "Enter your name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextSection extends StatelessWidget {
  const _NextSection({required this.role, required this.loading, required this.onNext});
  final String role;
  final bool loading;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12.h),
        Text("This is how it'll appear on your $role profile",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall),
        Text("Can't change it later",
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AllColor.loginButtomColor,
              fontWeight: FontWeight.w300,
            )),
        SizedBox(height: 40.h),
        CustomAuthButton(
          buttonText: loading ? "Please wait..." : "Next",
          onTap:loading ? (){} : onNext,
        ),
      ],
    );
  }
}
