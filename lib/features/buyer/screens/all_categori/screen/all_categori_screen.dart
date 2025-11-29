import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/localization/translation_kay.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
// যদি আপনার GlobalPagination উইজেট থাকে:
import 'package:market_jango/core/widget/global_pagination.dart';
import 'package:market_jango/features/buyer/data/buyer_categori_data.dart';
import 'package:market_jango/features/buyer/widgets/custom_categories.dart';

import 'category_product_screen.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  static const String routeName = '/categories_screen';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCats = ref.watch(categoriesProvider);
    final notifier = ref.read(categoriesProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              // "All Categories"
              Tuppertextandbackbutton(screenName: ref.t(TKeys.all_categories)),
              SizedBox(height: 12.h),

              // গ্রিড + Pagination
              Expanded(
                child: asyncCats.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (resp) {
                    if (resp == null) return const SizedBox.shrink();
                    final page = resp.data;

                    return Column(
                      children: [
                        // সব দেখাতে itemCount = page.data.length
                        Expanded(
                          child: CustomCategories(
                            categoriCount: page.data.length,
                            physics: const AlwaysScrollableScrollPhysics(),
                            onTapCategory: (cat) => goToCategoriesProductPage(
                              context,
                              cat.id,
                              cat.name,
                              cat.vendor.id,
                            ),
                          ),
                        ),

                        SizedBox(height: 10.h),

                        GlobalPagination(
                          currentPage: page.currentPage,
                          totalPages: page.lastPage,
                          onPageChanged: (p) => notifier.changePage(p),
                        ),

                        SizedBox(height: 10.h),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void goToCategoriesProductPage(
    BuildContext context,
    int categoryId,
    String title,
    int vendorId,
  ) {
    context.pushNamed(CategoryProductScreen.routeName, extra: vendorId);
  }
}
