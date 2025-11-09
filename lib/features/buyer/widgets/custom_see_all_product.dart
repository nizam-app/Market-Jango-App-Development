import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/custom_new_product.dart';
import 'package:market_jango/features/buyer/screens/product/product_details.dart';
import 'package:market_jango/features/buyer/widgets/custom_discunt_card.dart';

class CustomSeeAllProduct extends ConsumerWidget {

  final product;
  const CustomSeeAllProduct({
    super.key,
    required this.product,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: GridView.builder(
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          // mainAxisSpacing: 0.h,
          crossAxisSpacing: 8.w,
          childAspectRatio: 0.77,
        ),
        itemCount: product.length,
        // Example item count
        itemBuilder: (context, index) {
          final products = product[index];
          return GestureDetector(
            onTap: () {
              context.push(ProductDetails.routeName, extra: products.id);
            },
            child: Stack(
              children: [
                CustomNewProduct(
                  width: 162,
                  height: 150,
                  productPricesh: products.sellPrice,
                  productName: products.name,
                  image: products.image,
                  imageHeight: 137,
                ),
                if (products.discount != null && products.discount != 0)
                  Positioned(
                    top: 10.h,
                    right: 15.w,
                    child: CustomDiscountCord(discount: ""),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}