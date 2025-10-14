import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/auth/screens/car_info.dart';
import 'package:market_jango/features/auth/screens/phone_number.dart';
import 'package:market_jango/features/auth/screens/vendor_request_from.dart';
import 'package:market_jango/features/auth/screens/vendor_request_screen.dart';

import '../../../core/constants/api_control/auth_api.dart';
import '../../../core/widget/global_snackbar.dart';
import '../data/name_set.dart';
import '../logic/empty_validator.dart';
class NameScreen extends StatefulWidget {
  const NameScreen({super.key, required this.roleName});
  final String roleName;
  static final String routeName = '/nameScreen';

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final ok = await postfrem(keyname: "name",name: _nameCtrl.text.trim(),url:  AuthAPIController.nameSet);
      if (!ok) {
       GlobalSnackbar.show(context, title: "Error", message: "Failed to save name", type: CustomSnackType.error);
        return;
      }
      // same navigation logic as before
      final role = widget.roleName;
      if (role == "Vendor") {
        context.push(VendorRequestScreen.routeName);
      } else if (role == "Driver") {
        context.push(CarInfoScreen.routeName);
      } else {
        context.push(PhoneNumberScreen.routeName);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.w),
            child: Column(
              children: [
                SizedBox(height: 30.h),
                const CustomBackButton(),
                _NameForm(formKey: _formKey, ctrl: _nameCtrl),
                _NextSection(
                  role: widget.roleName,
                  loading: _loading,
                  onNext: _onNext,
                ),
              ],
            ),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20.h),
          Center(child: Text("What's your name", style: t.titleLarge)),
          SizedBox(height: 24.h),
          TextFormField(
            controller: ctrl,
            keyboardType: TextInputType.name,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: emptyValidator, // your existing required validator
            decoration: InputDecoration(
              hintText: "Enter your name",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.r)),
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
        Text(
          "This is how it'll appear on your $role profile",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text(
          "Can't change it later",
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AllColor.loginButtomColor,
            fontWeight: FontWeight.w300,
          ),
        ),
        SizedBox(height: 40.h),
        CustomAuthButton(
          buttonText: loading ? "Please wait..." : "Next",
          onTap: () {
            if (loading) return;
            onNext();
          },
        ),
      ],
    );
  }
}
