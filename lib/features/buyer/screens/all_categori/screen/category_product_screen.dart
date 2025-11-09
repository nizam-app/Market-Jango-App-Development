// lib/features/buyer/screens/category/category_product_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/screen/buyer_massage/widget/custom_textfromfield.dart';
import 'package:market_jango/features/buyer/screens/all_categori/data/buyer_catagori_vendor_list_data.dart';
import 'package:market_jango/features/buyer/screens/product/product_details.dart';
import 'package:market_jango/features/buyer/widgets/custom_discunt_card.dart';

import '../../buyer_vendor_profile/buyer_vendor_profile_screen.dart';

class CategoryProductScreen extends StatelessWidget {
  const CategoryProductScreen({super.key, required this.categoryVendorId});
  final int categoryVendorId;
  static const String routeName = '/categoryProductScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 10.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25.r),
                child: CustomTextFromField(
                  controller: TextEditingController(),
                  hintText: "Search your vendor",
                  prefixIcon: Icons.search,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Text(
                "Trend Loop",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontSize: 24.sp),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  VendorListSection(vendorId: categoryVendorId,),
                  const Expanded(child: ProductGridSection()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VendorListSection extends ConsumerWidget {
  const VendorListSection({
    super.key,
    required this.vendorId,   // currently active/selected vendor (to highlight)
    this.limit = 1,
  });

  final int vendorId;
  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorsAsync = ref.watch(vendorsProvider(limit));

    return Container(
      width: 110.w,
      color: AllColor.grey500,
      child: vendorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (vendors) {
          if (vendors.isEmpty) {
            return const Center(child: Text('No vendors'));
          }
          return ListView.builder(
            itemCount: vendors.length,
            itemBuilder: (context, index) {
              final v = vendors[index];
              final isActive = v.id == vendorId;

              return Column(
                children: [
                  SizedBox(height: 10.h),
                  InkWell(
                    onTap: () {
                      
                      context.push(
                        BuyerVendorProfileScreen.routeName,
                        extra: v.id,
                      );
                    },
                    child: CircleAvatar(
                      radius: isActive ? 32.r : 28.r,
                      backgroundColor:
                      isActive ? AllColor.orange : AllColor.white,
                      child: CircleAvatar(
                        radius: isActive ? 28.r : 24.r,
                        backgroundColor: AllColor.grey200,
                        child: Text(
                          _initials(v.businessName),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: AllColor.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Text(
                      v.businessName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.isEmpty ? '?' : parts.first[0].toUpperCase();
    return (parts[0].isEmpty ? '' : parts[0][0]) +
        (parts[1].isEmpty ? '' : parts[1][0].toUpperCase());
  }
}


class ProductGridSection extends StatelessWidget {
  const ProductGridSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 10.r),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.5,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return ProductCard(
          title: "Style meets comfort.",
          price: 128.00,
          imageUrl:
              "https://images.unsplash.com/photo-1514996937319-344454492b37?q=80&w=3087&auto=format&fit=crop",
          storeName: "R2A Store",
          memberSince: "Member Since 2014",
          storeImage: "https://randomuser.me/api/portraits/men/32.jpg",
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final String title;
  final double price;
  final String imageUrl;
  final String storeName;
  final String memberSince;
  final String storeImage;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.storeName,
    required this.memberSince,
    required this.storeImage,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(ProductDetails.routeName),
      child: Container(
        decoration: BoxDecoration(
          color: AllColor.white,
          borderRadius: BorderRadius.circular(4.r),
          boxShadow: [
            BoxShadow(
              color: AllColor.black.withOpacity(0.1),
              blurRadius: 6,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image + Discount badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(4.r),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 130.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // ✅ Only one Positioned (outside). The badge itself has no Positioned.
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: const CustomDiscountCord(),
                ),
              ],
            ),

            // Text + Store Info
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(color: AllColor.black),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    "\$$price",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 8.r,
                        backgroundImage: NetworkImage(storeImage),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            storeName,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AllColor.black,
                            ),
                          ),
                          Text(
                            memberSince.length > 12
                                ? '${memberSince.substring(0, 12)}...'
                                : memberSince,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AllColor.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}