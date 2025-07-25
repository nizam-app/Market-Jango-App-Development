import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/buyer/widgets/home_product_title.dart';
class SeeMoreButton extends StatelessWidget {
  const SeeMoreButton({super.key, required this.name, required this.seeMoreAction,this.isSeeMore = true});
  final String name;
  final VoidCallback seeMoreAction;
  final bool isSeeMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30.h,),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            HomePorductTitel(name: name),
            Spacer(),
            TextButton(
              onPressed:
                seeMoreAction
              ,
              child:isSeeMore? Text(
                'See More',
                style: TextStyle(
                  color: AllColor.yellow500,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ):SizedBox()
            ),
          ],
        ),
        SizedBox(height: 16.h,),
      ],
    );
  }
}


