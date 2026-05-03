import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/core/localization/Keys/buyer_kay.dart';
import 'package:market_jango/core/localization/tr.dart';
import 'package:market_jango/features/vendor/inventory/data/vendor_inventory_api.dart';
import 'package:market_jango/features/vendor/inventory/screen/vendor_inventory_product_screen.dart';

class VendorInventoryScreen extends ConsumerWidget {
  const VendorInventoryScreen({super.key});

  static const String routeName = '/vendor/inventory';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(vendorInventoryProvider);
    final search = ref.watch(vendorInventorySearchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(ref.t(BKeys.inventory, fallback: 'Inventory')),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search products',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              controller: TextEditingController(text: search)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: search.length),
                ),
              onChanged: (v) =>
                  ref.read(vendorInventorySearchProvider.notifier).state = v,
              onSubmitted: (_) => ref.invalidate(vendorInventoryProvider),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: asyncItems.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(child: Text('No inventory found.'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(vendorInventoryProvider),
                    child: ListView.separated(
                      padding: EdgeInsets.only(bottom: 16.h),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, i) {
                        final p = items[i];
                        final latest = p.inventoryLogs.isNotEmpty
                            ? p.inventoryLogs.first
                            : null;
                        final delta = latest?.quantityChange;
                        final deltaIsPlus = (delta ?? 0) >= 0;
                        final deltaColor =
                            deltaIsPlus ? Colors.green : Colors.red;

                        return InkWell(
                          onTap: () => context.push(
                            VendorInventoryProductScreen.routeName,
                            extra: p.id,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          child: Container(
                            padding: EdgeInsets.all(14.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        p.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15.sp,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AllColor.orange.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        'Stock: ${p.stock}',
                                        style: TextStyle(
                                          color: AllColor.orange,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (latest != null) ...[
                                  SizedBox(height: 10.h),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 6.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: deltaColor.withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          '${deltaIsPlus ? '+' : ''}${delta ?? 0}',
                                          style: TextStyle(
                                            color: deltaColor,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          '${latest.changeType} • ${latest.actorName}',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey.shade600,
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  SizedBox(height: 10.h),
                                  Row(
                                    children: [
                                      Text(
                                        'No recent events',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.chevron_right,
                                        color: Colors.grey.shade600,
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

