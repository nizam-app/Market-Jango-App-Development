import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/%20business_logic/models/categories_model.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/constants/image_control/image_path.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/widget/custom_new_product.dart';
import 'package:market_jango/core/widget/global_search_bar.dart';
import 'package:market_jango/core/widget/global_notification_icon.dart';
import 'package:market_jango/core/widget/see_more_button.dart';
import 'package:market_jango/features/buyer/data/banner_data.dart';
import 'package:market_jango/features/buyer/data/categories_data_read.dart';
import 'package:market_jango/features/buyer/logic/slider_manage.dart';
import 'package:market_jango/features/buyer/screens/product/model/buyer_product_details_model.dart';
import 'package:market_jango/features/buyer/screens/product/product_details.dart';
import 'package:market_jango/features/buyer/screens/see_just_for_you_screen.dart';
import 'package:market_jango/features/buyer/widgets/custom_categories.dart';
import 'package:market_jango/features/buyer/widgets/custom_discunt_card.dart';
import 'package:market_jango/features/buyer/widgets/custom_new_items_show.dart';
import 'package:market_jango/features/buyer/widgets/custom_top_card.dart';
import 'package:market_jango/features/buyer/widgets/home_product_title.dart';
import 'package:market_jango/features/vendor/screens/vendor_home/data/global_search_riverpod.dart';
import 'package:market_jango/core/models/global_search_model.dart';
import 'all_categori/screen/all_categori_screen.dart';
import 'all_categori/screen/category_product_screen.dart';
import 'filter/screen/location_filtering_tab.dart';
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20.w,),
            child: Column(
              children: [
          
                BuyerHomeSearchBar(),
                bannerProvider.when(
                  data: (data) {
                    if(data == null){
                      return const Center(child: Text("No Data"));
                    }
                    final banners = data.banners ?? [];
                    return PromoSlider(imageList: banners.map((e) => e.image).toList(),);
                  } ,
                  loading: () {
                    return const Center(child: Text("Loading..."));
                  },
                  error: (error, stackTrace) {
                    return const Center(child: Text('Error'));
                  },
                ),
                SeeMoreButton(name:"Categories",seeMoreAction: (){goToAllCategoriesPage();},),
                CustomCategories(scrollableCheck: NeverScrollableScrollPhysics(),categoriCount: 4,goToCategoriesProductPage:() {
                  goToCategoriesProductPage(context);
                } ,),
                SeeMoreButton(name:"Top Products",seeMoreAction: (){},isSeeMore: false,),
                CustomTopProducts(),
                // TimerScreen(),
                // DiscountProduct(),
                SeeMoreButton(name:"New Items",seeMoreAction: (){goToNewItemsPage();},),
                CustomNewItemsShow(),
                SeeMoreButton(name:"Just For you",seeMoreAction: (){goToJustForYouPage();},),
                JustForYouProduct()
              ],
            ),
          ),
        ),
      ),
    );
  }
  void goToAllCategoriesPage() {
    context.push(CategoriesScreen.routeName);
  }
  void goToNewItemsPage(){context.pushNamed(
      SeeJustForYouScreen.routeName, pathParameters: {"screenName": "New Items"});}
  void goToJustForYouPage(){context.pushNamed(
      SeeJustForYouScreen.routeName, pathParameters: {"screenName": "Just For You"});}
 void goToCategoriesProductPage(BuildContext context) {
context.push(CategoryProductScreen.routeName);
}
}

class JustForYouProduct extends StatelessWidget {
  const JustForYouProduct({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          // mainAxisSpacing: 0.h,
          crossAxisSpacing: 8.w,
          childAspectRatio: 0.56.h,
        ),
        itemCount: 20,
        // Example item count
        itemBuilder: (context, index) {
      return CustomNewProduct(width: 162.w, height: 175.h, productPricesh: "New T-shirt, sun-glass",productName: "New T-shirt,");
        });
  }
}



  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.h,
      child: ListView.builder(
          shrinkWrap: true,
          physics:AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          // Example item count
          itemBuilder: (context, index) {
            return CustomNewProduct(width: 130.w, height: 138.h,productPricesh: "New T-shirt, sun-glass",productName: "New T-shirt,",);}
      ),
    );
  }






  void goToDetailsScreen(BuildContext context) {
    context.push(ProductDetails.routeName);
  }



class DiscountProduct extends StatelessWidget {
  const DiscountProduct({
    super.key,
  });

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
            padding: EdgeInsets.symmetric(horizontal: 5.w,vertical: 5.h),
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
            padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.h),
            child: Text("T shirt",style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16.sp),),
          )
        ],
      );}
    );
  }
}

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          SizedBox(height: 30.h,),
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
          SizedBox(height: 20.h,)
        ],
      );
  }

  Widget _timeBox(String value) {
    return Container(
      padding:  EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.black12.withOpacity(0.05.sp),
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Text(
        value,
        style:  TextStyle(
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
  PromoSlider({required this.imageList});
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
class BuyerHomeSearchBar extends StatelessWidget {
  const  BuyerHomeSearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20.h,),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: GlobalSearchBar<GlobalSearchResponse, GlobalSearchProduct>(
                provider: searchProvider,
                itemsSelector: (res) => res.products,
                itemBuilder: (context, p) => ProductSuggestionTile(p: p),
                onItemSelected: (p) {
                  context.push(ProductDetails.routeName, extra: p.toDetail());
                },
                hintText: 'Search products...',
                debounce: const Duration(seconds:1),
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
           GlobalNotificationIcon()
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