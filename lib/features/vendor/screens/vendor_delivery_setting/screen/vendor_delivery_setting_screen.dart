import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/core/widget/global_pagination.dart';
import 'package:market_jango/features/vendor/screens/vendor_delivery_setting/data/vendor_route_points_data.dart';
import 'package:market_jango/features/vendor/widgets/custom_back_button.dart';

class VendorDeliverySettingScreen extends ConsumerStatefulWidget {
  const VendorDeliverySettingScreen({super.key});

  static const String routeName = '/vendor_delivery_setting';

  @override
  ConsumerState<VendorDeliverySettingScreen> createState() =>
      _VendorDeliverySettingScreenState();
}

class _VendorDeliverySettingScreenState
    extends ConsumerState<VendorDeliverySettingScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final query = _searchController.text.trim();
      ref.read(routePointsProvider.notifier).setSearch(query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(routePointsProvider);
    final notifier = ref.read(routePointsProvider.notifier);

    return Scaffold(
      backgroundColor: AllColor.white,
      appBar: AppBar(
        backgroundColor: AllColor.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: const CustomBackButton(),
        ),
        title: Text(
          ref.t(BKeys.delivery_setting, fallback: 'Delivery setting'),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AllColor.black,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14.sp, color: AllColor.grey),
                  ),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: () => notifier.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (response) {
            if (response == null) {
              return const Center(child: Text('No data'));
            }
            final items = response.items;
            final pagination = response.pagination;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Zone row + Add button
                  Row(
                    children: [
                      Text(
                        'Zone',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AllColor.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // Search by name
                  TextField(
                    controller: _searchController,
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: 'Search by name',
                      hintStyle: TextStyle(fontSize: 14.sp, color: AllColor.grey),
                      prefixIcon: Icon(Icons.search, size: 22.r, color: AllColor.grey),
                      filled: true,
                      fillColor: AllColor.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: AllColor.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: AllColor.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: AllColor.orange, width: 1.5),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                    ),
                    onSubmitted: (_) {
                      if (mounted) {
                        notifier.setSearch(_searchController.text.trim());
                      }
                    },
                  ),
                  SizedBox(height: 16.h),
                  // Table - horizontal scroll with fixed column widths so all columns visible
                  if (items.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.h),
                      child: Center(
                        child: Text(
                          'No route points found.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AllColor.grey,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Use Add / Remove in Action column to manage routes.',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AllColor.grey,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              Colors.grey.shade100,
                            ),
                            columnSpacing: 16.w,
                            horizontalMargin: 12.w,
                            columns: [
                              DataColumn(
                                label: Text('Route Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)),
                              ),
                              DataColumn(
                                label: Text('Flat', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)),
                              ),
                              DataColumn(
                                label: Text('Distance', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)),
                              ),
                              DataColumn(
                                label: Text('Weight', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)),
                              ),
                              DataColumn(
                                label: Text('Cube', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)),
                              ),
                              DataColumn(
                                label: Text('Action', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)),
                              ),
                            ],
                            rows: items.map((item) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: 140.w, maxWidth: 200.w),
                                      child: Text(
                                        item.displayRouteName,
                                        style: TextStyle(fontSize: 12.sp),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(
                                    item.flatEnabled
                                        ? item.price.toStringAsFixed(2)
                                        : '—',
                                    style: TextStyle(fontSize: 12.sp),
                                  )),
                                  DataCell(Text(
                                    item.distanceBaseRange ?? '—',
                                    style: TextStyle(fontSize: 12.sp),
                                  )),
                                  DataCell(Text(
                                    item.weightBaseRange ?? '—',
                                    style: TextStyle(fontSize: 12.sp),
                                  )),
                                  DataCell(Text(
                                    item.cubicBaseRange ?? '—',
                                    style: TextStyle(fontSize: 12.sp),
                                  )),
                                  const DataCell(Text('—')),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 16.h),
                  if (pagination.lastPage > 1)
                    GlobalPagination(
                      currentPage: pagination.currentPage,
                      totalPages: pagination.lastPage,
                      onPageChanged: (page) => notifier.changePage(page),
                    ),
                  SizedBox(height: 24.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

}
