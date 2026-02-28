import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/widget/custom_new_product.dart';
import 'package:market_jango/features/buyer/data/new_items_data.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/screen/buyer_vendor_profile_screen.dart';

class CustomNewItemsShow extends ConsumerWidget {
  const CustomNewItemsShow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newItemsAsync = ref.watch(buyerNewItemsProvider);
    return SizedBox(
      height: 210.h,
      child: newItemsAsync.when(
        data: (data) {
          final products = data?.data.data ?? [];
          if (products.isEmpty) {
            return const SizedBox.shrink();
          }
          // Use Row for 1-2 items to ensure left alignment, ListView for more items
          if (products.length <= 2) {
            return Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int index = 0; index < products.length; index++) ...[
                    CustomNewProduct(
                      width: 130,
                      height: 140,
                      productPrices: products[index].sellPrice.isNotEmpty
                          ? products[index].sellPrice
                          : products[index].regularPrice,
                      productName: products[index].name.toString(),
                      imageHeight: 130,
                      image: products[index].image,
                      onTap: () {
                        context.push(
                          BuyerVendorProfileScreen.routeName,
                          extra: {
                            'vendorId': products[index].vendor.id,
                            'userId': products[index].vendor.userId,
                          },
                        );
                      },
                    ),
                    if (index < products.length - 1) SizedBox(width: 12.w),
                  ],
                ],
              ),
            );
          }
          
          return ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 20.w, right: 20.w),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: CustomNewProduct(
                  width: 130,
                  height: 140,
                  productPrices: product.sellPrice.isNotEmpty
                      ? product.sellPrice
                      : product.regularPrice,
                  productName: product.name.toString(),
                  imageHeight: 130,
                  image: product.image,
                  onTap: () {
                    context.push(
                      BuyerVendorProfileScreen.routeName,
                      extra: {
                        'vendorId': product.vendor.id,
                        'userId': product.vendor.userId,
                      },
                    );
                  },
                ),
              );
            },
          );
        },
        error: (error, stack) => Text(ref.t(BKeys.something_went_wrong)),
        loading: () => Center(child: Text(ref.t(BKeys.loading))),
      ),
    );
  }
}
