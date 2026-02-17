import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/features/buyer/data/buyer_top_data.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/screen/buyer_vendor_profile_screen.dart';

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
            //'No top products'
            return Center(child: Text(ref.t(BKeys.no_top_products)));
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
                        extra: {
                          'vendorId': p.vendor.id,
                          'userId': p.vendor.userId,
                        },
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 4.h, left: 6.w, right: 6.w),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(
                                0,
                                3,
                              ), // changes position of shadow
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 32.r,
                          backgroundColor: AllColor.white,
                          child: ClipOval(
                            child: (p.image.isNotEmpty)
                                ? FirstTimeShimmerImage(
                                    imageUrl: p.image,
                                    width: 56.r,
                                    height: 56.r,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 56.r,
                                    height: 56.r,
                                    color: AllColor.grey200,
                                    child: Icon(Icons.image_not_supported, size: 18.sp),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    p.name.length > 10 ? '${p.name.substring(0, 10)}...' : p.name,
                    style: TextStyle(fontSize: 12.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
        loading: () => const Center(child: Text('Loading...')),
      ),
    );
  }
}
