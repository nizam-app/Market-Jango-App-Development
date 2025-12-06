import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/buyer/screens/order/screen/buyer_order_history_screen.dart';
import 'package:market_jango/features/buyer/screens/order/screen/buyer_order_page.dart';
import 'package:market_jango/features/transport/screens/language_screen.dart';
import 'package:market_jango/business_logic/providers/user_provider.dart';
import 'package:market_jango/business_logic/models/user_model.dart';

import '../global_profile_edit_screen.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  static const String routeName = '/settingsScreen';

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    return ScreenBackground(child: Padding(
      padding:  EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Tuppertextandbackbutton(screenName: "My Settings") ,
          SizedBox(height: 16.h),
          userAsync.when(
            data: (user) => ProfileSection(user: user),
            loading: () => ProfileSection(user: null, isLoading: true),
            error: (error, stack) => ProfileSection(user: null, error: error.toString()),
          ),

          SizedBox(height: 20.h),
          userAsync.when(
            data: (user) => Column(
              children: [
                _SettingsLine(icon: Icons.phone_in_talk_outlined, text: user.phone),
                _DividerLine(),
                _SettingsLine(icon: Icons.email_outlined, text: user.email),
              ],
            ),
            loading: () => Column(
              children: [
                _SettingsLine(icon: Icons.phone_in_talk_outlined, text: "Loading..."),
                _DividerLine(),
                _SettingsLine(icon: Icons.email_outlined, text: "Loading..."),
              ],
            ),
            error: (error, stack) => Column(
              children: [
                _SettingsLine(icon: Icons.phone_in_talk_outlined, text: "Error"),
                _DividerLine(),
                _SettingsLine(icon: Icons.email_outlined, text: "Error"),
              ],
            ),
          ),

          SizedBox(height: 12.h),
          _DividerLine(),

          _SettingsTile(
            leadingIcon: Icons.shopping_bag_outlined,
            title: "My Order",
            onTap: () {context.push(BuyerOrderPage.routeName);},
          ),
          _DividerLine(),
          _SettingsTile(
            leadingIcon: Icons.event_note_outlined,
            title: "Order history",
            onTap: () {context.push(BuyerOrderHistoryScreen.routeName);},
          ),
          _DividerLine(),
          _SettingsTile(
            leadingIcon: Icons.language_outlined,
            title: "Language",
            onTap: () {context.push(LanguageScreen.routeName);},
          ),
          _DividerLine(),

          // ---- Log out (red/orange accent) ----
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
    ),);
  }
}

/* ===================== widgets ===================== */

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
class ProfileSection extends StatelessWidget {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const ProfileSection({
    super.key,
    this.user,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 26.r,
          backgroundImage: NetworkImage(user?.image ?? "https://randomuser.me/api/portraits/women/68.jpg"),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isLoading ? "Loading..." : user?.name ?? "No Name",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AllColor.black),
              ),
              SizedBox(height: 4.h),
              Text(
                isLoading ? "Loading..." : user?.email ?? "No Email",
                style: TextStyle(fontSize: 13.sp, color: AllColor.black),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push(BuyerProfileEditScreen.routeName),
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
            Icon(Icons.chevron_right,
                color: arrowColor ?? AllColor.black, size: 20.sp),
          ],
        ),
      ),
    );
  }
}

class _PrivateBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AllColor.orange,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        "Private",
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
