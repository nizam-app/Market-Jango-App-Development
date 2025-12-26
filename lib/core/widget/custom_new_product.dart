import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/utils/image_controller.dart';

class CustomNewProduct extends StatelessWidget {
  const CustomNewProduct({
    super.key,
    this.width = 100,
    required this.height,
    this.imageHeight = 157,
    required this.productPrices,
    required this.productName,
    this.checking = false,
    this.onTap,
    this.image =
        "https://t4.ftcdn.net/jpg/05/98/45/79/360_F_598457961_hojY3MEjPaYBgdUkfaWO6mPNuHce6WFv.jpg",
    this.viewCount,
  });
  final double width;
  final double height;
  final double imageHeight;
  final String productPrices;
  final String productName;
  final String image;
  final int? viewCount; // number of views

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
          width: width.w,
          height: height.h,
          decoration: BoxDecoration(
            color: AllColor.white,
            borderRadius: BorderRadius.circular(7.r),
            boxShadow: [
              BoxShadow(
                color: AllColor.black.withOpacity(0.06),
                blurRadius: 18.r,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: SizedBox.expand(
                    child: FirstTimeShimmerImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // View count overlay - always show if viewCount is not null
                if (viewCount != null)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.remove_red_eye,
                            size: 12.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            viewCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.h, left: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 3.h),
              Text(
                productName.length < 12
                    ? productName
                    : "${productName.substring(0, 12)}...",
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(color: AllColor.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 10.h),
              Text(
                productPrices.length < 12
                    ? productPrices
                    : "${productPrices.substring(0, 12)}...",
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
