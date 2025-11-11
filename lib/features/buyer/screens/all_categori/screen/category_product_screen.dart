// lib/features/buyer/screens/category/category_product_screen.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_search_bar.dart';
import 'package:market_jango/features/buyer/screens/all_categori/data/buyer_catagori_vendor_list_data.dart';
import 'package:market_jango/features/buyer/screens/all_categori/data/vendor_first_product_data.dart';
import 'package:market_jango/features/buyer/screens/all_categori/model/buyer_vendor_search_model.dart';
import 'package:market_jango/features/buyer/screens/product/product_details.dart';
import 'package:market_jango/features/buyer/widgets/custom_discunt_card.dart';

import '../../buyer_vendor_profile/screen/buyer_vendor_profile_screen.dart';
import '../data/buyer_vendor_search_data.dart';

final selectedVendorIdProvider = StateProvider.autoDispose<int>((ref) => 1);

class CategoryProductScreen extends ConsumerStatefulWidget {
  const CategoryProductScreen({super.key, required this.categoryVendorId});
  final int categoryVendorId;
  static const String routeName = '/categoryProductScreen';

  @override
  ConsumerState<CategoryProductScreen> createState() =>
      _CategoryProductScreenState();
}

class _CategoryProductScreenState extends ConsumerState<CategoryProductScreen> {
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedVendorIdProvider.notifier).state =
          widget.categoryVendorId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedVendorIdProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padding(
            //   padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 10.h),
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(25.r),
            //     child: CustomTextFromField(
            //       controller: TextEditingController(),
            //       hintText: "Search your vendor",
            //       prefixIcon: Icons.search,
            //     ),
            //   ),
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 10.h),
              child: GlobalSearchBar<VendorSearchResponse, VendorSuggestion>(
                provider: vendorSearchProvider, // আপনার সার্চ প্রোভাইডার
                itemsSelector: (res) => res.data.suggestions, // suggestion list
                itemBuilder: (context, v) => VendorSuggestionTile(v: v),
                onItemSelected: (v) {
                  // ✅ সার্চ থেকে সিলেক্ট করলে লিস্টে হাইলাইট/সুইচ হবে
                  ref.read(selectedVendorIdProvider.notifier).state =
                      v.vendorId;
                },
                hintText: 'Search vendors...',
                debounce: const Duration(milliseconds: 600),
                minChars: 1,
                showResults: true,
                resultsMaxHeight: 380,
                autofocus: false,
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
                  VendorListSection(vendorId: selectedId, limit: 10),
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
    required this.vendorId, // currently active/selected vendor (to highlight)
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
                      backgroundColor: isActive
                          ? AllColor.orange
                          : AllColor.white,
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
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
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
    if (parts.length == 1)
      return parts.first.isEmpty ? '?' : parts.first[0].toUpperCase();
    return (parts[0].isEmpty ? '' : parts[0][0]) +
        (parts[1].isEmpty ? '' : parts[1][0].toUpperCase());
  }
}

class ProductGridSection extends ConsumerWidget {
  const ProductGridSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncVendors = ref.watch(vendorFirstProductProvider);

    return asyncVendors.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (list) {
        final items = list; // already filtered to product != null
        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 10.r),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 0.5,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final v = items[index];
            final p = v.product!;

            return ProductCard(
              title: p.name, // product name
              price: p.sellPrice, // product sell price
              imageUrl: p.image, // product image
              storeName: v.businessName.isNotEmpty
                  ? v.businessName
                  : v.vendorName, // store/biz name
              memberSince: v.category != null
                  ? "Category: ${v.category!.name}"
                  : "Vendor #${v.vendorId}", // placeholder text
              storeImage:
                  v.vendorImage ??
                  "https://ui-avatars.com/api/?name=${Uri.encodeComponent(v.vendorName)}",
              discount: p.discount,
              productId: p.id,
              vendorId: v.vendorId,
            );
          },
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
  final int? discount;
  final int productId;
  final int vendorId;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.storeName,
    required this.memberSince,
    required this.storeImage,
    this.discount,
    required this.productId,
    required this.vendorId,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(ProductDetails.routeName, extra: productId),
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

                if (discount != null && discount != 0)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: CustomDiscountCord(discount: '${discount}'),
                  ),
              ],
            ),

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
                  SizedBox(height: 20.h),
                  InkWell(
                    onTap: () => context.push(
                      BuyerVendorProfileScreen.routeName,
                      extra: vendorId,
                    ),
                    child: Row(
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
                              "${storeName.substring(0, math.min(10, storeName.length))}",
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

class VendorSuggestionTile extends StatelessWidget {
  const VendorSuggestionTile({super.key, required this.v});
  final VendorSuggestion v;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      leading: CircleAvatar(
        radius: 18.r,
        backgroundColor: AllColor.grey200,
        backgroundImage: (v.imageUrl != null && v.imageUrl!.isNotEmpty)
            ? NetworkImage(v.imageUrl!)
            : null,
        child: (v.imageUrl == null || v.imageUrl!.isEmpty)
            ? Text(
                _initials(v.businessName),
                style: TextStyle(fontSize: 12.sp, color: AllColor.black),
              )
            : null,
      ),
      title: Text(
        v.businessName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
      ),
      subtitle: Text(
        v.ownerName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12.sp, color: AllColor.grey500),
      ),
    );
  }

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1)
      return parts.first.isEmpty ? '?' : parts.first[0].toUpperCase();
    return (parts[0].isEmpty ? '' : parts[0][0]).toUpperCase() +
        (parts[1].isEmpty ? '' : parts[1][0].toUpperCase());
  }
}