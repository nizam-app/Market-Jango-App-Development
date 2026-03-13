import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/widget/global_pagination.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:market_jango/features/vendor/screens/vendor_delivery_setting/data/vendor_route_points_data.dart';
import 'package:market_jango/features/vendor/screens/vendor_delivery_setting/model/vendor_route_point_model.dart';
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
          'Delivery setting',
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
                      SizedBox(width: 12.w),
                      IconButton(
                        onPressed: items.isEmpty
                            ? null
                            : () => _showAddRouteSheet(context, ref, items),
                        icon: Icon(
                          Icons.add_circle_outline,
                          size: 28.r,
                          color: AllColor.orange,
                        ),
                        tooltip: 'Add route',
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
                                  DataCell(
                                    _ActionCell(
                                      item: item,
                                      notifier: notifier,
                                      onSuccess: () {
                                        GlobalSnackbar.show(
                                          context,
                                          title: 'Success',
                                          message: item.isSelected
                                              ? 'Route removed'
                                              : 'Route added',
                                        );
                                      },
                                      onError: (msg) {
                                        GlobalSnackbar.show(
                                          context,
                                          title: 'Error',
                                          message: msg,
                                          type: CustomSnackType.error,
                                        );
                                      },
                                    ),
                                  ),
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

  void _showAddRouteSheet(
    BuildContext context,
    WidgetRef ref,
    List<RoutePointItem> items,
  ) {
    final notSelected = items.where((e) => !e.isSelected).toList();
    if (notSelected.isEmpty) {
      GlobalSnackbar.show(
        context,
        title: 'Info',
        message: 'All routes are already added.',
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Add route',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AllColor.black,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: notSelected.length,
                itemBuilder: (ctx, i) {
                  final item = notSelected[i];
                  return ListTile(
                    title: Text(item.displayRouteName),
                    subtitle: Text(
                      '${item.zoneName} • ${item.price.toStringAsFixed(2)} ${item.currency}',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      try {
                        await ref.read(routePointsProvider.notifier).optIn(item.id);
                        if (context.mounted) {
                          GlobalSnackbar.show(
                            context,
                            title: 'Success',
                            message: 'Route added',
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          GlobalSnackbar.show(
                            context,
                            title: 'Error',
                            message: e.toString(),
                            type: CustomSnackType.error,
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCell extends StatelessWidget {
  const _ActionCell({
    required this.item,
    required this.notifier,
    required this.onSuccess,
    required this.onError,
  });

  final RoutePointItem item;
  final RoutePointsNotifier notifier;
  final VoidCallback onSuccess;
  final void Function(String) onError;

  @override
  Widget build(BuildContext context) {
    if (item.isSelected) {
      return TextButton(
        onPressed: () async {
          try {
            await notifier.optOut(item.id);
            onSuccess();
          } catch (e) {
            onError(e.toString());
          }
        },
        child: Text(
          'Remove',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return TextButton(
      onPressed: () async {
        try {
          await notifier.optIn(item.id);
          onSuccess();
        } catch (e) {
          onError(e.toString());
        }
      },
      child: Text(
        'Add',
        style: TextStyle(
          fontSize: 12.sp,
          color: AllColor.orange,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
