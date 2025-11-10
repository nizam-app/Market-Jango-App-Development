import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/widget/custom_new_product.dart';
import 'package:market_jango/core/widget/see_more_button.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/data/buyer_vendor_categori_data.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/model/buyer_vendor_category_model.dart';
import 'package:market_jango/features/buyer/screens/review/review_screen.dart';
import 'package:market_jango/features/buyer/screens/see_just_for_you_screen.dart';
import 'package:market_jango/features/buyer/widgets/custom_discunt_card.dart';

import 'buyer_vendor_cetagory_screen.dart';

class BuyerVendorProfileScreen extends ConsumerWidget {
  const BuyerVendorProfileScreen({super.key, required this.vendorId});
  static final String routeName = '/vendorProfileScreen';
  final int vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vendorCategoryProductsProvider(vendorId));
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomVendorUpperSection(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Column(
                  children: [
                    SeeMoreButton(name: "Populer", isSeeMore: false),
                    PopularProduct(),

                    async.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text(e.toString())),
                      data: (res) {
                        final categories = res?.data.categories.data ?? [];

                        if (categories.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          children: [
                            for (final c in categories) ...[
                              SeeMoreButton(
                                name: c.name,
                                seeMoreAction: () {
                                  context.pushNamed(
                                    BuyerVendorCetagoryScreen.routeName,
                                    pathParameters: {"screenName": c.name}, 
                                    extra: vendorId, 
                                  );
                                },
                              ),
                              FashionProduct(products: c.products),
                            ],
                          ],
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomVendorUpperSection extends StatelessWidget {
  const CustomVendorUpperSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              context.pop();
            },
            child: Icon(Icons.arrow_back_ios),
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile image
              CircleAvatar(
                radius: 35.r,
                backgroundImage: NetworkImage(
                  "https://images.unsplash.com/photo-1607746882042-944635dfe10e",
                ),
              ),
              SizedBox(height: 8.h),

              // Name + Location
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "TrendLoop",
                    style: theme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Icon(Icons.location_on, size: 16.sp, color: Colors.red),
                  Text("Dhaka", style: theme.titleMedium),
                ],
              ),
              SizedBox(height: 4.h),

              // Opening time
              Text(
                "Opening time: 8:00 am - 7:00 pm",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
              SizedBox(height: 8.h),

              // Rating + Review count
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StarRating(rating: 4.6, color: Colors.amber),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {
                      goToReviewScreen(context);
                    },
                    child: Text(
                      "4.6 ( 66 reviews )",
                      style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }

  void goToReviewScreen(BuildContext context) {
    context.push(ReviewScreen.routeName);
  }
}

class FashionProduct extends StatelessWidget {
  const FashionProduct({
    super.key,
    this.products,
  });
  final List<VcpProduct>? products;

  @override
  Widget build(BuildContext context) {
    final items = products ?? const [];

    return SizedBox(
      height: 220.h,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: items.isEmpty ? 10 : items.length,
        itemBuilder: (context, index) {
          if (items.isEmpty) {
            return CustomNewProduct(
              width: 130,
              height: 140,
              productName: 'Product Name',
              productPricesh: 'prices',
              imageHeight: 130,
            );
          }

          final p = items[index];
          return CustomNewProduct(
            width: 130,
            height: 140,
            imageHeight: 130,

            productName: p.name,
            productPricesh: p.sellPrice.toStringAsFixed(2),
            image: p.image,
            // 
          );
        },
      ),
    );
  }
}


class PopularProduct extends StatelessWidget {
  const PopularProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        // mainAxisSpacing: 0.h,
        crossAxisSpacing: 8.w,
        childAspectRatio: 0.68.h,
      ),
      itemCount: 4,
      // Example item count
      itemBuilder: (context, index) {
        return Stack(
          children: [
            CustomNewProduct(
              width: 162.w,
              height: 175.h,
              productPricesh: 'Product Name',
              productName: 'price',
            ),
            Positioned(top: 10, right: 30, child: CustomDiscountCord()),
          ],
        );
      },
    );
  }
}