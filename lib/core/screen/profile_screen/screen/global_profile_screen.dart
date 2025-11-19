import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/screen/global_language/screen/global_language_screen.dart';
import 'package:market_jango/core/screen/profile_screen/screen/global_profile_edit_screen.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/buyer/screens/order/screen/buyer_order_history_screen.dart';
import 'package:market_jango/features/buyer/screens/order/screen/buyer_order_page.dart';
import 'package:market_jango/features/vendor/screens/vendor_profile_edit/screen/vendor_edit_profile.dart';

import '../../../../features/vendor/screens/vendor_my_product_screen.dart/screen/vendor_my_product_screen.dart';
import '../../../utils/get_user_type.dart';
import '../data/profile_data.dart';
import '../model/profile_model.dart';

class GlobalSettingScreen extends ConsumerWidget {
  const GlobalSettingScreen({super.key});
  static const String routeName = '/settingsScreen';

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
          data: (user) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),
              Tuppertextandbackbutton(screenName: "My Settings"),
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
                  title: "My Order",
                  onTap: () => context.push(BuyerOrderPage.routeName),
                ),
              if (userTypeAsync.value == "vendor")
                _SettingsTile(
                  leadingIcon: Icons.shopping_bag_outlined,
                  title: "My Product",
                  onTap: () => context.push(VendorMyProductScreen.routeName),
                ),
              _DividerLine(),
              if (userTypeAsync.value == "buyer")
                _SettingsTile(
                  leadingIcon: Icons.event_note_outlined,
                  title: "Order history",
                  onTap: () => context.push(BuyerOrderHistoryScreen.routeName),
                ),
              _DividerLine(),
              _SettingsTile(
                leadingIcon: Icons.language_outlined,
                title: "Language",
                onTap: () => context.push(GlobalLanguageScreen.routeName),
              ),
              _DividerLine(),
              _SettingsTile(
                leadingIcon: Icons.logout_outlined,
                title: "Log Out",
                titleColor: AllColor.orange,
                iconColor: AllColor.orange,
                arrowColor: AllColor.orange,
                onTap: () {},
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}

class SettingTitle extends StatelessWidget {
  const SettingTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "My Settings",
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
            CircleAvatar(radius: 26.r, backgroundImage: NetworkImage(imageUrl)),
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
            if (userTypeAsync.value == "buyer") {
              context.push(BuyerProfileEditScreen.routeName, extra: userType);
            } else if (userTypeAsync.value == "vendor") {
              context.push(VendorEditProfile.routeName, extra: userType);
            }  else if (userTypeAsync.value == "transport") {
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