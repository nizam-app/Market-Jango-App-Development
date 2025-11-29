import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/localization/translation_kay.dart';
import 'package:market_jango/core/widget/custom_new_product.dart';
import 'package:market_jango/features/buyer/data/new_items_data.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/screen/buyer_vendor_profile_screen.dart';

class CustomNewItemsShow extends ConsumerWidget {
  const CustomNewItemsShow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newItemsAsync = ref.watch(buyerNewItemsProvider);
    bool loading = newItemsAsync.isLoading;
    return SizedBox(
      height: 210.h,
      child: newItemsAsync.when(
        data: (data) {
          final products = data!.data.data.map((e) => e.product).toList();
          return ListView.builder(
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            // Example item count
            itemBuilder: (context, index) {
              final product = products[index];
              return Builder(
                builder: (context) {
                  return CustomNewProduct(
                    width: 130,
                    height: 140,
                    productPrices: product.sellPrice,
                    productName: product.name.toString(),
                    imageHeight: 130,
                    image: product.image,
                    onTap: () {
                      context.push(
                        BuyerVendorProfileScreen.routeName,
                        extra: product.vendor.userId,
                      );
                    },
                  );
                },
              );
            },
          );
        },
        error: (error, stack) => Text(ref.t(TKeys.something_went_wrong)),
        loading: () => Center(child: Text(ref.t(TKeys.loading))),
      ),
    );
  }
}
