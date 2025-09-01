import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:market_jango/core/widget/custom_new_product.dart';

import 'package:market_jango/features/buyer/widgets/custom_discunt_card.dart';
class CustomSeeAllProduct extends StatelessWidget {
  const CustomSeeAllProduct({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            // mainAxisSpacing: 0.h,
            crossAxisSpacing: 8.w,
            childAspectRatio: 0.6.h,
          ),
          itemCount: 20,
          // Example item count
          itemBuilder: (context, index) {
            return Stack(
              children: [
                CustomNewProduct(width: 162.w, height: 178.h, text: 'Product Name', text2: '',),
                Positioned(
                  right: 10.w,
                    child: CustomDiscountCord())
              ],
            );

          })
      ,
    );
  }
}