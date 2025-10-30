import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/buyer/screens/product/product_details.dart';

class CustomNewProduct extends StatelessWidget {
  const CustomNewProduct({
    super.key,
    required this.width,
    required this.height,
    required this.text,
    required this.text2,
    this.checking = false,
     this.onTap,
    this.image =
        "https://res.cloudinary.com/dxrb6gab0/image/upload/v1761320111/product/image/k11fpqaa52odzuch0mlt.jpg",
  });
  final double width;
  final double height;
  final String text;
  final String text2;
  final String image;
 
  final bool checking;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AllColor.white,
            borderRadius: BorderRadius.circular(7.r),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              InkWell(
                onTap: onTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    image,
                    height: 157.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Discount Tag
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.h, left: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 3.h),
              Text(
                text2.length < 12 ? text2 : text2.substring(0,12) + "...",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(color: AllColor.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 10.h),
              Text(
                text.length < 12 ? text : text.substring(0,12) + "...",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontSize: 18.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }
}