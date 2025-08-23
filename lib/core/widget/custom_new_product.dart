import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/constants/image_control/image_path.dart';

class CustomNewProduct extends StatelessWidget {
  const CustomNewProduct({
    super.key, required this.width, required this.height
  });
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w,vertical: 5.h),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.asset(
                  '${ImagePath.justForYouImage}', // আপনার ইমেজ পাথ দিন এখানে
                  fit: BoxFit.contain,

                ),
              ),
              // Discount Tag

            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.h,left: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 3.h,),
              Text("New T-shirt, sun-glass".length > 12 ? "New T-shirt," : "New T-shirt, sun-glass",style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AllColor.black),maxLines: 1,overflow: TextOverflow.ellipsis,),
              SizedBox(height: 5.h,),
              Text("\$17,00",style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 18),)
            ],
          ),
        ),

      ],
    );
  }
}