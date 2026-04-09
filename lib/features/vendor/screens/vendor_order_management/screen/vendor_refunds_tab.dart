import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/constants/color_control/all_color.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/provider/vendor_orders_provider.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/screen/vendor_refund_detail_screen.dart';

/// Refunds list + summary — `GET /vendor/refunds` (doc §5.2).
class VendorRefundsTab extends ConsumerWidget {
  const VendorRefundsTab({super.key});

  static const _statusChoices = <String?>[
    null,
    'pending',
    'approved',
    'rejected',
  ];

  String _statusLabel(String? s) {
    if (s == null) return 'All statuses';
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ref.watch(vendorRefundListParamsProvider);
    final async = ref.watch(vendorRefundsPayloadProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(vendorRefundsPayloadProvider);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        children: [
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(e.toString()),
            data: (payload) {
              final s = payload.summary;
              if (s == null) return const SizedBox.shrink();
              return _SummaryCard(summary: s);
            },
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final d = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(now.year + 1),
                      initialDate: now,
                    );
                    if (d == null) return;
                    final f =
                        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                    ref.read(vendorRefundListParamsProvider.notifier).state =
                        ref.read(vendorRefundListParamsProvider).copyWith(
                              page: 1,
                              fromDate: f,
                            );
                  },
                  child: Text(params.fromDate ?? 'From date'),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final d = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(now.year + 1),
                      initialDate: now,
                    );
                    if (d == null) return;
                    final f =
                        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                    ref.read(vendorRefundListParamsProvider.notifier).state =
                        ref.read(vendorRefundListParamsProvider).copyWith(
                              page: 1,
                              toDate: f,
                            );
                  },
                  child: Text(params.toDate ?? 'To date'),
                ),
              ),
              IconButton(
                onPressed: () {
                  ref.read(vendorRefundListParamsProvider.notifier).state =
                      const VendorRefundListParams(page: 1);
                },
                icon: const Icon(Icons.clear),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          DropdownButtonFormField<String?>(
            value: params.status,
            decoration: InputDecoration(
              labelText: 'Status',
              filled: true,
              fillColor: AllColor.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            items: _statusChoices
                .map(
                  (v) => DropdownMenuItem<String?>(
                    value: v,
                    child: Text(_statusLabel(v)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              ref.read(vendorRefundListParamsProvider.notifier).state =
                  ref.read(vendorRefundListParamsProvider).copyWith(
                        page: 1,
                        status: v,
                        clearStatus: v == null,
                      );
            },
          ),
          SizedBox(height: 16.h),
          async.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (payload) {
              final page = payload.refunds;
              if (page.items.isEmpty) {
                return Text(
                  'No refunds in this range.',
                  style: TextStyle(color: AllColor.grey500, fontSize: 14.sp),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...page.items.map(
                    (r) => _RefundTile(
                      item: r,
                      onTap: () => context.push(
                        VendorRefundDetailScreen.routePath(r.id),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: params.page <= 1
                            ? null
                            : () {
                                ref
                                        .read(
                                          vendorRefundListParamsProvider
                                              .notifier,
                                        )
                                        .state =
                                    params.copyWith(page: params.page - 1);
                              },
                        child: const Text('Prev'),
                      ),
                      Text('${params.page} / ${page.lastPage}'),
                      TextButton(
                        onPressed: params.page >= page.lastPage
                            ? null
                            : () {
                                ref
                                        .read(
                                          vendorRefundListParamsProvider
                                              .notifier,
                                        )
                                        .state =
                                    params.copyWith(page: params.page + 1);
                              },
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final VendorRefundSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AllColor.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: AllColor.grey200),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 10.h),
            _row('Pending', summary.pending),
            _row('Approved', summary.approved),
            _row('Rejected', summary.rejected),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, VendorRefundBucket b) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: AllColor.grey500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${b.count} · ${b.total}',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RefundTile extends StatelessWidget {
  const _RefundTile({required this.item, required this.onTap});

  final VendorRefundListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: BorderSide(color: AllColor.grey200),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          item.productName.isEmpty ? 'Refund #${item.id}' : item.productName,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
        ),
        subtitle: Text(
          '${item.status} · ${item.amount}\n'
          '${item.orderNumber.isNotEmpty ? 'Order ${item.orderNumber}\n' : ''}'
          '${item.customerName.isNotEmpty ? item.customerName : ''}',
          style: TextStyle(fontSize: 12.sp, height: 1.35),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
