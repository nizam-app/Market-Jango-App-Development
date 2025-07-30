import 'dart:async';

import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';
import 'package:market_jango/%20business_logic/models/categories_model.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/see_more_button.dart';
import 'package:market_jango/features/buyer/data/categories_data_read.dart';
import 'package:market_jango/features/buyer/logic/slider_manage.dart';
import 'package:market_jango/features/buyer/widgets/home_product_title.dart';

import 'location_filter_page.dart';
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
                SeeMoreButton(name:"Top Products",seeMoreAction: (){},isSeeMore: false,),
                TopProducts(),
                TimerScreen(),
                DiscountProduct(),
                SeeMoreButton(name:"New Items",seeMoreAction: (){goToNewItemsPage();},),
                NewItemsShow(),
                SeeMoreButton(name:"Just For you",seeMoreAction: (){goToJustForYouPage();},),
                GridView.builder(shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10.h,
                      crossAxisSpacing: 8.w,
                      childAspectRatio: 0.7.h,
                    ),
                    itemCount: 4,
                    // Example item count
                    itemBuilder: (context, index) {
                  return CustomNewProduct(width: 162.w, height: 172.h);
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
  void goToCategoriesPage() {}
  void goToNewItemsPage(){}
  void goToJustForYouPage(){}

}

class NewItemsShow extends StatelessWidget {
  const NewItemsShow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190.h,
      child: ListView.builder(
          shrinkWrap: true,
          physics:AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          // Example item count
          itemBuilder: (context, index) {
            return CustomNewProduct(width: 140.w, height: 140.h);}
      ),
    );
  }
}

class CustomNewProduct extends StatelessWidget {
  const CustomNewProduct({
    super.key, required this.width, required this.height
  });
 final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w,vertical: 5.h),
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AllColor.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: [
              // Image
              Image.asset(
                'assets/images/clothing3.jpg', // আপনার ইমেজ পাথ দিন এখানে
                fit: BoxFit.cover,
              ),
              // Discount Tag
    
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w,vertical: 5.h),
          child: Column(
            children: [
              Text("T shirt",style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AllColor.black),),
              Text("\$17,00",style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 18),)
            ],
          ),
        ),
    
      ],
    );
  }
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
          childAspectRatio: 0.72.h,
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
                Positioned(
                  top: 0.h,
                  right: 0.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AllColor.yellow500,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Text(
                      '-20%',
                      style:Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize: 12.sp,color: AllColor.white
                      ),
                      ),
                    ),
                  ),

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

class TopProducts extends ConsumerWidget {
   TopProducts({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allProducts = ref.watch(Category.loadCategories);
    return SizedBox(
      height: 55.h,
      width: double.infinity,
      child:allProducts.when(data: (product) {
        List<ProductModel> topProducts =product.where((eliment) => eliment.topProduct == true).toList();
        return ListView.builder(
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: topProducts.length, // Example item count
        itemBuilder: (context, index) {
          final allTopProduct = topProducts[index];
          return CircleAvatar(radius: 30.r,backgroundColor: AllColor.white,
              child: CircleAvatar(
                radius: 24.r,
                backgroundImage: AssetImage("${allTopProduct.image}"),
                ),
              );
              }
      );}, error: (error, stack) => Text('Something went wrong'),
        loading: () => CircularProgressIndicator(),
    ));
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
            childAspectRatio: 0.75.h,
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
                        gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 4.h,
                          crossAxisSpacing: 4.w,
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
            InkWell(
              onTap: () {
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
  void goToNotificationScreen(BuildContext context) {
  }
  void openingFilter(BuildContext context) {
Logger().e("Don't work'");
showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LocationFilterPage(),
    );

  }
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
