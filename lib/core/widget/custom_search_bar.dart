import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';

class CustomSearchBar extends StatelessWidget {
  const  CustomSearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Search for products',
        hintStyle: TextStyle(color: AllColor.hintTextColor,fontSize: 16.sp),
        prefixIcon: Icon(Icons.search,),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 12.h,),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50.r),
          borderSide: BorderSide(color: Colors.grey), // ফোকাসে যেটা দেখাতে চান
        ),
      ), // থিম ইনহেরিট না করার জন্য
    );
  }

}