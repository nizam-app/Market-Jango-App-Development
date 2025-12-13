import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/models/global_search_model.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/widget/custom_new_product.dart';
import 'package:market_jango/core/widget/global_notification_icon.dart';
import 'package:market_jango/core/widget/global_search_bar.dart';
import 'package:market_jango/core/widget/see_more_button.dart';
import 'package:market_jango/features/buyer/data/banner_data.dart';
import 'package:market_jango/features/buyer/data/buyer_categori_data.dart';
import 'package:market_jango/features/buyer/data/buyer_just_for_you_data.dart';
import 'package:market_jango/features/buyer/data/buyer_top_data.dart';
import 'package:market_jango/features/buyer/data/new_items_data.dart';
import 'package:market_jango/features/buyer/logic/slider_manage.dart';
import 'package:market_jango/features/buyer/model/buyer_top_model.dart';
import 'package:market_jango/features/buyer/screens/all_categori/screen/all_categori_screen.dart';
import 'package:market_jango/features/buyer/screens/all_categori/screen/category_product_screen.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/screen/buyer_vendor_profile_screen.dart';
import 'package:market_jango/features/buyer/screens/filter/screen/buyer_filtering.dart';
import 'package:market_jango/features/buyer/screens/see_just_for_you_screen.dart';
import 'package:market_jango/features/buyer/widgets/custom_categories.dart';
import 'package:market_jango/features/buyer/widgets/custom_discunt_card.dart';
import 'package:market_jango/features/buyer/widgets/custom_new_items_show.dart';
import 'package:market_jango/features/buyer/widgets/custom_top_card.dart';
import 'package:market_jango/features/buyer/widgets/home_product_title.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/data/global_search_riverpod.dart';


class BuyerHomeScreen extends ConsumerStatefulWidget {
  const BuyerHomeScreen({super.key});
  static const String routeName = '/buyerHomeScreen';
  @override
  ConsumerState<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends ConsumerState<BuyerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final bannerProvider = ref.watch(bannerNotifierProvider);
    final justForYou = ref.watch(
      justForYouProvider(BuyerAPIController.just_for_you),
    );
    final newItems = ref.watch(buyerNewItemsProvider);
    return Scaffold(
      backgroundColor: AllColor.white70,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(bannerNotifierProvider);
            ref.invalidate(topProductProvider);
            ref.invalidate(justForYouProvider(BuyerAPIController.just_for_you));
            ref.invalidate(buyerNewItemsProvider);
            ref.invalidate(categoriesProvider);
            await Future.wait([
              ref.read(bannerNotifierProvider.future),
              ref.read(topProductProvider.future),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  BuyerHomeSearchBar(),
                  bannerProvider.when(
                    data: (data) {
                      if (data == null || data.banners.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return PromoSlider(
                        imageList: data.banners.map((e) => e.image).toList(),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (error, stackTrace) => const SizedBox.shrink(),
                  ),
                  SeeMoreButton(
                    name: ref.t(BKeys.categories),
                    seeMoreAction: () => goToAllCategoriesPage(context),
                  ),
                  CustomCategories(
                    categoriCount: 4,
                    physics: const NeverScrollableScrollPhysics(),
                    showOnlyTopCategories: true,
                    requireProducts: false,
                    onTapCategory: (cat) =>
                        goToCategoriesProductPage(context, cat.id, cat.name),
                  ),
                  // Top Products Section - only show if products exist
                  ref.watch(topProductProvider).when(
                    data: (products) {
                      if (products.isEmpty) return const SizedBox.shrink();
                      return Column(
                        children: [
                          SeeMoreButton(
                            name: ref.t(BKeys.topProducts),
                            seeMoreAction: () {},
                            isSeeMore: false,
                          ),
                          CustomTopProducts(),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  // New Items Section - only show if products exist
                  newItems.when(
                    data: (data) {
                      if (data == null || data.data.data.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        children: [
                          SeeMoreButton(
                            name: ref.t(BKeys.newItems),
                            seeMoreAction: () => goToNewItemsPage(ref, context, data),
                          ),
                          CustomNewItemsShow(),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (err, _) => const SizedBox.shrink(),
                  ),

                  // Just For You Section - only show if products exist
                  justForYou.when(
                    data: (data) {
                      if (data == null || data.data.data.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        children: [
                          SeeMoreButton(
                            name: ref.t(BKeys.justForYou),
                            seeMoreAction: () =>
                                goToJustForYouPage(ref, context, data),
                          ),
                          JustForYouProduct(),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (err, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void goToAllCategoriesPage(BuildContext context) {
    context.push(CategoriesScreen.routeName);
  }

  void goToNewItemsPage(
    WidgetRef ref,
    BuildContext context,
    TopProductsResponse productsResponse,
  ) {
    context.pushNamed(
      SeeJustForYouScreen.routeName,
      extra: {
        'screenName': 'New Items',
        'url': BuyerAPIController.new_items,
      },
    );
  }

  void goToJustForYouPage(
    WidgetRef ref,
    BuildContext context,
    TopProductsResponse productsResponse,
  ) {
    context.pushNamed(
      SeeJustForYouScreen.routeName,
      extra: {
        'screenName': 'Just For You',
        'url': BuyerAPIController.just_for_you,
      },
    );
  }

  void goToCategoriesProductPage(BuildContext context, int id, String name) {
    context.push(CategoryProductScreen.routeName, extra: id);
  }
}

class JustForYouProduct extends ConsumerWidget {
  const JustForYouProduct({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncJustForYou = ref.watch(
      justForYouProvider(BuyerAPIController.just_for_you),
    );

    return asyncJustForYou.when(
      loading: () => const Center(child: Text('Loading...')),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Failed to load: $e'),
      ),
      data: (products) {
        final topProducts = products!.data.data;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.w,
            childAspectRatio: 0.70,
          ),
          itemCount: topProducts.length,
          itemBuilder: (context, index) {
            final p = topProducts[index];
            final price = (p.sellPrice.isNotEmpty
                ? p.sellPrice
                : p.regularPrice);

            return GestureDetector(
              onTap: () {
                final detail = p;

                context.push(
                  BuyerVendorProfileScreen.routeName,
                  extra: {
                    'vendorId': detail.vendor.id,
                    'userId': detail.vendor.userId,
                  },
                );
              },
              child: CustomNewProduct(
                width: 162,
                height: 170,
                productName: p.name,
                productPrices: price,
                image: p.image,
              ),
            );
          },
        );
      },
    );
  }
}

@override
Widget build(BuildContext context) {
  return SizedBox(
    height: 220.h,
    child: ListView.builder(
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: 6,
      // Example item count
      itemBuilder: (context, index) {
        return CustomNewProduct(
          width: 130.w,
          height: 138.h,
          productPrices: "New T-shirt, sun-glass",
          productName: "New T-shirt,",
        );
      },
    ),
  );
}

// void goToDetailsScreen(BuildContext context) {
//   context.push(ProductDetails.routeName);
// }

class DiscountProduct extends StatelessWidget {
  const DiscountProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4.h,
        crossAxisSpacing: 4.w,
        childAspectRatio: 0.65.h,
      ),
      itemCount: 6,
      // Example item count
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
              // margin: EdgeInsets.symmetric(horizontal: 5.w,vertical: 5.h),
              decoration: BoxDecoration(
                color: AllColor.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  // Image
                  Image.asset(
                    'assets/images/clothing3.jpg', // আপনার ইমেজ পাথ দিন এখানে
                    fit: BoxFit.cover,
                  ),
                  // Discount Tag
                  CustomDiscountCord(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              child: Text(
                "T shirt",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontSize: 16.sp),
              ),
            ),
          ],
        );
      },
    );
  }
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 30.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HomePorductTitel(name: 'Flash Sale'),
            Spacer(),
            Icon(Icons.timer_outlined, size: 28.sp),
            SizedBox(width: 12.w),
            _timeBox("00"),
            SizedBox(width: 4.w),
            _timeBox("36"),
            SizedBox(width: 4.w),
            _timeBox("58"),
          ],
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _timeBox(String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.black12.withOpacity(0.05.sp),
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class PromoSlider extends ConsumerWidget {
  final List<String> imageList;
  PromoSlider({super.key, required this.imageList});
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(sliderIndexProvider);
    final currentIndexNotifier = ref.read(sliderIndexProvider.notifier);

    return Column(
      children: [
        SizedBox(height: 30.h),

        CarouselSlider.builder(
          carouselController: _controller,
          itemCount: imageList.length,
          itemBuilder: (context, index, realIndex) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: FirstTimeShimmerImage(
                imageUrl: imageList[index],
                fit: BoxFit.cover,
                width: 1.sw,
              ),
            );
          },
          options: CarouselOptions(
            height: 158.h,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 3),
            enlargeCenterPage: false,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              currentIndexNotifier.state = index;
            },
            scrollDirection: Axis.horizontal,
            reverse: false,
            enableInfiniteScroll: true,
          ),
        ),

        SizedBox(height: 12),

        // Dot Indicator (Reactive with Riverpod)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imageList.asMap().entries.map((entry) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: currentIndex == entry.key ? 30.0.w : 8.0.w,
              height: 8.0.h,
              margin: EdgeInsets.symmetric(horizontal: 8.0.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: currentIndex == entry.key
                    ? Colors.orange
                    : Colors.orange.withOpacity(0.1.sp),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class BuyerHomeSearchBar extends ConsumerWidget {
  const BuyerHomeSearchBar({super.key});
  @override
  Widget build(BuildContext context, ref) {
    return Column(
      children: [
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: GlobalSearchBar<GlobalSearchResponse, GlobalSearchProduct>(
                provider: searchProvider,
                itemsSelector: (res) => res.products,
                itemBuilder: (context, p) => ProductSuggestionTile(p: p),
                onItemSelected: (p) {
                  context.push(
                    BuyerVendorProfileScreen.routeName,
                    extra: {
                      'vendorId': p.vendor?.id ?? 0,
                      'userId': p.vendor?.userId ?? 0,
                    },
                  );
                },
                hintText: ref.t(BKeys.searchProduct),
                debounce: const Duration(seconds: 1),
                minChars: 1,
                showResults: true,
                resultsMaxHeight: 380,
                autofocus: false,
              ),
            ),
            SizedBox(width: 8.w),
            // Menu Icon
            Container(
              height: 35.h,
              width: 35.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4.sp,
                    offset: Offset(0, 0.5.sp),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.filter_list, size: 20.sp),
                onPressed: () {
                  openingFilter(context);
                },
              ),
            ),

            SizedBox(width: 8.w),
            // Notification Icon
            GlobalNotificationIcon(),
          ],
        ),
      ],
    );
  }

  void openingFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LocationFilteringTab(),
    );
  }
}
