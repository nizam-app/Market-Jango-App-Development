// driver_edit_profile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';

class DriverEditProfile extends StatefulWidget {
  const DriverEditProfile({super.key});
  static final routeName = "/driverEidtProfile";

  @override
  State<DriverEditProfile> createState() => _DriverEditProfileState();
}

class _DriverEditProfileState extends State<DriverEditProfile> {
  bool _online = true;

  void _onBack() => Navigator.of(context).maybePop();
  void _toggleOnline(bool v) => setState(() => _online = v);
  void _onSave() {
    // TODO: handle save
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AllColor.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30,),
            CustomBackButton(),
            const _PageHeader(),
            _FormScroll(
              online: _online,
              onToggleOnline: _toggleOnline,
            ),
            _BottomSave(onTap: _onSave),
           
          
          ],
        ),
      ),
    );
  }
}

/* ------------------------------ Custom Codebase ------------------------------ */

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          Text(
            "Settings",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AllColor.black,
            ),
          ),
          Text(
            "Your Profile",
            style: TextStyle(fontSize: 13.sp, color: AllColor.black54),
          ),
        ],
      ),
    );
  }
}

class _FormScroll extends StatelessWidget {
  const _FormScroll({
    required this.online,
    required this.onToggleOnline,
  });

  final bool online;
  final ValueChanged<bool> onToggleOnline;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AvatarEditor(
              imageUrl:
                  "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=800&auto=format&fit=crop",
              onEditTap: () {

              }, 
            ),
            SizedBox(height: 18.h),

            _FieldLabel("Name"),
            _EditField(hint: "Enter your full name"),
            SizedBox(height: 12.h),

            _FieldLabel("Email"),
            _EditField(hint: "Enter your email", keyboardType: TextInputType.emailAddress),
            SizedBox(height: 12.h),

            _FieldLabel("Phone number"),
            _EditField(hint: "Enter your phone number", keyboardType: TextInputType.phone),
            SizedBox(height: 12.h),

            _FieldLabel("Price"),
            _EditField(hint: "Enter your price", keyboardType: TextInputType.number),
            SizedBox(height: 16.h),

            _OnlineStatusRow(value: online, onChanged: onToggleOnline),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

class _AvatarEditor extends StatelessWidget {
  const _AvatarEditor({required this.imageUrl, required this.onEditTap});
  final String imageUrl;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 88.w,
            height: 88.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AllColor.grey200, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AllColor.black.withOpacity(.06),
                  blurRadius: 10.r,
                  offset: Offset(0, 4.h),
                )
              ],
              image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
            ),
          ),
          Positioned(
            right: -2.w,
            bottom: -2.h,
            child: InkWell(
              onTap: onEditTap,
              borderRadius: BorderRadius.circular(18.r),
              child: Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: AllColor.blue500,
                  shape: BoxShape.circle,
                  border: Border.all(color: AllColor.white, width: 3),
                ),
                child: Icon(Icons.edit, size: 14.sp, color: AllColor.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: AllColor.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.hint,
    this.keyboardType,
  });

  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14.sp, color: AllColor.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AllColor.black54, fontSize: 13.sp),
        filled: true,
        fillColor: AllColor.grey100,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _OnlineStatusRow extends StatelessWidget {
  const _OnlineStatusRow({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Online Status",
          style: TextStyle(fontSize: 13.sp, color: AllColor.black87, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AllColor.white,
          activeTrackColor: AllColor.blue500,
          inactiveThumbColor: AllColor.white,
          inactiveTrackColor: AllColor.grey300,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}

class _BottomSave extends StatelessWidget {
  const _BottomSave({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 16.h),
      child: SizedBox(
        width: 1.sw,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 13.h),
            decoration: BoxDecoration(
              color: AllColor.loginButtomColor, // orange
              borderRadius: BorderRadius.circular(24.r),
            ),
            alignment: Alignment.center,
            child: Text(
              "Save Changes",
              style: TextStyle(
                color: AllColor.white,
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
