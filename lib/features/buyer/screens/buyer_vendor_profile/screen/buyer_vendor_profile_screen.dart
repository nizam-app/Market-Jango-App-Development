import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/screen/profile_screen/data/profile_data.dart';
import 'package:market_jango/core/screen/profile_screen/model/profile_model.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/widget/custom_new_product.dart';
import 'package:market_jango/core/widget/see_more_button.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/data/buyer_vendor_categori_data.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/data/buyer_vendor_propuler_product_data.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/data/user_id_by_vendor_data.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/model/buyer_vendor_category_model.dart';
import 'package:market_jango/features/buyer/screens/product/product_details.dart';
import 'package:market_jango/features/buyer/screens/review/data/buyer_review_data.dart';
import 'package:market_jango/features/buyer/screens/review/review_screen.dart';
import 'package:market_jango/features/buyer/widgets/custom_discunt_card.dart';
import 'package:market_jango/core/screen/buyer_massage/model/chat_history_route_model.dart';
import 'package:market_jango/core/screen/buyer_massage/screen/global_chat_screen.dart';
import 'package:market_jango/core/utils/get_user_type.dart';

import 'buyer_vendor_cetagory_screen.dart';

class BuyerVendorProfileScreen extends ConsumerWidget {
  const BuyerVendorProfileScreen({
    super.key,
    required this.vendorId,
    required this.userId,
  });

  static final String routeName = '/vendorProfileScreen';
  final int vendorId;
  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Logger().d(vendorId);
    final async = ref.watch(vendorCategoryProductsProvider(vendorId));
    final int? effectiveUserId;
    if (userId > 0) {
      effectiveUserId = userId;
    } else {
      effectiveUserId = ref.watch(userIdByVendorIdProvider(vendorId)).valueOrNull;
    }
    final userAsync = effectiveUserId != null && effectiveUserId > 0
        ? ref.watch(userProvider(effectiveUserId.toString()))
        : const AsyncValue<UserModel>.loading();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Cover image section with back icon overlay
              userAsync.when(
                data: (user) {
                  final coverImageUrl = user.coverImage;
                  final hasCoverImage = coverImageUrl != null &&
                      coverImageUrl.trim().isNotEmpty &&
                      (coverImageUrl.startsWith('http://') ||
                          coverImageUrl.startsWith('https://'));
                  final String safeCoverImage = coverImageUrl?.trim() ?? '';

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.r),
                          bottomRight: Radius.circular(20.r),
                        ),
                        child: Container(
                          height: 200.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                          ),
                          child: hasCoverImage
                              ? FirstTimeShimmerImage(
                                  imageUrl: safeCoverImage,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey.shade300,
                                  child: Center(
                                    child: Icon(
                                      Icons.store,
                                      size: 50.r,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      // Back icon positioned on top of cover image
                      Positioned(
                        top: 10.h,
                        left: 10.w,
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Stack(
                  children: [
                    Container(
                      height: 200.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    // Back icon positioned on top of cover image
                    Positioned(
                      top: 10.h,
                      left: 10.w,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                error: (_, __) => Stack(
                  children: [
                    Container(
                      height: 200.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.store,
                          size: 50.r,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                    // Back icon positioned on top of cover image
                    Positioned(
                      top: 10.h,
                      left: 10.w,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CustomVendorUpperSection(
                userId: effectiveUserId?.toString(),
                vendorId: vendorId,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Column(
                  children: [
                    SeeMoreButton(name: "Popular", isSeeMore: false),
                    PopularProduct(vendorId: vendorId),

                    async.when(
                      loading: () =>
                          const Center(child: Text('Loading...')),
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
  const CustomVendorUpperSection({
    super.key,
    required this.userId,
    required this.vendorId,
  });

  final String? userId;
  final int vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId == null || userId!.isEmpty || userId == '0') {
      return Padding(
        padding: EdgeInsets.all(20.w),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    final async = ref.watch(userProvider(userId!));
    final reviewCountAsync = ref.watch(vendorReviewCountProvider(vendorId));
    final theme = Theme.of(context).textTheme;
    final myUserIdAsync = ref.watch(getUserIdProvider);

    return async.when(
      loading: () => Padding(
        padding: EdgeInsets.all(20.w),
        child: const Center(child: Text('Loading...')),
      ),
      error: (e, _) =>
          Padding(padding: EdgeInsets.all(20.w), child: Text(e.toString())),
      data: (v) {
        // ---- SAFE READS (no ! anywhere) ----
        final vendor = v.vendor; // may be null
        bool hasText(String? s) => s != null && s.trim().isNotEmpty;

        final name = hasText(v.name)
            ? v.name
            : (vendor != null && hasText(vendor.businessName))
            ? vendor.businessName
            : 'Vendor';

        final img = hasText(v.image)
            ? v.image
            : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQvulry9PHytXyLFph-HdGDizB7P5EF38IskQ&s';

        final location = (vendor != null && hasText(vendor.country))
            ? vendor.country
            : '—';

        // যদি আসল রেটিং না থাকে, UI ঠিক রাখতে fallback
        final double rating = vendor?.avgRating ?? 0;
        // Use total review count from API instead of nested reviews length
        final reviewCount = reviewCountAsync.value ?? 0;
        final reviewText =
            '${rating.toStringAsFixed(2)} ( $reviewCount reviews )';

        final openingTime = (vendor != null && hasText(vendor.openTime))
            ? vendor.openTime!
            : '8:00 AM';
        final closingTime = (vendor != null && hasText(vendor.closeTime))
            ? vendor.closeTime!
            : '7:00 PM';
        final opening = 'Opening time: $openingTime - $closingTime';

        // ---- UI (unchanged look) ----
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back icon removed - now on cover image
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                    child: FirstTimeShimmerImage(
                      imageUrl: img,
                      width: 70.r,
                      height: 70.r,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: theme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Icon(Icons.location_on, size: 16.sp, color: Colors.red),
                      Flexible(
                        child: Text(
                          location,
                          style: theme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StarRating(rating: rating, color: Colors.amber),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: GestureDetector(
                          onTap: () => goToReviewScreen(context, vendorId),
                          child: Text(
                            reviewText,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => goToChatScreen(context, ref, v, myUserIdAsync),
                child: const Icon(Icons.chat_bubble_outline),
              ),
            ],
          ),
        );
      },
    );
  }

  void goToReviewScreen(BuildContext context, int vendorId) {
    context.push(ReviewScreen.routeName, extra: vendorId);
  }

  void goToChatScreen(
    BuildContext context,
    WidgetRef ref,
    UserModel vendor,
    AsyncValue<String?> myUserIdAsync,
  ) {
    final myUserIdStr = myUserIdAsync.value;
    if (myUserIdStr == null || myUserIdStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to get user ID. Please login again.'),
        ),
      );
      return;
    }

    final myUserIdInt = int.tryParse(myUserIdStr);
    if (myUserIdInt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid user ID. Please login again.'),
        ),
      );
      return;
    }

    final vendorName = vendor.name.isNotEmpty
        ? vendor.name
        : (vendor.vendor?.businessName.isNotEmpty ?? false)
            ? vendor.vendor!.businessName
            : 'Vendor';

    final vendorImage = vendor.image.isNotEmpty
        ? vendor.image
        : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQvulry9PHytXyLFph-HdGDizB7P5EF38IskQ&s';

    try {
      context.push(
        GlobalChatScreen.routeName,
        extra: ChatArgs(
          partnerId: vendor.id,
          partnerName: vendorName,
          partnerImage: vendorImage,
          myUserId: myUserIdInt,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open chat: ${e.toString()}'),
        ),
      );
    }
  }
}

class FashionProduct extends StatelessWidget {
  const FashionProduct({super.key, this.products});

  final List<VcpProduct>? products;

  @override
  Widget build(BuildContext context) {
    final items = products ?? const [];

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 220.h,
      // Use Row for 1-2 items to ensure left alignment, ListView for more items
      child: items.length <= 2
          ? Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int index = 0; index < items.length; index++) ...[
                    GestureDetector(
                      onTap: () =>
                          context.push(ProductDetails.routeName, extra: items[index].id),
                      child: CustomNewProduct(
                        width: 130,
                        height: 140,
                        productName: items[index].name,
                        productPrices: items[index].sellPrice.toStringAsFixed(2),
                        image: items[index].image,
                        imageHeight: 130,
                      ),
                    ),
                    if (index < items.length - 1) SizedBox(width: 12.w),
                  ],
                ],
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 10.w, right: 10.w),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final p = items[index];
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: GestureDetector(
                    onTap: () =>
                        context.push(ProductDetails.routeName, extra: p.id),
                    child: CustomNewProduct(
                      width: 130,
                      height: 140,
                      productName: p.name,
                      productPrices: p.sellPrice.toStringAsFixed(2),
                      image: p.image,
                      imageHeight: 130,
                    ),
                  ),
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
      loading: () => const Center(child: Text('Loading...')),
      error: (e, _) =>
          Padding(padding: EdgeInsets.all(12.w), child: Text(e.toString())),
      data: (resp) {
        final items = resp?.data ?? const [];
        if (items.isEmpty) {
          //'No popular products found'
          return Padding(
            padding: EdgeInsets.all(12.w),
            child: Text(ref.t(BKeys.no_popular_products_found)),
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
                  if (p.discount > 0)
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
