import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/screen/global_language/screen/global_language_screen.dart';
import 'package:market_jango/core/screen/google_map/data/location_store.dart';
import 'package:market_jango/core/screen/profile_screen/screen/global_profile_edit_screen.dart';
import 'package:market_jango/core/utils/auth_session_utils.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/buyer/screens/order/screen/buyer_order_history_screen.dart';
import 'package:market_jango/features/buyer/screens/order/screen/buyer_order_page.dart';

import '../../../../features/vendor/screens/vendor_my_product_screen.dart/screen/vendor_my_product_screen.dart';
import '../../../utils/get_user_type.dart';
import '../data/profile_data.dart';
import '../model/profile_model.dart';

class GlobalSettingScreen extends ConsumerWidget {
  const GlobalSettingScreen({super.key});
  static const String routeName = '/settingsScreen';

  /// Show logout confirmation dialog
  static void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AllColor.black,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 16.sp,
              color: AllColor.black87,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AllColor.black87,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await AuthSessionUtils.logoutAndGoToLogin(context);
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AllColor.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(
      userProvider(ref.watch(getUserIdProvider).value ?? ""),
    );
    final userTypeAsync = ref.watch(getUserTypeProvider);

    return ScreenBackground(
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: userAsync.when(
          data: (user) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  //"My Settings"
                  Tuppertextandbackbutton(screenName: ref.t(BKeys.settings)),
                  SizedBox(height: 16.h),
                  ProfileSection(
                    name: user.name,
                    username: user.email,
                    imageUrl: user.image,
                    userType: user,
                  ),

                  SizedBox(height: 20.h),
                  _SettingsLine(
                    icon: Icons.phone_in_talk_outlined,
                    text: user.phone,
                  ),
                  _DividerLine(),
                  _SettingsLine(icon: Icons.email_outlined, text: user.email),

                  SizedBox(height: 12.h),
                  _DividerLine(),

                  if (userTypeAsync.value == "buyer")
                    _SettingsTile(
                      leadingIcon: Icons.shopping_bag_outlined,
                      // "My Order"
                      title: ref.t(BKeys.myOrders),
                      onTap: () => context.push(BuyerOrderPage.routeName),
                    ),
                  if (userTypeAsync.value == "driver")
                    _SettingsLine(
                      icon: Icons.price_change,
                      text: user.driver?.price ?? "Not set now",
                    ),
                  if (userTypeAsync.value == "vendor")
                    _SettingsTile(
                      leadingIcon: Icons.shopping_bag_outlined,
                      //"My Product"
                      title: ref.t(BKeys.my_product),
                      onTap: () =>
                          context.push(VendorMyProductScreen.routeName),
                    ),
                  _DividerLine(),
                  if (userTypeAsync.value == "buyer")
                    _SettingsTile(
                      leadingIcon: Icons.event_note_outlined,
                      // "Order history"
                      title: ref.t(BKeys.orderHistory),
                      onTap: () =>
                          context.push(BuyerOrderHistoryScreen.routeName),
                    ),
                  _DividerLine(),
                  _SettingsTile(
                    leadingIcon: Icons.language_outlined,
                    title: ref.t(BKeys.language),
                    onTap: () => context.push(GlobalLanguageScreen.routeName),
                  ),
                  _DividerLine(),
                  _SettingsTile(
                    leadingIcon: Icons.logout_outlined,
                    title: ref.t(BKeys.logOut),
                    titleColor: AllColor.orange,
                    iconColor: AllColor.orange,
                    arrowColor: AllColor.orange,
                    onTap: () => GlobalSettingScreen._showLogoutConfirmation(context),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: Text('Loading...')),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}

class SettingTitle extends ConsumerWidget {
  const SettingTitle({super.key});

  @override
  Widget build(BuildContext context,ref ) {
    return Text(
     // "My Settings",
      ref.t(BKeys.my_settings),
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w800,
        color: AllColor.black,
      ),
    );
  }
}

class ProfileSection extends ConsumerWidget {
  final String name;
  final String username;
  final String imageUrl;
  final UserModel userType;

  const ProfileSection({
    super.key,
    required this.name,
    required this.username,
    required this.imageUrl,
    required this.userType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTypeAsync = ref.watch(getUserTypeProvider);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipOval(
              child: FirstTimeShimmerImage(
                imageUrl: imageUrl,
                width: 52.r,
                height: 52.r,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: -2.h,
              right: -2.w,
              child: Container(
                width: 18.r,
                height: 18.r,
                decoration: BoxDecoration(
                  color: AllColor.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AllColor.black.withOpacity(0.08),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.photo_camera_outlined,
                  size: 12.sp,
                  color: AllColor.black,
                ),
              ),
            ),
          ],
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AllColor.black,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    username.length > 20
                        ? '${username.substring(0, 17)}...'
                        : username,
                    style: TextStyle(fontSize: 13.sp, color: AllColor.black),
                  ),
                  SizedBox(width: 8.w),
                  _PrivateBadge(status: userType.status),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            ref.invalidate(selectedLatitudeProvider);
            ref.invalidate(selectedLongitudeProvider);
            if (userTypeAsync.value == "buyer") {
              context.push(BuyerProfileEditScreen.routeName, extra: userType);
            } else if (userTypeAsync.value == "vendor") {
              context.push(BuyerProfileEditScreen.routeName, extra: userType);
            } else if (userTypeAsync.value == "transport") {
              context.push(BuyerProfileEditScreen.routeName, extra: userType);
            } else if (userTypeAsync.value == "driver") {
              context.push(BuyerProfileEditScreen.routeName, extra: userType);
              // Transport
            }
          },

          icon: Icon(Icons.edit_outlined, color: AllColor.black, size: 18.sp),
        ),
      ],
    );
  }
}

class _SettingsLine extends StatelessWidget {
  const _SettingsLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, color: AllColor.black, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                color: AllColor.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.leadingIcon,
    required this.title,
    this.onTap,
    this.titleColor,
    this.iconColor,
    this.arrowColor,
  });

  final IconData leadingIcon;
  final String title;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? iconColor;
  final Color? arrowColor;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            Icon(leadingIcon, color: iconColor ?? AllColor.black, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: titleColor ?? AllColor.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: arrowColor ?? AllColor.black,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivateBadge extends StatelessWidget {
  final String status;
  const _PrivateBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AllColor.orange,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: AllColor.white,
          fontWeight: FontWeight.w700,
          fontSize: 11.sp,
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0,
      thickness: 1,
      color: AllColor.grey.withOpacity(0.25),
    );
  }
}
