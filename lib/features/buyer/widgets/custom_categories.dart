import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart' show Logger;
import 'package:market_jango/%20business_logic/models/categories_model.dart';
import 'package:market_jango/features/buyer/data/categories_data_read.dart';
import 'package:market_jango/features/buyer/screens/location_filter_page.dart';
import 'package:riverpod/riverpod.dart';
class CustomCategories extends ConsumerWidget{
  CustomCategories({
    super.key,this.scrollableCheck,required this.categoriCount
  });
  final scrollableCheck;
  final int categoriCount;


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
          itemCount: categoriCount,
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