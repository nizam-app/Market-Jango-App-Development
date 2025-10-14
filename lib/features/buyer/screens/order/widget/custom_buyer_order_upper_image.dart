import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';

class CustomBuyerOrderUpperImage extends StatelessWidget {
  const CustomBuyerOrderUpperImage({
    super.key,
    required this.imageUrl,
    this.title = "To Receive",
    this.subtitle = "All Orders",
    this.onTap,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          CircleAvatar(
            radius: 25.r, // small like the mock
            backgroundImage: NetworkImage(imageUrl),
          ),
          SizedBox(width: 10.w),

          // Texts
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AllColor.black,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AllColor.grey, // lighter subtitle
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}