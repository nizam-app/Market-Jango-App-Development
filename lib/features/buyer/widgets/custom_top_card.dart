import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/buyer/data/buyer_top_data.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/screen/buyer_vendor_profile_screen.dart';
import 'package:market_jango/features/buyer/screens/product/model/buyer_product_details_model.dart';
import 'package:market_jango/features/buyer/screens/product/product_details.dart';

class CustomTopProducts extends ConsumerWidget {
  const CustomTopProducts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(topProductProvider);
    return SizedBox(
      height: 87.h,
      width: double.infinity,
      child: asyncData.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(child: Text('No top products'));
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      context.push(
                        BuyerVendorProfileScreen.routeName,
                        extra: p.vendor.userId,
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 4.h, left: 6.w,right: 6.w),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 32.r,
                          backgroundColor: AllColor.white,
                          child: CircleAvatar(
                            radius: 28.r,
                            backgroundImage: (p.image.isNotEmpty) ? NetworkImage(p.image) : null,
                            child: (p.image.isEmpty) ? Icon(Icons.image_not_supported, size: 18.sp) : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(p.name, style: TextStyle(fontSize: 12.sp)),
                ],
              );
            },
          );
        },
        error: (error, _) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}