import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/translation_kay.dart';
import 'package:market_jango/features/buyer/widgets/home_product_title.dart';

import '../localization/tr.dart';
class SeeMoreButton extends ConsumerWidget {
  const SeeMoreButton({super.key, required this.name,  this.seeMoreAction,this.isSeeMore = true});
  final String name;
  final VoidCallback? seeMoreAction;
  final bool isSeeMore;

  @override
  Widget build(BuildContext context,ref) {
    return Column(
      children: [
        SizedBox(height: 20.h,),
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
                ref.t(TKeys.seeAll),
                style: TextStyle(
                  color: AllColor.orange500,
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