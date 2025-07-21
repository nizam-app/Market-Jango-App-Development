import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/widget/see_more_button.dart';
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
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 20.w,),
          child: Column(
            children: [

              BuyerHomeSearchBar(),
              PromoSlider(),
              SeeMoreButton(name:"Categories",seeMoreAction: (){goToCategoriesPage();},),
              

            ],
          ),
        ),
      ),
    );
  }
  void goToCategoriesPage() {

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
