import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/global_pagination.dart';
import 'package:market_jango/features/buyer/data/buyer_just_for_you_data.dart';
import 'package:market_jango/features/buyer/model/buyer_top_model.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/data/buyer_vendor_categori_data.dart';
import 'package:market_jango/features/buyer/screens/product/model/buyer_product_details_model.dart';
import 'package:market_jango/features/buyer/screens/product/product_details.dart';
import 'package:market_jango/features/buyer/widgets/custom_see_all_product.dart';
class BuyerVendorCetagoryScreen extends ConsumerWidget {
  const BuyerVendorCetagoryScreen({
    super.key,
    required this.screenName,
    required this.vendorId,
  });

  final String screenName;
  final int vendorId;

  static const String routeName = '/buyerVendorCetagoryScreen';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(vendorCategoryProductsProvider(vendorId).notifier);
    final async = ref.watch(vendorCategoryProductsProvider(vendorId));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              Tuppertextandbackbutton(screenName: screenName), // ← API name
              SizedBox(height: 12.h),
              Expanded(
                child: async.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text(e.toString())),
                  data: (res) {
                    final cats = res?.data.categories.data ?? [];
                    final match = cats.where(
                          (c) => c.name.toLowerCase() == screenName.toLowerCase(),
                    );
                    final products = (match.isNotEmpty ? match.first.products : [])
                        .toList();
                    Logger().e(products);
                    return CustomSeeAllProduct(
                      product: products, 
                    );
                  },
                ),
              ),
              GlobalPagination(
                currentPage: notifier.currentPage,
                totalPages: notifier.lastPage,
                onPageChanged: notifier.changePage,
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}