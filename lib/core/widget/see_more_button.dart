import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
class SeeMoreButton extends StatelessWidget {
  const SeeMoreButton({super.key, required this.name, required this.seeMoreAction});
  final String name;
  final VoidCallback seeMoreAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30.h,),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 20.w),
              child: Text(
                '$name',
               style:Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 24.sp,
              )
            ),),
            Spacer(),
            TextButton(
              onPressed:
                seeMoreAction
              ,
              child: Text(
                'See More',
                style: TextStyle(
                  color: AllColor.yellow500,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h,),
      ],
    );
  }
}
