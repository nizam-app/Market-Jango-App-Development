import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/features/buyer/widgets/custom_see_all_product.dart';

import 'home_screen.dart';
class SeeNewItemsScreen extends StatelessWidget {
  const SeeNewItemsScreen({super.key});
  static const String routeName = '/seeNewItemsScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
                    children: [
            Tuppertextandbackbutton(screenName: "New Items"),
                      CustomSeeAllProduct()


                    ],
                  ),
          ))
    );
  }
}
