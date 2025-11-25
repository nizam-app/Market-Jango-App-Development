import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';

class CustomTextFromField extends StatelessWidget {
  const CustomTextFromField({
    super.key,
    this.hintText,
    this.prefixIcon,
    required this.controller,
    this.onFieldSubmitted,
  });
  final String? hintText;
  final IconData? prefixIcon;
  final TextEditingController controller;
  final onFieldSubmitted;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: onFieldSubmitted,

      decoration: InputDecoration(
        hintText: '$hintText',

        prefixIcon: Icon(prefixIcon),
        filled: true,
        fillColor: AllColor.grey300,
        contentPadding: EdgeInsets.symmetric(vertical: 0.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
