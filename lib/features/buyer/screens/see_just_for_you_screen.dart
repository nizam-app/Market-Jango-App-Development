import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/widget/TupperTextAndBackButton.dart';
import 'package:market_jango/core/widget/global_pagination.dart';
import 'package:market_jango/features/buyer/data/buyer_just_for_you_data.dart';
import 'package:market_jango/features/buyer/model/buyer_top_model.dart';
import 'package:market_jango/features/buyer/screens/product/model/buyer_product_details_model.dart';
import 'package:market_jango/features/buyer/screens/product/product_details.dart';
import 'package:market_jango/features/buyer/widgets/custom_see_all_product.dart';
class SeeJustForYouScreen extends ConsumerWidget {
  const SeeJustForYouScreen({
    super.key,
    required this.screenName,
    required this.url,
  });
  final String screenName;
  final String url;
  static const String routeName = '/seeJustForYouScreen';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prod = ref.watch(justForYouProvider("${url}"));
    final notifier = ref.read(justForYouProvider("${url}").notifier);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: prod.when(
            data: (products) {
                               final pagination = products!.data;
              return Column(
                children: [
                  Tuppertextandbackbutton(screenName: "$screenName"),
                  CustomSeeAllProduct(
                    product: products?.data.data.map((e) => e.product).toList(),
                  ),
                  GlobalPagination(
                    currentPage: pagination.currentPage,
                    totalPages: pagination.lastPage,
                    onPageChanged: (page) {
                      notifier.changePage(page);
                    },
                  ),
                ],
              );
            }   ,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error loading Just For You: $err'),
          ),
        ),
      ),
    );
  }
}