import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/buyer/screens/buyer_vendor_profile/screen/buyer_vendor_profile_screen.dart';
import 'package:market_jango/features/buyer/screens/filter/data/visibility_vendors_data.dart';

class AvailableVendorsScreen extends ConsumerWidget {
  const AvailableVendorsScreen({super.key, required this.params});

  static const String routeName = '/availableVendors';

  final VisibilityVendorsParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(visibilityVendorsProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available vendors'),
        centerTitle: true,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Text(
              e.toString().replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: TextStyle(color: AllColor.grey500),
            ),
          ),
        ),
        data: (vendors) {
          if (vendors.isEmpty) {
            return Center(
              child: Text(
                'No vendors found',
                style: TextStyle(fontSize: 14.sp, color: AllColor.grey500),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: vendors.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final v = vendors[index];
              return InkWell(
                onTap: () {
                  context.push(
                    BuyerVendorProfileScreen.routeName,
                    extra: {'vendorId': v.vendorId, 'userId': v.userId},
                  );
                },
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AllColor.grey200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22.r,
                        backgroundColor: AllColor.grey200,
                        backgroundImage: (v.image != null &&
                                (v.image!.startsWith('http://') ||
                                    v.image!.startsWith('https://')))
                            ? NetworkImage(v.image!)
                            : null,
                        child: (v.image == null ||
                                !(v.image!.startsWith('http://') ||
                                    v.image!.startsWith('https://')))
                            ? Icon(Icons.store, color: AllColor.grey500)
                            : null,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v.name,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if ((v.country ?? '').trim().isNotEmpty) ...[
                              SizedBox(height: 2.h),
                              Text(
                                v.country!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AllColor.grey500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AllColor.grey500),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

