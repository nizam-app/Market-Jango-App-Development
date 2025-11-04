import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/%20business_logic/models/categories_model.dart';
import 'package:market_jango/features/buyer/data/categories_data_read.dart';
import 'package:riverpod/riverpod.dart';
class CustomCategories extends ConsumerWidget{
  CustomCategories({
    super.key,this.scrollableCheck,required this.categoriCount, required this.goToCategoriesProductPage
  });
  final scrollableCheck;
  final int categoriCount;
  final VoidCallback goToCategoriesProductPage;



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
              onTap:
                goToCategoriesProductPage,
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

  Map<String, List<String>> buildCategoryImageMap(List<CategoriesModel> products) {
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