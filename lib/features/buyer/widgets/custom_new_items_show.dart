import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/widget/custom_new_product.dart';
import 'package:market_jango/features/buyer/screens/home_screen.dart';

class CustomNewItemsShow extends StatelessWidget {
  const CustomNewItemsShow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.h,
      child: ListView.builder(
          shrinkWrap: true,
          physics:AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          // Example item count
          itemBuilder: (context, index) {
            return CustomNewProduct(width: 130.w, height: 140.h, text: '', text2: '',);}
      ),
    );
  }
}
