import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/features/buyer/screens/filter/data/filter_product_search_data.dart';
import 'package:market_jango/features/buyer/screens/filter/model/filter_search_product_model.dart';
import 'package:market_jango/features/buyer/screens/product/product_details.dart';
import 'package:market_jango/core/widget/custom_new_product.dart';

class FilterScreen extends ConsumerWidget {
  const FilterScreen({super.key, this.filterParams});

  static final routeName = "/filterScreen";
  final Map<String, dynamic>? filterParams;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = _paramsFromMap(filterParams);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Tuppertextandbackbutton(screenName: "Filter Products"),
            if (params == null || !params.isValid)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list_rounded,
                          size: 56.sp,
                          color: AllColor.grey300,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Select location and category from the filter, then tap Apply to see products.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AllColor.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: _ProductGrid(params: params),
              ),
          ],
        ),
      ),
    );
  }

  FilterSearchParams? _paramsFromMap(Map<String, dynamic>? m) {
    if (m == null) return null;
    final country = m['visibility_country']?.toString().trim();
    final categoryId = m['category_id'];
    if (country == null || country.isEmpty) return null;
    final cid = categoryId is int
        ? categoryId
        : int.tryParse((categoryId?.toString() ?? ''));
    if (cid == null || cid <= 0) return null;
    final state = m['visibility_state']?.toString().trim();
    return FilterSearchParams(
      visibilityCountry: country,
      categoryId: cid,
      visibilityState: (state != null && state.isNotEmpty) ? state : null,
    );
  }
}

class _ProductGrid extends ConsumerWidget {
  const _ProductGrid({required this.params});

  final FilterSearchParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(filterProductSearchProvider(params));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: AllColor.grey500),
              SizedBox(height: 16.h),
              Text(
                e.toString().replaceFirst('Exception: ', ''),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: AllColor.grey500),
              ),
            ],
          ),
        ),
      ),
      data: (products) {
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_rounded, size: 56.sp, color: AllColor.grey300),
                SizedBox(height: 16.h),
                Text(
                  'No products found',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AllColor.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Try a different location or category.',
                  style: TextStyle(fontSize: 13.sp, color: AllColor.grey500),
                ),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.58,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return _ProductTile(product: p);
            },
          ),
        );
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});

  final FilterSearchProduct product;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.image != null && product.image!.trim().isNotEmpty
        ? product.image!
        : 'https://t4.ftcdn.net/jpg/05/98/45/79/360_F_598457961_hojY3MEjPaYBgdUkfaWO6mPNuHce6WFv.jpg';

    return GestureDetector(
      onTap: () => context.push(ProductDetails.routeName, extra: product.id),
      child: CustomNewProduct(
        width: 165,
        height: 220,
        productName: product.name,
        productPrices: product.displayPrice,
        image: imageUrl,
        imageHeight: 140,
      ),
    );
  }
}
