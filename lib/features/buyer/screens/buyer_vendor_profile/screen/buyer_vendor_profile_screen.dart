import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:market_jango/core/screen/profile_screen/data/profile_data.dart';
import 'package:market_jango/core/widget/custom_new_product.dart';
import 'package:market_jango/core/widget/see_more_button.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/data/buyer_vendor_categori_data.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/data/buyer_vendor_propuler_product_data.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/model/buyer_vendor_category_model.dart';
import 'package:market_jango/features/buyer/screens/product/product_details.dart';
import 'package:market_jango/features/buyer/screens/review/review_screen.dart';
import 'package:market_jango/features/buyer/widgets/custom_discunt_card.dart';

import 'buyer_vendor_cetagory_screen.dart';

class BuyerVendorProfileScreen extends ConsumerWidget {
  const BuyerVendorProfileScreen({super.key, required this.vendorId});

  static final String routeName = '/vendorProfileScreen';
  final int vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Logger().d(vendorId);
    final async = ref.watch(vendorCategoryProductsProvider(vendorId));
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomVendorUpperSection(vendorId: vendorId.toString()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Column(
                  children: [
                    SeeMoreButton(name: "Popular", isSeeMore: false),
                    PopularProduct(vendorId: vendorId),

                    async.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text(e.toString())),
                      data: (res) {
                        final categories = res?.data.categories.data ?? [];

                        if (categories.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          children: [
                            for (final c in categories) ...[
                              if (c.products.isNotEmpty)
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
                              if (c.products.isNotEmpty)
                                FashionProduct(products: c.products),
                            ],
                          ],
                        );
                      },
                    ),
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

class CustomVendorUpperSection extends ConsumerWidget {
  const CustomVendorUpperSection({super.key, required this.vendorId});

  final String vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(userProvider(vendorId));
    final theme = Theme.of(context).textTheme;

    return async.when(
      loading: () => Padding(
        padding: EdgeInsets.all(20.w),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) =>
          Padding(padding: EdgeInsets.all(20.w), child: Text(e.toString())),
      data: (v) {
        // ---- SAFE READS (no ! anywhere) ----
        final vendor = v.vendor; // may be null
        final hasText = (String? s) => s != null && s.trim().isNotEmpty;

        final name = hasText(v.name)
            ? v.name
            : (vendor != null && hasText(vendor.businessName))
            ? vendor.businessName
            : 'Vendor';

        final img = hasText(v.image)
            ? v.image!
            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQvulry9PHytXyLFph-HdGDizB7P5EF38IskQ&s';

        final location = (vendor != null && hasText(vendor.country))
            ? vendor.country
            : '—';

        // যদি আসল রেটিং না থাকে, UI ঠিক রাখতে fallback
        final double rating = vendor?.avgRating ?? 0;
        final reviewText =
            '${rating.toStringAsFixed(2)} ( ${v.vendor} reviews )';

        final opening = (v.createdAt != null && v.expiresAt != null)
            ? 'Opening time: ${v.createdAt} - ${v.expiresAt}'
            : 'Opening time: 8:00 am - 7:00 pm';

        // ---- UI (unchanged look) ----
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_ios),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 35.r,
                    backgroundImage: NetworkImage(img),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: theme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Icon(Icons.location_on, size: 16.sp, color: Colors.red),
                      Text(location, style: theme.titleMedium),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    opening,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StarRating(rating: rating, color: Colors.amber),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () =>
                            goToReviewScreen(context, int.parse(vendorId)),
                        child: Text(
                          reviewText,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }

  void goToReviewScreen(BuildContext context, int vendorId) {
    context.push(ReviewScreen.routeName, extra: vendorId);
  }
}

class FashionProduct extends StatelessWidget {
  const FashionProduct({super.key, this.products});

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
        itemCount: items.length,
        itemBuilder: (context, index) {
          if (items.isEmpty) {
            return const SizedBox.shrink();
          }

          if (items.isNotEmpty) {
            final p = items[index];
            return GestureDetector(
              onTap: () => context.push(ProductDetails.routeName, extra: p.id),
              child: CustomNewProduct(
                width: 130,
                height: 140,
                productName: p.name,
                productPrices: p.sellPrice.toStringAsFixed(2),
                image: p.image,
                imageHeight: 130,
              ),
            );
          }

          final p = items[index];
          return CustomNewProduct(
            width: 130,
            height: 140,
            imageHeight: 130,

            productName: p.name,
            productPrices: p.sellPrice.toStringAsFixed(2),
            image: p.image,
            //
          );
        },
      ),
    );
  }
}

class PopularProduct extends ConsumerWidget {
  const PopularProduct({super.key, required this.vendorId});

  final int vendorId; // pass the ID you used in Postman (e.g., 1)

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(popularProductsProvider(vendorId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Padding(padding: EdgeInsets.all(12.w), child: Text(e.toString())),
      data: (resp) {
        final items = resp?.data ?? const [];
        if (items.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(12.w),
            child: const Text('No popular products found'),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.w,
            childAspectRatio: 0.60,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final p = items[index].product;

            return GestureDetector(
              onTap: () => context.push(ProductDetails.routeName, extra: p.id),
              child: Stack(
                children: [
                  CustomNewProduct(
                    width: 162.w,
                    height: 175.h,
                    // Your widget’s param names are a bit swapped in example,
                    // keeping exactly as your API expects:
                    productPrices: p.name,
                    // title
                    productName: p.sellPrice.toStringAsFixed(2),
                    image: p.image,
                  ),
                  if (p.discount != null && p.discount! > 0)
                    Positioned(
                      top: 10,
                      right: 30,
                      child: CustomDiscountCord(
                        discount: p.discount.toString(),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
