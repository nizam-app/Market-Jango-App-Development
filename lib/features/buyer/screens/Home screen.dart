import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:market_jango/%20business_logic/models/categories_model.dart';
import 'package:market_jango/core/widget/see_more_button.dart';
import 'package:market_jango/features/buyer/data/categories_data_read.dart';
import 'package:market_jango/features/buyer/logic/slider_manage.dart';
class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});
  static const String routeName = '/buyerHomeScreen';

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 20.w,),
            child: Column(
              children: [
          
                BuyerHomeSearchBar(),
                PromoSlider(),
                SeeMoreButton(name:"Categories",seeMoreAction: (){goToCategoriesPage();},),
                Categories_list(),
                SeeMoreButton(name:"Top Products",seeMoreAction: (){goToTopProducts();},),
                TopProducts()
                
          
          
              ],
            ),
          ),
        ),
      ),
    );
  }
  void goToCategoriesPage() {}
  void goToTopProducts( ) {}
}

class TopProducts extends ConsumerWidget {
  const TopProducts({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topProducts = ref.watch(Category.loadCategories);
    return SizedBox(
      height: 50.h,
      width: double.infinity,
      child: ListView.builder(
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: 20, // Example item count
        itemBuilder: (context, index) {
          return CircleAvatar(radius: 25.r,
          child: CircleAvatar(radius: 20,
          backgroundColor: Colors.green,),);
        },
      ),
    );
  }
}

class Categories_list extends ConsumerWidget{
   Categories_list({
    super.key,
  });



   @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(Category.loadCategories);
    return categories.when(
      data: (categories) {
        final imageMap = buildCategoryImageMap(categories);
        final titles = imageMap.keys.toList();
        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 0.8,
          ),
          itemCount: 4,
          // Example item count
          itemBuilder: (context, index) {
           final title = titles[index];
           final images = imageMap[title]!;
            return InkWell(
              onTap: () {
               goToCategoriesPage();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(blurRadius: 5, color: Colors.black12)
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemBuilder: (context, indexImg) {// Default image if not found
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child:
                            Image.asset(
                              images[indexImg],
                              fit: BoxFit.cover,
                            )
                            ,
                          );
                        },
                      ),
                    ),
              
                    Padding(
                      padding: EdgeInsets.all(8.0.r),
                      child: Text(
                        "${title}",
                        style:Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16.sp)),
                    ),
              
                  ],
                ),
              ),
            );
          },
        );
      },loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, stack) => Center(child: Text('Error: $e')),
    );
  }
  void goToCategoriesPage() {
  }
   Map<String, List<String>> buildCategoryImageMap(List<ProductModel> products) {
     final Map<String, List<String>> categoryImageMap = {};

     for (var product in products) {
       final category = product.category;
       final image = product.image;

       if (categoryImageMap.containsKey(category)) {
         categoryImageMap[category]!.add(image);
       } else {
         categoryImageMap[category] = [image];
       }
     }
     Logger().i("Category Image Map: $categoryImageMap");
     return categoryImageMap;
   }


}

class BuyerHomeSearchBar extends StatelessWidget {
  const BuyerHomeSearchBar({
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
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Search for products',
                  prefixIcon: Icon(Icons.search,),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.r),
                    borderSide: BorderSide(color: Colors.grey), // ফোকাসে যেটা দেখাতে চান
                  ),
                ), // থিম ইনহেরিট না করার জন্য
              ),
            ),
            SizedBox(width: 8.w),
            // Menu Icon
            InkWell(
              onTap: () {
               goToNotificationScreen(context);
              },
              child: Container(
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
                  icon: Icon(Icons.menu, size: 20.sp),
                  onPressed: () {},
                ),
              ),
            ),
            SizedBox(width: 8.w),

            // Notification Icon
            InkWell(
              onTap: () {
                openingFilter(context);
              },
              child: Container(
                height: 35.h,
                width: 35.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0,0.5.sp),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.notifications, size: 20.sp),
                  onPressed: () {},
                ),
              ),
            ),

          ],
        ),
      ],
    );
  }
  void goToNotificationScreen(BuildContext context) {}
  void openingFilter(BuildContext context) {}
}

class PromoSlider extends ConsumerWidget {
  final CarouselSliderController _controller = CarouselSliderController();

  final List<String> imageList = [
    'assets/images/promo1.jpg',
    'assets/images/promo2.jpg',
    'assets/images/promo3.jpeg',
  ];

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
              child: Image.asset(
                imageList[index],
                fit: BoxFit.cover,
                width: double.infinity,
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
