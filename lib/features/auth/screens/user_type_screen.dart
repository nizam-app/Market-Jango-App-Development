import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/auth/logic/register_user_riverpod.dart';
import 'package:market_jango/features/auth/screens/name_screen.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
class UserScreen extends ConsumerWidget {
  const UserScreen({super.key});
  static const routeName = '/userScreen';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = const ['Buyer', 'Transport', 'Vendor', 'Driver'];
    final selected = ref.watch(userTypeP);
    final reg = ref.watch(registerP);
    final loading = reg.isLoading;

    // navigate on success
    ref.listen(registerP, (prev, next) {
      next.whenOrNull(
        data: (resp) {
          if (resp == null) return;
          GlobalSnackbar.show(context, title: "Success", message: "User type selected successfully");
          context.pushNamed(NameScreen.routeName,
              pathParameters: {'role': resp.data.user.userType});
        },
        error: (err, _) {
          GlobalSnackbar.show(context, title: "Error", message: err.toString(), type: CustomSnackType.error);
        },
      );
    });

    final dropTheme = Theme.of(context).copyWith(
      hoverColor: const Color(0xFFFF8C00),
      highlightColor: const Color(0xFFFF8C00),
      splashColor: Colors.transparent,
      focusColor: const Color(0xFFFF8C00),
    );

    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SizedBox(height: 30.h),
                const CustomBackButton(),
                SizedBox(height: 20.h),
                Text("User Type Selection",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp)),
                SizedBox(height: 24.h),

                Theme(
                  data: dropTheme,
                  child: Container(
                    height: 56.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF8E7),
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 14.r,
                          offset: Offset(0, 6.h),
                          color: Colors.black.withOpacity(0.06),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: items.contains(selected) ? selected : null,
                        hint: Text("Choose one",
                            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF6E7A8A), fontWeight: FontWeight.w500)),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        style: TextStyle(fontSize: 15.sp, color: Colors.black87),
                        items: items.map((e) => DropdownMenuItem(
                          value: e,
                          child: SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: Text(e),
                            ),
                          ),
                        )).toList(),
                        onChanged: (v) {
                          ref.read(userTypeP.notifier).state = v ?? 'Buyer';
                          },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),
                SizedBox(height: 460.h),

                CustomAuthButton(
                  buttonText: loading ? "Please wait..." : "Next",
                  onTap: () {
                    if (loading) return;             // non-null VoidCallback
                    ref.read(registerP.notifier).submit();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
