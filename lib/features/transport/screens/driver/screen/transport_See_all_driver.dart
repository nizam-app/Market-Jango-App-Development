// transport_See_all_driver.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:market_jango/core/utils/image_controller.dart';
import 'package:market_jango/core/widget/custom_auth_button.dart';
import 'package:market_jango/core/widget/global_pagination.dart';

import 'driver_details_screen.dart';
import '../data/transport_driver_data.dart';
import 'model/transport_driver_model.dart';

class TransportDriver extends ConsumerWidget {
  const TransportDriver({super.key});
  static const String routeName = '/transport_driver';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(approvedDriversProvider);
    final notifier = ref.read(approvedDriversProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F8),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomBackButton(),
                  Text(
                    "Driver",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
              SizedBox(height: 20.h),

              Expanded(
                child: state.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Failed to load drivers',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: () =>
                              ref.invalidate(approvedDriversProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  data: (resp) {
                    final page = resp?.data;
                    final items = page?.data ?? <Driver>[];

                    // If nothing to show, avoid building pagination math in your widget tree
                    if (items.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40.h),
                          const Text('No drivers found'),
                          SizedBox(height: 12.h),
                        ],
                      );
                    }

                    final totalPages = (page?.lastPage ?? 1);
                    final safeCurrent = notifier.currentPage.clamp(
                      1,
                      totalPages == 0 ? 1 : totalPages,
                    );

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          ...items.map(
                            (d) => _DriverCard(
                              driver: d,
                              carImage: (d.images is List)
                                  ? (d.images as List)
                                        .whereType<String>()
                                        .toList()
                                  : const <String>[],
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Only show pagination if we have >1 page
                          if (totalPages > 1)
                            GlobalPagination(
                              currentPage: safeCurrent,
                              totalPages: totalPages == 0 ? 1 : totalPages,
                              onPageChanged: (int p) => notifier.changePage(p),
                            ),

                          SizedBox(height: 12.h),
                        ],
                      ),
                    );
                  },
                ),
              ),
              state.when(
                data: (data) {
                  final page = data?.data;

                  return GlobalPagination(
                    currentPage: page!.currentPage ?? 1,
                    totalPages: page.lastPage,
                    onPageChanged: (int p) => notifier.changePage(p),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Failed to load drivers',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(height: 8.h),
                      ElevatedButton(
                        onPressed: () =>
                            ref.invalidate(approvedDriversProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Driver Card (data-bound)
class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.driver, required this.carImage});

  final Driver driver;
  final List<String> carImage;

  @override
  Widget build(BuildContext context) {
    final user = driver.user;

    // Safe fallbacks
    final avatarUrl = (user.image?.isNotEmpty == true)
        ? user.image!
        : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTxfenNzfIFlwE5dd7aduVOvGR05Qqz7EDi-Q&s";

    final carUrl = carImage.isNotEmpty
        ? carImage.first
        : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTxfenNzfIFlwE5dd7aduVOvGR05Qqz7EDi-Q&s";

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Driver Info
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Logger().e(driver.user.id);

                    context.push(
                      DriverDetailsScreen.routeName,
                      extra: driver.userId,
                    );
                  },
                  child: CircleAvatar(
                    radius: 20.r,
                    backgroundImage: NetworkImage(avatarUrl),
                  ),
                ),
                SizedBox(width: 10.w),
                InkWell(
                  onTap: () => context.push(
                    DriverDetailsScreen.routeName,
                    extra: driver.userId,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                      Text(
                        "${user.phone}",
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "\$${driver.price}/km",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            /// Car Image (safe)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: FirstTimeShimmerImage(
                  imageUrl: carUrl,
                  height: 120.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10.h),

            /// Title + Button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${driver.carName} • ${driver.location}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => context.push(
                      DriverDetailsScreen.routeName,
                      extra: driver.userId,
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Text(
                        "See Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
