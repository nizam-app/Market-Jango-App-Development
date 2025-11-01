

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/%20business_logic/models/categories_model.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/buyer/data/categories_data_read.dart';
import 'package:market_jango/features/buyer/screens/product/product_details.dart';

class CustomTopProducts extends ConsumerWidget {
  CustomTopProducts({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allProducts = ref.watch(Category.loadCategories);
    return SizedBox(
        height: 55.h,
        width: double.infinity,
        child:allProducts.when(data: (product) {
          List<CategoriesModel> topProducts =product.where((eliment) => eliment.topProduct == true).toList();
          return ListView.builder(
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: topProducts.length, // Example item count
              itemBuilder: (context, index) {
                final allTopProduct = topProducts[index];
                return InkWell(
                  onTap: (){context.push(ProductDetails.routeName,);},
                  child: CircleAvatar(radius: 30.r,backgroundColor: AllColor.white,
                    child: CircleAvatar(
                      radius: 24.r,
                      backgroundImage: AssetImage("${allTopProduct.image}"),
                    ),
                  ),
                );
              }
          );}, error: (error, stack) => Text('Something went wrong'),
          loading: () => CircularProgressIndicator(),
        ));
  }

}