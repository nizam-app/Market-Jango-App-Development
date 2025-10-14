import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/sreeen_brackground.dart';
import 'package:market_jango/features/buyer/screens/order/screen/buyer_order_history_screen.dart';
import 'package:market_jango/features/buyer/screens/order/screen/buyer_order_page.dart';
import 'package:market_jango/features/transport/screens/language_screen.dart';
import 'global_profile_edit_screen.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});
  static const String routeName = '/settings_screen';

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return ScreenBackground(child: Padding(
      padding:  EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Tuppertextandbackbutton(screenName: "My Settings") ,
          SizedBox(height: 16.h),
          const ProfileSection(),

          SizedBox(height: 20.h),
          _SettingsLine(icon: Icons.phone_in_talk_outlined, text: "(319) 555-0115"),
          _DividerLine(),
          _SettingsLine(icon: Icons.email_outlined, text: "mirable@gmail.com"),

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
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 26.r,
              backgroundImage: const NetworkImage(
                "https://randomuser.me/api/portraits/women/68.jpg",
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
                    )
                  ],
                ),
                child: Icon(Icons.photo_camera_outlined,
                    size: 12.sp, color: AllColor.black),
              ),
            ),
          ],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Mirable Lily",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AllColor.black,
                  )),
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.alternate_email, size: 14.sp, color: AllColor.black),
                  SizedBox(width: 4.w),
                  Text("mirable123",
                      style: TextStyle(fontSize: 13.sp, color: AllColor.black)),
                  SizedBox(width: 8.w),
                  _PrivateBadge(),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _gotoProfileEdit(context),
          icon: Icon(Icons.edit_outlined, color: AllColor.black, size: 18.sp),
        ),
      ],
    );
  }

  void _gotoProfileEdit(BuildContext context) {
    context.push(BuyerProfileEditScreen.routeName);
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
