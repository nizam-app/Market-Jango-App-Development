import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/buyer/data/buyer_top_data.dart';
import 'package:market_jango/features/buyer/screens/product/model/buyer_product_details_model.dart';
import 'package:market_jango/features/buyer/screens/product/product_details.dart';
// <-- যোগ করুন

class CustomTopProducts extends ConsumerWidget {
  const CustomTopProducts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(topProductProvider);

    return SizedBox(
      height: 70.h,
      width: double.infinity,
      child: asyncData.when(
        data: (products) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return InkWell(
                onTap: () {
                  context.push(ProductDetails.routeName, extra: p.toDetail());
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: CircleAvatar(
                    radius: 32.r,
                    backgroundColor: AllColor.white,
                    child: CircleAvatar(
                      radius: 28.r,
                      backgroundImage: NetworkImage(p.image),
                    ),
                  ),
                ),
              );
            },
          );
        },
        error: (error, stack) => Center(
          child: Text(
            ': $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}