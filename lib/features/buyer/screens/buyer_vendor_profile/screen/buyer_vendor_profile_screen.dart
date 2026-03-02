import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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
import 'vendor_promotion_screen.dart';

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
    final async = ref.watch(vendorCategoryProductsProvider(vendorId));
    final int? effectiveUserId;
    if (userId > 0) {
      effectiveUserId = userId;
    } else {
      effectiveUserId = ref
          .watch(userIdByVendorIdProvider(vendorId))
          .valueOrNull;
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
                  final hasCoverImage =
                      coverImageUrl != null &&
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
                      decoration: BoxDecoration(color: Colors.grey.shade200),
                      child: const Center(child: CircularProgressIndicator()),
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
                      decoration: BoxDecoration(color: Colors.grey.shade200),
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
                      loading: () => const Center(child: Text('Loading...')),
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
        final reviewText = '$reviewCount';

        final openingTime = (vendor != null && hasText(vendor.openTime))
            ? vendor.openTime!
            : '8:00 AM';
        final closingTime = (vendor != null && hasText(vendor.closeTime))
            ? vendor.closeTime!
            : '7:00 PM';
        final opening = 'Opening time: $openingTime - $closingTime';

        // ---- Refined profile card (polished) ----
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.orange.shade100.withOpacity(0.5),
                  blurRadius: 28,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26.r),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.35, 1.0],
                    colors: [
                      Colors.orange.shade50.withOpacity(0.5),
                      Colors.orange.shade50.withOpacity(0.15),
                      Colors.white,
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top row: Promotion + Chat
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(24.r),
                            elevation: 1,
                            shadowColor: Colors.orange.shade200.withOpacity(0.4),
                            child: InkWell(
                              onTap: () {
                                VendorPromotionScreen.showLinkCreatePopup(
                                  context,
                                  ref,
                                  vendorId,
                                );
                              },
                              borderRadius: BorderRadius.circular(24.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18.w,
                                  vertical: 11.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24.r),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                    width: 1.2,
                                  ),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.shade100.withOpacity(0.5),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.campaign_rounded,
                                      size: 20.r,
                                      color: Colors.orange.shade700,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Promotion',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange.shade800,
                                        letterSpacing: 0.25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            elevation: 1,
                            shadowColor: Colors.black.withOpacity(0.06),
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: () => goToChatScreen(
                                context,
                                ref,
                                v,
                                myUserIdAsync,
                              ),
                              customBorder: const CircleBorder(),
                              child: Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1.2,
                                  ),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 22.r,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 26.h),
                      // Profile image with ring
                      Container(
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.orange.shade200,
                              Colors.orange.shade500,
                              Colors.orange.shade700,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.shade300.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: EdgeInsets.all(3.5.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: FirstTimeShimmerImage(
                              imageUrl: img,
                              width: 82.r,
                              height: 82.r,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      // Name
                      Text(
                        name,
                        style: theme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                          color: const Color(0xFF1A1A1A),
                          letterSpacing: -0.35,
                          height: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10.h),
                      // Location
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(5.w),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 16.r,
                              color: Colors.red.shade400,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            location,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      // Opening time
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 16.r,
                              color: Colors.orange.shade600,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              opening,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 18.h),
                      // Rating + reviews (pill)
                      GestureDetector(
                        onTap: () => goToReviewScreen(context, vendorId),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.amber.shade50,
                                Colors.orange.shade50.withOpacity(0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(
                              color: Colors.amber.shade200,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.shade200.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StarRating(rating: rating, color: Colors.amber),
                              SizedBox(width: 12.w),
                              Icon(
                                Icons.rate_review_outlined,
                                size: 16.r,
                                color: Colors.grey.shade700,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                '$reviewText reviews',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
        const SnackBar(content: Text('Invalid user ID. Please login again.')),
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
        SnackBar(content: Text('Failed to open chat: ${e.toString()}')),
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
                      onTap: () => context.push(
                        ProductDetails.routeName,
                        extra: items[index].id,
                      ),
                      child: CustomNewProduct(
                        width: 130,
                        height: 140,
                        productName: items[index].name,
                        productPrices: items[index].sellPrice.toStringAsFixed(
                          2,
                        ),
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
